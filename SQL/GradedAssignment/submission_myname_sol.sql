/*

-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
  
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/

SELECT 
      state, 
      COUNT(customer_id) as no_of_customers
FROM customer_t
GROUP BY state
ORDER BY COUNT(customer_id) DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. 

Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/


WITH feed_bucket AS
(
    SELECT 
	CASE 
			WHEN customer_feedback = 'Very Good' THEN 5
			WHEN customer_feedback = 'Good' THEN 4
			WHEN customer_feedback = 'Okay' THEN 3
			WHEN customer_feedback = 'Bad' THEN 2
			WHEN customer_feedback = 'Very Bad' THEN 1
			END AS feedback_count,
            quarter_number
	FROM order_t
)
SELECT 
      quarter_number,
      avg(feedback_count) avg_feedback
FROM feed_bucket
GROUP BY quarter_number
ORDER BY 1;



-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.
      
Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/
      
WITH cust_feedback AS
(
	SELECT 
		quarter_number,
		SUM(CASE WHEN customer_feedback = 'Very Good' THEN 1 ELSE 0 END) AS very_good,
		SUM(CASE WHEN customer_feedback = 'Good' THEN 1 ELSE 0 END) AS good,
		SUM(CASE WHEN customer_feedback = 'Okay' THEN 1 ELSE 0 END) AS okay,
		SUM(CASE WHEN customer_feedback = 'Bad' THEN 1 ELSE 0 END) AS bad,
		SUM(CASE WHEN customer_feedback = 'Very Bad' THEN 1 ELSE 0 END) AS very_bad,
		COUNT(customer_feedback) AS total_feedbacks
	FROM order_t
	GROUP BY 1
)
SELECT quarter_number,
        (very_good/total_feedbacks)*100 perc_very_good,
        (good/total_feedbacks)*100 perc_good,
        (okay/total_feedbacks)*100 perc_okay,
        (bad/total_feedbacks)*100 perc_bad,
        (very_bad/total_feedbacks)*100 perc_very_bad
FROM cust_feedback
ORDER BY 1;


-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/


SELECT
      vehicle_maker,
      COUNT(cust.customer_id) number_of_customers
FROM product_t pro 
	INNER JOIN order_t ord
	    ON pro.product_id = ord.product_id
	INNER JOIN customer_t cust
	    ON ord.customer_id = cust.customer_id
GROUP BY 1
ORDER BY 2 desc
LIMIT 5;


-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/

SELECT state, vehicle_maker FROM (
	SELECT
		  state,
		  vehicle_maker,
		  COUNT(cust.customer_id) no_of_cust,
		  RANK() OVER (PARTITION BY state ORDER BY COUNT(customer_id) DESC) rnk
FROM product_t pro 
	INNER JOIN order_t ord
	    ON pro.product_id = ord.product_id
	INNER JOIN customer_t cust
	    ON ord.customer_id = cust.customer_id
	GROUP BY 1,2) tbl
WHERE rnk = 1;




-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/


SELECT 
	  quarter_number, 
	  COUNT(order_id) as total_orders
FROM order_t
GROUP BY 1
ORDER BY 1 ASC;




-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.
*/
      
      
WITH QoQ AS 
(
	SELECT
		  quarter_number,
		  SUM(quantity * (vehicle_price - ((discount/100)*vehicle_Price))) revenue
	FROM order_t
	GROUP BY 1
)
SELECT
      quarter_number,
  	  revenue,
      LAG(revenue) OVER(ORDER BY quarter_number) AS previous_revenue,
      (revenue - LAG(revenue) OVER(ORDER BY quarter_number))/LAG(revenue) OVER(ORDER BY quarter_number) AS qoq_perc_change
FROM QoQ;
      
      

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/


SELECT  
      quarter_number,
      SUM(quantity * (vehicle_price - ((discount/100)*vehicle_Price))) revenue,
      COUNT(order_id) total_orders
FROM order_t
GROUP BY quarter_number
ORDER BY 1;




-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/

SELECT 
     credit_card_type, 
     avg(discount) average_discount
FROM order_t ord 
INNER JOIN customer_t cust
	ON ord.customer_id = cust.customer_id
GROUP BY credit_card_type
ORDER BY 2 DESC;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/

SELECT 
      quarter_number, 
      AVG(DATEDIFF(ship_date, order_date)) average_shipping_time
FROM order_t
GROUP BY 1
ORDER BY 1;



-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



