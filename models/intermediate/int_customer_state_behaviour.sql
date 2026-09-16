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
avg(order_count) over(partition by state) as state_avg_order_count,
sum(total_spend) over(partition by customer_unique_id) as customer_total_spend 
from t)

select *,
case when order_count> state_avg_order_count then 'Repeat'
when order_count < state_avg_order_count then 'Regular'
else 'Average'
end as customer_activity_type,
DATEDIFF('day',first_purchase_date,last_purchase_date) as customer_lifetime_days,
total_spend *100/ NULLIF(customer_total_spend, 0) as state_spend_share
from p
