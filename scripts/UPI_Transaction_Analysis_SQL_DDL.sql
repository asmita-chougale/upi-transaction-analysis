SET sql_mode = 'STRICT_ALL_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO';
DROP DATABASE IF EXISTS upi_analytics;
CREATE DATABASE upi_analytics CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE upi_analytics;

CREATE TABLE customer_master (
  customer_id VARCHAR(10) PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  age INT NOT NULL,
  gender ENUM('male', 'female', 'other') NOT NULL,
  region ENUM('central', 'east', 'west', 'north', 'south') NOT NULL,
  date_joined DATE NOT NULL,
  is_business_user BOOLEAN NOT NULL,
  risk_score DECIMAL(3, 2) NOT NULL DEFAULT 0.00,
  mobile_number VARCHAR(10) NOT NULL,
  CONSTRAINT check_age_range CHECK (age >= 18 AND age <= 100),
  CONSTRAINT check_customer_master_risk_score_range CHECK (risk_score >= 0.00 AND risk_score <= 1.00),
  CONSTRAINT UK_customer_master_mobile_number UNIQUE(mobile_number)
) ENGINE=InnoDB;

CREATE TABLE device_info (
  device_id VARCHAR(10) PRIMARY KEY,
  customer_id VARCHAR(10) NOT NULL,
  device_type VARCHAR(20) NOT NULL CHECK (device_type IN ('android', 'feature_phone', 'ios', 'tablet')),
  app_version VARCHAR(10) NOT NULL,
  is_rooted BOOLEAN NOT NULL,
  last_active DATETIME NOT NULL,
  CONSTRAINT fk_device_info_customer_id FOREIGN KEY (customer_id) 
    REFERENCES customer_master(customer_id)
) ENGINE=InnoDB;

CREATE TABLE upi_account_details (
  upi_id VARCHAR(30) PRIMARY KEY,
  customer_id VARCHAR(10) NOT NULL,
  bank_name VARCHAR(30) NOT NULL,
  account_type VARCHAR(30) NOT NULL CHECK (account_type IN ('savings','current','credit_card_linked')),
  date_added DATE NOT NULL,
  status ENUM ('active','blocked','suspended') NOT NULL,
  CONSTRAINT fk_upi_account_details_customer_id FOREIGN KEY (customer_id)
	REFERENCES customer_master(customer_id)
) ENGINE=InnoDB;

CREATE TABLE merchant_info (
	merchant_id VARCHAR(10) PRIMARY KEY,
    merchant_name VARCHAR(100) NOT NULL,
    merchant_type ENUM ('grocery','online','food','electronics','apparel','transport') NOT NULL,
    region ENUM('central', 'east', 'west', 'north', 'south') NOT NULL,
    onboard_date DATE NOT NULL,
    risk_score DECIMAL(3, 2) NOT NULL DEFAULT 0.00,
    CONSTRAINT check_merchant_info_risk_score_range CHECK (risk_score >= 0.00 AND risk_score <= 1.00)
) ENGINE=InnoDB;

CREATE TABLE upi_transaction_history (
	transaction_id VARCHAR(15) PRIMARY KEY,
    upi_id VARCHAR(30) NOT NULL,
    customer_id VARCHAR(10) NOT NULL,
    timestamp DATETIME NOT NULL,
    amount DECIMAL(6,2) NOT NULL,
    transaction_type ENUM ('send','receive','merchant_payment','bill_pay') NOT NULL,
    merchant_id VARCHAR(10), 
    counterparty_upi VARCHAR(30) NOT NULL,
    status ENUM ('success','failed','pending') NOT NULL,
    device_id VARCHAR(10) NOT NULL,
    device_type VARCHAR(20) NOT NULL CHECK (device_type IN ('android', 'feature_phone', 'ios', 'tablet')),
    channel ENUM ('app','intent','qr_code') NOT NULL,
    fraud_flag BOOLEAN NOT NULL,
    reversal_flag BOOLEAN NOT NULL,
    failure_reason VARCHAR(1000),
    CONSTRAINT fk_upi_transaction_history_upi_id FOREIGN KEY (upi_id)
		REFERENCES upi_account_details(upi_id),
	CONSTRAINT fk_upi_transaction_history_customer_id FOREIGN KEY (customer_id)
		REFERENCES customer_master(customer_id),
	CONSTRAINT fk_upi_transaction_history_merchant_id FOREIGN KEY (merchant_id)
		REFERENCES merchant_info(merchant_id),
	CONSTRAINT fk_upi_transaction_history_device_id FOREIGN KEY (device_id)
		REFERENCES device_info(device_id),
	CONSTRAINT chk_failure_detail CHECK (
        (status = 'failed' AND (failure_reason IS NOT NULL OR LENGTH(failure_reason) > 0)) 
        OR 
        (status <> 'failed' AND (failure_reason IS NULL OR LENGTH(failure_reason) = 0))
    )
)ENGINE=InnoDB;

CREATE TABLE customer_feedback_surveys (
	feedback_id VARCHAR(15) PRIMARY KEY,
	customer_id VARCHAR(10) NOT NULL,
    date_submitted DATE NOT NULL,
    feedback_text VARCHAR(1000) NOT NULL,
    satisfaction_score TINYINT NOT NULL,
    issue_type ENUM ('app_usability','fraud','other','transaction') NOT NULL,
    resolved BOOLEAN NOT NULL,
	CONSTRAINT fk_customer_feedback_surveys_customer_id FOREIGN KEY (customer_id)
		REFERENCES customer_master(customer_id),
	CONSTRAINT check_customer_feedback_satisfaction_score_range CHECK (satisfaction_score >= 1 AND satisfaction_score <= 5)
)ENGINE=InnoDB;

CREATE TABLE fraud_alert_history (
	alert_id VARCHAR(15) PRIMARY KEY,
    transaction_id VARCHAR(15) NOT NULL, 
    alert_type ENUM ('frequent_failure','suspicious_login','unusual_amount','unusual_time') NOT NULL,
    alert_date DATETIME NOT NULL,
    resolved BOOLEAN NOT NULL,
    resolution_date DATETIME,
    remarks VARCHAR(1000) NOT NULL,
    CONSTRAINT fk_fraud_alert_history_transaction_id FOREIGN KEY (transaction_id)
		REFERENCES upi_transaction_history(transaction_id)
)ENGINE=InnoDB;

