select count(order_id) as no_of_orders,
customer_id
from {{ ref('int_order_delivery') }}
group by customer_id
