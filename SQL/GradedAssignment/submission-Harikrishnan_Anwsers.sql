use WHEELS;
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

SELECT STATE, 
	COUNT(*) AS NUMBER_OF_CUSTOMERS
FROM CUSTOMER_T 
GROUP BY STATE 
ORDER BY NUMBER_OF_CUSTOMERS DESC;
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. 

Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/

WITH AVERAGE_RATE
AS ( 
	SELECT CUSTOMER_FEEDBACK, 
		CASE 
			WHEN CUSTOMER_FEEDBACK = 'very bad' 
				THEN 1
			WHEN CUSTOMER_FEEDBACK = 'bad' 
				THEN 2 
            WHEN CUSTOMER_FEEDBACK = 'okay' 
				THEN 3 
            WHEN CUSTOMER_FEEDBACK = 'good' 
				THEN 4 
            WHEN CUSTOMER_FEEDBACK = 'very good' 
				THEN 5 
			END FEEDBACK, QUARTER_NUMBER 
	FROM ORDER_T 
    ) 
SELECT QUARTER_NUMBER, 
	AVG(FEEDBACK) AS AVG_RATING 
FROM AVERAGE_RATE 
GROUP BY QUARTER_NUMBER 
ORDER BY QUARTER_NUMBER;



-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.
      
Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/
      
WITH TOTAL_FEEDBACK 
AS (
    SELECT COUNT(CUSTOMER_FEEDBACK) AS TOTAL_FEEDBACK, 
		QUARTER_NUMBER
    FROM ORDER_T
    GROUP BY 2
	),

CATEGORY_FEEDBACK 
AS (
    SELECT COUNT(CUSTOMER_FEEDBACK) AS FEEDBACK_COUNT, 
		CUSTOMER_FEEDBACK, 
		QUARTER_NUMBER
    FROM ORDER_T
    GROUP BY 2, 3
	)

SELECT
    CATEGORY_FEEDBACK.CUSTOMER_FEEDBACK,
    CATEGORY_FEEDBACK.QUARTER_NUMBER,
    (FEEDBACK_COUNT / TOTAL_FEEDBACK.TOTAL_FEEDBACK) * 100 AS FEEDBACK_PERCENTAGE
FROM CATEGORY_FEEDBACK
INNER JOIN TOTAL_FEEDBACK
    ON CATEGORY_FEEDBACK.QUARTER_NUMBER = TOTAL_FEEDBACK.QUARTER_NUMBER
ORDER BY CATEGORY_FEEDBACK.QUARTER_NUMBER,  CATEGORY_FEEDBACK.CUSTOMER_FEEDBACK;
-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/



-- ---------------------------------------------------------------------------------------------------------------------------------
SELECT 
	P.VEHICLE_MAKER,
    COUNT(P.VEHICLE_MAKER) AS CUSTOMER_COUNT
FROM CUSTOMER_T C
JOIN ORDER_T O 
    ON C.CUSTOMER_ID = O.CUSTOMER_ID
JOIN PRODUCT_T P
    ON  O.PRODUCT_ID = P.PRODUCT_ID
GROUP BY P.VEHICLE_MAKER
ORDER BY CUSTOMER_COUNT DESC
LIMIT 5;
    

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/

SELECT STATE, 
	VEHICLE_MAKER, 
    NUM_CUSTOMERS 
FROM ( 
	SELECT C.STATE, 
		P.VEHICLE_MAKER, 
        COUNT(O.CUSTOMER_ID) AS NUM_CUSTOMERS, 
        RANK() OVER (PARTITION BY C.STATE ORDER BY COUNT(O.CUSTOMER_ID) DESC) AS RANKING 
	FROM ORDER_T O 
    INNER JOIN CUSTOMER_T C 
		ON O.CUSTOMER_ID = C.CUSTOMER_ID 
	INNER JOIN PRODUCT_T P 
		ON O.PRODUCT_ID = P.PRODUCT_ID 
	GROUP BY C.STATE, P.VEHICLE_MAKER 
    ) 
SUBQUERY WHERE RANKING = 1 
ORDER BY NUM_CUSTOMERS 
DESC;
-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/

SELECT QUARTER_NUMBER, 
	COUNT(ORDER_ID) AS NUM_ORDERS 
FROM ORDER_T 
GROUP BY QUARTER_NUMBER 
ORDER BY QUARTER_NUMBER 
ASC;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.
*/
WITH CTE 
AS ( 
	SELECT QUARTER_NUMBER,
		SUM(VEHICLE_PRICE * QUANTITY) AS TOTAL_REVENUE
	FROM ORDER_T 
    GROUP BY QUARTER_NUMBER 
    ) 
SELECT QUARTER_NUMBER,
	TOTAL_REVENUE,
    ((TOTAL_REVENUE - LAG(TOTAL_REVENUE, 1) OVER (ORDER BY QUARTER_NUMBER)) / LAG(TOTAL_REVENUE, 1) OVER (ORDER BY QUARTER_NUMBER)) * 100 AS QOQ_CHANGE 
FROM CTE 
ORDER BY QUARTER_NUMBER;   
      

-- ---------------------------------------------------------------------------------------------------------------------------------


/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

SELECT QUARTER_NUMBER,
	SUM(VEHICLE_PRICE * QUANTITY) AS TOTAL_REVENUE, 
    COUNT(ORDER_ID) AS NUM_ORDERS 
FROM ORDER_T 
GROUP BY QUARTER_NUMBER 
ORDER BY QUARTER_NUMBER;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/

SELECT C.CREDIT_CARD_TYPE,
	AVG(O.DISCOUNT) AS AVG_DISCOUNT 
FROM ORDER_T O 
INNER JOIN CUSTOMER_T C 
	ON O.CUSTOMER_ID = C.CUSTOMER_ID 
GROUP BY C.CREDIT_CARD_TYPE;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/

SELECT QUARTER_NUMBER,
	AVG(DATEDIFF(SHIP_DATE, ORDER_DATE)) AS AVG_SHIP_TIME 
FROM ORDER_T 
GROUP BY QUARTER_NUMBER 
ORDER BY QUARTER_NUMBER;
-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



