LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\customer_master.csv'
INTO TABLE customer_master 
FIELDS TERMINATED BY ',' 
IGNORE 1 LINES -- Add this if your CSV has a header row
(customer_id, full_name, mobile_number, age, gender, region, date_joined, @temp_bool, risk_score ) 
SET is_business_user = IF(@temp_bool = 'TRUE', TRUE, FALSE);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\device_info.csv'
INTO TABLE device_info 
FIELDS TERMINATED BY ',' 
IGNORE 1 LINES -- Add this if your CSV has a header row
(device_id, customer_id, device_type, app_version, @temp_bool, last_active ) 
SET is_rooted = IF(@temp_bool = 'TRUE', TRUE, FALSE);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\upi_account_details.csv'
INTO TABLE upi_account_details 
FIELDS TERMINATED BY ',' 
IGNORE 1 LINES -- Add this if your CSV has a header row
(upi_id, customer_id, bank_name, account_type, date_added, status );

-- 1. CSV File saved as Text (Tab delimited) (*.txt) beacuse comma in merchant_name is confused by delimiter
-- 2. Date format is DD-MM-YYYY

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\merchant_info.txt'
INTO TABLE merchant_info 
FIELDS TERMINATED BY '\t' 
IGNORE 1 LINES -- Add this if your CSV has a header row
(merchant_id, merchant_name, merchant_type, region, @date, risk_score )
SET onboard_date = STR_TO_DATE(@date, '%d-%m-%Y');

-- Set merchant_id to null if blank to avoid foreign key check error
 
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\upi_transaction_history.csv'
INTO TABLE upi_transaction_history 
FIELDS TERMINATED BY ',' 
IGNORE 1 LINES -- Add this if your CSV has a header row
(transaction_id, upi_id, customer_id, timestamp, amount, transaction_type, @merchant_id, counterparty_upi, status, device_id, device_type, channel, @fraud_flag, @reversal_flag, failure_reason )
SET 
	merchant_id = IF(TRIM(@merchant_id) = '', NULL, @merchant_id),
	fraud_flag = IF(@fraud_flag = 'TRUE', TRUE, FALSE),
	reversal_flag = IF(@reversal_flag = 'TRUE', TRUE, FALSE);
    
     
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\customer_feedback_surveys.csv'
INTO TABLE customer_feedback_surveys 
FIELDS TERMINATED BY ',' 
IGNORE 1 LINES -- Add this if your CSV has a header row
(feedback_id, customer_id, @date_submitted, feedback_text, satisfaction_score, issue_type, @resolved)
SET 
	date_submitted = STR_TO_DATE(@date_submitted, '%Y-%m-%d'),
    resolved = IF(@resolved = 'TRUE', TRUE, FALSE);
           
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\fraud_alert_history.csv'
INTO TABLE fraud_alert_history 
FIELDS TERMINATED BY ',' 
IGNORE 1 LINES -- Add this if your CSV has a header row
(alert_id, transaction_id, alert_type, @alert_date, @resolved,@resolution_date, remarks ) 
SET resolved = IF(@resolved = 'TRUE', 1, 0),
	alert_date = STR_TO_DATE(@alert_date, '%Y-%m-%d %H:%i:%s.%f'),
    resolution_date = IF(TRIM(@resolution_date) = '', NULL, STR_TO_DATE(@resolution_date, '%Y-%m-%d %H:%i:%s.%f'));
    
    
SELECT COUNT(*) FROM customer_feedback_surveys;
SELECT COUNT(*) FROM customer_master;
SELECT COUNT(*) FROM device_info;
SELECT COUNT(*) FROM fraud_alert_history;
SELECT COUNT(*) FROM merchant_info;
SELECT COUNT(*) FROM upi_account_details;
SELECT COUNT(*) FROM upi_transaction_history;
    