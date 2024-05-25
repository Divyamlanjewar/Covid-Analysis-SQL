select * from portfolio..deaths$
where continent is not null
order by 3,4


-----------------------
--select * from portfolio..vaccinations
--order by 3,4
-----------------------


select location,date, total_cases,new_cases,total_deaths,population
from portfolio..deaths$
where continent is not null
order by 1,2



----------------------- death percentage rate

select location,date, total_cases,total_deaths,(convert(float,total_deaths)/nullif(convert(float,total_cases),0))*100 as deathpercerntage
from portfolio..deaths$
order by 1,2



----------------------- death percentage of united states

select location,date, total_cases,total_deaths,(convert(float,total_deaths)/nullif(convert(float,total_cases),0))*100 as deathpercerntage
from portfolio..deaths$
where location like '%states%'
order by 1,2


-----------------------   perentage of population affected

select location,date, total_cases,population,(convert(float,total_cases)/nullif(convert(float,population),0))*100 as affected_population
from portfolio..deaths$
where location like '%states%'
order by 1,2




------------------------------showing countries with highest death count per population(sr.no,location,totalDeathCount)

select location,max(cast(total_deaths as int)) as totalDeathCount
from portfolio..deaths$
where continent is not null
group by location
order by totalDeathCount desc




------------------------------showing the continent with highest death count per population (se.no,continent,totalDeathCount)

select continent,max(cast(total_deaths as int)) as totalDeathCount
from portfolio..deaths$
where continent is not null
group by continent
order by totalDeathCount desc




---------------------------breaking to the GLOBALLY


select  sum(new_cases)as TotalCases, sum(cast(new_deaths as int))as Total_Deaths ,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentageGlobally
from portfolio..deaths$
where continent is not null
--group by date
order by 1,2





--------------------- total population VS Vaccination(sr.no,continent,location,date,population,new_vaccinations)

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100

from portfolio..deaths$ dea
join portfolio..vaccinations_1$ vac
    on dea.location = vac.location
    and dea.date=vac.date
where dea.continent is not null
order by 2,3




----------------------use CTE

with popvsVac (continent,location,date,population,New_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from portfolio..deaths$ dea
join portfolio..vaccinations_1$ vac
    on dea.location = vac.location
    and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select*,(RollingPeopleVaccinated/population)*100
from popvsVac







-------------------Temp_Table

CREATE TABLE #PercentPopulationVaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_Vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

-- Insert data into the temporary table and calculate the percentage
INSERT INTO #PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
    portfolio..deaths$ dea
JOIN
    portfolio..vaccinations_1$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;







------- view to store data for later vizualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
    (SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) / dea.population) * 100 AS PercentPopulationVaccinated
FROM
    portfolio..deaths$ dea
JOIN
    portfolio..vaccinations_1$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;





	




















