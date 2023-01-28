-- Top 10 members by spending

SELECT item_id, COUNT(id) AS frequency
FROM transactions
WHERE status NOT IN ('cancelled')
GROUP BY item_id
ORDER BY 2 DESC
LIMIT 10;