Select *
From ProjectPortfolio..CovidDeaths
order by 3,4

Select *
From ProjectPortfolio..CovidVaccinations
order by 3,4


-- Select data to start with

Select Location, date, total_cases, new_cases, total_deaths, population
From ProjectPortfolio..CovidDeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in the country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
Where location like '%Canada%'
and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--Average Median age by deaths
Select Location, Population, continent, AVG(median_age) as AverageMedianAge, total_deaths
From ProjectPortfolio..CovidData
Group by Location, Population, continent, median_age, total_deaths


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


Select *
From ProjectPortfolio..CovidVaccinations

-- Total Population vs Vaccinations
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
From ProjectPortfolio..CovidDeaths d
Join ProjectPortfolio..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
Where d.continent is not null
Order by 2,3

-- Using Temp Table to Show Percentage of Population that has recieved at least one Covid Vaccine

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, People_Vaccinated) as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as PeopleVaccinated
From ProjectPortfolio..CovidDeaths d
Join ProjectPortfolio..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
--order by 2,3
)
Select *, (People_Vaccinated/population)*100 as PercentVaccinated
From PopvsVac

 
 -- Creating View to store data for later visualizations

Create View 
PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From PercentPopulationVaccinated
