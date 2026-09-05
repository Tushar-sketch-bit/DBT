with final as (select
state,
total_orders,
delivered_orders,
late_orders,
on_time_orders,
avg_delivery_days,
avg_delay,
late_orders *100/ delivered_orders as late_rate,
from {{ ref('int_state_delivery_metrics') }} )

select * ,
rank() over(order by late_rate desc) as late_rnk
from final

