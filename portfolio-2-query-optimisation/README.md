# Portfolio 2: Query Processing and Optimisation

## Goal

To measure how PostgreSQL executes realistic Veltrix queries, add indexes where they help, and analyse the performance before and after.

## Dataset

To make performance differences measurable, `01_generate_data.sql` generated 10,000 customers, 10,004 wallets and 200,000 transactions using `generate_series()` and `random()`. Balances are random test values and are not reconciled with transactions, because this data is for performance testing only.

## Method

1. Ran four queries with `EXPLAIN ANALYZE` before adding any indexes (`02_queries_before_indexes.sql`).
2. Created three indexes (`03_create_indexes.sql`) and ran `ANALYZE` to refresh table statistics.
3. Re-ran the same queries and compared execution plans and times.
4. Each query was run several times, and the figures below come from the uploaded screenshots.

## Indexes created

| Index | Type | Purpose |
|---|---|---|
| idx_transactions_from_wallet_created | Composite (from_wallet_id, created_at DESC) | Find one wallet's transactions in date order |
| idx_transactions_failed_created | Partial (WHERE status = 'failed') | Find recent failed transactions; only indexes failed rows, so it is smaller |
| idx_wallets_customer | Foreign key index | Support joins between customers and wallets; PostgreSQL does not index foreign keys automatically |

## Results

| Query | Before | After | Plan change |
|---|---|---|---|
| 1. Wallet statement | __ ms | 0.068 ms | Parallel Seq Scan → Bitmap Index Scan |
| 2. Failed transactions (30 days) | __ ms | 6.954 ms | Parallel Seq Scan → Bitmap Index Scan on partial index |
| 3. Top 10 senders (90 days) | __ ms | 136.050 ms | No change: Seq Scan kept |
| 4. Customer lookup by email | 3.852 ms | Not re-run | Already used the automatic UNIQUE index |

## Analysis

**Query 1** improved the most. Before indexing, PostgreSQL read all 200,000 transactions to find just 19 belonging to wallet 500. With the composite index, it went directly to those 19 rows (Heap Blocks: exact=19).

**Query 2** also improved significantly. The plan's Index Cond only checks `created_at`, because the partial index contains failed transactions only, so status does not need to be re-checked during the index search. The gain is smaller than Query 1 because about 2,350 rows are returned from 1,341 different table blocks, which is more real work. The row count also dropped from 2,553 to 2,353 between runs, because the 30-day window moved forward and older failed transactions fell outside it.

**Query 3** did not improve, and the optimiser was right. The query keeps about 30,000 of 200,000 transactions (Rows Removed by Filter: 169,171) and needs every customer's wallet. When a query needs a large fraction of a table, reading it sequentially is faster than jumping through an index thousands of times. PostgreSQL's cost-based optimiser used the refreshed statistics to make this choice.

**Query 4** shows that PostgreSQL automatically creates indexes for primary keys and UNIQUE constraints (here `customers_email_key`), but not for foreign keys.

## Trade-offs of indexing

Indexes use extra disk space and slow down INSERT and UPDATE operations slightly, because each index must be updated as well. For Veltrix, the read speed-up on statements and support queries justifies this cost, but indexes should only be created for columns that important queries actually filter, join or sort on.

## Lessons learned

- Indexes help most when a query needs a small fraction of a large table.
- A partial index can target a specific subset of data efficiently.
- The optimiser may correctly choose not to use an index.
- Execution times vary between runs, so queries should be run more than once.
