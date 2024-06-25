select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select * 
from PortfolioProject..CovidVaccinations
order by 3,4

select location, date, total_cases, new_cases , total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- looking at Total cases vs Total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

-- looking at total cases vs population

select location, date, population, total_cases, (total_cases/population) * 100 as InfectionPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

-- looking at Countries with highest infection rate compared to population

select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)) * 100 as InfectionPercentage
from PortfolioProject..CovidDeaths
--where location like '%india%'
group by location, population
order by InfectionPercentage desc

-- looking at countries with highest death rate per population

select location, Max(cast(total_deaths as int)) as HighestdeathCount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by location
order by HighestdeathCount desc

--BY CONTINENT
--showing continents with the highest death count per population

select Continent, Max(cast(total_deaths as int)) as HighestdeathCount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by HighestdeathCount desc

--Global numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Joining two tables we have
select *
from PortfolioProject..CovidDeaths
order by location, date

select *
from PortfolioProject..CovidVaccinations
order by location, date

select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
--,(RollingVaccinationCount/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Since we can't use column (RollingVaccinationCount) as it is because we just created it, we will use two methods to solve this: CTE or TEMP table
--CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount) as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
--,(RollingVaccinationCount/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT * , (RollingVaccinationCount/population)*100 as PercentageVaccinated
FROM PopvsVac

--TEMP Table
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingVaccinationCount numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT * , (RollingVaccinationCount/population)*100 as PercentageVaccinated
FROM #PercentagePopulationVaccinated

--Creating views for later

CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

CREATE VIEW Highestdeathcountcountries AS
select location, Max(cast(total_deaths as int)) as HighestdeathCount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by location


SELECT * 
FROM PercentagePopulationVaccinated

