
--Added later where continent is not null bc when running the TotalDeathCount part it was showing us continent totals. This fixed it.
Select *
From PortfolioProject1..CovidDeaths
where continent is not null
order by 3,4


--Select *
--From PortfolioProject1..CovidVaccinations
--order by 3,4
--after we look at this, we can "comment this out"

--Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths and creating alias
--shows the liklyhood of dying if you contract covid in your contry
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
order by 1,2

--Looking at the US
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at the total cases vs populataion 
--shows what percentage has gotten Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
where Location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to populations

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
--where Location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


--Showing the countries with the highest death count per Population
--Also casting bc total_deaths is a nvarchar(255) = data error

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--where Location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc


--Let's break things down by continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--where Location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--not accurate data
--this is correct
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--where Location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc


--showing the continents with the highest death counts

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--where Location like '%states%'
where continent is not null
Group by date
order by TotalDeathCount desc


---- Global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where continent is not null
Group By date
order by 1,2

--remove date and find total number

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where continent is not null
--Group By date
order by 1,2

--Tableau 2
Select location, SUM(cast(new_deaths as int)) as totalDeathCount
From PortfolioProject1..CovidDeaths
where continent is null
and location not in('World', 'European Union', 'International')
Group By location
order by TotalDeathCount desc


--joining the data sets
Select *
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.Location = vac.location
	and dea.date = vac.date

-- Looking at total population vs vaccinations
-- instead of "CAST" you can use (CONVERT(int,vac.new_vaccinations))
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location, dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.Location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use a CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.Location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table #PercentPopulationVaccinated
--use below when altering tables to avoid errors
--Drop Table if exists #PercentPopulationVaccinated
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.Location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--creating view to store data for later visualizations

Create View PercentPopulationVaccinated1 as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.Location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated1

---.3

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
--where Location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

---.4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
--where Location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc