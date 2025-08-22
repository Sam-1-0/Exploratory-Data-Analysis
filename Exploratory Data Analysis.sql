-- EXPLORATORY (JUST LOOKING FOR INSIGHTS) DATA ANALYSIS PROJECT

WITH laid_off AS
(SELECT company, YEAR(`date`) AS `Year`, SUM(total_laid_off) AS l
FROM layoffs_staging_2
GROUP BY company, `Year`),
ranking AS 
(SELECT *, DENSE_RANK() OVER(PARTITION BY `Year` ORDER BY l DESC) AS rnk
FROM laid_off
WHERE `Year` IS NOT NULL)
SELECT *
FROM ranking
WHERE rnk <= 5;


#SAME QUERY AS ABOVE BUT USING SUBQUERIES INSTEAD OF CTEs

SELECT company, YEAR(date) ,SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company, YEAR(date);

SELECT *, DENSE_RANK() OVER(PARTITION BY d ORDER BY l DESC) AS rnk
FROM (SELECT company, YEAR(date) AS d ,SUM(total_laid_off) AS l
FROM layoffs_staging_2
GROUP BY company, YEAR(date)) AS t;


SELECT *
FROM (SELECT *, DENSE_RANK() OVER(PARTITION BY d ORDER BY l DESC) AS rnk
FROM (SELECT company, YEAR(date) AS d ,SUM(total_laid_off) AS l
FROM layoffs_staging_2
GROUP BY company, YEAR(date)) AS t) AS a
WHERE rnk<=5;



# CHECKING TOP 5 LAYING OFFS EACH YEAR FROM INDIA
SELECT *
FROM layoffs_staging_2
WHERE country LIKE '%india%';


SELECT *
FROM (SELECT *, DENSE_RANK() OVER(PARTITION BY d ORDER BY l DESC) AS rnk
FROM (SELECT company, YEAR(date) AS d ,SUM(total_laid_off) AS l
FROM layoffs_staging_2
WHERE country LIKE'%INDIA%'
GROUP BY company, YEAR(date)) AS t) AS a
WHERE rnk<=5;



# CHECKING ON COMPANIES HAVING MULTIPLE LAYOFFS
SELECT company, COUNT(company)
FROM(
SELECT company, YEAR(`date`) AS `Year`, SUM(total_laid_off) AS l
FROM layoffs_staging_2
GROUP BY company, `Year`) AS t
GROUP BY company
HAVING COUNT(company) >= 2
ORDER BY COUNT(company) DESC
;


# CHECKING TOP 5 COMPANIES WITH MAXIMUM NO OF EMPLOYEES BEING LAID OFF
SELECT company, SUM(total_laid_off) AS l
FROM layoffs_staging_2
GROUP BY company
ORDER BY l DESC
LIMIT 1,5;
















