SELECT
ms. Region of Origin,
AVG(ms. Total Number of Dead and Missing) AS missing_rate, AVG(ds. Unemployment rate) AS Unemployment_rate,
CORR(ms. Total Number of Dead and Missing, ds. Unemployment rate) AS correlation_missing_unemployment
FROM
Global missing migrants ms JOIN
World data ds ON ms. Country of Origin = ds.country AND ms.incident year = ds.incident year GROUP BY
ms. Country of Origin ORDER BY
correlation_missing_unemployment DESC;


--Geographical analysis with coordinates

SELECT
gmm.`Incident year`, gmm.`Country of Origin`, gmm.`Region of Incident`, gmm.`Coordinates`, wd.`Country`, wd.`Latitude`, wd.`Longitude`, wd.`Population`, wd.`GDP`,
wd.`Life expectancy`,
-- Formula per calcolare la distanza in chilometri (6371 * ACOS(
COS(RADIANS(SUBSTRING_INDEX(gmm.`Coordinates`, ',', 1))) * COS(RADIANS(wd.`Latitude`)) * COS(RADIANS(wd.`Longitude`) - RADIANS(SUBSTRING_INDEX(gmm.`Coordinates`, ',', -1))) + SIN(RADIANS(SUBSTRING_INDEX(gmm.`Coordinates`, ',', 1))) * SIN(RADIANS(wd.`Latitude`))
)) AS Distance_KM FROM
`Global_missing_migrants` gmm LEFT JOIN
`world_data_2023` wd ON
(6371 * ACOS(
COS(RADIANS(SUBSTRING_INDEX(gmm.`Coordinates`, ',', 1))) * COS(RADIANS(wd.`Latitude`)) * COS(RADIANS(wd.`Longitude`) - RADIANS(SUBSTRING_INDEX(gmm.`Coordinates`, ',', -1))) + SIN(RADIANS(SUBSTRING_INDEX(gmm.`Coordinates`, ',', 1))) * SIN(RADIANS(wd.`Latitude`))
))) <= 100;
 

 
--Development indicators and migration flows:

SELECT
wd.`Country`, wd.`Population`,
wd.`Density\n(P/Km2)` AS Population_Density, wd.`Fertility Rate`,
wd.`Infant mortality`, gmm.`Country of Origin`, gmm.`Incident year`, gmm.`Number of Dead`,
gmm.`Total Number of Dead and Missing` FROM
`world_data_2023` wd RIGHT JOIN
`Global_missing_migrants` gmm ON
wd.`Country` = gmm.`Country of Origin` WHERE
wd.`Country` IS NOT NULL;
