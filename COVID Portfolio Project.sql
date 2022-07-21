
Select * FROM CovidDeaths
WHERE continent is not null
ORDER By 3, 4


-- Select Data 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1, 2

-- Looking at total cases vs populations
-- Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
ORDER BY 1, 2


-- Looking at countries with highest infection rate compared to population 

SELECT Location, Population, max(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC


-- Looking at countries with highest infection rate compared to population WITH DATE (4)


SELECT Location, Population,date, max(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, population, date
ORDER BY PercentPopulationInfected DESC



-- Showing Countries with Highest Death Count per Population

SELECT location, max(cast(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Break things down by continent 
-- Showing continents with the highest death count per population

SELECT continent, max(cast(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers 

SELECT sum(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE location like '%states%'
where continent is not null
--GROUP BY date
ORDER BY 1, 2


-- We take these out as they are not included in the above queries and want to stay consistent 
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is null 
AND location not in ('World','European Union', 'International')
AND location NOT LIKE '%Income'
GROUP BY location 
ORDER BY TotalDeathCount desc 


-- Looking at Total Population vs Vaccinations

With PopvsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated) 
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated 
	-- (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
--ORDER BY 2, 3
)

Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac;




-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated 
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

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated 
	-- (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location
AND dea.date = vac.date
--where dea.continent is not null
--ORDER BY 2, 3

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated;


-- Create view to store data for later visualizations

Create View PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated 
	-- (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
--ORDER BY 2, 3

SELECT * 
FROM PercentPopulationVaccinated