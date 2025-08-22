-- DATA CLEANING PROJECT --

-- STEPS OF DATA CLEANING ARE
-- 1. REMOVE DUPLICATE ROWS
-- 2. STANDARDIZE THE TABLE
-- 3. LOOK FOR ANY NULL/BLANK VALUES
-- 4. REMOVE ANY UNNECESSARY ROWS OR COLOUMNS


CREATE DATABASE world_layoffs;
SELECT * FROM layoffs;


# CREATING ANOTHER TABLE SAME AS PRIMARY TABLE TO DO ALL THE QUERIES WITHOUT TAMPERING THE DATA IN PRIMARY TABLE
CREATE TABLE layoffs_staging(
	LIKE layoffs);

INSERT INTO layoffs_staging
SELECT * FROM layoffs;


-- 1. REMOVING DUPLICATES

SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT * FROM (
SELECT * ,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging) as sub
WHERE row_num > 1;

# THE ABOVE QUERY CAN ALSO BE WRITTEN USING CTEs LIKE

WITH query_cte AS
(SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging)
SELECT *
FROM query_cte
WHERE row_num> 1;

# CREATING ANOTHER BECAUSE DUPLICATES CAN'T BE DELETED DIRECTLY FROM CTE

CREATE TABLE layoffs_staging_2( LIKE layoffs_staging );
ALTER TABLE layoffs_staging_2
ADD COLUMN row_num INT;

INSERT INTO layoffs_staging_2
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE FROM layoffs_staging_2
WHERE row_num >1;



-- 2.STANDARDIZING DATA

--  CORRECTING cloumn 'company'
SELECT DISTINCT company 
FROM layoffs_staging_2 
ORDER BY company;
UPDATE layoffs_staging_2
SET company = TRIM(company);

-- CORRECTING COLUMN 'industry'
SELECT DISTINCT industry
FROM layoffs_staging_2
ORDER BY industry;

SELECT industry 
FROM layoffs_staging_2
WHERE industry LIKE 'crypto%';

UPDATE layoffs_staging_2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- CORRECTING COLUMN 'country'
SELECT DISTINCT country 
FROM layoffs_staging_2
ORDER BY country;

SELECT *
FROM layoffs_staging_2
WHERE country LIKE 'United States%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) AS trimmed_country
FROM layoffs_staging_2
ORDER BY country;

UPDATE layoffs_staging_2
SET country =TRIM(TRAILING '.' FROM country) ;


-- CORRECTING COLUMN 'date'
-- CHANGING THE COLUMN 'date' DATATYPE FROM TEXT TO DATE.
SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging_2
MODIFY COLUMN `date` DATE;



-- 3. DEALNG WITH NULL/BLANK VALUES

SELECT * FROM layoffs_staging_2
WHERE industry IS NULL
OR industry = '';

SELECT * FROM layoffs_staging_2
WHERE company = 'Carvana';

-- POPULATING THE INDUSTRY COLUMN FOR ROWS WHICH HAVE ANOTHER ENTRY FROM SAME COMPANY.
SELECT *
FROM layoffs_staging_2 as t1
JOIN layoffs_staging_2 as t2
ON t1.company = t2.company
AND t1.location = t2.location
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging_2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging_2 AS t1
JOIN layoffs_staging_2 AS t2
ON t1.company = t2.company
AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT * 
FROM layoffs_staging_2
WHERE industry IS NULL;



-- 4. DELETING UNNCESSEARY ROWS AND COLUMNS.

-- REMOVING UNWANTED ROWS
SELECT *
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * FROM layoffs_staging_2;


-- REMOVING COLUMN 'row_num'
ALTER TABLE layoffs_staging_2
DROP COLUMN row_num;