select
state,
seller_id,
revenue,
state_avg_revenue,
revenue-state_avg_revenue as diff_from_state_avg,
Case 
when revenue > state_avg_revenue Then 'Above average'
when revenue < state_avg_revenue then 'Below average'
else 'At average'
end as performance_status,
state_contribution_pct,
state_rank,
state_total_revenue
from {{ ref('int_seller_state_performance') }}
order by revenue
