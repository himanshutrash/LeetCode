# Write your MySQL query statement below
with CTE as (
select d.driver_id,driver_name,

avg( case when month(trip_date) <= 6 then distance_km/fuel_consumed else null end)as first_half,
avg( case when month(trip_date) > 6 then distance_km/fuel_consumed else null end) as second_half

from drivers d join trips t
on d.driver_id = t.driver_id
group by d.driver_id
having first_half is not null
and second_half is not null
)

select driver_id,driver_name,
round(first_half,2) as first_half_avg,
round(second_half,2) as second_half_avg,
round(second_half - first_half,2) as efficiency_improvement 
from cte
where second_half > first_half
order by efficiency_improvement  DESC , driver_name