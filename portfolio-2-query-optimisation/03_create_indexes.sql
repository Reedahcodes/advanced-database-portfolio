-- Veltrix Digital Wallet: Indexes created to optimise queries
-- Portfolio 2: Query Processing and Optimisation

-- Composite index for Query 1 (wallet statement sorted by date)
CREATE INDEX idx_transactions_from_wallet_created
  ON transactions (from_wallet_id, created_at DESC);

-- Partial index for Query 2 (only failed transactions)
CREATE INDEX idx_transactions_failed_created
  ON transactions (created_at)
  WHERE status = 'failed';

-- Foreign key index for joins in Query 3
-- (PostgreSQL does not index foreign keys automatically)
CREATE INDEX idx_wallets_customer
  ON wallets (customer_id);

-- Refresh table statistics so the optimiser uses the new indexes wisely
ANALYZE transactions;
ANALYZE wallets;
