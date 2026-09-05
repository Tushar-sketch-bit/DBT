with payment_per_order as (
select 
order_id,
sum(payment_value) as order_spend
from {{ ref('stg_orderpayments') }}
group by order_id
)
select
p.order_id,
p.order_spend,
o.customer_id,
o.order_status,
o.order_purchase_timestamp,
c.customer_unique_id,
c.customer_state
from payment_per_order as p

left join {{ ref('stg_orders') }} as o 
on p.order_id = o.order_id

left join {{ ref('stg_customers') }} as c
on o.customer_id = c.customer_id

