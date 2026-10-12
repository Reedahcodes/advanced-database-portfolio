-- Veltrix Digital Wallet: Constraint tests
-- Portfolio 1: Each insert below is EXPECTED TO FAIL,
-- proving the constraints protect the data.

-- Test 1: UNIQUE constraint rejects a duplicate email
INSERT INTO customers (full_name, email, phone)
VALUES ('Fake Ada', 'ada.bello@example.com', '07000000000');

-- Test 2: CHECK constraint rejects a negative balance
INSERT INTO wallets (customer_id, balance) VALUES (1, -500);

-- Test 3: FOREIGN KEY rejects a wallet for a non-existent customer
INSERT INTO wallets (customer_id) VALUES (99);
