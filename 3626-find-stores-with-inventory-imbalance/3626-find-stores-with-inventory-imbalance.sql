# Write your MySQL query statement below
with cte as(
select distinct store_id,
     first_value(product_name) over(partition by store_id order by price desc) as most_exp_product,
     first_value(product_name) over(partition by store_id order by price) as cheapest_product,
     first_value(quantity) over(partition by store_id order by price desc) as most_exp_product_quant,
     first_value(quantity) over(partition by store_id order by price) as cheapest_product_quant
from inventory)

select cte.store_id,s.store_name,s.location,cte.most_exp_product, cte.cheapest_product,
    round(cheapest_product_quant/most_exp_product_quant,2) as imbalance_ratio
from cte
join stores as s
on cte.store_id=s.store_id
where cte.store_id in (select store_id
                    from inventory
                    group by store_id
                    having count(*)>=3) and cte.most_exp_product_quant<cte.cheapest_product_quant
order by imbalance_ratio desc,s.store_name