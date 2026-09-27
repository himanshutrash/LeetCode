# Write your MySQL query statement below

WITH prerequisites AS
(
  SELECT 
        *,
        MAX(session_rating) as max_rating,
        MIN(session_rating) as min_rating,
        COUNT(session_id) as total_sessions,
        COUNT(CASE WHEN session_rating >= 4 THEN 1 END) as max_extreme_rating,
        COUNT(CASE WHEN session_rating <= 2 THEN 1 END) as min_extreme_rating,
        COUNT(CASE WHEN session_rating >= 4 THEN 1 END) + COUNT(CASE WHEN session_rating <= 2 THEN 1 END) as total_extreme_rating
    FROM reading_sessions
    GROUP BY book_id
),
polarized_openions AS 
(
    SELECT 
        *,
        max_rating - min_rating AS rating_spread ,
        (max_extreme_rating + min_extreme_rating) / total_sessions AS polarization_score
    FROM prerequisites
    WHERE max_extreme_rating >= 1 
          AND min_extreme_rating >= 1
          AND total_sessions >=5 
          AND ((max_extreme_rating + min_extreme_rating) / total_sessions) >= 0.6  
)

SELECT
    b.*,
    rs.rating_spread,
    ROUND(rs.polarization_score, 2) as polarization_score
FROM polarized_openions as rs
JOIN books as b
ON rs.book_id = b.book_id
ORDER BY rs.polarization_score DESC, b.title DESC
