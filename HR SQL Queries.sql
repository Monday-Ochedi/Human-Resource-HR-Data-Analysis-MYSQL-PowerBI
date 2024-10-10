CREATE DATABASE projects;

USE projects;

SELECT * FROM hr;

-- DATA CLEANING
-- RENAME ID COLUMN TO SOMETHING MORE RECALLABLE
ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL; 

-- TO CHECK DATA TYPES
DESCRIBE hr;

-- SAFE MODE IS A SECURITY FEATURE; REMOVE FROM SAFE MODE IN ORDER DURING DATA CLEANING
SET sql_safe_updates = 0;

-- TO CHANGE THE FORMATING OF THE DATE COLUMNS TO SOMETHING FROM CONSISTENT: YEAR/MONTH/DAY, USING THE DATE FORMAT
SELECT birthdate FROM hr;
UPDATE hr
SET birthdate = CASE
 WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
 WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
 ELSE NULL 
END;

-- CHANGE DATA TYPE OF BIRTHDATE
ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

-- CHANGING THE DATE FORMAT OF THE HIRE DATE
UPDATE hr
SET hire_date = CASE
 WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
 WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
 ELSE NULL 
END;
ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

-- TO CHECK WHAT YOU'VE DONE
SELECT hire_date FROM hr;

-- TERMDATE IS BASICALLY THE TERMINATION DATE; WE NEED TO CHANGE THE DATA TYPE FROM STRING TO TEXT AND HANDLE THE MISSING VALUES

UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

-- CHANGE THE TERMMDATE DATA TYPE TO DATE
ALTER TABLE hr
MODIFY COLUMN termdate DATE;

SELECT termdate FROM hr;

-- ADD AN AGE COLUMN FROM THE BIRTHDATE COLUMN
ALTER TABLE hr
ADD COLUMN age INT;

-- TO CALCULATE AGE FOR AGE COLUMN; USING TIMESTAMPDIFF WHICH CALCULATES THE DIFFERENCE BETWEEN THE CURRENT DATE AND THE BIRTHDATE
UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT birthdate, age FROM hr;

-- FROM THE ABOVE WE'RE GETTING SOME NEGTIVE VALUES FROM AGE COLUNN 
SELECT 
	MIN(age) AS youngest,
    MAX(age) AS OLDEST
FROM hr;

-- WE WANT TO SELECT RECORDS THAT THE AGE IS LESS THAN 18 BECAUSE IT WON'T BE USEFULL
SELECT COUNT(*) FROM hr
WHERE age < 18;

-- QUESTIONS AND ANALYTICAL ANSWERS IN RELATION TO THE GIVEN DATA

-- DATA ANALYSIS

-- 1. WHAT IS THE GENDER BREAKDOWN OF EMPLOYEES IN THE COMPANY
SELECT gender, count(*) AS count
FROM hr
WHERE age >= 18 AND termdate IS NULL 
GROUP BY gender;

-- 2. WHAT IS THE RACE/ETHNICITY BREAKDOWN OF EMPLOYEES IN THE COMPANY
SELECT race, count(race) AS count
FROM hr
WHERE age >= 18 AND termdate IS NULL 
GROUP BY race
ORDER BY count(race) DESC;	

-- 3. WHAT IS THE AGE DISTRIBUTION OF EMPLOYEES IN THE COMPANY
SELECT 
	MIN(age) AS youngest,
    MAX(age) AS oldest
FROM hr
WHERE age >= 18 AND termdate IS NULL;

SELECT
	CASE
		WHEN age >= 18 AND age <= 24 THEN '18-24'
        WHEN age >= 25 AND age <= 34 THEN '25-34'
        WHEN age >= 35 AND age <= 44 THEN '35-44'
        WHEN age >= 45 AND age <= 54 THEN '45-54'
        WHEN age >= 55 AND age <= 64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
    count(*) AS count
FROM hr
WHERE age >= 18 AND termdate IS NULL 
GROUP BY age_group
ORDER BY age_group;

SELECT
	CASE
		WHEN age >= 18 AND age <= 24 THEN '18-24'
        WHEN age >= 25 AND age <= 34 THEN '25-34'
        WHEN age >= 35 AND age <= 44 THEN '35-44'
        WHEN age >= 45 AND age <= 54 THEN '45-54'
        WHEN age >= 55 AND age <= 64 THEN '55-64'
        ELSE '65+'
	END AS age_group, gender,
    count(*) AS count
FROM hr
WHERE age >= 18 AND termdate IS NULL 
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- 4. HOW MANY EMPLOYEES WORK AT HEADQUARTERS VERSUS REMOTE LOCATIONS
SELECT location, count(*) AS count
FROM hr
WHERE age >= 18 AND termdate IS NULL 
GROUP BY location;

-- 5. WHAT IS THE AVERAGE LENGTH OF EMPLOYMENT FOR EMPLOYEES WHO HAVE BEEN TERMINATED
SELECT
	ROUND(AVG(DATEDIFF(termdate, hire_date))/365, 0) AS avg_length_employment
FROM hr
WHERE termdate <= curdate() AND termdate IS NOT NULL AND age >= 18;

-- 6. HOW DOES THTE GENDER DISTRIBUTION OF JOB TITLES ACROSS THE COMPANY
SELECT department, gender, count(*) AS count
FROM hr
WHERE age >= 18 AND termdate IS NULL 
GROUP BY department, gender
ORDER BY department;

-- 7. WHAT IS THE DISTRIBUTION OF JOBS TITLES ACROSS THE COMPANY
SELECT jobtitle, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate IS NULL 
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8. WHICH DEPARTMENT HAS THE HIGHEST TURNOVER RATE
SELECT department,
	total_count,
    terminated_count,
    terminated_count/total_count AS termination_rate
FROM (
	SELECT department,
    count(*) AS total_count,
    SUM(CASE WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
    FROM hr
    WHERE age >= 18
    GROUP BY department
    ) AS subquery
ORDER BY termination_rate DESC;

-- 9. WHAT IS THE DISTRIBUTION OF EMPLOYEES ACROSS LOCATIONS BY STATE
SELECT location_state, count(*) AS count
FROM hr
WHERE age >= 18 AND termdate IS NULL 
GROUP BY location_state
ORDER BY count DESC;

-- 10. HOW HAS THE COMPANY'S EMPLOYEE COUNT CHANGED OVER TIME BASED ON HIRE AND TERMDATES
SELECT 
	year,
    hires,
    terminations,
    hires - terminations AS net_change,
    round((hires - terminations)/hires * 100, 2) AS net_change_percent
FROM (
	SELECT YEAR(hire_date) AS year,
    count(*) AS hires,
    SUM(CASE WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminations
    FROM hr
    WHERE age >= 18
    GROUP BY YEAR(hire_date)
    ) AS subquery
ORDER BY year ASC;

-- 11. WHAT IS THE TENURE DISTRIBUTION FOR EACH DEPARTMENT
SELECT department, ROUND(AVG(DATEDIFF(termdate, hire_date)/365), 0) AS avg_tenure
FROM hr 
WHERE termdate <= curdate() AND termdate IS NOT NULL AND age >= 18
GROUP BY department;

SELECT * FROM hr;