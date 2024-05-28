-- EXPLORATORY DATA ANALYSIS

SELECT *
FROM layoffs_staging2;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Looking at laid_offs to see how big these layoffs were
SELECT MAX(CAST(total_laid_off AS SIGNED)), MAX(CAST(percentage_laid_off AS SIGNED))
FROM layoffs_staging2;

-- Looking at Percentage to see how big the impact of these layoffs were to the companies
SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM world_layoffs.layoffs_staging2;

-- Looking at companies which had 100 percent of they company laid off
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY CAST(funds_raised AS SIGNED) DESC;
-- it looks like these are mostly startups who all went out of business during this time
-- if we order by funcs_raised we can see how big some of these companies were
-- Deliveroo Australia raised 1.8 billion and went under

-- Companies with the biggest Layoff on a single day
SELECT company, CAST(total_laid_off AS SIGNED) AS sum_total_laid_off
FROM layoffs_staging2
ORDER BY sum_total_laid_off DESC
LIMIT 5;

-- Companies with the biggest layoffs
SELECT company, SUM(CAST(total_laid_off AS SIGNED)) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY sum_total_laid_off DESC
LIMIT 10;

-- by location 
SELECT country, location, SUM(CAST(total_laid_off AS SIGNED)) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY country, location
ORDER BY sum_total_laid_off DESC
LIMIT 15;

-- by country 
SELECT country,  SUM(CAST(total_laid_off AS SIGNED)) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY sum_total_laid_off DESC
LIMIT 15;

-- by stage
SELECT stage, SUM(CAST(total_laid_off AS SIGNED)) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY sum_total_laid_off DESC;

-- by industry
SELECT industry, SUM(CAST(total_laid_off AS SIGNED)) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY industry
ORDER BY sum_total_laid_off DESC;
-- Retail, Consumer and Transportation are the most affected industries

-- Looking at the total laid off by Year
SELECT YEAR(`date`) AS `Year`, SUM(CAST(total_laid_off AS SIGNED)) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY `Year`
ORDER BY `Year` DESC;

-- by month
SELECT SUBSTRING(`date`,1,7) AS `Year-Month`, SUM(CAST(total_laid_off AS SIGNED)) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY `Year-Month`
ORDER BY `Year-Month`;

-- Looking at the total laid off rolling out by month
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `Year-Month`, SUM(CAST(total_laid_off AS SIGNED)) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY `Year-Month`
)
SELECT `Year-Month`, sum_total_laid_off
	, SUM(sum_total_laid_off) OVER(ORDER BY `Year-Month`) AS rolling_total_layoffs
FROM Rolling_Total;

-- Showing the top 5 companies with highest total layoff per year
WITH Company_Year AS
(
SELECT company, YEAR(`date`) As `Year`, SUM(CAST(total_laid_off AS SIGNED)) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, 
	DENSE_RANK() OVER (PARTITION BY `Year` ORDER BY sum_total_laid_off DESC) AS Ranking
FROM Company_Year
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;


-- Creating views for further visualization:

-- Looking at companies which had 100 percent of they company laid off
DROP VIEW IF EXISTS companies_out;
CREATE VIEW companies_out AS
(
	SELECT company, industry, total_laid_off, country, funds_raised
	FROM layoffs_staging2
	WHERE percentage_laid_off = 1
	ORDER BY CAST(funds_raised AS SIGNED) DESC
);

SELECT *
FROM companies_out;

-- Looking at the total laid off rolling out per country by month
DROP VIEW IF EXISTS rolling_month;

CREATE VIEW rolling_month AS
(
	WITH Rolling_Total AS
	(
	SELECT country, SUBSTRING(`date`,1,7) AS `Year-Month`, SUM(CAST(total_laid_off AS SIGNED)) AS sum_total_laid_off
	FROM layoffs_staging2
	WHERE total_laid_off IS NOT NULL
    GROUP BY country, `Year-Month`
    ORDER BY country
	)
	SELECT country, `Year-Month`, sum_total_laid_off
		, SUM(sum_total_laid_off) OVER(ORDER BY `Year-Month`) AS rolling_total_layoffs
	FROM Rolling_Total
    ORDER BY country, `Year-Month`
);

SELECT *
FROM rolling_month;

-- Looking at the total laid off by Year, countr, company and industry
DROP VIEW IF EXISTS layoffs_totals;

CREATE VIEW layoffs_totals AS
(
	SELECT YEAR(`date`) AS `Year`, country , company, industry, SUM(CAST(total_laid_off AS SIGNED)) AS sum_total_laid_off
	FROM layoffs_staging2
	WHERE total_laid_off IS NOT NULL
	GROUP BY `Year`, country, company, industry
	ORDER BY `Year`, country ASC
);

SELECT *
FROM layoffs_totals;


