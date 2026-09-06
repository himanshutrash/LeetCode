-- Write your PostgreSQL query statement below

 WITH CTE AS(
	SELECT U.user_id, U.activity_type AS activity_trial, U.activity_date AS activity_date_trial, U.activity_duration AS activity_duration_trial, 
 	U1.activity_type AS activity_paid,  U1.activity_date AS activity_date_paid , U1.activity_duration AS activity_duration_paid
 	FROM UserActivity U INNER JOIN 
 	UserActivity U1 ON U.user_id = U1.user_id 
 			AND U.activity_date <= U1.activity_date 
 			AND U.activity_type = 'free_trial' 
 			AND U1.activity_type = 'paid'
 ),
CTE2 AS(
 	SELECT user_id, ROUND(AVG( CASE WHEN activity_trial = 'free_trial' THEN activity_duration_trial ELSE 0 END ),2) trial_avg_duration ,
 					ROUND(AVG( CASE WHEN activity_trial = 'paid' THEN activity_duration_trial ELSE 0 END ),2) paid_avg_duration 
 	FROM(
 		SELECT DISTINCT user_id, activity_trial, activity_date_trial, activity_duration_trial FROM CTE  
 		UNION ALL
 		SELECT DISTINCT user_id, activity_paid, activity_date_paid, activity_duration_paid FROM CTE
 	)sub
 	GROUP BY user_id, activity_trial
 )
 SELECT user_id,  MAX(trial_avg_duration ) trial_avg_duration , MAX(paid_avg_duration) paid_avg_duration
 FROM CTE2
 GROUP BY user_id
 ORDER BY user_id