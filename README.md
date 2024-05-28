# Layoffs Worldwide 

Companies around the globe are fighting an economy slowdown and have started laying employees off. The objective here is to explore the global layoffs data publicly available online from when COVID-19 was declared as a pandemic to understand the numbers and discover useful insights.

Dates from 01/01/2020 to 30/04/2021.

***Public DataSet:*** 🔗[Kaggle - Layoffs Dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022/data)

## 🛠 Skills used: 

**Database:** Laragon Full 6.0 Server, MySQL Workbench 8.0

**Data Manipulation:** SQL

# Data Cleaning

- Remove Duplicates
- Standardize the Data
- Null Values or Blank Values
- Remove unnecessary columns or rows

# Data Exploration

Some of the queries created and the results:

**1-** Looking at companies which had 100 percent of they company laid off

```sql
SELECT company, location, country, industry, funds_raised
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY CAST(funds_raised AS SIGNED) DESC;
```

Result: 

![CompaniesClosing](https://raw.githubusercontent.com/anapsoliveira/Layoffs-Worldwide/main/images/Result1.JPG)

**Deliveroo Australia raised 1.8 billion and went under.



**2-** Top 10 companies with the biggest layoffs

```sql
SELECT company, SUM(CAST(total_laid_off AS SIGNED)) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY sum_total_laid_off DESC
LIMIT 10;
```

Result: 

![BiggestLayoffs](https://raw.githubusercontent.com/anapsoliveira/Layoffs-Worldwide/main/images/Result2.JPG)

**3-** Looking at the total laid off rolling out by month

```sql
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `Year-Month`, SUM(CAST(total_laid_off AS SIGNED)) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY `Year-Month`
)
SELECT `Year-Month`, sum_total_laid_off
	, SUM(sum_total_laid_off) OVER(ORDER BY `Year-Month`) AS rolling_total_layoffs
FROM Rolling_Total;
```

Result: 

![RollingTotals](https://raw.githubusercontent.com/anapsoliveira/Layoffs-Worldwide/main/images/Result3.JPG)


# Data Visualization

🔗[ World Layoffs | Tableau Public](https://public.tableau.com/views/WordLayoffs/Dashboard1?:language=en-US&:sid=&:display_count=n&:origin=viz_share_link)

![Tableau Dashboard](https://raw.githubusercontent.com/anapsoliveira/Layoffs-Worldwide/main/images/Visualization.JPG)


## Some notes:

- It is possible to use Data Scraping to populate the null values on funds_raised column.
- It would be nice to know the total employees that each company had so we could analyse the percentage laid off.

## Authors 👋

- [@anapsoliveira](https://www.github.com/anapsoliveira)

[![portfolio](https://img.shields.io/badge/my_portfolio-000?style=for-the-badge&logo=ko-fi&logoColor=white)](https://github.com/anapsoliveira)

[![linkedin](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/anapsoliveira/)
