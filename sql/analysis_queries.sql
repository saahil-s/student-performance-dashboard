-- Query 1: Total student enrollment in Illinois by race/ethnicity
SELECT 
    RACE_ETHNICITY,
    SUM(STUDENT_COUNT) AS total_students,
    ROUND(SUM(STUDENT_COUNT) * 100.0 / SUM(SUM(STUDENT_COUNT)) OVER(), 2) AS percentage
FROM state_membership
GROUP BY RACE_ETHNICITY
ORDER BY total_students DESC;



-- Query 2: Total enrollment by grade in Illinois
SELECT 
    GRADE,
    SUM(STUDENT_COUNT) AS total_students,
    ROUND(SUM(STUDENT_COUNT) * 100.0 / SUM(SUM(STUDENT_COUNT)) OVER(), 2) AS percentage
FROM state_membership
GROUP BY GRADE
ORDER BY total_students DESC;

-- Query 3: Top 20 largest Illinois districts by total enrollment
SELECT 
    LEA_NAME,
    SUM(STUDENT_COUNT) AS total_students
FROM district_membership
GROUP BY LEA_NAME
ORDER BY total_students DESC
LIMIT 20;


-- Query 4: Number of students by grade at Oak Park & River Forest High Sch
SELECT
    GRADE, SUM(STUDENT_COUNT) AS total_students
FROM school_membership
WHERE SCH_NAME = 'Oak Park & River Forest High Sch' 
GROUP BY GRADE
ORDER BY total_students DESC;


-- Query 5: Accurate enrollment for CUSD 200 (sum one sex to avoid double counting)
SELECT
    RACE_ETHNICITY,
    SUM(STUDENT_COUNT) AS total_students,
    ROUND(SUM(STUDENT_COUNT) * 100.0 / SUM(SUM(STUDENT_COUNT)) OVER(), 2) AS percentage
FROM district_membership
WHERE LEA_NAME = 'CUSD 200'
AND SEX = 'Female'
GROUP BY RACE_ETHNICITY
ORDER BY total_students DESC;


-- Query 6: Top 10 largest high schools in Illinois by enrollment
SELECT
    s.SCH_NAME,
    d.LEA_NAME,
    SUM(s.STUDENT_COUNT) AS total_students
FROM school_membership s
JOIN district_membership d ON s.LEAID = d.LEAID
WHERE s.GRADE IN ('Grade 9', 'Grade 10', 'Grade 11', 'Grade 12')
GROUP BY s.SCH_NAME, d.LEA_NAME
ORDER BY total_students DESC
LIMIT 10;
-- got student counts that were way too high due to double counting 

-- Check school table columns
PRAGMA table_info(school_membership);

-- Query 6: Top 10 largest high schools in Illinois by enrollment
SELECT
    SCH_NAME,
    ST_LEAID,
    SUM(STUDENT_COUNT) AS total_students
FROM school_membership
WHERE GRADE IN ('Grade 9', 'Grade 10', 'Grade 11', 'Grade 12')
AND SEX = 'Female'
GROUP BY SCH_NAME, ST_LEAID
ORDER BY total_students DESC
LIMIT 10;


-- Query 7: Where does OPRF rank among Illinois high schools?
SELECT
    SCH_NAME,
    ST_LEAID,
    SUM(STUDENT_COUNT) AS total_students,
    RANK() OVER (ORDER BY SUM(STUDENT_COUNT) DESC) AS rank
FROM school_membership
WHERE GRADE IN ('Grade 9', 'Grade 10', 'Grade 11', 'Grade 12')
AND SEX = 'Female'
GROUP BY SCH_NAME, ST_LEAID
ORDER BY total_students DESC
LIMIT 100;

-- OPRF ranks 17th out of 100 schools, counted 1525 total_students
-- so 1525 * 2 = 3050, which is close to 3276 students in 2025,
-- which was found on
-- https://www.illinoisreportcard.com/school.aspx?source=studentcharacteristics&source2=enrollment&Schoolid=060162000130001
-- The numbers differ because rows with null values were dropped.
-- NCES intentionally leaves student counts blank 
-- when a cell has fewer than ~3-5 students
-- Done to protect student privacy (FERPA)
-- Causes slight undercounting when null rows are dropped

