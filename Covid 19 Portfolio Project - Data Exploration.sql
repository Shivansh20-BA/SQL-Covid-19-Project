/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


-- Select Data that we are going to be starting with

SELECT continent, location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 2, 3;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT  location, date, total_cases, total_deaths, population, 
ROUND((total_deaths/total_cases) * 100, 2) as Death_Percentage
FROM CovidDeaths
--WHERE location LIKE '%INDIA%' AND continent IS NOT NULL
ORDER BY 1, 2;



-- Total Cases vs Population
-- Shows what percentage of population infected with Covid


SELECT  location, date, total_deaths, total_cases, population, 
ROUND((total_cases/population) * 100, 2) as Cases_Percentage
FROM CovidDeaths
--WHERE location LIKE '%STATES%'
WHERE continent IS NOT NULL
ORDER BY 1, 2;



-- Countries with Highest Infection Rate compared to Population


SELECT  location, population, 
ROUND(MAX((total_cases/population) * 100), 2) as Cases_Percentage
FROM CovidDeaths
--WHERE location LIKE '%STATES%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Cases_Percentage DESC;




-- Countries with Highest Death Count per Population

SELECT  location, MAX(CONVERT(INT, total_deaths)) Total_Deaths  
FROM CovidDeaths
--WHERE location LIKE '%STATES%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Deaths DESC; 





-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population


SELECT  continent, MAX(CONVERT(INT, total_deaths)) Total_Deaths  
FROM CovidDeaths
--WHERE location LIKE '%STATES%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Deaths DESC; 



-- GLOBAL NUMBERS OF CASES


SELECT date, SUM(CAST(new_cases AS int)) Total_Cases, SUM(population) POPULATION,
ROUND((SUM(CAST(new_cases AS int))/SUM(population)) * 100, 4) as Cases_Percentage
FROM CovidDeaths
--WHERE location LIKE '%STATES%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1;



SELECT SUM(CAST(new_cases AS int)) Total_Cases, SUM(population) Population,
Round((SUM(CAST(new_cases AS float))/SUM(population)) * 100, 4) as Cases_Percentage
FROM CovidDeaths
--WHERE location LIKE '%STATES%'
WHERE continent IS NOT NULL
ORDER BY 1;



-- GLOBAL NUMBERS OF DEATHS


SELECT date, SUM(CAST(new_cases AS int)) Total_Cases, SUM(CAST(new_deaths AS int)) Total_Deaths,
ROUND(SUM(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float)) * 100, 2) as Deaths_Percentage
FROM CovidDeaths
--WHERE location LIKE '%STATES%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1;


SELECT SUM(CAST(new_cases AS int)) Total_Cases, SUM(CAST(new_deaths AS int)) Total_Deaths,
ROUND(SUM(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float)) * 100, 2) as Deaths_Percentage
FROM CovidDeaths
WHERE location LIKE '%India%'
and continent IS NOT NULL
ORDER BY 1;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(int, CV.new_vaccinations)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.Location, CD.Date) AS RollingPeopleVaccinated
FROM CovidDeaths CD
JOIN CovidVaccinations CV
	ON CD.location = CV.location 
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL -- AND CD.location LIKE '%INDIA%'
ORDER BY 2, 3;


-- Using CTE to perform Calculation on Partition By in previous query


WITH PopvsVac AS
(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(int, CV.new_vaccinations)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.Location, CD.Date) AS RollingPeopleVaccinated
FROM CovidDeaths CD
JOIN CovidVaccinations CV
	ON CD.location = CV.location 
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL --AND CD.location LIKE '%INDIA%'
--ORDER BY 2, 3;
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(int, CV.new_vaccinations)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.Location, CD.Date) AS RollingPeopleVaccinated
FROM CovidDeaths CD
JOIN CovidVaccinations CV
	ON CD.location = CV.location 
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL --AND CD.location LIKE '%INDIA%'
--ORDER BY 2, 3;

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations


CREATE VIEW PercentPopulationVaccinated AS
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(int, CV.new_vaccinations)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.Location, CD.Date) AS RollingPeopleVaccinated
FROM CovidDeaths CD
JOIN CovidVaccinations CV
	ON CD.location = CV.location 
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL --AND CD.location LIKE '%INDIA%'
--ORDER BY 2, 3;

SELECT * 
FROM PercentPopulationVaccinated
ORDER BY 2, 3;