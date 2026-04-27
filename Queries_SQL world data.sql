--First, I created a table to analyze the data from the World Data dataset.

CREATE TABLE IF NOT EXISTS public."World data" (
"ID" integer NOT NULL, "Country" "char", "Density (P/Km2)" integer, "Abbreviation" "char",
"Agricultural Land( %)" double precision, "food_insecurity_rate" REAL,
"Land Area(Km2)" double precision, "Armed Forces size" integer, "Capital/Major City" "char",
"Co2-Emissions" double precision, "Forested Area (%)" double precision, "GDP" double precision,
“gdp_per_capita” double precision, "Infant mortality" double precision, "Largest city" "char",
"Life expectancy" double precision, "Maternal mortality ratio" integer, "Minimum wage" double precision,
“primary_enrollment_rate” double precision, “literacy_rate” double precision,
“tertiary_enrollment_rate” double precision
"Out of pocket health expenditure" double precision, "Population" integer,
"Total tax rate" double precision, "Unemployment rate" double precision, "Urban_population" integer
CONSTRAINT "World data _pkey" PRIMARY KEY ("ID")
)
 
--I wanted to analyze population density and land area to study spatial distribution patterns.

SELECT
Country, Population, Land Area(Km2),
(Population / NULLIF(Land Area(Km2), 0)) AS population_density, CASE
WHEN (Population / NULLIF(land_area, 0)) >= 1000 THEN 'High Density'
WHEN (Population / NULLIF(land_area, 0)) BETWEEN 500 AND 999 THEN 'Medium Density' ELSE 'Low Density'
END AS density_category FROM
World data ORDER BY
density_category, population_density DESC;


--I calculated standard deviations in density to identify areas significantly above or below the norm, which may indicate unique spatial patterns.

WITH Density (P/Km2) AS ( SELECT
Country, Population, Land Area(Km2),
(Population / NULLIF(Land Area(Km2), 0)) AS population_density FROM
World data
),
stats AS ( SELECT
 
AVG(Density (P/Km2)) AS avg_density, STDDEV_POP(population_density) AS stddev_density
FROM
density_data
)
SELECT
d. Country, d.Population,
d. Land Area(Km2),
d. Density (P/Km2), s.avg_density, s.stddev_density, CASE
WHEN d. Density (P/Km2) > s.avg_density + 2 * s.stddev_density THEN 'Significantly Above Average' WHEN d. Density (P/Km2) < s.avg_density - 2 * s.stddev_density THEN 'Significantly Below Average' ELSE 'Within Average Range'
END AS density_deviation_category FROM
density_data d CROSS JOIN
stats s ORDER BY
d. Density (P/Km2) DESC;

 
--I wanted to Investigate the relationship between agricultural land and food security.

SELECT CORR(Agricultural Land( %), food_insecurity_rate) AS correlation FROM world_data;

--I identified countries where high agricultural land percentages coexist with high food insecurity (indicating inefficiencies or other issues):

SELECT country, agricultural_land_percentage, food_insecurity_rate FROM world_data
WHERE agricultural_land_percentage > 50 -- High agricultural land percentage AND food_insecurity_rate > 20 -- High food insecurity rate (threshold may vary) ORDER BY food_insecurity_rate DESC;
 
--I wanted to Explore correlations between economic indicators such as GDP and various socio-economic factors. (infant mortality, life expectancy)

SELECT
Country,
CORR(gdp_per_capita, Infant mortality) AS corr_gdp_infant_mortality, CORR(gdp_per_capita, Life expectancy) AS corr_gdp_life_expectancy
FROM
World data GROUP BY
Country;


--To calculate the average enrollment rates for primary and tertiary education across all countries:

SELECT
AVG(primary_enrollment_rate) AS avg_primary_enrollment, AVG(tertiary_enrollment_rate) AS avg_tertiary_enrollment
FROM world_data;


--Analyze the correlation between educational enrollment rates and GDP per capita as an indicator of human capital development:

SELECT
CORR(primary_enrollment_rate, gdp_per_capita) AS primary_gdp_correlation, CORR(tertiary_enrollment_rate, gdp_per_capita) AS tertiary_gdp_correlation
FROM world_data;


--Identify countries with low tertiary enrollment rates but high GDP per capita (or vice versa):

SELECT
country, primary_enrollment_rate, tertiary_enrollment_rate, gdp_per_capita
FROM world_data
WHERE (tertiary_enrollment_rate < 20 AND gdp_per_capita > 20000) OR (tertiary_enrollment_rate > 70 AND gdp_per_capita < 5000)
ORDER BY gdp_per_capita DESC;
 
--Explore the overall impact of enrollment rates on literacy and GDP per capita:

SELECT
country, primary_enrollment_rate, tertiary_enrollment_rate, literacy_rate, gdp_per_capita
FROM world_data
WHERE literacy_rate IS NOT NULL
ORDER BY literacy_rate DESC, gdp_per_capita DESC;
