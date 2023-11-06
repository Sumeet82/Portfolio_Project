					--	✱✱✱	COVID-19 PROJECT   ✱✱✱      --


	--select *
	--from [Project portfolio]..CovidVaccination
	--order by 3,4

	select *
	from [Project portfolio]..CovidDeaths
	where continent is not null
	order by 3,4

	--✱Basic overview of the Data ✱
			       	       	  --[Including Location, date, total_cases, new_cases, total_deaths, population]
		
	SELECT location, date, total_cases, new_cases, total_deaths, population
	from [Project portfolio]..CovidDeaths
	order by 1,2


	

--{1st. Data created}
		      --[[looking at Total_Cases vs Total_Deaths]
							           --[Shows the likelihood of dying if you contact coivd in your country]
  
	SELECT location, date, total_cases, total_deaths, (convert(float,total_deaths)/NULLIF(convert(float,total_cases),0))*100 as DeathPercentage
	from [Project portfolio]..CovidDeaths
	--Where location like '%India%'
	order by 1,2


--{2nd. Data created}
		      --[lookinng at total case vs population]
				   			       --[shows the percentage of population  infected by covid]

	SELECT location, date,population, total_cases, (convert(float,total_cases)/NULLIF(convert(float,population),0))*100 as PercentPopulationInfected
	from [Project portfolio]..CovidDeaths
	Where location like '%India%'
	order by 1,2


--{3rd. Data created}
		      --[looking at contries with highest infection rate compared to population]
	
 						-- ✱✱✱ {[Data used for visualisation]} ✱✱✱

	SELECT location , population, max(total_cases) as HighestInfectionCount , (convert(float,max(total_cases))/NULLIF(convert(float,population),0))*100 as PercentPopulationInfected
	from [Project portfolio]..CovidDeaths
	--Where location like '%India%'
	group by location, population
	order by PercentPopulationInfected desc



	

--{4th.Data created}  
		     --[Showing countries with highest death Count]
								    -- ✱✱✱ [Data used for visualisation] ✱✱✱

	SELECT location , SUM(cast(total_deaths as bigint)) as TotalDeathCount
	from [Project portfolio]..CovidDeaths
	--Where location like '%India%'
	where continent is not null
	and location not in ('World', 'European Union', 'International')
	group by location
	order by TotalDeathCount desc


--{5th. Data created}
		    --[Lets's break down by continent]
						       --[showing continents with highest death count per population]

	SELECT continent , Max(cast(total_deaths as bigint)) as TotalDeathCount
	from [Project portfolio]..CovidDeaths
	--Where location like '%India%'
	where continent is not null
	group by continent
	order by TotalDeathCount desc


--{6th. Data created}
		     --[Global number]
				       -- ✱✱✱ {[Data used for visualisation]} ✱✱✱

	SELECT sum(new_cases) as total_case , sum(cast(new_deaths as int )) as total_deaths, sum(cast(new_deaths as int ))/nullif(sum(new_cases),0)*1000 as Deathpercentage
	from [Project portfolio]..CovidDeaths  
	--Where location like '%India%'
	where continent is not null
	--group by date
	order by 1,2
	 	     --[ Deathpercentage is 9% ]


--{7th. Data created}
		      --[Joining both Sheet's location, to show Vaccination Rolling as per Location in symmetric order]
		
	select dea.continent , dea.location , dea.date, dea.population , vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as Vaccinated_Rolling
	from [Project portfolio]..CovidDeaths dea
	join [Project portfolio]..CovidVaccination vac
	on  dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

		
--8th.{Data created}
		     --[Using CTE]

	With PopvsVac (continent, Location, date, population, new_vaccinations ,Vaccinated_Rolling)
	AS 
(
	select dea.continent , dea.location , dea.date, dea.population , vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as Vaccinated_Rolling
	from [Project portfolio]..CovidDeaths dea
	join [Project portfolio]..CovidVaccination vac
	on  dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
	select *, (Vaccinated_Rolling/population)*100 as VaccinationPercentpopulation
	from PopvsVac


--{9th. Data created}
		      --[TEMP TABLE]
				     --[Creating Table by Joining Both Sheet to display vaccination being rolled baseed on location as Population/continent]

	Create Table #PercentageOfPopulationVaccinated
(
	continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	population numeric,
	new_Vaccinations numeric,
	Vaccinated_Rolling numeric,
)

	INSERT INTO #PercentageOfPopulationVaccinated
	select dea.continent , dea.location , dea.date, dea.population , vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as Vaccinated_Rolling
	from [Project portfolio]..CovidDeaths dea
	join [Project portfolio]..CovidVaccination vac
	on  dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	select *, (Vaccinated_Rolling/population)*100
	from #PercentageOfPopulationVaccinated

--{10th. Data created}
		     --[ Final Temporary data]	
			                       --[ View Creation For Ease of Displaying Data ]
		
	Create View VacRoling as 
	select dea.continent , dea.location , dea.date, dea.population , vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as Vaccinated_Rolling
	from [Project portfolio]..CovidDeaths dea
	join [Project portfolio]..CovidVaccination vac
	on  dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null	
	--order by 2,3

	select *
	from VacRoling