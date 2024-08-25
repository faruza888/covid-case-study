select * 
from portfolioproject1..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from portfolioproject1..CovidVaccination
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject1..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentages
from portfolioproject1..CovidDeaths
where location like'%states%'
order by 1,2

--looking at total cases vs population


select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from portfolioproject1..CovidDeaths
where location like'%states%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location , population, max(total_cases) as HighestInfectioncount, max((total_cases/population))*100 as
PercentPopulationInfected
from portfolioproject1..CovidDeaths
--where location like'%states%'
group by location , population
order by PercentPopulationInfected desc

--showing countries with highest death count per population

select location , max(cast(total_deaths as int)) as TotalDeathCount

from portfolioproject1..CovidDeaths
--where location like'%states%'
where continent is not null
group by location 
order by TotalDeathCount desc

-- lets break things down by continent

--showing continents with highest death count per population

select continent , max(cast(total_deaths as int)) as TotalDeathCount

from portfolioproject1..CovidDeaths
--where location like'%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBER

select sum(new_cases) as total_cases,sum(cast(new_cases as int)) as total_deaths,
sum(cast(new_cases as int))/sum(new_cases)*100 as deathpercentage

from portfolioproject1..CovidDeaths
--where location like'%states%'
where continent is not null
--group by date
order by 1,2
 

 --join table coviddeaths and covidvaccination

select * 
from portfolioproject1..CovidDeaths dea
join portfolioproject1..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date

--looking at total population vs vaccination

select dea.continent, dea.location, dea.date, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from portfolioproject1..CovidDeaths dea
join portfolioproject1..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE

with popvsvac (continent, location ,date , population,  new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(Convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioproject1..CovidDeaths dea
join portfolioproject1..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100
from popvsvac



--temp table

create table #percentpopulationvaccinated

(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentpopulationvaccinated

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(Convert(bigint,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioproject1..CovidDeaths dea
join portfolioproject1..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * , (RollingPeopleVaccinated/population)*100
from #percentpopulationvaccinated



--creating view to store data for later visualization

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(Convert(bigint,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioproject1..CovidDeaths dea
join portfolioproject1..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationvaccinated