

--Total Cases vs Total Deaths 

USE CovProject
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--- Total Cases vs Population

USE CovProject
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2

---Countries with Highest Infection Rate compared to Population

USE CovProject
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

---Countries with Highest Death Count per Population
USE CovProject
SELECT Location, MAX(Cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


---CONTINENT VIEW Highest Death Count Per Population

USE CovProject
SELECT continent, MAX(Cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--- GLOBAL NUMBERS

USE CovProject
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
Group By date
ORDER BY 1,2


---Total Population vs Vaccinations

USE CovProject
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations 
, SUM(CAST(vax.new_vaccinations as int)) OVER ( PARTITION BY dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vax ON dea.location=vax.location 
AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE

WITH PopVsVax (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations 
, SUM(CAST(vax.new_vaccinations as int)) OVER ( PARTITION BY dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vax ON dea.location=vax.location 
AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
) 
SELECT *, (RollingPeopleVaccinated/Population)*100 AS Percent_pop_vaccinated
FROM PopVsVax


---USE WITH TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations 
, SUM(CAST(vax.new_vaccinations as int)) OVER ( PARTITION BY dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vax ON dea.location=vax.location 
AND dea.date = vax.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations 
, SUM(CAST(vax.new_vaccinations as int)) OVER ( PARTITION BY dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vax ON dea.location=vax.location 
AND dea.date = vax.date
WHERE dea.continent IS NOT NULL