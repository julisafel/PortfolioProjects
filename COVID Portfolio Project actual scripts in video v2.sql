SELECT *
FROM PortfolioProjecct..CovidDeaths
Where continent is not null
order by 3,4
 

SELECT *
FROM PortfolioProjecct..CovidVaccinations
order by 3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjecct..CovidDeaths
order by 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From PortfolioProjecct..CovidDeaths
order by 1,2

--CHECKING U.S.
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjecct..CovidDeaths
Where location like '%states%'
order by 1,2

--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID
SELECT Location, date, total_cases, Population,(total_cases/Population)*100 as PercentPopulationInfected
FROM PortfolioProjecct..CovidDeaths
WHERE Location like '%states%'
order by 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE
SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM PortfolioProjecct..CovidDeaths
-- Where location like '%states%'
Group by location, Population
order by PercentPopulationInfected desc

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProjecct..CovidDeaths
-- Where location like '%states%'
Group by location
order by TotalDeathCount desc

--USING CAST
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjecct..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc


--BREAKING THINGS DOWN BY CONTIENT

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjecct..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



--SHOWING CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjecct..CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
From PortfolioProjecct..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By date
order by 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProjecct..CovidDeaths dea
,(RollingPeopleVaccinated/population)*100
JOIN PortfolioProjecct..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProjecct..CovidDeaths dea
Join PortfolioProjecct..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE


Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProjecct..CovidDeaths dea
JOIN PortfolioProjecct..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--USED IF WE MAKE ALTERATIONS

Drop Table if exists #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProjecct..CovidDeaths dea
JOIN PortfolioProjecct..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3





CREATE VIEW TotalPopulationvsVaccinations AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (
        PARTITION BY dea.Location 
        ORDER BY dea.Date
    ) AS RollingPeopleVaccinated,
    (SUM(CONVERT(INT, vac.new_vaccinations)) OVER (
        PARTITION BY dea.Location 
        ORDER BY dea.Date
    ) / NULLIF(dea.population, 0)) * 100 AS PercentVaccinated
FROM PortfolioProjecct..CovidDeaths dea
JOIN PortfolioProjecct..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;




CREATE VIEW HighestDeathPerPopulation AS
SELECT 
    continent, 
    MAX(CAST(COALESCE(total_deaths, 0) AS INT)) AS TotalDeathCount
FROM PortfolioProjecct..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent;
