CREATE TABLE telco_churn
(
	customerID                 VARCHAR(20),
	gender                     VARCHAR(10),
	SeniorCitizen              INT,
	Partner	                   VARCHAR,
	Dependents                 VARCHAR,
	tenure	                   INT,
	PhoneService               VARCHAR(5) ,
	MultipleLines              VARCHAR(20),
	InternetService            VARCHAR(20),
	OnlineSecurity             VARCHAR(20),
	OnlineBackup               VARCHAR(20),
	DeviceProtection           VARCHAR(20),
	TechSupport                VARCHAR(20),
	StreamingTV                VARCHAR(20),
	StreamingMovies            VARCHAR(20),
	Contract                   VARCHAR(20),
	PaperlessBilling           VARCHAR(5),
	PaymentMethod              VARCHAR(30),
	MonthlyCharges             FLOAT,
	TotalCharges               FLOAT,
	Churn                      VARCHAR(5)
);

/* Data Exploration and Validation */
SELECT * FROM telco_churn;

SELECT
	COUNT(*) AS total_customers FROM telco_churn;


-- Check for missing/null values in key columns
SELECT COUNT(*) AS missing_total_charges
FROM telco_churn
WHERE "totalcharges" IS NULL;

-- Check for duplicate customerID records
SELECT "customerid", COUNT(*) AS record_count
FROM telco_churn
GROUP BY "customerid"
HAVING COUNT(*) > 1;

-- Overall churn rate (Yes vs No) with percentage
SELECT "churn",
       COUNT(*) AS total_customers,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM telco_churn), 2) AS percentage
FROM telco_churn
GROUP BY "churn";

-- Total revenue lost due to churned customers
SELECT 
	ROUND(SUM(monthlycharges)::numeric, 2) AS montly_loss,
	ROUND(SUM(totalcharges)::numeric, 2) AS total_historical
FROM telco_churn
WHERE "churn" = 'Yes';

-- Churn rate by contract type
SELECT "contract", "churn", COUNT(*) AS total,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY "contract"), 2) AS percentage
FROM telco_churn
GROUP BY "contract", "churn"
ORDER BY "contract";

-- Churn rate by payment method
SELECT "paymentmethod", "churn", COUNT(*) AS total,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY "paymentmethod"), 2) AS percentage
FROM telco_churn
GROUP BY "paymentmethod", "churn"
ORDER BY "paymentmethod";

-- Average monthly charges: churned vs retained customers
SELECT churn, 
	ROUND(AVG(monthlycharges)::num, 2) AS avg_monthly_charges
FROM telco_churn
GROUP BY churn;

-- Paperless billing customers vs churn
SELECT "PaperlessBilling", "Churn", COUNT(*) AS total
FROM telco_churn
GROUP BY "PaperlessBilling", "Churn";

-- Average tenure of churned vs retained customers
SELECT churn, ROUND(AVG("tenure"), 2) AS avg_tenure_months
FROM telco_churn
GROUP BY "churn";

-- Customers grouped into tenure buckets and their churn rate
SELECT
    CASE
        WHEN tenure <= 12 THEN '0-12 months'
        WHEN tenure <= 24 THEN '13-24 months'
        WHEN tenure <= 48 THEN '25-48 months'
        ELSE '49+ months'
    END AS tenure_group,
    churn,
    COUNT(*) AS total
FROM telco_churn
GROUP BY tenure_group, churn
ORDER BY tenure_group;

-- Customers who churned within their first 6 months (early churn risk)
SELECT COUNT(*) AS early_churners
FROM telco_churn
WHERE tenure <= 6 AND churn = 'Yes';

-- Churn rate by internet service type
SELECT internetservice, churn, COUNT(*) AS total
FROM telco_churn
GROUP BY internetservice, churn;

-- Impact of OnlineSecurity on churn
SELECT onlinesecurity, churn, COUNT(*) AS total
FROM telco_churn
GROUP BY onlinesecurity, churn;

-- Impact of TechSupport on churn
SELECT techsupport, churn, COUNT(*) AS total
FROM telco_churn
GROUP BY techsupport, churn;

-- Customers with NO OnlineSecurity AND NO TechSupport who churned (high-risk group)
SELECT COUNT(*) AS high_risk_churners
FROM telco_churn
WHERE onlineSecurity = 'No' AND techsupport = 'No' AND churn = 'Yes';

-- Churn rate by gender
SELECT gender, churn, COUNT(*) AS total
FROM telco_churn
GROUP BY gender, churn;

-- Churn rate among senior citizens vs non-senior citizens
SELECT seniorcitizen, churn, COUNT(*) AS total
FROM telco_churn
GROUP BY seniorcitizen, churn;

-- Churn rate by presence of partner and dependents
SELECT partner, dependents, churn, COUNT(*) AS total
FROM telco_churn
GROUP BY partner, dependents, churn;

-- Top 10 highest-paying customers who churned (potential biggest loss)
SELECT customerid, monthlyCharges, totalcharges, churn
FROM telco_churn
WHERE churn = 'Yes'
ORDER BY totalCharges DESC
LIMIT 10;

-- Rank customers by MonthlyCharges within each Contract type (window function)
SELECT customerid, contract, monthlycharges,
       RANK() OVER (PARTITION BY contract ORDER BY monthlyCharges DESC) AS charge_rank
FROM telco_churn;

-- Categorize customers by charge level and check churn pattern
SELECT
    CASE
        WHEN monthlyCharges < 35 THEN 'Low'
        WHEN monthlyCharges BETWEEN 35 AND 70 THEN 'Medium'
        ELSE 'High'
    END AS charge_category,
    churn,
    COUNT(*) AS total
FROM telco_churn
GROUP BY charge_category, churn
ORDER BY charge_category;

-- Complete churn summary: count, avg tenure, avg monthly charges, avg total charges
SELECT
    churn,
    COUNT(*) AS total_customers,
    ROUND(AVG(tenure), 2) AS avg_tenure,
    ROUND(AVG(monthlycharges):: numeric, 2) AS avg_monthly_charges,
    ROUND(AVG(totalcharges):: numeric, 2) AS avg_total_charges
FROM telco_churn
GROUP BY churn;


