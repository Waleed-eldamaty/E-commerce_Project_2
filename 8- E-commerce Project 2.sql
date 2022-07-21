-- Situation:
-- Cindy is close to securing Maven Fuzzy Factory’s next round of funding, and she needs your help to tell a compelling story to investors.
-- You’ll need to pull the relevant data, and help your CEO craft a story about a data driven company that has been producing rapid growth.

-- Objective:
-- Use SQL to: Extract and analyze traffic and website performance data to craft a growth story that your CEO can sell.
-- Dive in to the marketing channel activities and the website improvements that have contributed to your success to date, and use the opportunity to flex your analytical skills for the investors while you’re at it.
-- As an Analyst, the first part of your job is extracting and analyzing the data. The next (equally important) part is communicating the story effectively to your stakeholders.

/* Email was sent on 20th of March-2015 from the CEO: Cindy Sharp and it includes the following:
 Now that we’ve been in market for 3 years, we’ve generated enough growth to raise a much larger round of venture capital funding. We’re close to securing a large round from one of the best West Coast firms.
I need your analytical skills to help me paint a picture of high growth, and data driven performance optimization.
 Tell the story of your company’s growth, using trended performance data
Use the database to explain how you’ve been able to produce growth, by diving in to channels and website optimizations
Flex your analytical muscles so the VCs know your company is a serious data driven shop*/
-- -----------------------------------------------------------------------------------------------------------------------------

-- Question (1): First, I’d like to show our volume growth.
-- Can you pull overall session and order volume, trended by quarter for the life of the business? Since the most recent quarter is incomplete, you can decide how to handle it.
-- -----------------------------------------------------------------------------------------------------------------------------
-- Solution Starts:
SELECT
year(website_sessions.created_at) AS Yr,
quarter(website_sessions.created_at) AS Qr,
COUNT(DISTINCT website_sessions.website_session_id) AS Number_of_Sessions,
COUNT(DISTINCT orders.order_id) AS Number_of_orders
FROM website_sessions
LEFT JOIN orders
on website_sessions.website_session_id=orders.website_session_id
WHERE year(website_sessions.created_at) IN ('2012','2013','2014')
GROUP BY 1,2
ORDER BY 1,2;

-- Conlcusion to question(1):
-- There is a large growth in the number of orders and sessions fromo when it started on the 1st quarter of 2012 till the 4th quarter of 2014
-- -----------------------------------------------------------------------------------------------------------------------------

-- Question (2): Next, let’s showcase all of our efficiency improvements.
-- I would love to show quarterly figures since we launched, for session to order conversion rate, revenue per order, and revenue per session.
-- -----------------------------------------------------------------------------------------------------------------------------
-- Solution Starts:

SELECT
year(website_sessions.created_at) AS Yr,
quarter(website_sessions.created_at) AS Qr,
COUNT(DISTINCT website_sessions.website_session_id) AS Number_of_Sessions,
COUNT(DISTINCT orders.order_id) AS Number_of_orders,
COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conversion_rate,
SUM(orders.price_usd)/COUNT(DISTINCT orders.order_id) AS revenue_per_order,
SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions
LEFT JOIN orders
on website_sessions.website_session_id=orders.website_session_id
WHERE year(website_sessions.created_at) IN ('2012','2013','2014')
GROUP BY 1,2
ORDER BY 1,2;

-- Conlcusion to question(2):
-- The conversion rate has increased from 3% at Q1 of 2012 to 7.7% by Q4 of 2014.
-- The revenue per order has increased from 49.99 dollars to well above 60 dollars
-- The revenue per session has increased from 1 dollar and 59 cents to 4 dollars and 93 cents.
-- The revenue per session metric is really important because it allows the marketing director to spent more to acquire traffic. The higher he can bid the more traffic you will get since more customers will see your ads.
-- This means that as you optimize your business you will get more efficient which will get you more volume
-- -----------------------------------------------------------------------------------------------------------------------------

-- Question (3): I’d like to show how we’ve grown specific channels.
-- Could you pull a quarterly view of orders from Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type in?
-- -----------------------------------------------------------------------------------------------------------------------------
-- Solution Starts:
-- To get the number of sessions, use the following query:
SELECT
year(Sessions_wtih_channel_grouping.created_at) AS Yr,
quarter(Sessions_wtih_channel_grouping.created_at) AS Qr,
COUNT(DISTINCT CASE WHEN channel_grouping= 'Brand Search' then website_session_id ELSE NULL END) AS brand_search,
COUNT(DISTINCT CASE WHEN channel_grouping= 'Gsearch nonbrand' then website_session_id ELSE NULL END) AS gsearch_nonbrand,
COUNT(DISTINCT CASE WHEN channel_grouping= 'Bsearch nonbrand' then website_session_id ELSE NULL END) AS bsearch_nonbrand,
COUNT(DISTINCT CASE WHEN channel_grouping= 'Direct_Type_In' then website_session_id ELSE NULL END) AS Direct,
COUNT(DISTINCT CASE WHEN channel_grouping= 'organic_search' then website_session_id ELSE NULL END) AS organic
FROM(
SELECT
created_at,
website_session_id,
CASE
	WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com','https://www.bsearch.com') THEN 'organic search'
    WHEN utm_campaign = 'nonbrand' AND utm_source = 'gsearch' THEN 'Gsearch nonbrand'
    WHEN utm_campaign = 'nonbrand' AND utm_source = 'bsearch' THEN 'Bsearch nonbrand'
    WHEN utm_campaign = 'brand' THEN 'Brand Search'
    WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
    END AS channel_grouping
    FROM website_sessions
WHERE year(created_at) IN ('2012','2013','2014')) AS Sessions_wtih_channel_grouping
GROUP BY year(Sessions_wtih_channel_grouping.created_at),
quarter(Sessions_wtih_channel_grouping.created_at);


-- To get the number of orders , use the following query:
SELECT
year(Sessions_wtih_channel_grouping.created_at) AS Yr,
quarter(Sessions_wtih_channel_grouping.created_at) AS Qr,
COUNT(DISTINCT CASE WHEN channel_grouping= 'Gsearch nonbrand' then order_id ELSE NULL END) AS gsearch_nonbrand,
COUNT(DISTINCT CASE WHEN channel_grouping= 'Bsearch nonbrand' then order_id ELSE NULL END) AS bsearch_nonbrand,
COUNT(DISTINCT CASE WHEN channel_grouping= 'Brand Search' then order_id ELSE NULL END) AS brand_search,
COUNT(DISTINCT CASE WHEN channel_grouping= 'organic search' then order_id ELSE NULL END) AS organic,
COUNT(DISTINCT CASE WHEN channel_grouping= 'Direct_Type_In' then order_id ELSE NULL END) AS Direct
FROM(
SELECT
website_sessions.created_at,
website_sessions.website_session_id,
orders.order_id,
CASE
	WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN 'organic search'
    WHEN utm_campaign = 'nonbrand' AND utm_source = 'gsearch' THEN 'Gsearch nonbrand'
    WHEN utm_campaign = 'nonbrand' AND utm_source = 'bsearch' THEN 'Bsearch nonbrand'
    WHEN utm_campaign = 'brand' THEN 'Brand Search'
    WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
    END AS channel_grouping
    FROM website_sessions
    LEFT JOIN orders
on website_sessions.website_session_id=orders.website_session_id
WHERE year(website_sessions.created_at) IN ('2012','2013','2014')) AS Sessions_wtih_channel_grouping
GROUP BY year(Sessions_wtih_channel_grouping.created_at),
quarter(Sessions_wtih_channel_grouping.created_at)
ORDER BY year(Sessions_wtih_channel_grouping.created_at),
quarter(Sessions_wtih_channel_grouping.created_at);

-- Instead of using the previous subquery, it can be done in one step as follows:
SELECT
year(website_sessions.created_at) AS Yr,
quarter(website_sessions.created_at) AS Qr,
COUNT(DISTINCT CASE  WHEN utm_campaign = 'nonbrand' AND utm_source = 'gsearch' THEN order_id ELSE NULL END) AS Gsearch_nonbrand_orders,
COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND utm_source = 'bsearch' THEN order_id ELSE NULL END) AS Bsearch_nonbrand_orders,
COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN order_id ELSE NULL END) AS Brand_Search_orders,
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN  order_id ELSE NULL END) AS organic_orders,
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN order_id ELSE NULL END) AS direct_type_in_orders
    FROM website_sessions
    LEFT JOIN orders
on website_sessions.website_session_id=orders.website_session_id
WHERE year(website_sessions.created_at) IN ('2012','2013','2014')
GROUP BY 1,2
ORDER BY 1,2;

-- Conlcusion to question(3):
-- What the investors will be interested in is the brand search, organic and direct type in numbers
-- If we looked at the 2nd quarter from 2012, the gsearch nonbrand had around 291 orders meanwhile the 3 categories (brand search, organic and direct type in) had a sum of 56 orders with a ratio of 6:1
-- If we looked at the 4th quarter from 2014, the gsearch nonbrand had around 3248 orders meanwhile the 3 categories (brand search, organic and direct type in) had a sum of 1752 orders with a ratio of 2:1
-- This means the business has become much less dependent on the paid gsearch nonbrand campaigns and starts to build its own brand which have a better margin and takes you out of the dependency of the search engine
-- -----------------------------------------------------------------------------------------------------------------------------

-- Question (4): Next, let’s show the overall session to order conversion rate trends for those same channels, by quarter.
-- Please also make a note of any periods where we made major improvements or optimizations.
-- -----------------------------------------------------------------------------------------------------------------------------
-- Solution Starts:
SELECT
year(website_sessions.created_at) AS Yr,
quarter(website_sessions.created_at) AS Qr,
COUNT(DISTINCT CASE  WHEN utm_campaign = 'nonbrand' AND utm_source = 'gsearch' THEN order_id ELSE NULL END)/
COUNT(DISTINCT CASE  WHEN utm_campaign = 'nonbrand' AND utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS Gsearch_nonbrand_conversion_rate,

COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND utm_source = 'bsearch' THEN order_id ELSE NULL END)/
COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS Bsearch_nonbrand_conversion_rate,

COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN order_id ELSE NULL END)/
COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS Brand_Search_conversion_rate,

COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN  order_id ELSE NULL END)/
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_conversion_rate,

COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN order_id ELSE NULL END)/
COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_conversion_rate
    FROM website_sessions
    LEFT JOIN orders
on website_sessions.website_session_id=orders.website_session_id
WHERE year(website_sessions.created_at) IN ('2012','2013','2014')
GROUP BY 1,2
ORDER BY 1,2;

-- Conlcusion to question(4):
-- The gsearch nonbrand conversion rate increased from 3.2 % to  7.8 %. More than doubling. Same goes for bsearch nonbrand conversion rate
-- All conversion rates have increased significantly from where they were initially to where they are now
-- This efficiency improvements are going to impress the investments and it shows that the company knows what they are doing
-- -----------------------------------------------------------------------------------------------------------------------------

-- Question (5): We’ve come a long way since the days of selling a single product.
--  Let’s pull monthly trending for revenue and margin by product, along with total sales and revenue. Note anything you notice about seasonality.
-- -----------------------------------------------------------------------------------------------------------------------------
-- Solution Starts:

SELECT
YEAR(created_at) as yr,
Month(created_at) as mo,
SUM(CASE WHEN product_id =1 THEN price_usd ELSE NULL END ) AS mrfuzzy_revenue,
SUM(CASE WHEN product_id =2 THEN price_usd ELSE NULL END ) AS lovebear_revenue,
SUM(CASE WHEN product_id =3 THEN price_usd ELSE NULL END ) AS birthdaybear_revenue,
SUM(CASE WHEN product_id =4 THEN price_usd ELSE NULL END ) AS minibear_revenue,
SUM(CASE WHEN product_id =1 THEN price_usd - cogs_usd ELSE NULL END ) AS mrfuzzy_margin,
SUM(CASE WHEN product_id =2 THEN price_usd - cogs_usd ELSE NULL END ) AS lovebear_margin,
SUM(CASE WHEN product_id =3 THEN price_usd - cogs_usd ELSE NULL END ) AS birthdaybear_margin,
SUM(CASE WHEN product_id =4 THEN price_usd - cogs_usd ELSE NULL END ) AS minibear_margin,
SUM(price_usd) AS Total_Revenue,
SUM(price_usd-cogs_usd) AS Total_Margin
FROM order_items
WHERE year(created_at) IN ('2012','2013','2014')
GROUP BY 1,2;

-- Conlcusion to question(5):
-- Mr fuzzy original revenue was 3000 $ per month then it reached 79,000 $ in December of 2014
-- For Mr Fuzzy, months November and December showed a huge increase in the revenue due to the holiday season at the end of the year
-- For Lovebear, February was the month that showed a surge in the revenue since it was targeting couples. So it was used as a gift probably on Valentine day
-- As for the birthdaybear and minibear, there isn't much data about them to understand seasonality.
-- -----------------------------------------------------------------------------------------------------------------------------

-- Question (6): Let’s dive deeper into the impact of introducing new products.
-- Please pull monthly sessions to the /products page, and show how the % of those sessions clicking through another page has changed over time,
-- along with a view of how conversion from /products to placing an order has improved.
-- -----------------------------------------------------------------------------------------------------------------------------
-- Solution Starts:

-- First we identify all the views of the /product page

CREATE TEMPORARY TABLE products_pageview
SELECT
website_session_id,
website_pageview_id,
created_at AS saw_product_page_at,
pageview_url
FROM
website_pageviews
WHERE pageview_url= '/products';


-- For QA:
SELECT * FROM products_pageview;


SELECT
YEAR(saw_product_page_at) AS yr,
MONTH(saw_product_page_at) AS mo,
COUNT(DISTINCT products_pageview.website_session_id) AS Number_of_Sessions_reached_product_page,
COUNT(DISTINCT website_pageviews.website_session_id) AS Number_of_Sessions_clicked_to_next_page_after_product_page,
COUNT(DISTINCT website_pageviews.website_session_id) /COUNT(DISTINCT products_pageview.website_session_id) AS clickthrough_rate,
COUNT(DISTINCT orders.order_id) AS Number_of_orders,
COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT products_pageview.website_session_id) AS product_to_order_rate
FROM
products_pageview
LEFT JOIN website_pageviews
ON products_pageview.website_session_id=website_pageviews.website_session_id -- Same Session
AND  products_pageview.website_pageview_id < website_pageviews.website_pageview_id -- They had seen another page AFTER the /product page
LEFT JOIN Orders
ON orders.website_session_id=products_pageview.website_session_id
WHERE YEAR(saw_product_page_at) IN ('2012','2013','2014')
GROUP BY 1,2;

-- Conlcusion to question(6):
-- The clickthrough rate of people seeing the page after the product page has increased from 75 % at the beginning of the business to around 85 % by Quarter 4 of 2014
-- The clickthrough rate of people seeing the product page then ordered has increased from 8 % at the beginning of the business to 13.4 % by Quarter 4 of 2014
-- This means that the improvements the business had made of adding additional products that may appeal to other customers have positvely impacted the clickthrough rate and helped contribute to the health of the business
-- -----------------------------------------------------------------------------------------------------------------------------

-- Question (7): We made our 4 th product available as a primary product on December 05, 2014 (it was previously only a cross sell item).
-- Could you please pull sales data since then, and show how well each product cross sells from one another?
-- -----------------------------------------------------------------------------------------------------------------------------
-- Solution Starts:

CREATE TEMPORARY TABLE Primary_Products_Table
SELECT
order_id,
primary_product_id,
created_at AS ordered_at
FROM orders
WHERE created_at > '2014-12-05'; -- When the 4th product was added

-- For QA:
SELECT * FROM Primary_Products_Table;

-- Make the following subquery first:

SELECT
Primary_Products_Table.*,
order_items.product_id AS Cross_sell_product_id
FROM Primary_Products_Table
LEFT JOIN order_items
ON order_items.order_id=Primary_Products_Table.order_id
AND order_items.is_primary_item = 0; -- To bring cross-sells only

-- Use the previous subquery to do the following:

SELECT
primary_product_id,
COUNT(DISTINCT order_id) AS total_orders,
COUNT(DISTINCT CASE WHEN Cross_sell_product_id = 1 THEN order_id ELSE NULL END ) AS cross_sold_product_1,
COUNT(DISTINCT CASE WHEN Cross_sell_product_id = 2 THEN order_id ELSE NULL END ) AS cross_sold_product_2,
COUNT(DISTINCT CASE WHEN Cross_sell_product_id = 3 THEN order_id ELSE NULL END ) AS cross_sold_product_3,
COUNT(DISTINCT CASE WHEN Cross_sell_product_id = 4 THEN order_id ELSE NULL END ) AS cross_sold_product_4,
COUNT(DISTINCT CASE WHEN Cross_sell_product_id = 1 THEN order_id ELSE NULL END ) /COUNT(DISTINCT order_id) AS Product_1_cross_sell_rate,
COUNT(DISTINCT CASE WHEN Cross_sell_product_id = 2 THEN order_id ELSE NULL END ) /COUNT(DISTINCT order_id) AS Product_2_cross_sell_rate,
COUNT(DISTINCT CASE WHEN Cross_sell_product_id = 3 THEN order_id ELSE NULL END ) /COUNT(DISTINCT order_id) AS Product_3_cross_sell_rate,
COUNT(DISTINCT CASE WHEN Cross_sell_product_id = 4 THEN order_id ELSE NULL END ) /COUNT(DISTINCT order_id) AS Product_4_cross_sell_rate
FROM(
SELECT
Primary_Products_Table.*,
order_items.product_id AS Cross_sell_product_id
FROM Primary_Products_Table
LEFT JOIN order_items
ON order_items.order_id=Primary_Products_Table.order_id
AND order_items.is_primary_item = 0 ) AS Primary_with_cross_sell -- To bring cross-sells only
GROUP BY primary_product_id;

-- Conlcusion to question(7):
-- Product 4 cross sells very well with all products
-- 933 of product 1 orders were cross sold with product 4
-- Above 20 % of the orders for products (1 = 20.89 %),(2 = 20.36 %) ,(3 = 22.39 %) end up purchasing product 4 as well
-- -----------------------------------------------------------------------------------------------------------------------------

-- Question (8):  In addition to telling investors about what we’ve already achieved, let’s show them that we still have plenty of gas in the tank.
-- Based on all the analysis you’ve done, could you share some recommendations and opportunities for us going forward? No right or wrong answer here I’d just like to hear your perspective!
-- -----------------------------------------------------------------------------------------------------------------------------
-- Solution Starts:

-- Focus on different areas of the website were you still saw a drop off
-- Add more products similar to the products cross sold really well