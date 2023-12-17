select * from prtfOlio..coviddeathS
where continent is not null


-- looking at total cases vs total deaths
-- shows  likelihood of dying if you contact covid in your country
select  location , date ,total_cases , total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From prtfolio..CovidDeaths
where location = 'morocco'
and continent is not null
order by 1,2
-- looking at total cases vs population
-- show what percentage of population got covid
select  location , date ,population,total_cases , total_deaths, 
(total_cases/population)*100 as percentofpopulationinfect
From prtfolio..CovidDeaths
--where location = 'morocco'
where continent is not null
order by 1,2

-- looking at countries with highest infection rate compare to population
select  location ,population ,max(total_cases) as highestinfection, max((total_cases/population))*100 as percentpopulationinfected
From prtfolio..CovidDeaths
--where location = 'morocco'
where continent is not null
group by location,population
order by percentpopulationinfected desc
-- showing countries with highest deaths count per population

select  location ,max(cast(total_deaths as int)) as totaldeathcount
From prtfolio..CovidDeaths
--where location = 'morocco'
where continent is null
group by location
order by totaldeathcount desc

-- let's break things down by continent

-- showing the continent with the highest deaths

select  continent ,max(cast(total_deaths as int)) as totaldeathcount
From prtfolio..CovidDeaths
--where location = 'morocco'
where continent is not null
group by continent
order by totaldeathcount desc


-- global numbers 

select  SUM(new_cases), sum(cast(new_deaths as int)) as totaldeaths ,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage -- 
From prtfolio..CovidDeaths
--where location = 'morocco'
where continent is not null
--group by date
order by 1,2

-- looking at total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population , vac.new_vaccinations
,sum(convert(int ,vac.new_vaccinations)) over 
(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from prtfolio..Coviddeaths dea
join prtfolio..Covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
order by 2,3


--use CTE 


with popvsvac (continent ,location,date,population, new_vaccinations, rollingpeoplevaccinated)
as (
select dea.continent,dea.location,dea.date,dea.population , vac.new_vaccinations
,sum(convert(int ,vac.new_vaccinations)) over 
(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from prtfolio..Coviddeaths dea
join prtfolio..Covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
--order by 2,3
)
select*,(rollingpeoplevaccinated/population)*100 from popvsvac





-- TEMP Table
drop table if exists #Percentpopulationvaccinated
create table #Percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into #Percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population , vac.new_vaccinations
,sum(convert(int ,vac.new_vaccinations)) over 
(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from prtfolio..Coviddeaths dea
join prtfolio..Covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--and vac.new_vaccinations is not null
--order by 2,3
select *, (rollingpeoplevaccinated/population)*100 from #Percentpopulationvaccinated


--creating view to store data for later visualizations
drop view  Percentpopulationvaccinated
create view Percentpopulationvaccinated as 
select dea.continent,dea.location,dea.date,dea.population , vac.new_vaccinations
,sum(convert(int ,vac.new_vaccinations)) over 
(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from prtfolio..Coviddeaths dea
join prtfolio..Covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--and vac.new_vaccinations is not null
--order by 2,3


select * from Percentpopulationvaccinated