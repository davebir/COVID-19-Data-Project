-- Select Data that we are going to be starting with

SELECT 
    Location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    CovidDeaths_
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2;



-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT 
    Location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS DeathPercentage
FROM
    CovidDeaths_
WHERE
    location LIKE '%states%'
        AND continent IS NOT NULL
ORDER BY 1 , 2;



-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT 
    Location,
    date,
    Population,
    total_cases,
    (total_cases / population) * 100 AS PercentPopulationInfected
FROM
    CovidDeaths_
ORDER BY 1 , 2;



-- Countries with Highest Infection Rate compared to Population

SELECT 
    Location,
    Population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM
    CovidDeaths_
WHERE
	location like '%states'
GROUP BY Location , Population
ORDER BY PercentPopulationInfected DESC;



-- Countries with Highest Death Count per Population

SELECT 
    Location,
    MAX(CAST(Total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM
    CovidDeaths_
WHERE
    continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;



-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

SELECT 
    continent,
    MAX(CAST(Total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM
    CovidDeaths_
WHERE
    continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;



-- GLOBAL NUMBERS --
-- DAILY PERCENTAGE

SELECT
	date,
    SUM(new_cases) AS TotalCases,
    SUM(CAST(new_deaths AS UNSIGNED)) AS NewDeaths,
    SUM(CAST(new_deaths AS UNSIGNED)) / SUM(new_cases) * 100 AS DeathPercentage
FROM
    CovidDeaths_
WHERE
    continent IS NOT NULL
GROUP BY date
ORDER BY CAST(date AS date);



-- OVERALL GLOBAL PERCENTAGE

SELECT
    SUM(new_cases) AS TotalCases,
    SUM(CAST(new_deaths AS UNSIGNED)) AS NewDeaths,
    SUM(CAST(new_deaths AS UNSIGNED)) / SUM(new_cases) * 100 AS DeathPercentage
FROM
    CovidDeaths_
WHERE
    continent IS NOT NULL
ORDER BY CAST(date AS date);



-- JOIN --

SELECT 
    *
FROM
    CovidDeaths_ dea
        JOIN
    CovidVaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date;
	
	

-- Looking at total population vs vaccination
-- How many people in the world have ben vaccinated

SELECT
	dea.continent, 
	dea.location, 
    	dea.date, 
    	dea.population, 
    	vac.new_vaccinations,
    	SUM(CONVERT(vac.new_vaccinations, UNSIGNED)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
FROM CovidDeaths_ dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null AND dea.location = 'United States'
ORDER BY 2,3;



-- USING CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(
SELECT
	dea.continent, 
	dea.location, 
    	dea.date, 
    	dea.population, 
   	vac.new_vaccinations,
	SUM(CONVERT(vac.new_vaccinations, unsigned)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
-- 	(RollingPeopleVaccinated/population)*100
FROM CovidDeaths_ dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null AND dea.location = 'United States'
-- order by 2,3	
)
SELECT *,
    (RollingPeopleVaccinated / Population)
FROM PopvsVac;



-- CREEATING VIEWS TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentPopulationPopulated AS
SELECT
	dea.continent, 
	dea.location, 
    	dea.date, 
    	dea.population, 
   	vac.new_vaccinations,
	SUM(CONVERT(vac.new_vaccinations, unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM CovidDeaths_ dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null


