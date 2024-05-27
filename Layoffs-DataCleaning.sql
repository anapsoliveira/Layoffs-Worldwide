-- DATA CLEANING PROJECT

-- Public Dataset from: https://www.kaggle.com/datasets/swaptr/layoffs-2022/data
-- Layoff numbers from companies worldwide
-- Dates from 2020-03-11 to 2024-05-24

-- STEPS:
-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove unnecessary columns or rows

-- Creating a staging table to preserve the raw data

SELECT *
FROM layoffs;

CREATE TABLE layoffs_staging 
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

-- Step 1. Removing Duplicates

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Cazoo';

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE 
FROM layoffs_staging2
WHERE row_num = 2;

SELECT *
FROM layoffs_staging2;

-- Step 2. Standardizing the Data

SELECT company, TRIM(company)
FROM layoffs_staging2
ORDER BY company;

SELECT company, TRIM(TRAILING '.' FROM company)
FROM layoffs_staging2
ORDER BY company;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY location;

SELECT *
FROM layoffs_staging2
WHERE location like 'Non-%';
-- Maybe fix it, adding the correct location

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

SELECT DISTINCT stage
FROM layoffs_staging2
ORDER BY stage;

SELECT `date`
FROM layoffs_staging2
ORDER BY `date`;

SELECT `date`,
str_to_date(`date`, '%Y-%m-%d')
FROM layoffs_staging2;

UPDATE layoffs_staging2 
SET `date` = str_to_date(`date`, '%Y-%m-%d');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Step 3. Null Values or Blank Values

SELECT *
FROM layoffs_staging2
WHERE industry = ''
OR industry IS NULL;

SELECT *
FROM layoffs_staging2
WHERE company = 'Appsmith';

UPDATE layoffs_staging2
SET industry = 'Other'
WHERE company = 'Appsmith';

SELECT * 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry = '' OR t1.industry IS NULL)
AND t2.industry != '' OR t2.industry IS NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry = '' OR t1.industry IS NULL)
AND t2.industry != '' OR t2.industry IS NULL;

SELECT count(*)
FROM layoffs_staging2
WHERE industry like '%othe%';
-- Too many 'Other' Industry, maybe update it later

SELECT *
FROM layoffs_staging2
WHERE stage  = ''
OR stage IS NULL
OR stage like '%unk%'
ORDER BY stage;

UPDATE layoffs_staging2
SET stage = 'Unknown'
WHERE stage  = ''
OR stage IS NULL;

SELECT count(*)
FROM layoffs_staging2
WHERE stage = 'Unknown';
-- Too many 'Unknown' stage, maybe update it later

SELECT *
FROM layoffs_staging2
order by country;

SELECT count(*)
FROM layoffs_staging2
WHERE funds_raised = 'None';

UPDATE layoffs_staging2
SET funds_raised = null
WHERE funds_raised = 'None';

SELECT count(*)
FROM layoffs_staging2
WHERE total_laid_off = 'None';

UPDATE layoffs_staging2
SET total_laid_off = null
WHERE total_laid_off = 'None';

SELECT count(*)
FROM layoffs_staging2
WHERE percentage_laid_off = '';

UPDATE layoffs_staging2
SET percentage_laid_off = null
WHERE percentage_laid_off = '';

-- Step 4. Removing unnecessary columns or rows

SELECT *
FROM layoffs_staging2
WHERE (total_laid_off = 'None' OR total_laid_off = '0' OR total_laid_off IS NULL)
AND (percentage_laid_off = '' OR percentage_laid_off = '0' OR percentage_laid_off IS NULL);

DELETE
FROM layoffs_staging2
WHERE (total_laid_off = 'None' OR total_laid_off = '0' OR total_laid_off IS NULL)
AND (percentage_laid_off = '' OR percentage_laid_off = '0' OR percentage_laid_off IS NULL);

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
