select *
from PortfolioProject.. CovidDeaths 
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, 
total_deaths, population 
from PortfolioProject.. CovidDeaths
order by 3,4


-- looking at total case vs total deaths
-- shows the likelihood of dying if you contract covid in USA
select location, date, total_cases, total_deaths,(total_deaths/Nullif( total_cases,0))*100 as DeathPercentage
from PortfolioProject.. CovidDeaths
where location like '%states%'
order by 1,2


--looking at total cases vs population 
--shows what percentage of the population got covid
select location, date, population, total_cases, (total_cases/Nullif( population, 0))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


--looking at countries with highest infection rate compared to population 
select location, population, max(total_cases)as highestInfectioncount, max ((total_cases/Nullif( population, 0)))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc


--showing countries with highest death count per population 
select location, max(total_deaths)as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent  is not null
group by location
order by TotalDeathCount desc


DELETE FROM PortfolioProject..CovidDeaths
WHERE Location= 'world' or location ='High income' or location ='Upper middle income'
or location ='Europe' or location= 'Asia' or location= 'North America' or location= 'South America'
or location ='South America' or location= 'Lower middle income' or location= 'European union'


--showing the continents with the highest death count per population
Select SUM(cast(new_deaths as int)) as TotalDeathCount, continent
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by continent 
order by TotalDeathCount desc



-- Global numbers
select SUM(new_cases)as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/sum(Nullif(new_cases, 0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent  is not null
--group by date
order by 1,2



--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations,
sum( vac.new_vaccinations) over( partition by dea.location  order by dea.location, dea.date) as RollingPeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..covidvaccinations vac 
on dea.location= vac.location 
and dea.date= vac.date
order by 2,3



--USE CTE
with popvsVac( continent, location, date, population,new_vaccinations, RollingPeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations,
sum( vac.new_vaccinations) over( partition by dea.location  order by dea.location, dea.date) as RollingPeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..covidvaccinations vac 
on dea.location= vac.location 
and dea.date= vac.date
)

select *, ( RollingPeoplevaccinated/population)*100
from popvsVac




-- TEMP Table

Drop table if --exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric, 
RollingPeoplevaccinated numeric 
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations,
sum( vac.new_vaccinations) over( partition by dea.location  order by dea.location, dea.date) as RollingPeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..covidvaccinations vac 
on dea.location= vac.location 
and dea.date= vac.date
order by 2,3

select *, ( RollingPeoplevaccinated/population)*100
from ##PercentPopulationVaccinated



--creating view to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations,
sum( vac.new_vaccinations) over( partition by dea.location  order by dea.location, dea.date) as RollingPeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..covidvaccinations vac 
on dea.location= vac.location 
and dea.date= vac.date

select*
from PercentPopulationVaccinated
