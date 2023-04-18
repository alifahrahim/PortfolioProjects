--Initial Data Check
SELECT *
FROM 
	PortfolioProject.dbo.CovidDeaths
WHERE
	continent IS NOT NULL
ORDER BY 
	3,4

SELECT *
FROM 
	PortfolioProject.dbo.CovidVaccinations
WHERE
	continent IS NOT NULL
ORDER BY 
	3,4

--Select Data that will be used
SELECT 
	location, date, total_cases, new_cases, total_deaths, population
FROM 
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
ORDER BY 
	1,2

--Looking at Total Cases vs Total Deaths
--Shows likelyhood of death, if contracting virus in a certain country
SELECT
	location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM 
	PortfolioProject..CovidDeaths
WHERE 
	location LIKE '%Indonesia%'
AND
	continent IS NOT NULL
ORDER BY 
	1,2

--Looking at Total Cases vs Population
SELECT
	location, date, total_cases, population, (total_cases/population)*100 AS covid_percentage
FROM 
	PortfolioProject..CovidDeaths
--WHERE 
	--location LIKE '%Emirates%'
--AND
	--continent IS NOT NULL
ORDER BY 
	1,2

--Looking at Countries with Highest Infection Rate with Respect to Population
SELECT
	location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS covid_percentage
FROM 
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	location, population
ORDER BY 
	covid_percentage DESC

--Showing Countries with Highest Death Count per Population
SELECT
	location, MAX(total_deaths) AS highest_death_count
FROM 
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	location
ORDER BY 
	highest_death_count DESC

--Showing total death in each continent
SELECT
	location, MAX(total_deaths) AS total_death_count
FROM 
	PortfolioProject..CovidDeaths
WHERE
	continent IS NULL
GROUP BY
	location
ORDER BY 
	total_death_count DESC

--Showing highest death count in each continent
SELECT
	location, MAX(total_deaths) AS highest_death_count
FROM 
	PortfolioProject..CovidDeaths
WHERE
	continent IS NULL 
GROUP BY
	location
ORDER BY
	highest_death_count DESC

--Total Global Numbers
SELECT
	SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,(SUM(new_deaths)/SUM(new_cases))*100 AS global_death_percentage
FROM 
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
ORDER BY 
	1,2


--Joining two tables to look at Total Population vs. Vaccinations
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM 
	PortfolioProject.dbo.CovidDeaths dea
JOIN
	PortfolioProject.dbo.CovidVaccinations vac
	On
		dea.location = vac.location
	and	dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
ORDER BY
	2,3

--Calculate Percentage of Rolling People Vaccinated using CTE
WITH population_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM 
	PortfolioProject.dbo.CovidDeaths dea
JOIN
	PortfolioProject.dbo.CovidVaccinations vac
	On
		dea.location = vac.location
	and	dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
)

SELECT *, (rolling_people_vaccinated/population)*100 AS rolling_vaccination_percentage
FROM
	population_vs_vac


--Calculate Percentage of Rolling People Vaccinated using Temp Table 
DROP TABLE IF EXISTS #RollingVaccinationPercentage
CREATE TABLE #RollingVaccinationPercentage
	(
	continent nvarchar(255), 
	location nvarchar(255), 
	date datetime, 
	population numeric, 
	new_vaccinations numeric, 
	rolling_people_vaccinated numeric
	)
INSERT INTO #RollingVaccinationPercentage
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM 
	PortfolioProject.dbo.CovidDeaths dea
JOIN
	PortfolioProject.dbo.CovidVaccinations vac
	On
		dea.location = vac.location
	and	dea.date = vac.date
WHERE
	dea.continent IS NOT NULL

SELECT *, (rolling_people_vaccinated/population)*100 AS rolling_vaccination_percentage
FROM
	#RollingVaccinationPercentage

--Creating view for future Data Visualizations
CREATE VIEW RollingVaccinationPercentage AS
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_people_vaccinated
FROM 
	PortfolioProject.dbo.CovidDeaths dea
JOIN
	PortfolioProject.dbo.CovidVaccinations vac
	On
		dea.location = vac.location
	and	dea.date = vac.date
WHERE
	dea.continent IS NOT NULL

SELECT *
FROM RollingVaccinationPercentage
