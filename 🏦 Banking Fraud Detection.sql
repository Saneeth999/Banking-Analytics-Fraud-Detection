SELECT * FROM accounts;
SELECT * FROM branches;
SELECT * FROM customers;
SELECT * FROM fraud_flags;
SELECT * FROM login_activity;
SELECT * FROM transactions;

                            -- 🏦 Banking Fraud Detection
-- 1️⃣ Total Transaction Amount Per Account

SELECT a.account_type AS account_type ,ROUND(SUM(t.amount),2) as Total_Amount
FROM transactions as t
JOIN accounts as a
	ON a.account_id=t.account_id
GROUP BY a.account_type 
ORDER BY SUM(t.amount) DESC;



-- 2️⃣ Average Transaction Amount Per Customer

SELECT C.customer_id as Customer_Id, C.full_name As Full_Name,ROUND(AVG(t.amount),2) as Avg_Amount
FROM customers as c
JOIN accounts as a
	ON a.customer_id=c.customer_id
JOIN transactions as t
	ON t.account_id =a.account_id
GROUP BY C.customer_id
ORDER BY AVG(t.amount) DESC;




-- 3️⃣ Count of Transactions Per Merchant Category




SELECT  merchant_category, COUNT(transaction_id) AS Total_transactions
FROM transactions
GROUP BY merchant_category
ORDER BY COUNT(transaction_id) DESC;




-- 4️⃣ High-Value Transactions 
-- List all transactions above 100,000



SELECT   account_id,ROUND(SUM(amount),2) AS Total_transaction
from transactions
GROUP BY account_id
HAVING SUM(amount) > 100000;


-- 5️⃣ Transactions per Branch

SELECT b.branch_name as Brach_Name,
	  
	   ROUND(SUM(amount),2) AS Total_Amount
FROM branches as b
JOIN accounts as a
	ON a.branch_id =b.branch_id
JOIN transactions as t
	ON t.account_id = a. account_id
GROUP BY b.branch_name
ORDER BY ROUND(SUM(amount),2) DESC;






-- 6️⃣ Active vs Inactive Accounts

-- Find accounts with at least 1 transaction vs accounts with no transactions.


SELECT 
    a.account_id,
    a.account_type,
    CASE 
        WHEN t.transaction_id IS NULL THEN 'Inactive'
        ELSE 'Active'
    END AS status
FROM accounts a
LEFT JOIN transactions t
    ON a.account_id = t.account_id
GROUP BY a.account_id, a.account_type, t.transaction_id
ORDER BY a.account_id;



-- 7️⃣ Top 5 Customers by Transaction Volume

-- Rank customers based on total transaction amount and show top 5.



SELECT c.customer_id as customer_id,
		c.full_name as  full_name,
		ROUND(SUM(t.amount),2) AS Total_transactions
FROM customers as c
JOIN accounts as a
	ON c.customer_id=a.customer_id
JOIN transactions as t
	ON t.account_id = a.account_id
GROUP BY c.customer_id,c.full_name
ORDER BY ROUND(SUM(t.amount),2) DESC
LIMIT 5;





-- 8️⃣ Average Transaction Amount by Transaction Type

-- Compare average debit vs credit transactions.

SELECT transaction_type,ROUND(AVG(amount),2) as Avg_Transactions
FROM transactions 
GROUP BY transaction_type
ORDER BY ROUND(AVG(amount),2) DESC;




-- 9️⃣ Most Frequent Merchant Category per Account

-- Find the merchant category with the most transactions per account.

SELECT DISTINCT ON (account_id)
    account_id,
    merchant_category AS most_frequent_category,
    COUNT(*) OVER (PARTITION BY account_id, merchant_category) AS total_transactions
FROM transactions
ORDER BY account_id, total_transactions DESC;




-- 🔟 Transactions in the Last 30 Days
-- Count all transactions per customer in the last 30 days.

SELECT COUNT(t.transaction_id) AS total_count,
		c.customer_id as customer_id,
		c.full_name as full_name
FROM customers as c
JOIN accounts as a
	ON a.customer_id = c.customer_id
JOIN transactions as t
	ON t.account_id = a.account_id
WHERE t.transaction_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY c.customer_id,c.full_name
ORDER BY COUNT(t.transaction_id) DESC;


-- 1️⃣1️⃣ Branch with Maximum Transactions
-- Identify the branch with the highest total number of transactions.


SELECT b.branch_id as branch_id,b.branch_name as branch_name,
	   COUNT(t.transaction_id) as TotalNum_transactions
FROM branches  as b
JOIN accounts as a
	ON a.branch_id=b.branch_id
JOIN transactions as t
	ON t.account_id =a.account_id
GROUP BY b.branch_id,b.branch_name
ORDER BY COUNT(t.amount) DESC
LIMIT 1;



-- 1️⃣2️⃣ Customers with Multiple Accounts

-- List customers who have both Savings and Current accounts.



 
SELECT 
    c.customer_id as customer_id,
    c.full_name as full_name
FROM customers AS c
JOIN accounts AS a
    ON a.customer_id = c.customer_id
WHERE a.account_type IN ('Savings', 'Current')
GROUP BY c.customer_id, c.full_name
HAVING COUNT(DISTINCT a.account_type) = 2;





-- 1️⃣3️⃣ International Transactions
-- 
-- Find total number of international transactions per customer.


SELECT c.customer_id as customer_id,
		c.full_name as full_name, 
		Count(t.transaction_id) as Total_num_transactions
FROM customers as c
JOIN accounts as a
	ON a.customer_id = c.customer_id
JOIN transactions as t
	ON t.account_id =a.account_id
WHERE t.transaction_type ='International'
GROUP BY C.customer_id,C.full_name
ORDER BY Count(t.transaction_id) DESC;





-- 1️⃣4️⃣ Suspicious Location Activity

-- List accounts that made transactions in more than 3 different locations in a month.




SELECT 
    t.account_id,
    DATE_TRUNC('month', t.transaction_date) AS transaction_month,
    COUNT(DISTINCT t.location) AS location_count
FROM transactions AS t
GROUP BY 
    t.account_id,
    DATE_TRUNC('month', t.transaction_date)
HAVING COUNT(DISTINCT t.location) > 3
ORDER BY location_count DESC;




-- 1️⃣5️⃣ Total Fraud Cases Per Branch

-- Count the number of flagged fraud transactions per branch.

select * from fraud_flags;
select * from transactions;

SELECT 
    b.branch_name,
    COUNT(f.transaction_id) AS total_fraud_cases
FROM branches b
JOIN accounts a
    ON b.branch_id = a.branch_id
JOIN transactions t
    ON a.account_id = t.account_id
JOIN fraud_flags f
    ON t.transaction_id = f.transaction_id
GROUP BY b.branch_name
ORDER BY total_fraud_cases DESC;