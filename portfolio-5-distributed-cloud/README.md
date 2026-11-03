# Portfolio 5: Distributed and Cloud Database Exercise

## Goal

To deploy the Veltrix database to the cloud and explain how replication, sharding, availability and consistency would apply as Veltrix grows.

## Part 1: Cloud Deployment

Veltrix was deployed to **Neon**, a serverless cloud PostgreSQL service, using the Free plan.

| Setting | Value |
|---|---|
| Project | veltrix |
| Branch | production |
| Region | AWS Europe Central 1 (Frankfurt) |
| Database engine | PostgreSQL |

**Steps taken**
1. Created the `veltrix` project in Frankfurt, the closest available region to Nigeria, to reduce latency for Nigerian users.
2. Ran `01_create_tables.sql` from Portfolio 1 in the Neon SQL Editor: 1 DROP and 6 CREATE statements completed successfully in 175 ms.
3. Ran `02_sample_data.sql`: 3 customers, 4 wallets, 1 merchant and 3 devices inserted.
4. Ran a verification query (`01_cloud_deployment.sql`) joining customers and wallets, which returned Ada Bello, Tunde Okafor and Zainab Musa with their NGN balances in 158 ms.

The cloud database was built from the same scripts as the local database, so it contains the starting balances rather than the balances changed during the Portfolio 3 experiments. This shows that the design can be redeployed reliably from version-controlled scripts.

**Observation:** Neon shows the compute as "Idle" when unused and wakes it automatically on the next query. This scale-to-zero behaviour reduces cost, with a short delay on the first query after a quiet period.

## Part 2: Distributed Database Concepts for Veltrix

### Replication

Replication keeps copies of the database on more than one server. A primary server handles all writes, and read replicas receive copies of the changes.

- **Availability:** if the primary fails, a replica can be promoted, so Veltrix stays online.
- **Performance:** read-heavy work, such as statements and reports, can run on replicas, reducing load on the primary.

For Veltrix, replication is the first scaling step, because wallet balances must stay safe and the service must remain available.

### Sharding

Sharding splits data across several servers, for example customers 1 to 1,000,000 on one shard and the next million on another. Each shard holds only part of the data, so the system can grow far beyond one server.

The main challenge for Veltrix is that a transfer between two customers on different shards becomes a distributed transaction, which is slower and harder to keep atomic than the single-server transactions shown in Portfolio 3. Sharding should therefore only be introduced when a single primary with replicas can no longer handle the load. If needed, sharding by customer_id would keep each customer's wallets and transactions together on one shard.

### Consistency and the CAP Theorem

When data is copied between servers, there is a short delay before every copy is updated. The CAP theorem states that, during a network failure between servers, a distributed system must choose between consistency (every read returns the latest data) and availability (every request receives a response).

| Data | Choice | Reason |
|---|---|---|
| Wallet balances and transfers | Strong consistency | A customer must never see or spend an outdated balance |
| Transaction history and statements | Read from replicas | A delay of a few seconds is acceptable |
| Analytics, fraud reports and notifications | Eventual consistency | Speed matters more than instant accuracy |

## Recommended Architecture for Veltrix

1. **Now:** a single cloud PostgreSQL primary in the closest region, deployed from version-controlled scripts.
2. **Growth:** add read replicas for statements and reporting, with automatic failover for availability.
3. **Large scale:** shard by customer_id only when necessary, keeping balance updates strongly consistent.
4. **Alongside:** Neo4j for fraud analytics (Portfolio 4), fed from PostgreSQL, which remains the system of record.

## Limitations

- Only the schema and sample data were deployed, not the 200,000 test transactions from Portfolio 2, to stay within the Free plan's storage.
- Replication and sharding are discussed rather than configured, because these features are limited on the Free plan.
- Frankfurt adds network latency for users in Nigeria, which a regional data centre or local caching could reduce.

## Lessons Learned

- A cloud database can be created and populated in minutes from existing scripts.
- Replication improves availability and read performance, while sharding improves capacity at the cost of complexity.
- Financial data needs strong consistency, while reports and analytics can accept eventual consistency.
