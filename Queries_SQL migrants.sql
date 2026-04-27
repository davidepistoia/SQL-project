CREATE TABLE IF NOT EXISTS public."Global missing migrants " (
"ID" integer NOT NULL, "Incident Type" "char", "Incident year" integer, "Reported Month" "char", "Region of Origin" "char", "Region of Incident" "char", "Country of Origin" "char", "Number of Dead" integer, “number_of_females” integer, “number_of_males” integer,
"Total Number of Dead and Missing" integer, "Number of Survivors" integer,
"Cause of Death" "char", "Migration route" "char",
CONSTRAINT "Global missing migrants _pkey" PRIMARY KEY ("ID")
)
 
--I wanted to explore trends and patterns in migration incidents to understand the most affected regions and routes.
--I writed this query to calculate the total number of migration incidents per region (considering both source and destination regions) to identify the most frequently affected areas.

SELECT
Region of Incidents, SUM(ID) AS total_incidents
FROM (
SELECT
Region of Origin AS region, COUNT(ID) AS incident_count
FROM
Global missing migrants GROUP BY
Region of Origin


UNION ALL


SELECT
Region of Incident AS region, COUNT(ID) AS incident_count
FROM
Global missing migrants GROUP BY
Region of Incident
) AS combined_regions GROUP BY
region ORDER BY
total_incidents DESC;
 
--I wanted to explore the most common migration routes (source to destination pairs), so I used this query that calculates the frequency of each route:

SELECT
Region of Origin, Region of Incident,
COUNT(ID) AS total_incidents FROM
Global missing migrants GROUP BY
Region of Origin, Region of Incident ORDER BY
total_incidents DESC LIMIT 10;


--To identify trends over time, such as yearly increases or decreases in migration incidents, i used the following query:

SELECT
EXTRACT(Incident year) AS year, COUNT(ID) AS total_incidents,
SUM(Total Number of Dead and Missing) AS total_migrants FROM
Global missing migrants GROUP BY
year ORDER BY
year;

--To find regions with the highest total migrant counts, we can aggregate by source and destination regions separately and then combine the totals:

SELECT
region,
SUM(migrant_count) AS total_migrants FROM (
SELECT
Region of Origin AS region, SUM(migrant_count) AS migrant_count
FROM
Global missing migrants GROUP BY
Region of Origin


UNION ALL


SELECT
Region of Incident AS region,
SUM(Total Number of Dead and Missing) AS migrant_count FROM
Global missing migrants GROUP BY
Region of Incident
) AS combined_regions GROUP BY
region ORDER BY
total_migrants DESC;
 

--Calculate the total number of females, males, and children involved in migration incidents:

SELECT
SUM(number_of_females) AS total_females, SUM(number_of_males) AS total_males, SUM(number_of_children) AS total_children
FROM migration_incidents;


SELECT
incident_year,
SUM(number_of_survivors) AS total_survivors, SUM(total_number_of_dead_and_missing) AS total_dead_and_missing, SUM(number_of_survivors) * 100.0 / NULLIF(SUM(number_of_survivors +
total_number_of_dead_and_missing), 0) AS survival_rate
FROM migration_incidents GROUP BY incident_year ORDER BY incident_year;

--Find the most common causes of death and the associated number of fatalities:

SELECT
cause_of_death,
SUM(total_number_of_dead_and_missing) AS total_fatalities FROM migration_incidents
GROUP BY cause_of_death
 
ORDER BY total_fatalities DESC LIMIT 5;

--Highlight regions with the highest mortality rates:

SELECT
region_of_incident, SUM(total_number_of_dead_and_missing) AS total_deaths,
SUM(number_of_survivors) + SUM(total_number_of_dead_and_missing) AS total_involved,
SUM(total_number_of_dead_and_missing) * 100.0 / NULLIF(SUM(number_of_survivors + total_number_of_dead_and_missing), 0) AS mortality_rate
FROM migration_incidents GROUP BY region_of_incident ORDER BY mortality_rate DESC LIMIT 5;

