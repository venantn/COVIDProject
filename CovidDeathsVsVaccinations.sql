SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 3,4
;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4
;
 --Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

-- Looking at total cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

-- Looking at total cases vs Population
-- Shows what percentage of population got COVID

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

-- Looking at countries with highest infection rate

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Group by Location, Population
ORDER BY PercentPopulationInfected desc
;

--Showing countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
Group by Location
ORDER BY TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTIENT



-- Showing continents with the highet death count
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is null AND location NOT LIKE '%income%' AND location NOT LIKE '%World%'
Group by location
ORDER BY TotalDeathCount desc


--GLOBAL NUMBERS
-- Tells us number of cases, number of deaths and the death percentage for the entire reporting population, everyday

SELECT date, SUM(new_cases)as TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not null 
Group by date
ORDER BY 1,2;

-- Tells us the total of totals 
SELECT  SUM(new_cases)as TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not null 
--Group by date
ORDER BY 1,2;



--Lets join our vaccination table with the covid deaths table


SELECT *
FROM PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	and dea.date = vac.date
;

--Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	and dea.date = vac.date
order by 2,3

--USE CTE

With PopVsVac (Continent, Loation, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/ Population)*100
From PopVsVac

----------------------------------------------
-- USE A TEMP TABLE
DROP Table is exists #PercentPopulation Vaccinated
CREATE TABLE #PercentPopulationVaccinated
 (
 Continent nvarchar(255), 
 Location nvarchar(255),
 Date datetime, 
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/ Population)*100
From #PercentPopulationVaccinated;


--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Create View TotalDeathsPerCountry AS
SELECT date, SUM(new_cases)as TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not null 
Group by date
--ORDER BY 1,2;
