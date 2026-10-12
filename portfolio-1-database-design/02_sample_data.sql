-- Veltrix Digital Wallet: Sample data
-- Portfolio 1: Inserts starter records to test the design

INSERT INTO customers (full_name, email, phone) VALUES
  ('Ada Bello',    'ada.bello@example.com',    '08031234567'),
  ('Tunde Okafor', 'tunde.okafor@example.com', '08029876543'),
  ('Zainab Musa',  'zainab.musa@example.com',  '09011122233');

-- Wallet 4 has no customer because it belongs to a merchant
INSERT INTO wallets (customer_id, balance) VALUES
  (1, 50000), (2, 12000), (3, 0),
  (NULL, 0);

INSERT INTO merchants (business_name, category, wallet_id)
VALUES ('Mama Put Kitchen', 'Food', 4);

INSERT INTO devices (customer_id, device_type, last_login) VALUES
  (1, 'iPhone 13',   now()),
  (1, 'Tecno Spark', now()),
  (2, 'Samsung A14', now());
