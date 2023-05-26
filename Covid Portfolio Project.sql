--These queries analyze various aspects of COVID-19 data, such as death percentages, population infection rates, vaccination rates, and population percentages.
This provides insight into the impact and response to the COVID-19 pandemic.

-- 1. Total Death Percentage by Location and Date in USA
select location, date, total_cases, total_deaths,(total_deaths/Nullif( total_cases,0))*100 as DeathPercentage
from PortfolioProject.. CovidDeaths
where location like '%states%'
order by 1,2


--2. Percentage of Population Infected by Location and Date
select location, date, population, total_cases, (total_cases/Nullif( population, 0))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


--3. Highest Infection Rate by Location Compared to Population
select location, population, max(total_cases)as highestInfectioncount, max ((total_cases/Nullif( population, 0)))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc


--4. Countries with the Highest Death Count per Population 
select location, max(total_deaths)as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent  is not null
group by location
order by TotalDeathCount desc


--5. calculate the highest infection count and the percentage of population infected for each location and date
select location, date, population, max(total_cases)as highestInfectioncount, max ((total_cases/Nullif( population, 0)))*100 as PercentpopulationInfected
from PortfolioProject..CovidDeaths
group by location, population, date
order by PercentPopulationInfected desc


--6. Continents with the Highest Death Count per Population
Select SUM(cast(new_deaths as int)) as TotalDeathCount, continent
From PortfolioProject..CovidDeaths
Where continent is not null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by continent 
order by TotalDeathCount desc



-- 7. Global COVID-19 Numbers
select SUM(new_cases)as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/sum(Nullif(new_cases, 0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent  is not null
--group by date
order by 1,2



--8. Population vs. Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations,
sum( vac.new_vaccinations) over( partition by dea.location  order by dea.location, dea.date) as RollingPeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..covidvaccinations vac 
on dea.location= vac.location 
and dea.date= vac.date
order by 2,3


--9. Percentage of Population Vaccinated
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



--10. Temporary Table
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



--11. Creating a View
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations,
sum( vac.new_vaccinations) over( partition by dea.location  order by dea.location, dea.date) as RollingPeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..covidvaccinations vac 
on dea.location= vac.location 
and dea.date= vac.date

select*
from PercentPopulationVaccinated
