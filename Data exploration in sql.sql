--Data Exploration in SQL  using CovidDeaths file

Select *
From CovidDeaths
ORDER by 3,4 

--Select *
--From CovidVaccinations
--ORDER by 3,4 

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
ORder by 1,2



--Looking at Total Cases vs Total Deaths
--lets use wildcard and select states 
--Wildcard characters are used with the LIKE operator. 
--The LIKE operator is used in a WHERE clause to search for a specified pattern in a column.

Select Location, date, total_cases,  total_deaths, ((Total_deaths/total_cases)*100) as PercentDeaths
From CovidDeaths
Where location Like '%states%'
ORder by 1,2

--Looking at the Total cases Vs Population 
--Shows what percentage of population got covid 

Select Location, date, Population, total_cases, (total_deaths/population)*100 as PercentPopulationInfected
From CovidDeaths
--WHERE Location Like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compare to population

Select Location,  Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
From CovidDeaths
--Where location Like '%states%'
Group by Location, Population
ORder by PercentPopulationInfected DESC



--Showing Countries with Highest Death Count per Population 
Select Location, MAX(Total_deaths) as TotalDeathCount
From CovidDeaths
--Where location Like '%states%'
Group by Location
ORder by TotalDeathCount DESC

--lets use CAST to convert data from string to int, so we can get the correct result


Select Location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location Like '%states%'
Group by Location
ORder by TotalDeathCount DESC

--location shwos world lets change that with the help of Not null
--( in CovidDeaths file in location there are some errors where locations shows Asia and continent shows Null
-- so we will use Where Continent is not Null in order to remove that)


Select Location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location Like '%states%'
Where Continent is not Null
Group by Location
ORder by TotalDeathCount DESC

--LETS BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location Like '%states%'
Where Continent is not Null
Group by continent
ORder by TotalDeathCount DESC


Select location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location Like '%states%'
Where Continent is  Null
Group by location
ORder by TotalDeathCount DESC

--GLOBAL NUMBERS
Select date, SUM(new_cases)
From CovidDeaths
Where continent is not null
Group By date
order by 1,2

-- lets also check SUm of new_deaths

Select date, SUM(new_cases), SUM(new_deaths)
From CovidDeaths
Where continent is not null
Group By date
order by 1,2

--result (Msg 8117, Level 16, State 1, Line 102
--Operand data type nvarchar is invalid for sum operator.

--LETS USE CAST FUNCTION to Convert data type from nvarchar into int

Select date, SUM(new_cases), SUM(cast(new_deaths as int))
From CovidDeaths
Where continent is not null
Group By date
order by 1,2

--lets Calculate DeathPercentage


Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(New_Cases)*100 
as DeathPercentage
From CovidDeaths
Where continent is not null
Group By date
order by 1,2

--LETS give Aliase 


Select date, SUM(new_cases) as total_cases,  SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 
as DeathPercentage
From CovidDeaths
Where continent is not null
Group By date
order by 1,2

--Lets remove Date from the above and comment out Group by date

Select SUM(new_cases) as total_cases,  SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 
as DeathPercentage
From CovidDeaths
Where continent is not null
--Group By date
order by 1,2

--LETS LOOK AT OUR COVIDVACCINATION FILE

SELECT *
FROM coviddeaths dea
JOIN covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths dea
JOIN covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
ORDER BY 1,2,3

--LETS use where continent is not null

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths dea
JOIN covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.Continent is not null
ORDER BY 2,3

--LETS USE PARITION BY 
-- we can also use CONVERT instead of CAST to change data type...

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location)
FROM coviddeaths dea
JOIN covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.Continent is not null
ORDER BY 2,3

--lets order by location inside partition 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.Continent is not null
ORDER BY 2,3

--CTEs

WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.Continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE
DROP table if exists #PercentPopulatedVaccinated
CREATE TABLE #PercentPopulatedVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulatedVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--Where dea.Continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulatedVaccinated


--Create Views  to Store data for later Visualization 

Create View PercentPopulatedVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.Continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulatedVaccinated