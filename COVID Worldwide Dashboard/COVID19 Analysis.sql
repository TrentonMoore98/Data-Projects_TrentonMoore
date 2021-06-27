-- import datasets
SELECT 
  * 
FROM 
  `probable-sprite-316417.covid_death.covid_data` 
WHERE 
  continent IS NOT NULL 
ORDER BY 
  3, 
  4;
SELECT 
  * 
FROM 
  `probable-sprite-316417.covid_death.CovidVaccinations` 
ORDER BY 
  1, 
  2;
  
-- GLOBAL NUMBERS
-- Showcase Total Cases, Total Deaths, and Effectiveness of the virus (Death Percentage)
-- 1. TABLEAU QUERY 1
SELECT 
  SUM(new_cases) AS total_cases, 
  SUM(new_deaths) AS total_deaths, 
  (
    SUM(new_deaths) / SUM(new_cases)
  )* 100 As DeathPercentage 
FROM 
  `probable-sprite-316417.covid_death.covid_data` 
WHERE 
  continent IS NOT NULL 
ORDER BY 
  1, 
  2;
  
-- GLOBAL NUMBERS BY DATE
-- We can see from our data the 5 deadliest days of covid
SELECT 
  date, 
  SUM(new_cases) AS total_cases, 
  SUM(new_deaths) AS total_deaths, 
  (
    SUM(new_deaths) / SUM(new_cases)
  )* 100 As DeathPercentageDaily 
FROM 
  `probable-sprite-316417.covid_death.covid_data` 
WHERE 
  continent IS NOT NULL 
  AND new_deaths IS NOT NULL 
  AND total_deaths IS NOT NULL 
  AND new_cases IS NOT NULL 
GROUP BY 
  date 
ORDER BY 
  DeathPercentageDaily DESC 
LIMIT 
  5;
  
-- Showing countries with higest death count per population
-- I converted total_deaths to an integer datatype with "CAST" in order to get accurate number
-- Added "WHERE" line to get rid of duplicate data 
--2. TABLEAU QUERY 2
SELECT 
  Location, 
  MAX(
    CAST(total_deaths AS int64)
  ) AS Total_Death_Count 
FROM 
  `probable-sprite-316417.covid_death.covid_data` 
WHERE 
  continent IS NOT NULL 
  AND location not in (
    'International', 'World', 'European Union'
  ) 
GROUP BY 
  location 
ORDER BY 
  Total_Death_Count DESC;
  
-- Looking at countries with highest infection rate compared to population
-- Aggregate countries daily data and population using "GROUP BY" in order to get full scope
-- 3. TEABLEAU QUERY 3
SELECT 
  Location, 
  population, 
  MAX(total_cases) AS Highest_Infection_Count, 
  MAX(
    (total_cases / population)
  )* 100 AS PercentPopulationInfected 
FROM 
  `probable-sprite-316417.covid_death.covid_data` 
GROUP BY 
  location, 
  population 
ORDER BY 
  PercentPopulationInfected DESC;
  
-- 4. TABLEAU QUERY 4
-- I build a time series that shows Infection rate for each country, over the course of Jan 2020 - May 2021
Select 
  Location, 
  Population, 
  date, 
  MAX(total_cases) as HighestInfectionCount, 
  Max(
    (total_cases / population)
  )* 100 as PercentPopulationInfected 
From 
  `probable-sprite-316417.covid_death.covid_data` 
Group by 
  Location, 
  Population, 
  date 
order by 
  PercentPopulationInfected desc;
 
 
-- Looking at Total Cases vs Total Deaths
-- DeathPercentage is the rate of death divided by total infected, represented as a percentage
SELECT 
  Location, 
  date, 
  population, 
  total_cases, 
  total_deaths, 
  (total_deaths / total_cases)* 100 AS DeathPercentage 
FROM 
  `probable-sprite-316417.covid_death.covid_data` 
ORDER BY 
  1, 
  2;
-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid-19 in 2021
SELECT 
  Location, 
  date, 
  population, 
  total_cases, 
  total_deaths, 
  (total_cases / population)* 100 AS Pop_Infected 
FROM 
  `probable-sprite-316417.covid_death.covid_data` 
WHERE 
  location = 'United States' 
  AND date > '2020-12-31' 
ORDER BY 
  1, 
  2;

-- NOW LOOKING AT CONTINENT DATA
-- Showing continents with the highest death count per population
SELECT 
  continent, 
  MAX(
    CAST(total_deaths AS int64)
  ) AS Total_Death_Count 
FROM 
  `probable-sprite-316417.covid_death.covid_data` 
WHERE 
  continent IS NOT NULL 
GROUP BY 
  continent 
ORDER BY 
  Total_Death_Count DESC;


-- We can see from our data the 5 LEAST deadliest days of covid
SELECT 
  date, 
  SUM(new_cases) AS total_cases, 
  SUM(new_deaths) AS total_deaths, 
  (
    SUM(new_deaths) / SUM(new_cases)
  )* 100 As DeathPercentageDaily 
FROM 
  `probable-sprite-316417.covid_death.covid_data` 
WHERE 
  continent IS NOT NULL 
  AND new_deaths IS NOT NULL 
  AND total_deaths IS NOT NULL 
  AND new_cases IS NOT NULL 
GROUP BY 
  date 
ORDER BY 
  DeathPercentageDaily ASC 
LIMIT 
  5;
-- Looking at Total Population vs Population Vaccinated
-- JOINING COVID DEATH AND VACCINATION DATA
-- PARTITION vaccinations by location. Do not want the aggregate function to keep running.
-- ORDER BY inside my partition to order the countries, and order by date to separate the data by date
-- This will create a rolling count of people vaccinated
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  SUM(vac.new_vaccinations) OVER (
    PARTITION BY dea.location 
    ORDER BY 
      dea.location, 
      dea.date
  ) AS RollingCountVaccinated 
FROM 
  `probable-sprite-316417.covid_death.covid_data` dea 
  JOIN `probable-sprite-316417.covid_death.CovidVaccinations` vac ON dea.location = vac.location 
  AND dea.date = vac.date 
WHERE 
  dea.continent IS NOT NULL 
ORDER BY 
  2, 
  3;
-- COUNTRY'S POPULATION VACCINATION RATE
-- USE TEMP TABLE to easier organize and store data, and use for later querying.
-- Optional "DROP TABLE" function added if you want additional alterations, certain versions of SQL will give an error if not added.
-- Also would delete the "TEMP" if this line were being used.
-- DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE temp TABLE PercentPopulationVaccinated(
  continent string, location string, 
  date DATETIME, population NUMERIC, 
  new_vaccinations NUMERIC, RollingCountVaccinated NUMERIC
);
INSERT INTO PercentPopulationVaccinated 
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  SUM(vac.new_vaccinations) OVER (
    PARTITION BY dea.location 
    ORDER BY 
      dea.location, 
      dea.date
  ) AS RollingCountVaccinated 
FROM 
  `probable-sprite-316417.covid_death.covid_data` dea 
  JOIN `probable-sprite-316417.covid_death.CovidVaccinations` vac ON dea.location = vac.location 
  AND dea.date = vac.date 
WHERE 
  dea.continent IS NOT NULL 
  AND vac.continent IS NOT NULL 
ORDER BY 
  2, 
  3;
SELECT 
  *, 
  (
    RollingCountVaccinated / population
  )* 100 AS Total_Vaccinated_Percent 
FROM 
  PercentPopulationVaccinated;

-- From here, I can pull my BigQuery data directly from Tableau or
-- I can also put my data back into excel and export to Tableau
-- If I were however using SQL Server, or one that is maybe not connected via Tabluea,
-- I could create a view to send it to Tableau
  
