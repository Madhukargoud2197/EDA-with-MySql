-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2 ;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2 ;

# We can see that some companies laid off 100% of there employees, lets have a look at them.
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

#Lets check what was the funding of these companies that laidoff 100% and how many people were laid off.
SELECT company, total_laid_off, percentage_laid_off, funds_raised_millions
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC; # That looks really a spam from these companies, 2400 funds and 100% layoffs, thats really bad.

# Lets see how many employees each company laidoff and lets order them from most to least.
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC ; # Thats hard to digest that all these MNC'S are layingoff these many people.

# Lets see in what span period these layoffs happened.
SELECT MIN(`date`), MAX(`date`)
from layoffs_staging2 ; # From 2020 to 2023 (3 yrs).

# Lets see which country got affected the most with respect to the layoffs.
SELECT country, Sum(total_laid_off) as layoff_in_country
from layoffs_staging2
group by country
order by 2 DESC ;

# Lets check year by layoff
SELECT year(`date`), Sum(total_laid_off) as layoff_in_country
from layoffs_staging2
group by year(`date`)
order by 1 DESC ;

# Lets do the Rolling total of the layoffs
Select SUBSTRING(`date`,1,7) as `Month`, SUM(total_laid_off)
from layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 asc ; # We have the monthwise layoffs, now we create a cte and orderby month, lets see that

WITH Rolling_Total as
(
Select SUBSTRING(`date`,1,7) as `Month`, SUM(total_laid_off) AS total_off
from layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 asc 
)
SELECT `Month`, total_off,
SUM(total_off) over(order by `Month`) as rolling_total
FROM Rolling_Total ;

#Lets Rank the companies by the number of layoffs and see how these companies laidoff employees by each year
Select company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
group by company, YEAR(`date`)
order by SUM(total_laid_off) desc ;

# Lets now rank the companies based on there laidoffs wrt years.
# lets create an cte so it will be good visually.

WITH 
Company_Year (company, years, total_laidoff) AS
(
Select company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
group by company, YEAR(`date`)
), 
Company_year_rank as     # We are creating this additional cte so that we can find top 5 companies wrt layoffs partitioned by year
(select *,
dense_rank() over (
partition by years 
order by total_laidoff desc) AS RANKING
From Company_Year
WHERE years IS NOT NULL
)
select *
from Company_year_rank 
where RANKING <= 5 ;



