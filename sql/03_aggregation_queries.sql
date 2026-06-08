--==================================
-- Data Aggregation for Analysis
--==================================

-- Create CTE to calculate gross square footage per campus
WITH campus_gfa_totals AS (
    SELECT 
        campus_id,
        id AS building_id,
        gross_floor_area,
        -- Calculate total square footage per campus to use as the denominator
        SUM(gross_floor_area) OVER(PARTITION BY campus_id) AS total_campus_gfa
    FROM building_meta
    WHERE gross_floor_area > 0 AND gross_floor_area IS NOT NULL
),

-- Create CTE to clean and sum electricity consumption dataset
monthly_electricity AS (
	SELECT campus_id,
		   meter_id AS building_id,
		   EXTRACT(YEAR FROM timestamp) AS year,
		   EXTRACT(MONTH FROM timestamp) AS month,
		   SUM(consumption) as total_kw
	FROM building_consumption
	GROUP BY campus_id, building_id, year, month
),

-- Create CTE to clean and sum gas consumption dataset
monthly_gas AS (
	SELECT campus_id,
		   EXTRACT(YEAR FROM timestamp) AS year,
		   EXTRACT(MONTH FROM timestamp) AS month,
		   SUM(consumption) as total_gas
	FROM gas_consumption
	GROUP BY campus_id, year, month
),

-- Create CTE to clean and sum water consumption dataset
monthly_water AS (
	SELECT campus_id,
		   EXTRACT(YEAR FROM timestamp) AS year,
		   EXTRACT(MONTH FROM timestamp) AS month,
		   SUM(consumption) as total_water
	FROM water_consumption
	GROUP BY campus_id, year, month
)

-- Build final dataset of consumption totals
SELECT e.campus_id,
	   cm.name AS campus_name,
	   e.building_id AS building_id,
	   e.year AS year,
	   e.month AS month,
	   ROUND(e.total_kw, 2) AS total_kw_consumed,
	   /* Set default NULL value for total gas consumption to 0. Multiply gas consumption totals by variable calculated by 
	   finding building's percentage of campus gross floor area. */
	   CASE
	   	  WHEN g.total_gas IS NULL OR cgfa.gross_floor_area IS NULL THEN 0
		  ELSE ROUND(g.total_gas * (cgfa.gross_floor_area / cgfa.total_campus_gfa), 2)
	   END AS total_gas_consumed,
	   /* Set default NULL value for total water consumption to 0. Multiply water consumption totals by variable calculated 
	   by finding building's percentage of campus gross floor area. */
   	   CASE 
		  WHEN w.total_water IS NULL OR cgfa.gross_floor_area IS NULL THEN 0
		  ELSE ROUND(w.total_water * (cgfa.gross_floor_area / cgfa.total_campus_gfa), 2)
		END AS total_water_consumed
FROM monthly_electricity e

-- Joins for meta and clean utility total datasets
JOIN campus_meta cm
	ON cm.id = e.campus_id
LEFT JOIN campus_gfa_totals cgfa 
	ON e.building_id = cgfa.building_id 
	AND e.campus_id = cgfa.campus_id
LEFT JOIN monthly_gas g 
    ON e.campus_id = g.campus_id 
    AND e.year = g.year 
    AND e.month = g.month
LEFT JOIN monthly_water w 
    ON e.campus_id = w.campus_id 
    AND e.year = w.year
    AND e.month = w.month
ORDER BY e.campus_id, e.building_id, year, month;
