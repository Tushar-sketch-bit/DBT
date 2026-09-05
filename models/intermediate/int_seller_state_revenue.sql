SELECT
    seller_id,
    customer_state AS state,
    SUM(payment_value) AS revenue
FROM {{ ref('stg_revenue') }}
GROUP BY seller_id, customer_state
