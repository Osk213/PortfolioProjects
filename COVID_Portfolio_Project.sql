select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

--select * from PortfolioProject..CovidVaccinations
--order by 3, 4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of death by country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


-- Looking at total cases vs population

select Location, date, total_cases, population, (total_cases/population)*100 as infection_rate
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


-- Looking at countries by highest infection rate compared to population

select Location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as infection_rate
from PortfolioProject..CovidDeaths
group by population, location
order by infection_rate DESC



-- Looking at countries with highest death count per population

select Location, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by total_death_count desc



-- Now breaking it down by continent

select location, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by total_death_count desc


-- Showing continents with highest death count

select continent, MAX(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by total_death_count desc




-- GLOBAL NUMBERS

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_rate
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1, 2



-- Looking at total population vs vaccination

select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100 as rolling_vaccinated_percentage
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3



-- Using CTE

with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100 as rolling_vaccinated_percentage
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
) 
Select *, (rolling_people_vaccinated/population)*100 as rolling_vaccination_precentage
from PopvsVac



-- Temp Table
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent varchar(255), 
location varchar(255), 
date datetime,
population numeric, 
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100 as rolling_vaccinated_percentage
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null


Select *, (rolling_people_vaccinated/population)*100 as rolling_vaccination_precentage
from #PercentPopulationVaccinated



-- Creating View to store for future vizualizations


Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100 as rolling_vaccinated_percentage
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null


select *
from PercentPopulationVaccinated