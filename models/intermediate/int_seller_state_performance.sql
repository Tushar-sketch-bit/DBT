SELECT
seller_id,
state,
revenue,
AVG(revenue) OVER(partition by state) as state_avg_revenue,
SUM(revenue) OVER(partition by state) as state_total_revenue,
RANK() OVER(partition by state order by revenue desc) as state_rank,
revenue*100 / SUM(revenue) OVER(partition by state) as state_contribution_pct
FROM {{ ref('int_seller_state_revenue') }}
