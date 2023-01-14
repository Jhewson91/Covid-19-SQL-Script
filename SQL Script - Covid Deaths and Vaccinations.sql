-- Check that CovidDeaths data set has been imported correctly.
SELECT *
FROM PortfolioProject1..['CovidDeaths']
where continent is NOT Null
order by 3,4 

-- Check that CovidVaccinations data set has been imported correctly.
SELECT *
FROM PortfolioProject1..['CovidVaccinations']
order by 3,4

-- select columns we want to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..['CovidDeaths']
Order by 1,2 

-- Look at total_cases vs total_deaths as a %
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject1..['CovidDeaths']
where location like '%United Kingdom%' --see % of cases led to death in UK
Order by death_percentage desc


-- Look at total_cases vs population as a %
SELECT location, date, population, total_cases, (total_cases/population)*100 as case_percentage
FROM PortfolioProject1..['CovidDeaths']
where location like '%kingdom%' --see % of population of UK has had Covid
Order by case_percentage desc

-- Look at countries with highest infection rates
SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject1..['CovidDeaths']
Group by location, population
Order by PercentPopulationInfected desc

-- Look at countries with highest death rates
SELECT location, population, MAX(total_deaths) as HighestDeathCount, Max((total_deaths/population))*100 as PercentPopulationDeaths
FROM PortfolioProject1..['CovidDeaths']
Group by location, population
Order by PercentPopulationDeaths desc

-- Look at countries with highest death count
SELECT location, MAX(cast(total_deaths as int)) as totalDeathCount
FROM PortfolioProject1..['CovidDeaths']
where continent is NOT Null --inconsistent classification of location removed
Group by location
Order by totalDeathCount desc

-- Look at contintents with highest death count
SELECT continent, MAX(cast(total_deaths as int)) as totalDeathCount
FROM PortfolioProject1..['CovidDeaths']
where continent is NOT Null --inconsistent classification of location removed
Group by continent
Order by totalDeathCount desc

--Global Numbers - new cases vs new deaths today
SELECT SUM(new_cases) as totalNewCases, SUM(cast(new_deaths as int)) as totalNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as NewDeathPercentage--total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject1..['CovidDeaths']
where continent is NOT Null --inconsistent classification of location removed
--Group by date
Order by 1,2 

--Look at total population and cumulative frequency of vaccination per country
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Vac_Cumulative_Frequency
From PortfolioProject1..['CovidDeaths'] dea
Join PortfolioProject1..['CovidVaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is Not null 
Order by 2,3

--Use Common Table Expression (CTE) to determine % of population vaccinated with Vac_Cumulative_Frequency
--Create CTE named PopvsVacc, use the column names, and set up of queries above.
with PopvsVacc (Continent, location, date, population, new_vaccinations, Vac_Cumulative_Frequency)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Vac_Cumulative_Frequency
From PortfolioProject1..['CovidDeaths'] dea
Join PortfolioProject1..['CovidVaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is Not null 
--Order by 2,3
)
select *, (Vac_Cumulative_Frequency/population)*100 --perform % of population vaccinated calculation from Vac_Cumulative_Frequency
from PopvsVacc


--Create Temp Table (for same calculation - determine % of population vaccinated with Vac_Cumulative_Frequency)
--create table
create table #PercentagePopulationVaccinated
(
--create column names
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
Vac_Cumulative_Frequency numeric
)
--insert Vac_Cumulative_Frequency calculation into temp table
Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Vac_Cumulative_Frequency
From PortfolioProject1..['CovidDeaths'] dea
Join PortfolioProject1..['CovidVaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is Not null 
--Order by 2,3
--perform calculation to get % of population vaccinated with Vac_Cumulative_Frequency
select *, (Vac_Cumulative_Frequency/population)*100 --perform % of population vaccinated calculation from Vac_Cumulative_Frequency
from #PercentagePopulationVaccinated



--Create Views 
Create view totalNewCases as 
--Global Numbers - new cases vs new deaths today
SELECT SUM(new_cases) as totalNewCases, SUM(cast(new_deaths as int)) as totalNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as NewDeathPercentage--total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject1..['CovidDeaths']
where continent is NOT Null --inconsistent classification of location removed
--Group by date
--Order by 1,2 

select *
from totalNewCases


create view PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Vac_Cumulative_Frequency
From PortfolioProject1..['CovidDeaths'] dea
Join PortfolioProject1..['CovidVaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is Not null 

select *
from PercentagePopulationVaccinated