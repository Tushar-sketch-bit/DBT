select
    seller_id,
    sum(payment_value) as revenue
from {{ ref('stg_revenue') }}
group by seller_id
