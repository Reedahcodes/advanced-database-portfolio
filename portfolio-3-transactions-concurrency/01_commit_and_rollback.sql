-- Veltrix Digital Wallet: Transactions with COMMIT and ROLLBACK
-- Portfolio 3: Transactions and Concurrency

-- Check balances before
SELECT wallet_id, balance FROM wallets WHERE wallet_id IN (1, 2);

-- Successful transfer: Ada (wallet 1) sends Tunde (wallet 2) 5,000
-- Both updates and the transaction record succeed together, then COMMIT
BEGIN;
UPDATE wallets SET balance = balance - 5000 WHERE wallet_id = 1;
UPDATE wallets SET balance = balance + 5000 WHERE wallet_id = 2;
INSERT INTO transactions (from_wallet_id, to_wallet_id, amount, type, status)
VALUES (1, 2, 5000, 'transfer', 'completed');
COMMIT;

-- Failed transfer: Zainab (wallet 3, balance 0) tries to send Ada 10,000
-- Ada is credited first, then the debit violates CHECK (balance >= 0)
BEGIN;
UPDATE wallets SET balance = balance + 10000 WHERE wallet_id = 1;
UPDATE wallets SET balance = balance - 10000 WHERE wallet_id = 3;
COMMIT;

-- Cancel the failed transaction so Ada's credit is undone
ROLLBACK;

-- Verify: Ada's balance is unchanged and Zainab is still 0
SELECT wallet_id, balance FROM wallets WHERE wallet_id IN (1, 3);
