with t as (select 
customer_unique_id,
customer_state as state,
count(order_id) as order_count,
sum(order_spend) as total_spend,
min(order_purchase_timestamp) as first_purchase_date,
max(order_purchase_timestamp) as last_purchase_date,
from {{ ref('int_customer_orders') }}
group by customer_unique_id, customer_state
),
p as (select *,
avg(order_count) over(partition by state) as state_avg_order_count
from t)

select *,
case when order_count> state_avg_order_count then 'Repeat'
when order_count < state_avg_order_count then 'Regular'
else 'Average'
end as customer_activity_type
from p
