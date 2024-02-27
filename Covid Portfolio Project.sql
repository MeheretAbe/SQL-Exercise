--These queries analyze various aspects of COVID-19 data, such as death percentages, population infection rates, vaccination rates, and population percentages.
This provides insight into the impact and response to the COVID-19 pandemic.

-- select key variables we're interested in
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM test_data.covid_death 
ORDER BY location, date


--calculate covid death rate 
SELECT location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 AS death_rate
FROM test_data.covid_death 
WHERE location like '%States%'
ORDER BY 1,2

-- calculate covid infection rate
SELECT location, date, total_cases, population, (total_cases/population)*100 AS infection_rate
FROM test_data.covid_death 
WHERE location like '%States'
ORDER BY location, date


-- calculate highest covid infection count & rate across the countries
SELECT location, population, 
       MAX(total_cases) AS highest_infection_count, 
       MAX(total_cases/population)*100 AS highest_infection_rate
FROM test_data.covid_death 
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC


-- Countries with the Highest Death Count per Population 
select location, max(total_deaths)as TotalDeathCount
from test_data.covid_death
where continent  is not null
group by location
order by TotalDeathCount desc


-- calculate the worldwide covid death rate for each day
SELECT date, SUM(new_cases), SUM(new_deaths), (SUM(new_deaths)/sum(Nullif(new_cases, 0)*100 AS death_rate
FROM test_data.covid_death 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 4


-- join two tables and calculate the rolling count of new vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccination
FROM test_data.covid_death dea
JOIN test_data.covid_vaccination vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



-- CTE
  
WITH VacTable 
AS (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccination
  FROM test_data.covid_death dea
  JOIN test_data.covid_vaccination vac
  ON dea.location = vac.location 
  AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
)
  
SELECT *, (rolling_vaccination/population)*100 AS vac_rate
FROM VacTable


  
-- temp table
CREATE TABLE test_data.VacRate
(
  continent      nvarchar(255),
  location       nvarchar(255),
  Date           datetime,
  population     numeric,
  New_vaccinations numeric, 
  RollingPeoplevaccinated numeric
);
INSERT INTO test_data.VacRate
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
     SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccination
FROM test_data.covid_death dea
JOIN test_data.covid_vaccination vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;



-- Creating a View
create view test_data.VacRate as 
select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations,
sum( vac.new_vaccinations) over( partition by dea.location  order by dea.location, dea.date) as RollingPeoplevaccinated
from test_data.covid_death dea
join test_data.covid_vaccination vac
on dea.location= vac.location 
and dea.date= vac.date


