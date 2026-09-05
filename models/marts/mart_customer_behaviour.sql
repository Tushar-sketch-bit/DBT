select
customer_unique_id,
state,
order_count,
total_spend,
customer_total_spend,
state_spend_share,
first_purchase_date,
last_purchase_date,
customer_lifetime_days,
state_avg_order_count,
customer_activity_type

from {{ ref('int_customer_state_behaviour') }}
