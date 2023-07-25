Select *
From CovidProject.dbo.CovidDeaths$
order by 3,4

Select *
From CovidProject.dbo.CovidVaccinations$
order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject.dbo.CovidDeaths$
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contacted Covid in different countries

Select Location
, date
, total_cases
, total_deaths
, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject.dbo.CovidDeaths$
Where location like '%states%'
order by 1,2

-- Looking at Total cases vs Population

Select Location
, date,population
, total_cases,(total_cases/population)*100 as CasesPercentage
From CovidProject.dbo.CovidDeaths$
Where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location
, population
, MAX(total_cases) as highestInfectionCount
, MAX(total_cases/population)*100 as CasesPercentage
From CovidProject.dbo.CovidDeaths$
Group by location, population
order by CasesPercentage desc

-- Showing Countires with Highest Death Count per Population

Select Location
, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject.dbo.CovidDeaths$
Where continent is not null
Group by location, population
order by TotalDeathCount desc

-- BREAK THINGS DOWN BY CONTINENT



-- Contintents with the highest death count
Select location
, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject.dbo.CovidDeaths$
where continent is null
Group by location
Order by TotalDeathCount desc

-- shows covid death percentages over a period of time

Select Location
, date
, total_cases
, total_deaths
, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject.dbo.CovidDeaths$
where continent is null
order by 1,2

-- shows covid death percentages in Africa over time time
Select Location
, date
, total_cases
, total_deaths
, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject.dbo.CovidDeaths$
where continent is null 
and location = 'Africa'
order by 1,2


-- GLOBAL NUMBERS
-- shows the highest death percentages in the world
Select date
, SUM(new_cases) as Total_Cases
, SUM(cast(new_deaths as int)) as Total_Deaths
, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM CovidProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Total number of cases, deaths and death percentage
Select SUM(new_cases) as Total_Cases
, SUM(cast(new_deaths as int)) as Total_Deaths
, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM CovidProject.dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 1,2


-- Total population vs Vaccination

With PopvsVac( continent
, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT d.continent
, d.location
, d.date
, d.population
, v.new_vaccinations
, SUM(Cast(v.new_vaccinations as int)) OVER (Partition by d.location ORDER by d.location ,
d.date) as RollingPeopleVaccinated
FROM CovidProject.dbo.CovidDeaths$ d
JOIN CovidProject.dbo.CovidVaccinations$ v
on d.location = v.location
and d.date = v.date
WHERE d.continent is not null
)

select * 
, (RollingPeopleVaccinated/Population) *100 as VaccinatedPopulation
from PopvsVac

-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255)
, Location nvarchar(255)
, Date datetime
, Population numeric
, New_Vaccinations bigint
, RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT d.continent
, d.location
, d.date
, d.population
, v.new_vaccinations
, SUM(CONVERT(int, v.new_vaccinations)) OVER (Partition by d.location ORDER by d.location ,
d.date) as RollingPeopleVaccinated
FROM CovidProject.dbo.CovidDeaths$ d
JOIN CovidProject.dbo.CovidVaccinations$ v
on d.location = v.location
and d.date = v.date
WHERE d.continent is not null

-- Creating Views

Create View PercentPopulationVaccinated as
SELECT d.continent
, d.location
, d.date
, d.population
, v.new_vaccinations
, SUM(CONVERT(int, v.new_vaccinations)) OVER (Partition by d.location ORDER by d.location ,
d.date) as RollingPeopleVaccinated
FROM CovidProject.dbo.CovidDeaths$ d
JOIN CovidProject.dbo.CovidVaccinations$ v
on d.location = v.location
and d.date = v.date
WHERE d.continent is not null

SELECT *
FROM PercentPopulationVaccinated
