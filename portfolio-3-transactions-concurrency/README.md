# Portfolio 3: Transactions and Concurrency

## Goal

To demonstrate how PostgreSQL keeps Veltrix's money safe using transactions (COMMIT and ROLLBACK) and how it controls concurrent access to the same wallet using row-level locking.

## Files

| File | Purpose |
|---|---|
| 01_commit_and_rollback.sql | A successful transfer with COMMIT, and a failed transfer undone with ROLLBACK |
| 02_concurrency_locking.sql | Two sessions withdrawing from the same wallet at the same time |
| 1_balances_before.png to 05_balances_after_rollback.png | Evidence for COMMIT and ROLLBACK |
| 06_personA_update.png to 09_final_balance.png | Evidence for concurrency locking |

## Part 1: COMMIT (a successful transfer)

A transfer must take money from one wallet and add it to another. If only one step happened, money would be lost or created. Wrapping both updates and the transaction record in `BEGIN ... COMMIT` makes them atomic: all succeed together or none do.

- Before: Ada (wallet 1) had 50,000 and Tunde (wallet 2) had 12,000, a total of 62,000.
- The transfer script was accidentally executed three times, moving 15,000 in total.
- After: Ada had 35,000 and Tunde had 27,000, still a total of 62,000.

Even with repeated execution, every transfer moved money consistently and no money was created or lost.

## Part 2: ROLLBACK (a failed transfer)

Zainab (wallet 3) had a balance of 0 and attempted to send Ada 10,000. The script credited Ada first, then tried to debit Zainab.

- The debit violated the `CHECK (balance >= 0)` constraint from Portfolio 1, causing an error.
- `ROLLBACK` cancelled the entire transaction, including Ada's credit.
- After: Ada still had 35,000 and Zainab still had 0.

This demonstrates atomicity: a partial transfer was never saved, even though one of its steps had already run.

## Part 3: Concurrency control (two users, one wallet)

Two pgAdmin Query Tool sessions simulated two people withdrawing from Tunde's wallet (balance 27,000) at the same time.

1. **Session A** ran `BEGIN` and withdrew 1,000, but did not commit. This placed a row-level lock on wallet 2.
2. **Session B** tried to withdraw 2,000 from the same wallet. It did not fail; it waited, showing "Waiting for the query to complete".
3. **Session A** ran `COMMIT`, releasing the lock.
4. **Session B** completed immediately afterwards. Its message showed it had waited 3 min 21 secs.
5. The final balance was 24,000 (27,000 - 1,000 - 2,000), so both withdrawals were applied correctly.

## Isolation level

PostgreSQL's default isolation level is Read Committed. Under this level, a session only sees data that other transactions have committed. When Session B was released, it re-read wallet 2's committed balance (26,000) before subtracting 2,000, which is why the final result was correct.

Without locking, both sessions could read 27,000 at the same time and each write their own result, causing a "lost update" where one withdrawal disappears. Row-level locking prevents this.

## ACID properties demonstrated

| Property | Where it was shown |
|---|---|
| Atomicity | The failed transfer was rolled back completely |
| Consistency | The CHECK constraint prevented a negative balance |
| Isolation | Session B waited for Session A and only saw committed data |
| Durability | Committed balances remained after the sessions ended |

## Lessons learned

- Related changes must be grouped in one transaction so they succeed or fail together.
- Constraints and transactions work together: the constraint detects the problem and the rollback undoes the partial work.
- Row-level locks make concurrent users wait rather than overwrite each other.
- Running a script multiple times by mistake changes data each time, so financial scripts should be executed carefully.
