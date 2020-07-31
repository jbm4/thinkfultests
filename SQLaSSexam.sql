-- The naep table contains each state's average NAEP scores in math and reading 
-- for students in grades four and eight. The data spans various years between 1992 and 2017.
-- The finance table contains each state's total K-12 education revenue and expenditures 
-- for the years 1992-2016.

--1.Write a query that allows you to inspect the schema of the naep table. 
--come back to this.

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name='naep';


--2. Write a query that returns the first 50 records of the naep table.

SELECT *
FROM naep
LIMIT 50;


-- 3. Write a query that returns summary statistics (count, average, min, and max)
--for avg_math_4_score by state. 
-- Make sure to sort the results alphabetically by state name.

SELECT COUNT(avg_math_4_score) AS n_math_state,
	ROUND(AVG(avg_math_4_score), 3) AS avg_state,
	MIN(avg_math_4_score) AS min_state,
	MAX(avg_math_4_score) AS max_state,
	state
FROM naep
GROUP BY state
ORDER BY state;


-- 4.Write a query that alters the previous query so that it returns only 
-- the summary statistics for avg_math_4_score by state with differences 
-- in max and min values that are greater than 30.

SELECT COUNT(avg_math_4_score) AS n_math,
	ROUND(AVG(avg_math_4_score), 2) AS avg_state,
	MIN(avg_math_4_score) AS min_state,
	MAX(avg_math_4_score) AS max_state,
	state
FROM naep
GROUP BY state
HAVING ABS(MAX(avg_math_4_score)-MIN(avg_math_4_score))>30
ORDER BY state;

-- 5. Write a query that returns a field called bottom_10_states. 
-- This field should list the states in the bottom 10 for avg_math_4_score in the year 2000.

SELECT state AS bottom_10_states
FROM naep 
WHERE year=2000 
ORDER BY avg_math_4_score ASC 
LIMIT 10;


-- 6. Write a query that calculates the average avg_math_4_score, 
-- rounded to the nearest two decimal places, over all states in the year 2000.

SELECT ROUND(AVG(avg_math_4_score),2) AS avg_math_2000
FROM naep
GROUP BY year
HAVING year=2000;

-- 7. Write a query that returns a field called below_average_states_y2000. 
-- This field should list all states with an avg_math_4_score less than the average 
-- over all states in the year 2000.
WITH avg_year AS
(SELECT AVG(avg_math_4_score) AS avg_score_y,
 	year
FROM naep
GROUP BY year)
SELECT naep.state AS below_average_states_y2000
FROM naep
RIGHT OUTER JOIN avg_year 
ON naep.year = avg_year.year
WHERE avg_math_4_score < avg_score_y
	AND naep.year=2000;

--Look at your results. Do your above lists overlap? Should they overlap?

(SELECT state AS bottom_10_states
FROM naep 
WHERE year=2000 
ORDER BY avg_math_4_score ASC 
LIMIT 10)
INTERSECT
(WITH avg_year AS
(SELECT AVG(avg_math_4_score) AS avg_score_y,
 	year
FROM naep
GROUP BY year)
SELECT naep.state AS below_average_states_y2000
FROM naep
RIGHT OUTER JOIN avg_year 
ON naep.year = avg_year.year
WHERE avg_math_4_score < avg_score_y
	AND naep.year=2000);

--Seems like they completely overlap. That would make sense since the bottem 10 states
--should be below the average of 50.

-- 8.Write a query that returns a field called scores_missing_y2000 that 
-- lists any states with missing values in the avg_math_4_score 
-- column of the naep table for the year 2000.
WITH missing AS (
SELECT 
	CASE
		WHEN avg_math_4_score IS NULL
			THEN 1
		ELSE 0
	END AS missing_boolean,
	id
FROM naep)
SELECT naep.state AS scores_missing_y2000
FROM naep
JOIN missing --could do an outer join here but it is 1 to 1 on ids
ON naep.id=missing.id
WHERE missing.missing_boolean=1
	AND year=2000;


-- 9.Write a query that returns, for the year 2000, the state, avg_math_4_score, 
-- and total_expenditure from the naep table, joined using the LEFT OUTER JOIN clause with the finance table.
-- Use id as the key and order the output by total_expenditure from greatest to least. 
-- Make sure to round avg_math_4_score to the nearest two decimal places, 
-- and then filter out NULL values in avg_math_4_scores in order to see any correlation more clearly.

SELECT naep.state, 
	ROUND(naep.avg_math_4_score, 2) AS avg_math_4_score_rd, 
	finance.total_expenditure
FROM naep
LEFT OUTER JOIN finance
ON naep.id=finance.id
WHERE naep.year=2000
	AND naep.avg_math_4_score IS NOT NULL
ORDER BY finance.total_expenditure DESC;

--The positive correlation shown is between the size of the state and total expenditure.
--You should divide total exp by enrollment if you're looking for correlation between
--average scores and expenditure.