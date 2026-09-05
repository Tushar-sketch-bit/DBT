select
customer_state as state,
Count(*) as total_orders,
count(
   case when order_delivered_customer_date IS NOT NULL then order_id 
   end) as delivered_orders,
count (
   case when  delivery_status = 'Late' then order_id 
    end) as late_orders,
count (
   case when  delivery_status = 'On time' then order_id 
    end) as on_time_orders,

avg(delivery_days) as avg_delivery_days,

avg(
   case when  delivery_status = 'Late' then delay_days 
    end) as avg_delay

from {{ ref('int_order_delivery') }} 

group by customer_state
