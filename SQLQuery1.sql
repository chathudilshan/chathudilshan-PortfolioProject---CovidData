/*
Covid 19 Data Exploration 
*/

Select * 
From PortfolioProject1.dbo.CovidDeaths$
Where continent is not null
Order by 3,4

Select location,date, total_cases,new_cases,total_deaths,population
From PortfolioProject1.dbo.CovidDeaths$
Where continent is not null
Order by 1,2

--Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in a certain country
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject1.dbo.CovidDeaths$
Where location like '%Lanka%' AND continent is not null
Order by 1,2

--Total Cases vs Population
-- Shows the percentage of population infected with Covid
Select location, date, population, total_cases, (total_deaths/population)*100 as PercPopulationInfected
From PortfolioProject1.dbo.CovidDeaths$
Order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select location, population, Max (total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject1.dbo.CovidDeaths$
Group by Location, population
Order by PercentPopulationInfected desc

--Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1.dbo.CovidDeaths$
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Highest Death Count per Population by continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1.dbo.CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeathCount desc


--Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))/sum(new_cases)*100 as Death_Percentage
From PortfolioProject1.dbo.CovidDeaths$
Where continent is not null
Order by 1,2

--Joining two tables 
Select *
From PortfolioProject1.dbo.CovidDeaths$ as dea
Join PortfolioProject1.dbo.CovidVaccinations$ as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date 

--Select * 
--From PortfolioProject1.dbo.CovidVaccinations$

--Select * 
--From PortfolioProject1.dbo.CovidDeaths$

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast (vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject1.dbo.CovidDeaths$ as dea
Join PortfolioProject1.dbo.CovidVaccinations$ as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date 
Where dea.continent is not null
Order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query
With CTE_PopVac (Continent, Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast (vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject1.dbo.CovidDeaths$ as dea
Join PortfolioProject1.dbo.CovidVaccinations$ as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date 
Where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)/100 
From CTE_PopVac

-- Creating View to store data for later visualizations
Create View PercentPopVac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast (vac.new_vaccinations as BIGINT)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject1.dbo.CovidDeaths$ as dea
Join PortfolioProject1.dbo.CovidVaccinations$ as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date 
Where dea.continent is not null

Select *
From PercentPopVac