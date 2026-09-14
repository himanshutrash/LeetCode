# Write your MySQL query statement below
WITH employee_hour AS (
SELECT employee_id, DATEDIFF(meeting_date , "1900-01-01") DIV 7 AS w, 
SUM(duration_hours) AS hours FROM meetings GROUP BY employee_id, w
),

employee_heavy AS (
SELECT employee_id, COUNT(*) AS meeting_heavy_weeks from employee_hour
WHERE hours > 20 GROUP BY employee_id
)



SELECT a.employee_id, a.employee_name, a.department, b.meeting_heavy_weeks 
FROM employees a, employee_heavy b WHERE a.employee_id = b.employee_id AND b.meeting_heavy_weeks > 1 ORDER BY b.meeting_heavy_weeks DESC, a.employee_name