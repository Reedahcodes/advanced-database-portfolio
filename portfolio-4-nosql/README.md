# Portfolio 4: NoSQL and Advanced Data Models

## Goal

To model part of the Veltrix case study in a NoSQL database and show where a non-relational model is more suitable than PostgreSQL. A graph database (Neo4j) was chosen to detect fraud patterns between customers, devices and wallets.

## Tools

Neo4j AuraDB Free (cloud), queried with Cypher in the Neo4j Aura Query tool.

## Files

| File | Purpose |
|---|---|
| 01_veltrix_graph.cypher | Creates the graph and runs the fraud detection queries |
| 01_neo4j_instance_running.png | Free Neo4j instance running in the cloud |
| 02_first_graph.png | Normal customers, wallets and a transfer as a graph |
| 03_fraud_ring_graph.png | Full graph showing the simulated fraud ring |
| 04_shared_device_query.png | Query result: one device shared by three customers |
| 05_circular_transfers_query.png | Query result: money moving in a circle |

## Graph model

| Element | Type | Meaning |
|---|---|---|
| Customer | Node | A Veltrix user (customer_id, name) |
| Wallet | Node | A wallet holding money (wallet_id, balance) |
| Device | Node | A phone used to log in (device_id, model) |
| OWNS | Relationship | Customer → Wallet |
| USES | Relationship | Customer → Device |
| SENT | Relationship | Wallet → Wallet, with an amount |

Ada Bello and Tunde Okafor use the same customer IDs and balances as the PostgreSQL database, so the case study stays consistent across portfolios.

## Scenario

A simulated fraud ring was added: three customers (Musa, Kemi and Bayo) appear to be separate people, but all log in from the same device (DEV-777) and pass 200,000 around in a circle (wallet 101 → 102 → 103 → 101). Circular transfers like this are a common way to make accounts look active and legitimate.

## Results

**Fraud check 1: shared devices.** The query found DEV-777 used by 3 customers (Musa Ibrahim, Kemi Adeyemi and Bayo Olatunji) in 24 ms. Ada and Tunde were correctly not flagged, because they do not share a device.

**Fraud check 2: circular transfers.** Using a variable-length pattern `[:SENT*2..5]`, the query found the loop 101 → 102 → 103 → 101 in 38 ms. It returned three rows, which are the same circle seen from each of its three starting wallets. Ada's one-way transfer to Tunde was correctly not flagged.

## Why a graph database suits this problem

- **Relationships are stored directly.** In PostgreSQL, connections are rebuilt at query time with joins. In Neo4j, each relationship is stored as a direct link, so following connections is fast.
- **Multi-step patterns are simple to express.** Finding a loop of unknown length takes one line in Cypher (`[:SENT*2..5]`). In SQL, the same search needs a recursive common table expression, which is longer and harder to read.
- **The data is easy to see.** The fraud ring is visible immediately in the graph view, which helps analysts investigate.

## Limitations and design decision

A graph database is not a replacement for PostgreSQL in Veltrix. Balances and transfers need strict ACID transactions, constraints and reporting, which PostgreSQL handles well (Portfolio 3). The recommended design is polyglot persistence: PostgreSQL remains the system of record for money, while Neo4j is used alongside it for fraud analytics.

The free Neo4j instance pauses after a few days of inactivity, so the screenshots and script in this folder serve as the permanent evidence.

## Lessons learned

- Choosing a data model depends on the questions being asked: tables for transactions and reporting, graphs for connected patterns.
- Variable-length path queries make network patterns such as circular transfers easy to detect.
- Using the same customers in both databases keeps the case study consistent.
