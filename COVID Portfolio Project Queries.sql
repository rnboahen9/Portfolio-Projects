Select *
From ProjectOne..CovidDeaths
where continent is not null


Select *
From ProjectOne..CovidVaccinations
where continent is not null
order by 1,2

--Select *
--From ProjectOne..CovidVaccinations
--order by 3,4


--Select the Data we will be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From ProjectOne..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you have covid in USA
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From ProjectOne..CovidDeaths
where location like '%Ghana%'
order by 1,2

--Looking at Total cases vs population
--Shows what percentage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
From ProjectOne..CovidDeaths
--where location like '%Ghana%'
order by 1,2


--Looking at country with Highest infection rate

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From ProjectOne..CovidDeaths
--where location like '%Ghana%'
Group by Location, Population
order by PercentagePopulationInfected desc

--Showing the countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjectOne..CovidDeaths
--where location like '%Ghana%'
where continent is not null
Group by Location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

Select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjectOne..CovidDeaths
--where location like '%Ghana%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Showing continent with highest death count per population
Select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjectOne..CovidDeaths
--where location like '%Ghana%'
where continent is not null
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Deathpercentage
From ProjectOne..CovidDeaths
--where location like '%Ghana%'
where continent is not null
--Group By date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From ProjectOne..CovidDeaths dea
Join ProjectOne..CovidVaccinations vac 
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null	
order by 2,3



---TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From ProjectOne..CovidDeaths dea
Join ProjectOne..CovidVaccinations vac 
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null	
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From ProjectOne..CovidDeaths dea
Join ProjectOne..CovidVaccinations vac 
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null	
--order by 2,3

Select *
From PercentPopulationVaccinated
