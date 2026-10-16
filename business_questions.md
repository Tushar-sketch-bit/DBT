Based on the SQL in your mart models, here are the key business questions each mart answers for Power BI dashboards:     

mart_customer_behaviour                                                                                                  

 • Who are my highest-value customers by total spend?                                                                    
 • What is the customer lifetime value (CLV) per customer?                                                               
 • How frequently does each customer purchase (order count)?                                                             
 • What is the recency of each customer’s first and last purchase?                                                       
 • How many days has a customer been active (customer lifetime days)?                                                    
 • Is a customer classified as Repeat, Regular, or Average based on state average order count?                           
 • How much of the state’s total spend does an individual customer contribute?                                           

**Visual Mapping – mart_customer_behaviour**

| Business Question | Power BI Visual | Columns Used |
|---|---|---|
| Who are my highest-value customers by total spend? | Bar chart / Top N table | customer_unique_id, total_spend |
| What is the customer lifetime value (CLV) per customer? | Card / KPI / Table | customer_unique_id, total_spend |
| How frequently does each customer purchase (order count)? | Bar chart / Histogram | customer_unique_id, order_count |
| What is the recency of each customer’s first and last purchase? | Table / Scatter chart | customer_unique_id, first_purchase_date, last_purchase_date |
| How many days has a customer been active (customer lifetime days)? | Card / Table | customer_unique_id, customer_lifetime_days |
| Is a customer classified as Repeat, Regular, or Average based on state average order count? | Slicer / Table | customer_unique_id, customer_activity_type |
| How much of the state’s total spend does an individual customer contribute? | Treemap / Donut chart | customer_unique_id, state_spend_share |

mart_delivery_performance                                                                                                

 • What is the on-time delivery rate by state?                                                                           
 • Which states have the highest late delivery rate (ranked)?                                                            
 • What is the average delivery time in days per state?                                                                  
 • How many orders are delivered, late, or on time per state?                                                            
 • What is the average delay in days for late orders per state?                                                          

**Visual Mapping – mart_delivery_performance**

| Business Question | Power BI Visual | Columns Used |
|---|---|---|
| What is the on-time delivery rate by state? | Gauge / Bar chart | state, on_time_orders, delivered_orders |
| Which states have the highest late delivery rate (ranked)? | Bar chart / Table | state, late_rate, late_rnk |
| What is the average delivery time in days per state? | Bar chart / Card | state, avg_delivery_days |
| How many orders are delivered, late, or on time per state? | Stacked column chart | state, delivered_orders, late_orders, on_time_orders |
| What is the average delay in days for late orders per state? | Bar chart / Card | state, avg_delay |

marts_seller_performance                                                                                                 

 • Which sellers generate the most revenue within their state?                                                           
 • What is each seller’s revenue rank within their state?                                                                
 • How does a seller’s revenue compare to the state average (above/below/at average)?                                    
 • What percentage of total state revenue does each seller contribute?                                                   
 • What is the total revenue per state and per seller? 

**Visual Mapping – marts_seller_performance**

| Business Question | Power BI Visual | Columns Used |
|---|---|---|
| Which sellers generate the most revenue within their state? | Bar chart / Top N table | seller_id, state, revenue |
| What is each seller’s revenue rank within their state? | Table / Matrix | seller_id, state, state_rank |
| How does a seller’s revenue compare to the state average (above/below/at average)? | Conditional formatting table | seller_id, state, performance_status, diff_from_state_avg |
| What percentage of total state revenue does each seller contribute? | Donut chart / Treemap | seller_id, state, state_contribution_pct |
| What is the total revenue per state and per seller? | Matrix / Stacked bar chart | state, seller_id, revenue, state_total_revenue |
