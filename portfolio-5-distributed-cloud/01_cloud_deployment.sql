-- Veltrix Digital Wallet: Cloud deployment on Neon (serverless PostgreSQL)
-- Portfolio 5: Distributed and Cloud Database Exercise
--
-- Deployment steps:
-- 1. Created a Neon project named "veltrix" (Free plan) in a European AWS region,
--    the closest available option to Nigeria.
-- 2. Ran portfolio-1-database-design/01_create_tables.sql in the Neon SQL Editor
--    (1 DROP + 6 CREATE statements, all successful).
-- 3. Ran portfolio-1-database-design/02_sample_data.sql
--    (3 customers, 4 wallets, 1 merchant, 3 devices inserted).
-- 4. Verified the deployment with the query below.

-- Verification: customers and their wallets, served from the cloud
SELECT c.full_name, w.wallet_id, w.balance, w.currency
FROM customers c
JOIN wallets w ON w.customer_id = c.customer_id
ORDER BY c.customer_id;
