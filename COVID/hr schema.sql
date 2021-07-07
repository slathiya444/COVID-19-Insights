/*
Covid 19 Data Exploration 
*/
select * from coviddeaths
/



--The data that we mainly going to focus on

select  location, date_of,  total_cases, new_cases, total_deaths, population
from coviddeaths
Where continent is not null 
order by Location, date_of
/


--The death percentage as compared to Covid cases
--total cases vs. tota; deaths

Select location, date_of, total_cases,total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage
From CovidDeaths
where continent is not null 
--Where location like '%states%'
order by location, date_of
/


--The percentage of population get affacted with COVID
--total cases vs. total population

Select location, date_of, total_cases,population, round((total_cases/population)*100,2) as PopulationInfacted
From CovidDeaths
where continent is not null 
--Where location like '%states%'
order by location, date_of
/


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  round(Max((total_cases/population))*100,4) as PopulationInfected
From CovidDeaths
where continent is not null  
Group by Location, Population
order by PopulationInfected desc
/


-- Countries with Highest Death Count per Population

Select Location, MAX(Total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc
/


-- Continents with Highest Death Count per Population

Select continent, MAX(Total_deaths) as TotalDeathCount
From CovidDeaths
--Where continent is not null 
Group by continent
order by TotalDeathCount desc
/


--Global Numbers

--Daily data of the entire world for the number of cases, deaths and the percent of people who died because of COVID infaction

Select date_of, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, round((sum(new_deaths)/sum(new_cases)*100),2) as deathPercent
From CovidDeaths
where continent is not null 
Group By date_of
order by date_of
/

--The total insight overall

Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, round((sum(new_deaths)/sum(new_cases)*100),2) as deathPercent
From CovidDeaths
where continent is not null 
-- It is saying that total 2% of people are died after getting infacted by COVID.
/




-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
--for that we need to join the vaccination data with covidDeath data

Select dea.continent, dea.location, dea.date_of, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location order by dea.location, dea.date_of) as RollingPeopleVaccinated
From CovidDeaths dea Join CovidVaccinations vac
	On dea.location = vac.location and dea.date_of = vac.date_of
where dea.continent is not null 
order by dea.location, dea.date_of
/



--Now we are gonna use the column that we just created in trhe same query using CTE

with populationVSvaccination (continent, location, date_of,population, new_vaccinations, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date_of, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location order by dea.location, dea.date_of) as RollingPeopleVaccinated
From CovidDeaths dea Join CovidVaccinations vac
	On dea.location = vac.location and dea.date_of = vac.date_of
where dea.continent is not null 
--order by dea.location, dea.date_of
)
select continent,location,date_of,population,new_vaccinations,RollingPeopleVaccinated,round((RollingPeopleVaccinated/population)*100,4) as VaccinatedPercentage
FROM populationVSvaccination

/



--Alternatively, if we do not want to use CTE, we can create temporpry table

Create global temporary table PercentVaccinated
(
Continent varchar(255),
Location varchar(255),
Date_of  DATE,
Population number,
New_vaccinations number,
RollingPeopleVaccinated number
)
/

Insert into PercentVaccinated (
Select dea.continent, dea.location, dea.date_of, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location order by dea.location, dea.date_of) as RollingPeopleVaccinated
From CovidDeaths dea Join CovidVaccinations vac
	On dea.location = vac.location and dea.date_of = vac.date_of
where dea.continent is not null 
--order by dea.location, dea.date_of
)
/ 

--select count(*) from percentVaccinated
--/
select continent,location,date_of,population,new_vaccinations,RollingPeopleVaccinated,round((RollingPeopleVaccinated/population)*100,4) as VaccinatedPercentage
FROM PercentVaccinated
/
