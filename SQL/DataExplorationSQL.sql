/*Ordering the data using the 3rd and 4th columns*/
select * 
from CovidDeaths
where continent is not null
order by 3,4

--- Slecting the part of the entire data that we want to use.
Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1, 2

-- Lokking at the total cases vs total deaths
--It shows the likelihood of death if you contact covid in a particular region.
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%states%' and continent is not null
order by 1, 2


-- Looking at the total cases vs total population
-- It shows the percentage of population that got covid in a partivular region
Select location, date, total_cases, population, (total_deaths/population)*100 as CasePercentage
from CovidDeaths
where location like '%states%' and continent is not null
order by 1, 2

-- Looking at the countries with the highest infection rate compared to the population
Select location, population, max(total_cases) as HighestInfaectiionCount, max((total_cases/population))*100 as HighestCasePercentage
from CovidDeaths
where continent is not null
group by location, population
order by HighestCasePercentage desc


-- Showing the countries with the highest death count per population.
Select location, population, max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is not null
group by location, population
order by HighestDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT.

--Showing the continenet with the highest death count per population

Select location as Continent, max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is null
group by location
order by HighestDeathCount desc


-- GLOBAL NUMBERS ON NEW CASES DAILY
Select date, sum(new_cases) as Total_new_cases, sum(cast(new_deaths as int)) as Total_new_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1, 2


--WORKING ON THE TWO DATASETS
-- Calculating the sum of new vaccines by partitioning bylocation in order of date and location
--First method
SELECT 
    D.continent, 
    D.location, 
    D.date, 
    D.population, 
    V.new_vaccinations,
    -- Removed D.location from the ORDER-BY list below
    SUM(CAST(V.new_vaccinations AS BIGINT)) OVER (
        PARTITION BY D.location 
        ORDER BY D.date
    ) AS rolling_people_vaccinated
FROM CovidDeaths D
JOIN CovidVaccinations V
	ON D.location = V.location
	AND D.date = V.date	
WHERE D.continent IS NOT NULL
ORDER BY 2, 3

--Second method(including using a CTE(ORDER-BY is invalid) so tha rolling col can be used for computation).
--In other words, it calculates the percentage of people vaccinated in a location daily
with CTE as (SELECT 
    D.continent, 
    D.location, 
    D.date, 
    D.population, 
    V.new_vaccinations,
    -- CASTed D.location to standard varchar to prevent LOB type error
    SUM(CAST(V.new_vaccinations AS BIGINT)) OVER (
        PARTITION BY D.location 
        ORDER BY CAST(D.location AS VARCHAR(100)), D.date
    ) AS rolling_people_vaccinated
FROM CovidDeaths D
JOIN CovidVaccinations V
	ON D.location = V.location
	AND D.date = V.date	
WHERE D.continent IS NOT NULL)

select *, (rolling_people_vaccinated/population)*100 as Percent_vaccinated
from CTE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population bigint,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT 
    D.continent, 
    D.location, 
    D.date, 
    D.population, 
    V.new_vaccinations,
    -- CASTed D.location to standard varchar to prevent LOB type error
    SUM(CAST(V.new_vaccinations AS BIGINT)) OVER (
        PARTITION BY D.location 
        ORDER BY CAST(D.location AS VARCHAR(100)), D.date
    ) AS rolling_people_vaccinated
FROM CovidDeaths D
JOIN CovidVaccinations V
	ON D.location = V.location
	AND D.date = V.date	
WHERE D.continent IS NOT NULL

select *, (rolling_people_vaccinated/population)*100 as Percent_vaccinated
from #PercentPopulationVaccinated	


--CREATING VIEW: to store data for latter visualization("ORDER-BY" is invalid)
Create view RollingPeopleVaccinated as
SELECT 
    D.continent, 
    D.location, 
    D.date, 
    D.population, 
    V.new_vaccinations,
    -- Removed D.location from the ORDER BY list below
    SUM(CAST(V.new_vaccinations AS BIGINT)) OVER (
        PARTITION BY D.location 
        ORDER BY D.date
    ) AS rolling_people_vaccinated
FROM CovidDeaths D
JOIN CovidVaccinations V
	ON D.location = V.location
	AND D.date = V.date	
WHERE D.continent IS NOT NULL
--ORDER BY 2, 3

--Querying a stored view
select * from RollingPeopleVaccinated	