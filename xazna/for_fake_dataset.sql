SELECT COUNT(DISTINCT operation_code) FROM InfoP2P

SELECT TOP 10 sender_owner,SUM(debit) FROM InfoP2P
GROUP BY sender_owner
ORDER BY SUM(debit) DESC

SELECT COUNT(*) FROM InfoP2P
WHERE credit = 0

SELECT TOP 1 * FROM InfoP2P

-- table for fake datasets

CREATE VIEW AvgValues AS 
    SELECT 
        operation_code,
        sender_merchant,
        recipient_merchant,
        FORMAT(created_at, 'yyyy-MM') AS month,
        DATEPART(hour, created_at) AS hour,
        COUNT(*) AS count_hour,
        CONVERT(BIGINT, AVG(CAST(DATEDIFF(SECOND, created_at, updated_at) AS BIGINT))) AS time,
        CONVERT(DECIMAL(18,2), AVG(CAST(commission AS DECIMAL(18,2)))) AS commission,
        CONVERT(DECIMAL(18,2), AVG(CAST(debit AS DECIMAL(18,2)))) AS debit,
        CONVERT(DECIMAL(18,2), AVG(CAST(credit AS DECIMAL(18,2)))) AS credit,
        COUNT(DISTINCT username) AS new_users
    FROM InfoP2P
    WHERE MONTH(created_at) = 4
    GROUP BY 
        operation_code, sender_merchant, recipient_merchant, 
        FORMAT(created_at, 'yyyy-MM'), DATEPART(hour, created_at);


SELECT * FROM AvgValues;

-- debug overflow errors

--SELECT 
--    MAX(DATEDIFF(SECOND, created_at, updated_at)) AS max_diff,
--    MIN(DATEDIFF(SECOND, created_at, updated_at)) AS min_diff
--FROM InfoP2P;

--SELECT AVG(CAST(DATEDIFF(SECOND, created_at, updated_at) AS BIGINT)) AS avg_diff
--FROM InfoP2P;

--SELECT 
--    MAX(CAST(commission AS BIGINT)) AS max_commission, 
--    MIN(CAST(commission AS BIGINT)) AS min_commission, 
--    AVG(CAST(commission AS DECIMAL(18,2))) AS avg_commission
--FROM InfoP2P;


--SELECT 
--    MAX(debit) AS max_debit, 
--    MIN(debit) AS min_debit, 
--    AVG(debit) AS avg_debit
--FROM InfoP2P;

SELECT * INTO AvgValuesTable FROM AvgValues ;

SELECT * FROM AvgValuesTable

WITH ValuesTable AS
(SELECT 
	operation_code,
	sender_merchant,
	recipient_merchant,
	month,
	AVG(time) avg_transaction_time,
	CONVERT(INT,AVG(commission)) avg_commission,
	CONVERT(INT,AVG(debit)) avg_debit,
	CONVERT(INT,AVG(credit)) avg_credit,
	MAX(count_hour) max_hour,
	SUM(new_users) new_users
FROM AvgValuesTable
GROUP BY 
	operation_code,
	sender_merchant,
	recipient_merchant,
	month)

SELECT 
	V.operation_code,
	V.sender_merchant,
	V.recipient_merchant,
	V.month,
	A.hour,
	V.avg_transaction_time,
	A.new_users,
	V.avg_debit,
	V.avg_credit,
	V.avg_commission,
	V.max_hour transactions,
	CASE 
        WHEN LAG(V.new_users) OVER (ORDER BY V.month) > 0 
        THEN ROUND( (V.new_users - LAG(V.new_users) OVER (ORDER BY V.month)) * 100.0 / LAG(V.new_users) OVER (ORDER BY V.month), 2)
        ELSE NULL
    END AS user_growth_rate
FROM ValuesTable V
	LEFT JOIN AvgValuesTable A
	ON V.operation_code = A.operation_code
	AND V.sender_merchant = A.sender_merchant
	AND V.recipient_merchant = A.recipient_merchant
	AND V.month = A.month
	AND V.max_hour = A.count_hour
