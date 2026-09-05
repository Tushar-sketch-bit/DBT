select o.order_id,
c.customer_id,
c.customer_state,
o.order_status,
o.order_purchase_timestamp,
o.order_delivered_customer_date,
o.order_estimated_delivery_date,

date_diff('day', o.order_purchase_timestamp, o.order_delivered_customer_date) as delivery_days,
date_diff('day', o.order_estimated_delivery_date, o.order_delivered_customer_date) as delay_days,

case 
when o.order_delivered_customer_date IS NULL then 'Not delivered'
when o.order_delivered_customer_date > o.order_estimated_delivery_date then 'Late'
else 'On time'
end as delivery_status


from {{ ref('stg_orders') }} as o
left join {{ ref('stg_customers') }} as c
 on o.customer_id = c.customer_id

