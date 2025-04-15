--- daily,weekly and monthly transactions
USE XaznaP2P


SELECT 
	DATEPART(DATE,created_at) transaction_date,
	FORMAT(COUNT(debit),'N0') transaction_count,
	FORMAT(SUM(debit),'N0') total_sent,
	FORMAT(SUM(credit),'N0') total_received
FROM InfoP2P
GROUP BY DATEPART(DATE,created_at)
--ORDER BY Transaction_Date DESC;

SELECT 
	DATEPART(WEEK,created_at) transaction_date,
	FORMAT(COUNT(*),'N0') transaction_count,
	FORMAT(SUM(debit),'N0') total_sent,
	FORMAT(SUM(credit),'N0') total_received
FROM InfoP2P
GROUP BY DATEPART(WEEK,created_at)
ORDER BY transaction_date DESC;

SELECT 
	DATEPART(MONTH,created_at) transaction_date,
	FORMAT(COUNT(*),'N0') transaction_count,
	FORMAT(SUM(debit),'N0') total_sent,
	FORMAT(SUM(credit),'N0') total_received
FROM InfoP2P
GROUP BY DATEPART(MONTH,created_at)
ORDER BY transaction_date DESC;



CREATE VIEW JanuaryView AS
SELECT * FROM InfoP2P
WHERE MONTH(created_at) = 1

-- finding failed transactions
SELECT * FROM JanuaryView
WHERE debit IS NULL OR credit IS NULL


--- peak transactions hours
WITH CountTable AS
(SELECT 
	FORMAT(created_at,'yyyy-MM') month,
	DATENAME(WEEKDAY,created_at) weekday,
	FORMAT(created_at,'HH:00') hour,
	COUNT(debit) transactions 
FROM JanuaryView
GROUP BY 
	FORMAT(created_at,'yyyy-MM'),
	DATENAME(WEEKDAY,created_at),
	FORMAT(created_at,'HH:00'))

SELECT 
    month, 
    weekday, 
    hour
FROM (
    SELECT 
        month, 
        weekday, 
        hour, 
        transactions, 
        MAX(transactions) OVER (PARTITION BY month, weekday) AS max_transaction
    FROM CountTable
) t
WHERE transactions = max_transaction
ORDER BY 
    month, 
    weekday, 
    hour


--- frequent pairs

-- by debit
SELECT TOP 10 
    sender_owner, 
    recipient_owner, 
    FORMAT(SUM(debit), 'N0') AS debit, 
    COUNT(debit) AS transactions, 
    FORMAT(SUM(debit) / COUNT(debit), 'N0') AS avg_transaction
FROM JanuaryView
GROUP BY sender_owner, recipient_owner
ORDER BY SUM(debit) DESC, COUNT(debit) DESC;

-- by transactions count
SELECT TOP 10 
    sender_owner, 
    recipient_owner, 
    FORMAT(SUM(debit), 'N0') AS debit, 
    COUNT(debit) AS transactions, 
    FORMAT(SUM(debit) / COUNT(debit), 'N0') AS avg_transaction
FROM JanuaryView
GROUP BY sender_owner, recipient_owner
ORDER BY COUNT(debit) DESC, SUM(debit) DESC ;

-- multiple transactions in short interval
SELECT 
    sender_owner, 
	FORMAT(SUM(debit),'N0') debit,
	FORMAT(SUM(debit)/COUNT(debit),'N0') avg_transaction,
    COUNT(debit) transaction_count, 
    MIN(created_at) first_transaction, 
    MAX(created_at) last_transaction, 
    DATEDIFF(SECOND, MIN(created_at), MAX(created_at)) interval
FROM JanuaryView
GROUP BY sender_owner
HAVING COUNT(debit) > 5 AND DATEDIFF(SECOND, MIN(created_at), MAX(created_at)) < 300
ORDER BY transaction_count DESC;

SELECT 
    sender_owner, 
    COUNT(DISTINCT recipient_owner) AS unique_recipients, 
    SUM(debit) AS debit
FROM JanuaryView
GROUP BY sender_owner
HAVING COUNT(DISTINCT recipient_owner) > 10
ORDER BY unique_recipients DESC;

-- total earned commission
SELECT
	CAST(created_at as DATE) date,
	FORMAT(SUM(CAST(commission AS BIGINT)),'N0') commission
FROM JanuaryView
GROUP BY CAST(created_at as DATE)
ORDER BY CAST(created_at as DATE)

-- transactions by operation service
SELECT sender_service, recipient_service, COUNT(debit) transactions, FORMAT(SUM(CAST(debit AS BIGINT)),'N0') debit
FROM JanuaryView
GROUP BY sender_service, recipient_service
ORDER BY COUNT(debit) DESC


-- avg transaction summa per user
SELECT FORMAT(SUM(CAST(debit AS BIGINT))/COUNT(DISTINCT username),'N0') avg_debit FROM JanuaryView;

-- most long consecutive day transfers
WITH transfer_data AS (
	SELECT username, created_at, ROW_NUMBER() OVER(PARTITION BY username ORDER BY created_at) AS rn
	FROM JanuaryView),
minus_date AS (
	SELECT username, DATEADD(DAY, -rn, created_at) AS streak
	FROM transfer_data),
counting AS (
	SELECT username, COUNT(*) AS consecutive
	FROM minus_date
	GROUP BY username, streak)
SELECT username, MAX(consecutive) AS most_consecutive_days
FROM counting
GROUP BY username
ORDER BY MAX(consecutive) DESC

SELECT COUNT(*) FROM InfoP2P

SELECT OBJECT_ID('dbo.AvgValues', 'V')
