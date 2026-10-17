-- Veltrix Digital Wallet: Queries measured BEFORE adding indexes
-- Portfolio 2: Query Processing and Optimisation

-- Query 1: customer statement (transactions sent from one wallet)
EXPLAIN ANALYZE
SELECT * FROM transactions
WHERE from_wallet_id = 500
ORDER BY created_at DESC;

-- Query 2: failed transactions in the last 30 days
EXPLAIN ANALYZE
SELECT * FROM transactions
WHERE status = 'failed'
  AND created_at >= now() - interval '30 days';

-- Query 3: top 10 senders in the last 90 days
EXPLAIN ANALYZE
SELECT c.customer_id, c.full_name, SUM(t.amount) AS total_sent
FROM customers c
JOIN wallets w      ON w.customer_id = c.customer_id
JOIN transactions t ON t.from_wallet_id = w.wallet_id
WHERE t.created_at >= now() - interval '90 days'
  AND t.status = 'completed'
GROUP BY c.customer_id, c.full_name
ORDER BY total_sent DESC
LIMIT 10;

-- Query 4: customer lookup by email (already indexed via UNIQUE)
EXPLAIN ANALYZE
SELECT * FROM customers
WHERE email = 'customer500@veltrix.test';
