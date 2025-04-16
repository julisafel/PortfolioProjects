SELECT * 
FROM BCPortfolio..BreastCancerData
order by 1,2


--CLEANING DATA
UPDATE BCPortfolio..BreastCancerData
SET Patient_Status = 'Unknown'
WHERE Patient_Status IS NULL


SELECT Patient_ID, COUNT(*) AS Duplicate_Count
FROM BCPortfolio..BreastCancerData
GROUP BY Patient_ID
HAVING COUNT(*) > 1


SELECT Patient_ID, Age
FROM BCPortfolio..BreastCancerData
WHERE Age < 20 OR Age > 100

EXEC sp_rename 'BCPortfolio..BreastCancerData.Tumour_Stage', 'Tumor_Stage', 'COLUMN'



SELECT Tumor_Stage, COUNT(*) AS Total_Patients
FROM BCPortfolio..BreastCancerData
GROUP BY Tumor_Stage


--SURVIVAL RATE BY TUMOR STAGE
SELECT Tumor_Stage, 
       COUNT(*) AS Total_Patients,
       SUM(CASE WHEN Patient_Status = 'Alive' THEN 1 ELSE 0 END) AS Survived_Patients
FROM BCPortfolio..BreastCancerData
GROUP BY Tumor_Stage


SELECT Tumor_Stage, 
       COUNT(*) AS Total_Patients,
       SUM(CASE WHEN Patient_Status = 'Alive' THEN 1 ELSE 0 END) AS Survived_Patients,
       ROUND((SUM(CASE WHEN Patient_Status = 'Alive' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS Survival_Percentage
FROM BCPortfolio..BreastCancerData
GROUP BY Tumor_Stage


SELECT Surgery_Type, COUNT(*) AS Total_Patients
FROM BCPortfolio..BreastCancerData
GROUP BY Surgery_Type


--SURVIVAL RATE BY SURGERY TYPE
SELECT Surgery_Type, 
       COUNT(*) AS Total_Patients, 
       SUM(CASE WHEN Patient_Status = 'Alive' THEN 1 ELSE 0 END) AS Survived_Patients
FROM BCPortfolio..BreastCancerData
GROUP BY Surgery_Type


SELECT Surgery_Type, 
       COUNT(*) AS Total_Patients,
       SUM(CASE WHEN Patient_Status = 'Alive' THEN 1 ELSE 0 END) AS Survived_Patients,
       ROUND((SUM(CASE WHEN Patient_Status = 'Alive' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS Survival_Percentage
FROM BCPortfolio..BreastCancerData
GROUP BY Surgery_Type


--AVG AGE OF DIAGNOSIS PER TUMOR STAGE
SELECT Tumor_Stage, AVG(Age) AS Avg_Age
FROM BCPortfolio..BreastCancerData
GROUP BY Tumor_Stage


--AGE AND GENDER PER TUMOR STAGE
SELECT 
    Tumor_Stage,
    AVG(Age) AS Avg_Age,
    COUNT(CASE WHEN Gender = 'Male' THEN 1 END) AS Male_Patients,
    COUNT(CASE WHEN Gender = 'Female' THEN 1 END) AS Female_Patients
FROM BCPortfolio..BreastCancerData
GROUP BY Tumor_Stage


--TIME BETWEEN SURGERY AND LAST VISIT
SELECT AVG(DATEDIFF(DAY, Date_of_Surgery, Date_of_Last_Visit)) AS Avg_Days_Between_Visits
FROM BCPortfolio..BreastCancerData
WHERE Date_of_Last_Visit IS NOT NULL


--PATIENTS THAT DID NOT FOLLOW UP AFTER SURGERY
SELECT COUNT(*) AS No_Follow_Up_Patients
FROM BCPortfolio..BreastCancerData
WHERE Date_of_Last_Visit IS NULL


--COMBINED PATIENTS LAST VISIT AND NO SHOW AFTER SURGERY
SELECT 
    AVG(CASE 
        WHEN Date_of_Last_Visit IS NOT NULL 
        THEN DATEDIFF(DAY, Date_of_Surgery, Date_of_Last_Visit) 
    END) AS Avg_Days_Between_Visits,
    
    COUNT(CASE 
        WHEN Date_of_Last_Visit IS NULL 
        THEN 1 
    END) AS No_Follow_Up_Patients
FROM BCPortfolio..BreastCancerData


--FOLLOW UP VS NO FOLLOW UP PATIENTS BASED ON SURGERY TYPE
SELECT 
    Surgery_Type,
    COUNT(*) AS Total_Patients,
    SUM(CASE WHEN Date_of_Last_Visit IS NOT NULL THEN 1 ELSE 0 END) AS Follow_Up_Patients,
    SUM(CASE WHEN Date_of_Last_Visit IS NULL THEN 1 ELSE 0 END) AS No_Follow_Up_Patients,
    ROUND((SUM(CASE WHEN Date_of_Last_Visit IS NULL THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS Percentage_No_Follow_Up
FROM BCPortfolio..BreastCancerData
GROUP BY Surgery_Type



