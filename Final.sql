CREATE TABLE loan_info (
   LoanNr_ChkDgt BIGINT PRIMARY KEY,
   Name VARCHAR(255),
   City VARCHAR(255),
   State CHAR(255),
   Zip VARCHAR(255),
   Bank VARCHAR(100),
   BankState VARCHAR(2),
   NAICS INT,
   ApprovalDate VARCHAR(10),
   ApprovalFY VARCHAR(20),
   Term INT,
   NoEmp INT,
   NewExist INT,
   CreateJob INT,
   RetainedJob INT,
   FranchiseCode INT,
   UrbanRural INT,
   RevLineCr VARCHAR(2),
   LowDoc VARCHAR(2),
   ChgOffDate DATE,
   DisbursementDate DATE,
   DisbursementGross varchar(20),
   BalanceGross VARCHAR(20),
   MIS_Status VARCHAR(20),
   ChgOffPrinGr VARCHAR(20),
   GrAppv VARCHAR(20),
   SBA_Appv VARCHAR(20)
);






SELECT NAICS, SUM(REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC) AS TotalLoanApproval
FROM loan_info
GROUP BY NAICS
ORDER BY TotalLoanApproval DESC
LIMIT 10;

SELECT Bank, AVG(REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC) AS AverageLoanApproval
FROM loan_info
GROUP BY Bank;

SELECT L.NAICS, L.Bank, SUM(REPLACE(REPLACE(L.GrAppv, '$', ''), ',', '')::NUMERIC) AS TotalLoanApproval
FROM loan_info L
GROUP BY L.NAICS, L.Bank
ORDER BY TotalLoanApproval DESC
LIMIT 500;

SELECT L.State, L.BankState, SUM(REPLACE(REPLACE(L.DisbursementGross,'$', ''), ',', '')::NUMERIC) AS TotalDisbursement
FROM loan_info L
GROUP BY L.State, L.BankState;

/*Count of each MIS_Status category:*/
SELECT MIS_Status, COUNT(*) AS Count
FROM loan_info
GROUP BY MIS_Status;

/*Percentage distribution of MIS_Status:*/
SELECT MIS_Status, COUNT(*) AS Count, (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM loan_info)) AS Percentage
FROM loan_info
GROUP BY MIS_Status;

/*Average loan approval amount by MIS_Status:*/
SELECT MIS_Status, AVG(REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC) AS AvgLoanApproval
FROM loan_info
GROUP BY MIS_Status;

/*Total loan approval amount by MIS_Status:*/
SELECT MIS_Status, SUM(REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC) AS TotalLoanApproval
FROM loan_info
GROUP BY MIS_Status;

/*Maximum loan approval amount by MIS_Status::*/
SELECT MIS_Status, MAX(REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC) AS MaxLoanApproval
FROM loan_info
GROUP BY MIS_Status;

/*Minimum loan approval amount by MIS_Status:*/
SELECT MIS_Status, MIN(REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC) AS MaxLoanApproval
FROM loan_info
GROUP BY MIS_Status;

/*NAICS code with the highest count of PIF (Paid in Full) status:*/
SELECT L.NAICS, COUNT(*) AS PIF_Count
FROM loan_info L
WHERE L.MIS_Status = 'P I F'
GROUP BY L.NAICS
ORDER BY PIF_Count DESC
LIMIT 100;

/*NAICS code with the highest count of CHGOFF (Charged Off) status:*/
SELECT L.NAICS, COUNT(*) AS CHGOFF_Count
FROM loan_info L
WHERE L.MIS_Status = 'CHGOFF'
GROUP BY L.NAICS
ORDER BY CHGOFF_Count DESC
LIMIT 100;

/*Find the average loan amount approved for each NAICS code:*/
SELECT L.NAICS, AVG(Replace(Replace(L.GrAppv,'$',''), ',', '')::NUMERIC) AS AvgLoanAmount
FROM loan_info L
GROUP BY L.NAICS;

/*Calculate the total loan approval amount for each bank:*/
SELECT L.Bank, SUM(Replace(Replace(L.GrAppv,'$',''), ',', '')::NUMERIC) AS TotalLoanApproval
FROM loan_info L
GROUP BY L.Bank;

/*Determine the number of loans approved by each bank in urban and rural areas:*/
SELECT L.Bank, L.UrbanRural, COUNT(*) AS LoanCount
FROM loan_info L
GROUP BY L.Bank, L.UrbanRural;

/*Identify the banks with the highest number of loans in each state:*/
SELECT L.Bank, L.State, COUNT(*) AS LoanCount
FROM loan_info L
GROUP BY L.Bank, L.State
ORDER BY LoanCount DESC;

/*Count the number of loans by loan status:*/
SELECT MIS_Status, COUNT(*) AS LoanCount
FROM loan_info
GROUP BY MIS_Status;


/*Calculate the average loan term for loans approved by each bank:*/
SELECT L.Bank, AVG(L.Term) AS AvgLoanTerm
FROM loan_info L
GROUP BY L.Bank;

/*BalanceGross" and other variables. This will help you identify any patterns or trends in the data.*/
SELECT BalanceGross, GrAppv, DisbursementGross
FROM loan_info;

/*Identify the top 10 banks with the highest loan approval amounts:*/
SELECT Bank, SUM(Replace(Replace(L.GrAppv,'$',''), ',', '')::NUMERIC) AS TotalLoanApproval
FROM loan_info L
GROUP BY Bank
ORDER BY TotalLoanApproval DESC
LIMIT 10;


/*Calculate the percentage of loans approved for new businesses versus existing businesses:*/
SELECT CASE WHEN NewExist = 1 THEN 'Existing Business'
            WHEN NewExist = 2 THEN 'New Business'
            ELSE 'Undefined' END AS BusinessType,
       COUNT(*) AS LoanCount,
       COUNT(*) * 100.0 / (SELECT COUNT(*) FROM loan_info) AS Percentage
FROM loan_info
GROUP BY BusinessType;


/*Identify the top 10 NAICS codes with the highest default rates:*/
SELECT L.NAICS, COUNT(*) AS DefaultCount, COUNT(*) * 100.0 / (SELECT COUNT(*) FROM loan_info WHERE MIS_Status = 'CHGOFF') AS DefaultPercentage
FROM loan_info L
WHERE L.MIS_Status = 'CHGOFF'
GROUP BY L.NAICS
ORDER BY DefaultCount DESC
LIMIT 100;


/*Calculate the average loan amount for defaulting loans by business type:*/
SELECT CASE WHEN L.NewExist = 1 THEN 'Existing Business'
            WHEN L.NewExist = 2 THEN 'New Business'
            ELSE 'Undefined' END AS BusinessType,
       AVG(Replace(Replace(L.GrAppv,'$',''), ',', '')::NUMERIC) AS AvgLoanAmount
FROM loan_info L
WHERE L.MIS_Status = 'CHGOFF'
GROUP BY BusinessType;

/*Calculate the average number of employees for defaulting loans by business type:*/
SELECT CASE WHEN L.NewExist = 1 THEN 'Existing Business'
            WHEN L.NewExist = 2 THEN 'New Business'
            ELSE 'Undefined' END AS BusinessType,
       AVG(L.NoEmp) AS AvgEmployeeSize
FROM loan_info L
WHERE L.MIS_Status = 'CHGOFF'
GROUP BY BusinessType;

/*Identify the top 10 NAICS codes with the highest paid-in-full rates:*/
SELECT L.NAICS, COUNT(*) AS PIFCount,
       CASE WHEN (SELECT COUNT(*) FROM loan_info WHERE MIS_Status = 'PIF') > 0
            THEN COUNT(*) * 100.0 / (SELECT COUNT(*) FROM loan_info WHERE MIS_Status = 'PIF')
            ELSE NULL
       END AS PIFPercentage
FROM loan_info L
WHERE L.MIS_Status = 'P I F'
GROUP BY L.NAICS
ORDER BY PIFCount DESC
LIMIT 10;

/*Calculate the average loan amount for loans paid in full by business type:*/
SELECT CASE WHEN L.NewExist = 1 THEN 'Existing Business'
            WHEN L.NewExist = 2 THEN 'New Business'
            ELSE 'Undefined' END AS BusinessType,
       AVG(Replace(Replace(L.GrAppv,'$',''), ',', '')::NUMERIC) AS AvgLoanAmount
FROM loan_info L
WHERE L.MIS_Status = 'P I F'
GROUP BY BusinessType;

/*Calculate the average number of employees for loans paid in full by business typ*/
SELECT CASE WHEN L.NewExist = 1 THEN 'Existing Business'
            WHEN L.NewExist = 2 THEN 'New Business'
            ELSE 'Undefined' END AS BusinessType,
       AVG(L.NoEmp) AS AvgEmployeeSize
FROM loan_info L
WHERE L.MIS_Status = 'P I F'
GROUP BY BusinessType;


/*Ranking based on loan amount:*/

SELECT LoanNr_ChkDgt, Name, GrAppv,
       RANK() OVER (ORDER BY REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC DESC) AS loan_rank
FROM loan_info
Limit 50;

/*Ranking based on job creation:*/
SELECT LoanNr_ChkDgt, Name, CreateJob,
       DENSE_RANK() OVER (ORDER BY CreateJob DESC) AS job_rank
FROM loan_info
Limit 50;

/*Percentile calculation for loan amount:*/
SELECT LoanNr_ChkDgt, Name, GrAppv,
       PERCENT_RANK() OVER (ORDER BY REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC) AS loan_percentile
FROM loan_info
Limit 50;

/*Cumulative sum of job creation:*/
SELECT LoanNr_ChkDgt, Name, CreateJob,
       SUM(CreateJob) OVER (ORDER BY CreateJob DESC) AS cumulative_jobs
FROM loan_info
Limit 50;


SELECT LoanNr_ChkDgt, Name, CreateJob, GrAppv,
       DENSE_RANK() OVER (ORDER BY CreateJob DESC) AS job_rank
FROM loan_info
Limit 50;

/*Total Loan Amount by NAICS Code:*/
SELECT NAICS, GrAppv,
        SUM(REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC) OVER (PARTITION BY NAICS) AS total_loan_amount
FROM loan_info
limit 50;

/*Total Loan Amount by NAICS Code and there Pif percentage and chgoff percentage :*/
SELECT NAICS,
       COUNT(CASE WHEN MIS_Status = 'P I F' THEN 1 END) AS pif_count,
       COUNT(CASE WHEN MIS_Status = 'CHGOFF' THEN 1 END) AS chgoff_count,
       COUNT(*) AS total_count,
       ROUND((COUNT(CASE WHEN MIS_Status = 'P I F' THEN 1 END) * 100.0) / COUNT(*), 2) AS pif_percentage,
       ROUND((COUNT(CASE WHEN MIS_Status = 'CHGOFF' THEN 1 END) * 100.0) / COUNT(*), 2) AS chgoff_percentage
FROM loan_info
GROUP BY NAICS
ORDER BY total_count DESC
LIMIT 50;






/*Average Loan Amount by State:*/
SELECT State, GrAppv,
       AVG(REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC) OVER (PARTITION BY State) AS avg_loan_amount
FROM loan_info

/*Maximum Job Creation by Bank:*/
SELECT Bank, CreateJob,
       MAX(CreateJob) OVER (PARTITION BY Bank) AS max_job_creation
FROM loan_info

/*Loan Approval Rate by Urban/Rural Status:*/
SELECT UrbanRural, MIS_Status,
       COUNT(*) AS total_loans,
       COUNT(*) FILTER (WHERE MIS_Status = 'P I F') AS pif_count,
       COUNT(*) FILTER (WHERE MIS_Status = 'P I F') * 100.0 / COUNT(*) AS pif_percentage
FROM loan_info
GROUP BY UrbanRural, MIS_Status;

/*Cumulative Sum:*/
SELECT LoanNr_ChkDgt, Name, GrAppv,
       SUM(REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC) OVER (ORDER BY LoanNr_ChkDgt) AS cumulative_sum
FROM loan_info;
/*Cumulative Sum(2):*/
SELECT LoanNr_ChkDgt, Name, GrAppv,
       SUM(REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC) OVER (ORDER BY LoanNr_ChkDgt) AS cumulative_sum,
       COUNT(*) FILTER (WHERE MIS_Status = 'P I F') AS pif_count,
       COUNT(*) FILTER (WHERE MIS_Status = 'CHGOFF') AS chgoff_count,
       ROUND((COUNT(*) FILTER (WHERE MIS_Status = 'P I F') * 100.0) / COUNT(*), 2) AS pif_percentage,
       ROUND((COUNT(*) FILTER (WHERE MIS_Status = 'CHGOFF') * 100.0) / COUNT(*), 2) AS chgoff_percentage
FROM loan_info
GROUP BY LoanNr_ChkDgt, Name, GrAppv, MIS_Status
ORDER BY LoanNr_ChkDgt
Limit 80;



/*Rank by Loan Amount:*/
SELECT LoanNr_ChkDgt, Name, GrAppv,
       RANK() OVER (ORDER BY GrAppv DESC) AS loan_rank
FROM loan_info
Limit 80;

/*Moving Average:*/
SELECT LoanNr_ChkDgt, Name, GrAppv,
       AVG(REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC) OVER (ORDER BY LoanNr_ChkDgt ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_average
FROM loan_info
limit 80;

/*Lead and Lag*/
SELECT LoanNr_ChkDgt, Name, GrAppv,
       LAG(GrAppv) OVER (ORDER BY LoanNr_ChkDgt) AS previous_loan_amount,
       LEAD(GrAppv) OVER (ORDER BY LoanNr_ChkDgt) AS next_loan_amount
FROM loan_info
Limit 80;

 /*Total Loan Amount by NAICS Code:*/
 SELECT LoanNr_ChkDgt, Name, NAICS, GrAppv,
       SUM(REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC) OVER (PARTITION BY NAICS) AS total_loan_by_naics
FROM loan_info
limit 80;



/*Average Loan Amount by State:*/
SELECT LoanNr_ChkDgt, Name, State, GrAppv,
       AVG(REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC) OVER (PARTITION BY State) AS average_loan_by_state
FROM loan_info
limit 80;


/*Ratio of Retained Jobs to Created Jobs:*/
SELECT LoanNr_ChkDgt, Name, RetainedJob, CreateJob,
       RetainedJob::numeric / NULLIF(CreateJob, 0) AS job_retention_ratio
FROM loan_info
WHERE RetainedJob::numeric / NULLIF(CreateJob, 0) > 1
limit 80;



/*Loan Approval Rate by Franchise Code:*/
SELECT LoanNr_ChkDgt, Name, FranchiseCode, MIS_Status,
       COUNT(*) FILTER (WHERE MIS_Status = 'P I F') OVER (PARTITION BY FranchiseCode) AS pif_count,
       COUNT(*) OVER (PARTITION BY FranchiseCode) AS total_loans,
       COUNT(*) FILTER (WHERE MIS_Status = 'P I F') * 100.0 / COUNT(*) OVER (PARTITION BY FranchiseCode) AS approval_rate
FROM loan_info
GROUP BY LoanNr_ChkDgt, Name, FranchiseCode, MIS_Status;

/*Loan Approval Rate by Franchise Code:*/
SELECT
  FranchiseCode,
  COUNT(*) FILTER (WHERE MIS_Status = 'P I F') AS approved_loans,
  COUNT(*) FILTER (WHERE MIS_Status = 'CHGOFF') AS charged_off_loans,
  COUNT(*) AS total_loans,
  COUNT(*) FILTER (WHERE MIS_Status = 'P I F') * 100.0 / COUNT(*) AS approval_rate
FROM loan_info
GROUP BY FranchiseCode;

/*To calculate the loan approval rate based on the NASCI value, you can use the following query:*/
SELECT
  NAICS,
  COUNT(*) FILTER (WHERE MIS_Status = 'P I F') AS approved_loans,
  COUNT(*) FILTER (WHERE MIS_Status = 'CHGOFF') AS charged_off_loans,
  COUNT(*) AS total_loans,
  COUNT(*) FILTER (WHERE MIS_Status = 'P I F') * 100.0 / COUNT(*) AS approval_rate
FROM loan_info
GROUP BY NAICS
Limit 80;





/*x*/
WITH loan_info AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY NAICS ORDER BY REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC DESC) AS rn,
         RANK() OVER (PARTITION BY NAICS ORDER BY REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC DESC) AS rnk,
         DENSE_RANK() OVER (PARTITION BY NAICS ORDER BY REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC DESC) AS drnk,
         SUM(REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC) OVER (PARTITION BY NAICS) AS total_loan_amount_by_naics
  FROM loan_info
)

SELECT NAICS, GrAppv, rn, rnk, drnk, total_loan_amount_by_naics,
       CASE
           WHEN rn = 1 AND total_loan_amount_by_naics > 1000000 THEN 'Eligible'
           WHEN rnk <= 3 AND total_loan_amount_by_naics <= 1000000 THEN 'Eligible'
           ELSE 'Not Eligible'
       END AS LoanEligibility
FROM loan_info
ORDER BY NAICS, REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC DESC
Limit 100;

/*no2.*/



SELECT l.NAICS, l.GrAppv, l.rn, l.rnk, l.drnk, l.total_loan_amount_by_naics,
       n.UrbanRural,
       CASE
           WHEN (l.rn = 1 AND l.total_loan_amount_by_naics > 1000000) THEN 'Eligible'
           WHEN (l.rnk <= 3 AND l.total_loan_amount_by_naics <= 1000000) THEN 'Eligible'
           ELSE 'Not Eligible'
       END AS LoanEligibility
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY NAICS ORDER BY REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC DESC) AS rn,
           RANK() OVER (PARTITION BY NAICS ORDER BY REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC DESC) AS rnk,
           DENSE_RANK() OVER (ORDER BY REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC DESC) AS drnk,
           SUM(REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC) OVER (PARTITION BY NAICS) AS total_loan_amount_by_naics
    FROM loan_info
) l
JOIN loan_info n ON l.NAICS = n.NAICS
ORDER BY l.NAICS, REPLACE(REPLACE(l.GrAppv, '$', ''), ',', '')::NUMERIC DESC
Limit 80;




/*includes additional window functions on the employee size, urban/rural classification, 
and MIS_Status, as well as the top 5 states with the highest count of MIS_Status 'P I F':*/

WITH loan_info AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY NAICS ORDER BY REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC DESC) AS rn,
         RANK() OVER (PARTITION BY NAICS ORDER BY REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC DESC) AS rnk,
         DENSE_RANK() OVER (PARTITION BY NAICS ORDER BY REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC DESC) AS drnk,
         SUM(REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC) OVER (PARTITION BY NAICS) AS total_loan_amount_by_naics,
         ROW_NUMBER() OVER (PARTITION BY NoEmp ORDER BY REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC DESC) AS emp_size_rn,
         RANK() OVER (PARTITION BY UrbanRural ORDER BY REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC DESC) AS urban_rural_rnk,
         RANK() OVER (PARTITION BY MIS_Status ORDER BY REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC DESC) AS mis_status_rnk,
         COUNT(*) OVER (PARTITION BY State, MIS_Status) AS mis_status_count
  FROM loan_info
)



WITH loan_info AS (
  SELECT *,
         COUNT(*) OVER (PARTITION BY State, NAICS, NoEmp, MIS_Status) AS business_count,
         SUM(CreateJob) OVER (PARTITION BY State, NAICS, NoEmp, MIS_Status) AS total_generated_employees,
         ROW_NUMBER() OVER (PARTITION BY State, NAICS, NoEmp, MIS_Status ORDER BY REPLACE(REPLACE(GrAppv, '$', ''), ',', '')::NUMERIC DESC) AS rn,
         CASE WHEN NewExist = 1 THEN 'Existing Business' ELSE 'New Business' END AS BusinessAge
  FROM loan_info
  WHERE MIS_Status = 'P I F'
)

SELECT State, NAICS, NoEmp, MIS_Status, business_count, total_generated_employees, RevLineCr, BusinessAge,
       CASE
           WHEN rn = 1 THEN 'Top Business'
           ELSE 'Other Business'
       END AS BusinessCategory
FROM loan_info
ORDER BY State, NAICS, NoEmp, MIS_Status
Limit 500;


/* Elegeble */
SELECT l.NAICS, n.UrbanRural, n.City, n.State,
       CASE
           WHEN l.avg_pif_chgoff >= 90 AND n.UrbanRural = '1' THEN 'Eligible'
           WHEN l.avg_pif_chgoff >= 80 AND n.UrbanRural = '2' THEN 'Eligible'
           ELSE 'Not Eligible'
       END AS LoanEligibility
FROM (
    SELECT NAICS, AVG(CASE WHEN MIS_Status = 'P I F' THEN 1 WHEN MIS_Status = 'CHGOFF' THEN 0 END) * 100 AS avg_pif_chgoff
    FROM loan_info
    GROUP BY NAICS
) l
JOIN loan_info n ON l.NAICS = n.NAICS

limit 300;



/*top 5 */
SELECT l.NAICS, AVG(CASE WHEN l.MIS_Status = 'P I F' THEN 1 ELSE 0 END) AS avg_approval_rate
FROM loan_info l
WHERE l.NAICS != '0'
GROUP BY l.NAICS
ORDER BY avg_approval_rate DESC
LIMIT 5;

SELECT l.NAICS, AVG(CASE WHEN l.MIS_Status = 'CHGOFF' THEN 1 ELSE 0 END) AS avg_approval_rate
FROM loan_info l
WHERE l.NAICS != '0'
GROUP BY l.NAICS
ORDER BY avg_approval_rate DESC
LIMIT 5;


SELECT State, MIS_Status, AVG(NoEmp) AS AvgNoEmp
FROM loan_info
GROUP BY State, MIS_Status;

WITH bank_loan_counts AS (
    SELECT Bank, NAICS, COUNT(*) AS loan_count,
           ROW_NUMBER() OVER (PARTITION BY Bank ORDER BY COUNT(*) DESC) AS rn
    FROM loan_info
    WHERE MIS_Status = 'P I F'
    GROUP BY Bank, NAICS
)
SELECT Bank, NAICS, loan_count
FROM bank_loan_counts
WHERE rn <= 5
ORDER BY NAICS DESC, loan_count DESC
limit 100;














