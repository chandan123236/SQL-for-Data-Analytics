/* ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
Database Load Issues (follow if receiving permission denied when running SQL code below)

NOTE: If you are having issues with permissions. And you get error: 

'could not open file "[your file path]\job_postings_fact.csv" for reading: Permission denied.'

1. Open pgAdmin
2. In Object Explorer (left-hand pane), navigate to `sql_course` database
3. Right-click `sql_course` and select `PSQL Tool`
    - This opens a terminal window to write the following code
4. Get the absolute file path of your csv files
    1. Find path by right-clicking a CSV file in VS Code and selecting “Copy Path”
5. Paste the following into `PSQL Tool`, (with the CORRECT file path)

\copy company_dim FROM '[Insert File Path]/company_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_dim FROM '[Insert File Path]/skills_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy job_postings_fact FROM '[Insert File Path]/job_postings_fact.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_job_dim FROM '[Insert File Path]/skills_job_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

*/

-- NOTE: This has been updated from the video to fix issues with encoding

/*COPY company_dim
FROM 'C:/Users/chandankumar M G/Desktop/day_to_day_updates/SQL/01_SQL_Luke Barousse/SQL_Project_Data_Job_Analysis/csv_files/company_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_dim
FROM 'C:/Users/chandankumar M G/Desktop/day_to_day_updates/SQL/01_SQL_Luke Barousse/SQL_Project_Data_Job_Analysis/csv_files/skills_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY job_postings_fact
FROM 'C:/Users/chandankumar M G/Desktop/day_to_day_updates/SQL/01_SQL_Luke Barousse/SQL_Project_Data_Job_Analysis/csv_files/job_postings_fact.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_job_dim
FROM 'C:/Users/chandankumar M G/Desktop/day_to_day_updates/SQL/01_SQL_Luke Barousse/SQL_Project_Data_Job_Analysis/csv_files/skills_job_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8'); */

SELECT * FROM company_dim LIMIT 5;

-- Handling Date

SELECT job_posted_date
FROM job_postings_fact
LIMIT 10;

-- date

SELECT '2023-02-19';

SELECT
  job_title_short AS title,
  job_location   AS location,
  job_posted_date :: Date AS date
FROM
  job_postings_fact;

-- AT time zone
SELECT
  job_title_short AS title,
  job_location    AS location,
  job_posted_date AS date_time
FROM
  job_postings_fact
LIMIT 5;

--

SELECT
  job_title_short AS title,
  job_location    AS location,
  (job_posted_date AT TIME ZONE 'UTC') AT TIME ZONE 'EST' AS date_time
FROM
  job_postings_fact
LIMIT 5;

-- extract

SELECT
  job_title_short AS title,
  job_location     AS location,
  job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date_time,
  EXTRACT(MONTH FROM job_posted_date) AS date_month,
  EXTRACT(YEAR FROM job_posted_date) AS date_year
FROM
  job_postings_fact
LIMIT 5;

--
SELECT
    COUNT(job_id) AS job_posted_count,
    EXTRACT(MONTH FROM job_posted_date) AS month
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    month
ORDER BY
    job_posted_count DESC;


--
-- January 2023 jobs
CREATE TABLE january_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

-- February 2023 jobs
CREATE TABLE february_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

-- March 2023 jobs
CREATE TABLE march_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

select job_posted_date
FROM march_jobs;

-- case
SELECT
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    location_category;

-- sub queries
SELECT *
FROM (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) AS january_jobs;

-- CTE's
WITH january_jobs AS (
    -- CTE definition starts here
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
    -- CTE definition ends here
)
SELECT *
FROM january_jobs;

-- sub query

SELECT
  company_id,
  name AS company_name
FROM
  company_dim
WHERE
  company_id IN (
    SELECT
      company_id
    FROM
      job_postings_fact
    WHERE
      job_no_degree_mention = true
    ORDER BY
      company_id
  );

--CTE's 
WITH company_job_count AS (
  SELECT
    company_id,
    COUNT(*) AS total_jobs
  FROM
    job_postings_fact
  GROUP BY
    company_id
)
SELECT *
FROM company_job_count;

--
WITH company_job_count AS (
  SELECT
    company_id,
    COUNT(*) AS total_jobs
  FROM
    job_postings_fact
  GROUP BY
    company_id
)
SELECT
  company_dim.name AS company_name,
  company_job_count.total_jobs
FROM
  company_dim
LEFT JOIN company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER BY
  total_jobs DESC;

--practice question 07

WITH remote_job_skills AS (
  SELECT
    skill_id,
    COUNT(*) AS skill_count
  FROM
    skills_job_dim AS skills_to_job
  INNER JOIN job_postings_fact AS job_postings
    ON job_postings.job_id = skills_to_job.job_id
  WHERE
    job_postings.job_work_from_home = True
    AND job_postings.job_title_short = 'Data Analyst'
  GROUP BY
    skill_id
)

SELECT
  skills.skill_id,
  skills AS skill_name,
  skill_count
FROM
  remote_job_skills
INNER JOIN skills_dim AS skills
  ON skills.skill_id = remote_job_skills.skill_id
ORDER BY
  skill_count DESC
LIMIT 5;

--Union

-- Get jobs and companies from January
SELECT
  job_title_short,
  company_id,
  job_location
FROM
  january_jobs

UNION

-- Get jobs and companies from February
SELECT
  job_title_short,
  company_id,
  job_location
FROM
  february_jobs;

--Union ALL

SELECT
  job_title_short,
  company_id,
  job_location,
  'January' AS source_month
FROM january_jobs

UNION ALL

SELECT
  job_title_short,
  company_id,
  job_location,
  'February' AS source_month
FROM february_jobs

UNION ALL

SELECT
  job_title_short,
  company_id,
  job_location,
  'March' AS source_month
FROM march_jobs;

--Question 
-- Get jobs in Q1 with salary > 70,000, include posts without skills
WITH q1_jobs AS (
    SELECT *
    FROM (
        SELECT * FROM january_jobs
        UNION ALL
        SELECT * FROM february_jobs
        UNION ALL
        SELECT * FROM march_jobs
    ) AS all_q1
    WHERE salary_year_avg > 70000
)
SELECT 
    q1.job_id,
    q1.salary_year_avg,
    s.skills AS skill_name,
    s.type AS skill_type
FROM q1_jobs q1
LEFT JOIN skills_job_dim sj
    ON q1.job_id = sj.job_id
LEFT JOIN skills_dim s
    ON sj.skill_id = s.skill_id
ORDER BY q1.job_id;

---
SELECT
  job_title_short,
  job_location,
  job_via,
  job_posted_date::date,
  salary_year_avg
FROM
  ( SELECT * FROM january_jobs
    UNION ALL
    SELECT * FROM february_jobs
    UNION ALL
    SELECT * FROM march_jobs
  ) AS quarter1_job_postings
WHERE
  salary_year_avg > 70000
  AND job_title_short = 'Data Analyst'
ORDER BY
  salary_year_avg DESC;

