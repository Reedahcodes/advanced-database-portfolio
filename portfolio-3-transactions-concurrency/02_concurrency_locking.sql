-- Veltrix Digital Wallet: Concurrency control with row-level locking
-- Portfolio 3: Transactions and Concurrency
-- Run in TWO separate Query Tool sessions to simulate two users
-- withdrawing from Tunde's wallet (wallet 2) at the same time.

-- Starting balance of wallet 2: 27,000

-- SESSION A (Person A): start a withdrawal but do not commit yet
BEGIN;
UPDATE wallets SET balance = balance - 1000 WHERE wallet_id = 2;
-- Session A now holds a row-level lock on wallet 2

-- SESSION B (Person B): try to withdraw from the same wallet
UPDATE wallets SET balance = balance - 2000 WHERE wallet_id = 2;
-- Session B WAITS because the row is locked by Session A
-- (observed waiting time: 3 min 21 secs)

-- SESSION A: finish the withdrawal
COMMIT;
-- The lock is released, and Session B's update completes immediately

-- Verify the final balance: 27,000 - 1,000 - 2,000 = 24,000
SELECT wallet_id, balance FROM wallets WHERE wallet_id = 2;
