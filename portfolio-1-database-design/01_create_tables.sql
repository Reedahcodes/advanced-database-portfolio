-- Veltrix Digital Wallet: Table creation script
-- Portfolio 1: Database Design and Modelling
-- Creates 6 tables with primary keys, foreign keys and constraints


DROP TABLE IF EXISTS audit_logs, transactions, devices, merchants, wallets, customers CASCADE;

CREATE TABLE customers (
  customer_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  full_name    VARCHAR(100) NOT NULL,
  email        VARCHAR(150) NOT NULL UNIQUE,
  phone        VARCHAR(20)  NOT NULL UNIQUE,
  date_joined  DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE wallets (
  wallet_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id  INT REFERENCES customers(customer_id),
  balance      NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
  currency     CHAR(3) NOT NULL DEFAULT 'NGN',
  status       VARCHAR(10) NOT NULL DEFAULT 'active'
               CHECK (status IN ('active', 'frozen', 'closed'))
);

CREATE TABLE merchants (
  merchant_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  business_name  VARCHAR(150) NOT NULL,
  category       VARCHAR(50)  NOT NULL,
  wallet_id      INT NOT NULL UNIQUE REFERENCES wallets(wallet_id)
);

CREATE TABLE devices (
  device_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id  INT NOT NULL REFERENCES customers(customer_id),
  device_type  VARCHAR(50) NOT NULL,
  last_login   TIMESTAMP
);

CREATE TABLE transactions (
  transaction_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  from_wallet_id  INT REFERENCES wallets(wallet_id),
  to_wallet_id    INT REFERENCES wallets(wallet_id),
  amount          NUMERIC(14,2) NOT NULL CHECK (amount > 0),
  type            VARCHAR(12) NOT NULL
                  CHECK (type IN ('deposit', 'withdrawal', 'transfer', 'payment')),
  status          VARCHAR(10) NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'completed', 'failed', 'reversed')),
  created_at      TIMESTAMP NOT NULL DEFAULT now(),
  CHECK (from_wallet_id IS NOT NULL OR to_wallet_id IS NOT NULL)
);

CREATE TABLE audit_logs (
  log_id          INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  transaction_id  INT NOT NULL REFERENCES transactions(transaction_id),
  action          VARCHAR(50) NOT NULL,
  performed_by    VARCHAR(100) NOT NULL,
  logged_at       TIMESTAMP NOT NULL DEFAULT now()
);
