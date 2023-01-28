-- Top 10 members by spending

SELECT member_id, SUM(item_total_price) AS total_spending
FROM transactions
WHERE status NOT IN ('cancelled')
GROUP BY member_id
ORDER BY 2 DESC
LIMIT 10;