// Veltrix Digital Wallet: Graph model for fraud detection
// Portfolio 4: NoSQL and Advanced Data Models
// Database: Neo4j AuraDB Free | Query language: Cypher

// 1. Normal customers (same people and balances as PostgreSQL)
CREATE (ada:Customer {customer_id: 1, name: 'Ada Bello'}),
       (tunde:Customer {customer_id: 2, name: 'Tunde Okafor'}),
       (w1:Wallet {wallet_id: 1, balance: 35000}),
       (w2:Wallet {wallet_id: 2, balance: 24000}),
       (ada)-[:OWNS]->(w1),
       (tunde)-[:OWNS]->(w2),
       (w1)-[:SENT {amount: 5000}]->(w2);

// 2. Simulated fraud ring: three customers share one phone
//    and pass money around in a circle
CREATE (phone:Device {device_id: 'DEV-777', model: 'Infinix Hot 30'}),
       (musa:Customer {customer_id: 101, name: 'Musa Ibrahim'}),
       (kemi:Customer {customer_id: 102, name: 'Kemi Adeyemi'}),
       (bayo:Customer {customer_id: 103, name: 'Bayo Olatunji'}),
       (w101:Wallet {wallet_id: 101, balance: 5000}),
       (w102:Wallet {wallet_id: 102, balance: 5000}),
       (w103:Wallet {wallet_id: 103, balance: 5000}),
       (musa)-[:OWNS]->(w101),
       (kemi)-[:OWNS]->(w102),
       (bayo)-[:OWNS]->(w103),
       (musa)-[:USES]->(phone),
       (kemi)-[:USES]->(phone),
       (bayo)-[:USES]->(phone),
       (w101)-[:SENT {amount: 200000}]->(w102),
       (w102)-[:SENT {amount: 200000}]->(w103),
       (w103)-[:SENT {amount: 200000}]->(w101);

// 3. View the whole graph
MATCH (a)-[r]->(b) RETURN a, r, b;

// 4. Fraud check 1: devices shared by more than one customer
MATCH (c:Customer)-[:USES]->(d:Device)
WITH d, collect(c.name) AS customers, count(c) AS number_of_customers
WHERE number_of_customers > 1
RETURN d.device_id AS device, number_of_customers, customers;

// 5. Fraud check 2: money that travels in a circle (2 to 5 transfers)
MATCH path = (w:Wallet)-[:SENT*2..5]->(w)
RETURN [n IN nodes(path) | n.wallet_id] AS money_circle,
       length(path) AS number_of_transfers;
