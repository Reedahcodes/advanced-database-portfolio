-- Veltrix Digital Wallet: Large dataset generation
-- Portfolio 2: Query Processing and Optimisation
-- Generates enough data for indexing to make a measurable difference.
-- Note: balances are random test values and are not reconciled
-- with transactions; this data is for performance testing only.

-- Step 1: 10,000 customers
INSERT INTO customers (full_name, email, phone, date_joined)
SELECT
  'Customer ' || i,
  'customer' || i || '@veltrix.test',
  '080' || lpad(i::text, 8, '0'),
  CURRENT_DATE - (random() * 1000)::int
FROM generate_series(1, 10000) AS i;

-- Step 2: one wallet per new customer
INSERT INTO wallets (customer_id, balance)
SELECT customer_id, round((random() * 500000)::numeric, 2)
FROM customers
WHERE customer_id > 3;

-- Step 3: 200,000 transactions between random wallets
-- Repeated values in the arrays make transfers and completed
-- transactions more likely, reflecting real usage.
INSERT INTO transactions (from_wallet_id, to_wallet_id, amount, type, status, created_at)
SELECT
  CASE WHEN t.kind = 'deposit' THEN NULL ELSE t.w1 END,
  CASE WHEN t.kind = 'withdrawal' THEN NULL ELSE t.w2 END,
  round((random() * 99000 + 100)::numeric, 2),
  t.kind,
  (ARRAY['completed','completed','completed','completed','failed','pending'])[1 + floor(random() * 6)::int],
  now() - (random() * interval '365 days')
FROM (
  SELECT
    w.ids[1 + floor(random() * array_length(w.ids, 1))::int] AS w1,
    w.ids[1 + floor(random() * array_length(w.ids, 1))::int] AS w2,
    (ARRAY['deposit','withdrawal','transfer','transfer','payment'])[1 + floor(random() * 5)::int] AS kind
  FROM generate_series(1, 200000),
       (SELECT array_agg(wallet_id) AS ids FROM wallets) AS w
) AS t;

-- Step 4: verify row counts
SELECT
  (SELECT count(*) FROM customers)    AS customers,
  (SELECT count(*) FROM wallets)      AS wallets,
  (SELECT count(*) FROM transactions) AS transactions;
