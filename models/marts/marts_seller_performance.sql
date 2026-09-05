SELECT
    seller_id,
    state,
    revenue,
    state_avg_revenue,
    state_total_revenue,
    state_rank,
    state_contribution_pct,
    diff_from_state_avg,
    performance_status
FROM {{ ref('int_business_metrics') }}
