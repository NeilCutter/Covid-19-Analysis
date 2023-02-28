ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths float;

--Number of Countries
SELECT COUNT(DISTINCT Location) as TotalCountries
FROM Covid19_Project..CovidDeaths
WHERE continent is NOT NULL

--Looking at Total Cases vs Total Deaths
SELECT Location, MAX(total_cases) as OverallCases, MAX(total_deaths) as OverallDeaths,
(MAX(total_deaths)/MAX(total_cases)) * 100 as OverallDeathPercentage
FROM Covid19_Project..CovidDeaths
GROUP BY Location
ORDER BY Location

--Looking  at Total Cases vs Population
SELECT Location, 
MAX(population) as Population,
MAX(total_cases) as OverallCases,
(MAX(total_cases)/MAX(population)) * 100 as PopulationCovidPercentage
FROM Covid19_Project..CovidDeaths
GROUP BY Location
ORDER BY Location

--Looking at Countries with Highest and Lowest Infection Rate compared to Population
WITH HighestInfectedCountries as 
(
SELECT Location, 
	population,
	MAX(total_cases) as OverallCases, 
	MAX((total_cases/population)) * 100 as PopulationCovidPercentage
FROM Covid19_Project..CovidDeaths
GROUP BY Location, population
)
SELECT TOP(10) *
FROM HighestInfectedCountries
WHERE PopulationCovidPercentage is NOT NULL
ORDER BY PopulationCovidPercentage DESC --Remove "DESC" to check the countries with the lowest contraction of Covid-19

-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(total_deaths) as OverallDeaths
FROM Covid19_Project..CovidDeaths
WHERE continent is NOT NULL
GROUP BY Location
ORDER BY OverallDeaths DESC

-- Showing continent with the Highest Death count
SELECT continent, MAX(total_deaths) as OverallDeaths
FROM Covid19_Project..CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY OverallDeaths DESC


-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as OverallDeathPercentage
--(MAX(total_deaths)/MAX(total_cases)) * 100 as OverallDeathPercentage
FROM Covid19_Project..CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2

-- Looking at World Death Percentage Per Day
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
(SUM(cast(new_deaths as int))/SUM(new_cases)) * 100 as OverallDeathPercentage
FROM Covid19_Project..CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY date

-- CTE TABLE
WITH VaccinatedPercentage (continent, location, date, population, new_vaccinations,VaccinatedPerDay) 
as
(
-- Looking at Total Population vs Vaccinations
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CONVERT(bigint,Vac.new_vaccinations)) over 
(PARTITION BY(Dea.location) ORDER BY Dea.location, Dea.date) as VaccinatedPerDay
FROM Covid19_Project..CovidDeaths as Dea
JOIN Covid19_Project..CovidVaccinations as Vac
	ON Dea.location = Vac.location 
	AND Dea.date = Vac.date
WHERE Dea.continent is NOT NULL AND Dea.location = 'Cuba'
--ORDER BY 2,3
)
SELECT continent, location, date, population, new_vaccinations, VaccinatedPerDay, (VaccinatedPerDay/population) * 100 as VaccinatedPercent
FROM VaccinatedPercentage


-- TEMP TABLE
DROP TABLE IF EXISTS #VaccinatedPercentage
CREATE TABLE #VaccinatedPercentage
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population bigint, 
new_vaccinations int,
VaccinatedPerDay int
)
INSERT INTO #VaccinatedPercentage
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CONVERT(bigint,Vac.new_vaccinations)) over 
(PARTITION BY(Dea.location) ORDER BY Dea.location, Dea.date) as VaccinatedPerDay
FROM Covid19_Project..CovidDeaths as Dea
JOIN Covid19_Project..CovidVaccinations as Vac
	ON Dea.location = Vac.location 
	AND Dea.date = Vac.date
WHERE Dea.continent is NOT NULL AND Dea.location = 'Cuba'
--ORDER BY 2,3


Select *
FROM #VaccinatedPercentage

-- CREATING A VIEW
CREATE VIEW VaccinatedPercentage as
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, 
SUM(CONVERT(bigint,Vac.new_vaccinations)) over 
(PARTITION BY(Dea.location) ORDER BY Dea.location, Dea.date) as VaccinatedPerDay
FROM Covid19_Project..CovidDeaths as Dea
JOIN Covid19_Project..CovidVaccinations as Vac
	ON Dea.location = Vac.location 
	AND Dea.date = Vac.date
WHERE Dea.continent is NOT NULL AND Dea.location = 'Cuba'
--ORDER BY 2,3












