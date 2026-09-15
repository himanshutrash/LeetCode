# Write your MySQL query statement below
WITH RECURSIVE ordered AS (
    SELECT
        student_id,
        subject,
        session_date,
        hours_studied,
        ROW_NUMBER() OVER (PARTITION BY student_id ORDER BY session_date, session_id) AS rn,
        LEAD(session_date) OVER (PARTITION BY student_id ORDER BY session_date, session_id) AS next_date
    FROM study_sessions
),

totals AS (
    SELECT
        student_id,
        COUNT(*) AS total_sessions,
        SUM(hours_studied) AS total_study_hours
    FROM study_sessions
    GROUP BY student_id
),

date_ok AS (
    SELECT student_id
    FROM ordered
    GROUP BY student_id
    HAVING COALESCE(MAX(DATEDIFF(next_date, session_date)), 0) <= 2
),

max_half AS (
    SELECT FLOOR(MAX(total_sessions) / 2) AS m FROM totals
),

periods AS (
    SELECT 3 AS p
    UNION ALL
    SELECT p + 1 FROM periods, max_half WHERE p < max_half.m
),

candidates AS (
    SELECT
        t.student_id,
        pr.p AS period
    FROM totals t
    JOIN periods pr ON pr.p * 2 <= t.total_sessions
),

period_checks AS (
    SELECT
        c.student_id,
        c.period,
        SUM(CASE WHEN o2.subject IS NOT NULL AND o2.subject <> o1.subject THEN 1 ELSE 0 END) AS mismatches
    FROM candidates c
    JOIN ordered o1 ON o1.student_id = c.student_id
    LEFT JOIN ordered o2
        ON o2.student_id = c.student_id
        AND o2.rn = o1.rn + c.period
    GROUP BY c.student_id, c.period
),

distinct_check AS (
    SELECT
        c.student_id,
        c.period,
        COUNT(DISTINCT o.subject) AS distinct_subjects
    FROM candidates c
    JOIN ordered o
        ON o.student_id = c.student_id
        AND o.rn <= c.period
    GROUP BY c.student_id, c.period
),

valid_periods AS (
    SELECT pc.student_id, pc.period
    FROM period_checks pc
    JOIN distinct_check dc
        ON dc.student_id = pc.student_id
        AND dc.period = pc.period
    WHERE pc.mismatches = 0
      AND dc.distinct_subjects = pc.period
),

best_period AS (
    SELECT student_id, MIN(period) AS cycle_length
    FROM valid_periods
    GROUP BY student_id
)

SELECT
    s.student_id,
    s.student_name,
    s.major,
    b.cycle_length,
    t.total_study_hours
FROM students s
JOIN best_period b ON s.student_id = b.student_id
JOIN totals t ON s.student_id = t.student_id
JOIN date_ok d ON s.student_id = d.student_id
ORDER BY 4 DESC, 5 DESC;
