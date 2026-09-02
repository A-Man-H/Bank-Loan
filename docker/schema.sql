-- Schema for the Ensah Bank JavaFX app.
-- Derived from the SQL statements in Bank/src/application/*.java.
-- Loaded automatically by the MySQL container on first startup
-- (mounted into /docker-entrypoint-initdb.d).
CREATE DATABASE IF NOT EXISTS bank;
USE bank;

CREATE TABLE IF NOT EXISTS information (
  Id       INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100),
  fname    VARCHAR(100),
  lname    VARCHAR(100),
  phoneno  VARCHAR(30),
  email    VARCHAR(150),
  dob      VARCHAR(30),
  gender   VARCHAR(20),
  Balance  FLOAT DEFAULT 0,
  credit   FLOAT DEFAULT 0,
  Status   VARCHAR(40)
);

CREATE TABLE IF NOT EXISTS login (
  Id       INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100),
  email    VARCHAR(150),
  password VARCHAR(150)
);

CREATE TABLE IF NOT EXISTS operations (
  OpId      INT AUTO_INCREMENT PRIMARY KEY,
  Id        INT,
  fname     VARCHAR(100),
  lname     VARCHAR(100),
  operation VARCHAR(50),
  `date`    VARCHAR(30),
  amount    FLOAT
);

CREATE TABLE IF NOT EXISTS credits (
  CreditId INT AUTO_INCREMENT PRIMARY KEY,
  Id       INT,
  `month`  FLOAT,
  amount   FLOAT,
  pricem   FLOAT,
  `date`   VARCHAR(30)
);
