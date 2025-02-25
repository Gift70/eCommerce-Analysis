use project_db;

select * from ecommerce;

select count(order_id) from ecommerce;

# Top-selling product categories
SELECT 
    product_category, SUM(quantity) Total_Sold
FROM
    ecommerce
GROUP BY product_category
ORDER BY SUM(quantity) DESC;


# Total Revenue 
SELECT 
    SUM(total_revenue) AS Total_Revenue
FROM
    ecommerce;
    

# High value customers by country 
SELECT 
    customer_country, customer_id, clv
FROM
    ecommerce
ORDER BY clv DESC
LIMIT 10;


# Top-selling product categories based on revenue?
SELECT 
    product_category, ROUND(SUM(total_revenue), 2) Total_Revenue
FROM
    ecommerce
GROUP BY product_category
ORDER BY SUM(total_revenue) DESC;


# Which segments have the highest churn risk?
SELECT 
    rfm_segment, AVG(churn_risk)
FROM
    ecommerce
GROUP BY rfm_segment
ORDER BY AVG(churn_risk) DESC;


# Top 10 Customers
SELECT 
    customer_id, SUM(total_revenue) Top_Customers
FROM
    ecommerce
GROUP BY customer_id
ORDER BY SUM(total_revenue) DESC
LIMIT 10;


# How does the AOV vary across different RFM segments
SELECT 
    rfm_segment, ROUND(AVG(aov), 2) AOV
FROM
    ecommerce
GROUP BY rfm_segment
ORDER BY ROUND(AVG(aov), 2) DESC;


# Age distribution across different product categories
SELECT 
    product_category,
    customer_age,
    COUNT(customer_id) AS customer_count
FROM
    ecommerce
GROUP BY product_category , customer_age
ORDER BY product_category , customer_age;


# Which rfm segments contribute the most revenue
SELECT 
    rfm_segment,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    COUNT(DISTINCT customer_id) AS customers
FROM
    ecommerce
GROUP BY rfm_segment
ORDER BY total_revenue DESC;


# How does the conversion rate vary across customer segments
SELECT 
    rfm_segment, AVG(conversion_rate) Rate
FROM
    ecommerce
GROUP BY rfm_segment
ORDER BY Rate DESC;


# Which product categories have the highest refund rates
SELECT 
    product_category, ROUND(AVG(refund_rate), 2) Refund_Rate
FROM
    ecommerce
GROUP BY product_category
ORDER BY refund_rate DESC;


# How does customer engagement vary across different traffic sources
SELECT 
    traffic_source,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(order_id) AS total_orders,
    SUM(total_revenue) AS total_revenue
FROM
    ecommerce
GROUP BY traffic_source
ORDER BY total_revenue DESC;



# correlation between churn risk and total revenue contributed
SELECT 
    churn_risk,
    SUM(total_revenue) AS Total_revenue,
    COUNT(DISTINCT customer_id) AS Customer_count
FROM
    ecommerce
GROUP BY churn_risk
ORDER BY churn_risk;

# correlation cont.
SELECT 
    (SUM((churn_risk - avg_churn) * (total_revenue - avg_revenue)) / 
    SQRT(SUM(POW(churn_risk - avg_churn, 2)) * SUM(POW(total_revenue - avg_revenue, 2)))) 
    AS correlation_coefficient
FROM 
    (SELECT 
        churn_risk, 
        total_revenue, 
        (SELECT AVG(churn_risk) FROM ecommerce) AS avg_churn, 
        (SELECT AVG(total_revenue) FROM ecommerce) AS avg_revenue
    FROM ecommerce) AS subquery;


# Average customer lifetime value (CLV) for high-churn-risk customers
SELECT 
    ROUND(AVG(clv), 2) average_clv
FROM
    ecommerce
WHERE
    churn_risk = 1;


# Numbers of churned customers
select count(customer_id) churned_customers from ecommerce
where churn_risk = 1;


# Top 10 Products with the highest refund rate
SELECT 
    product_id, COUNT(*) AS refund_count
FROM
    ecommerce
WHERE
    refund_rate > 0
GROUP BY product_id
ORDER BY refund_count DESC
LIMIT 10;


# Total revenue trend over time (monthly/yearly)?
SELECT 
    DATE_FORMAT(order_date, '%Y-%m'),
    ROUND(SUM(total_revenue), 2) AS total_revenue
FROM
    ecommerce
GROUP BY order_date
ORDER BY order_date;


# Peak sales period (Seasonality Analysis)
SELECT 
    order_date, ROUND(SUM(total_revenue), 2) AS total_revenue
FROM
    ecommerce
GROUP BY order_date
ORDER BY total_revenue DESC;


# Average order value (AOV) trend over time
SELECT 
    order_date, AVG(aov) AS avg_order_value
FROM
    ecommerce
GROUP BY order_date
ORDER BY order_date;


# Peak sales periods (Month)
SELECT 
    EXTRACT(MONTH FROM order_date) AS sales_month,
    ROUND(SUM(total_revenue), 2) AS total_revenue
FROM
    ecommerce
GROUP BY sales_month
ORDER BY total_revenue DESC;


# How do price change impact sales volume
SELECT 
    unit_price, SUM(quantity) AS Quantity_sold
FROM
    ecommerce
GROUP BY unit_price
ORDER BY Quantity_sold;

#  What is the sell-through rate by product category
SELECT 
    product_category, AVG(sell_through_rate) AS STR
FROM
    ecommerce
GROUP BY product_category
ORDER BY STR DESC;


# How does stock availability affect sales trend
SELECT 
    product_category,
    AVG(stock_level) AS avg_stock,
    SUM(quantity) AS total_sold
FROM
    ecommerce
GROUP BY product_category
ORDER BY total_sold DESC;


# Which products have the slowest sales?
SELECT 
    product_id, product_category, SUM(quantity) AS total_sold
FROM
    ecommerce
GROUP BY product_id , product_category
ORDER BY total_sold;


#  Conversion rates by product category
SELECT 
    product_category,
    AVG(conversion_rate) AS avg_conversion_rate
FROM
    ecommerce
GROUP BY product_category
ORDER BY avg_conversion_rate DESC;


# Impact of average order value (AOV) on conversion rates
SELECT 
    CASE 
         WHEN aov < 50 THEN 'Low (<$50)' 
        WHEN aov BETWEEN 50 AND 100 THEN 'Medium ($50-$100)' 
        ELSE 'High (>$100)' 
    END AS aov_category,
    AVG(conversion_rate) AS avg_conversion_rate
FROM ecommerce
GROUP BY aov_category
ORDER BY avg_conversion_rate DESC;


# Which products have high conversion rates and high refund rates
SELECT 
    product_id,
    product_category,
    AVG(conversion_rate) AS avg_conversion_rate,
    SUM(refund_rate) AS total_refund_rate
FROM
    ecommerce
GROUP BY product_id , product_category
HAVING AVG(conversion_rate) > 0.1
    AND SUM(refund_rate) > 1
ORDER BY total_refund_rate DESC;


# What is the refund rate trend over time
SELECT 
    order_date AS Season,
    ROUND(AVG(refund_rate), 2) AS total_refunds
FROM
    ecommerce
GROUP BY Season
ORDER BY Season;


# Sales and refund trends over time
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(total_revenue) AS total_sales,
    SUM(refund_rate) AS total_refunds,
    (SUM(refund_rate) / NULLIF(SUM(total_revenue), 0)) * 100 AS refund_percentage
FROM
    ecommerce
GROUP BY month
ORDER BY month;


# Conversion rate trend over time
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS Season,
    AVG(conversion_rate) AS avg_conversion_rate
FROM
    ecommerce
GROUP BY Season
ORDER BY Season;


# Most valuable customers based on total spending
SELECT 
    customer_id,
    COUNT(order_id) AS total_orders,
    SUM(total_revenue) AS total_spent
FROM
    ecommerce
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;


# Customers spending pattern by country
SELECT 
    customer_country,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(total_revenue), 2) AS total_sales,
    ROUND(AVG(total_revenue), 2) AS avg_spent_per_customer
FROM
    ecommerce
GROUP BY customer_country
ORDER BY total_sales DESC;