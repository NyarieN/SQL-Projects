

SELECT *
FROM Project..CovidDeaths
ORDER BY 3,4 

--SELECT *
--FROM Project..CovidVaccinations
--ORDER BY 3,4

--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Project..CovidDeaths
ORDER BY 1,2

--looking at the total cases vs total deaths for each country as well as the percentage 

SELECT location, date, total_cases, total_deaths, (total_cases/population)*100 AS Population 
FROM Project..CovidDeaths
where location like '%states%'
ORDER BY 1,2

--looking at the daily total cases vs the daily infected populationpercentage daily

SELECT location, date,  population,total_cases, (total_cases/population)*100 AS PopulationInfectedPercentage
FROM Project..CovidDeaths
ORDER BY 1,2

--Order based on the country with the highest Population Infected percentage 
--MAX(total_cases) : sums us the total cases for each country , instead of showing total cases for each day , same purpose for MAX((total_cases/population))
SELECT location,  population , MAX(total_cases) AS TotalInfectedInTheCountry, MAX((total_cases/population))*100 AS PopulationInfectedPercentage 
FROM Project..CovidDeaths
GROUP BY location,population  
ORDER BY PopulationInfectedPercentage  desc

--Order based on the country with the highest infection
SELECT location,  population , MAX(total_cases) AS TotalInfectedInTheCountry, MAX((total_cases/population))*100 AS PopulationInfectedPercentage 
FROM Project..CovidDeaths
GROUP BY location,population
ORDER BY TotalInfectedInTheCountry desc

--Order based on the country with the highest population
SELECT location,  population , MAX(total_cases) AS TotalInfectedInTheCountry, MAX((total_cases/population))*100 AS PopulationInfectedPercentage 
FROM Project..CovidDeaths
GROUP BY location,population
ORDER BY population desc

--Lets look at the country with the highest deaths 
--always check your data type and see if it needs any cast
--lets exclude the continets 
Select location, population, MAX(cast(total_deaths as int)) AS TotalDeathsInCountry , MAX((total_deaths/population)) AS PopulationDeathPercentage
From Project..CovidDeaths
where continent is not null  --look at dataset to understand
Group by location,population  --Group by function basically helps in giving one summary.
Order by TotalDeathsInCountry desc

--now to see the total of the continets 

Select location, population, MAX(cast(total_deaths as int)) AS TotalDeathsInContinent , MAX((total_deaths/population)) AS PopulationDeathPercentage
From Project..CovidDeaths
where continent is null  --look at dataset to understand
Group by location, population
Order by TotalDeathsInContinent desc

Select location,  MAX(cast(total_deaths as int)) AS TotalDeathsInContinent
From Project..CovidDeaths
where continent is null  --look at dataset to understand
Group by location
Order by TotalDeathsInContinent desc

------GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Project..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2
------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Looking at total Population vs vaccinations
select dea.continent, dea.location , dea.date , dea.population, Vacc.new_vaccinations,
SUM(cast( Vacc.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location ,dea.date) as RollingPeopleVaccinated --Here you will see that it will add the sum day by day, instead of showing the total throughout , it will add daily to the prevoiuse total (try running without the "ORDER BY"
--, (RollingPeopleVaccinated/population)*100  we cannot use this without a CTE or  Temp table 
from Project..CovidDeaths AS dea
JOIN Project..CovidVaccinations AS Vacc
ON dea.location = Vacc.location AND dea.date = Vacc.date 
where dea.continent is not null
order by 2,3

----with CTE -----------------------------------------------------------------------------------------------------------------
--Trick : make sure every coloumn listed on "With PopvsVAC" IS the same or equal to the select coloums 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3 --ORDER BY DOES NOT WORK IN HERE
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query------------------------------------------------------------------------------------

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------
----LETS CREATE VIEWS TO STORE DATA FOR LATER VISUALIZATIONS

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3  order doesnt work here

select *
from PercentPopulationVaccinated

