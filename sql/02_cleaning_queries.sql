--===========================================
-- Cleaning/Transforming Datasets
--===========================================

--================
-- Building meta
--================

-- Round values for gross_floor_area and room_area to two decimal places and set "0" values to NULL

SELECT
	CASE
		WHEN gross_floor_area = 0 THEN NULL
		ELSE ROUND(gross_floor_area, 2)
	END AS clean_gross_area,
	ROUND(room_area, 2) AS clean_room_area
FROM building_meta;

-- Cast capacity as integir and replace "0" values to NULL

SELECT capacity,
	CASE
		WHEN capacity = 0 THEN NULL
		ELSE capacity::INT
	END AS clean_capacity
FROM building_meta;

--==========================
-- Building Consumption
--==========================

WITH duplicate_cte AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER (
            PARTITION BY campus_id, meter_id, timestamp 
            ORDER BY meter_id                           
        ) as row_num
    FROM building_consumption
)
SELECT * 
FROM duplicate_cte 
WHERE row_num > 1;

--=========================
-- Submeter Consumption
--=========================

WITH duplicate_cte AS (
    SELECT 
        *, 
		-- Use row_num function to identify potential duplicates
        ROW_NUMBER() OVER (
            PARTITION BY building_id, id, campus_id, timestamp
            ORDER BY id                           
        ) as row_num,
		-- Create total_count variable in order to see "duplicate" data against "original"
		COUNT(*) OVER (
            PARTITION BY building_id, id, campus_id, timestamp                          
        ) as total_count
    FROM submeter_consumption
)
SELECT * 
FROM duplicate_cte 
WHERE total_count > 1
ORDER BY building_id, id, campus_id, timestamp, row_num;

-- Refine above function to contain duplicate identification to true duplicates rather than values from multi-phase submeters

WITH duplicate_cte AS (
    SELECT 
        *, 
		-- Use row_num function to identify potential duplicates
        ROW_NUMBER() OVER (
            PARTITION BY building_id, id, campus_id, timestamp, consumption, current, voltage, power, power_factor
            ORDER BY id                           
        ) as row_num,
		-- Create total_count variable in order to see "duplicate" data against "original"
		COUNT(*) OVER (
            PARTITION BY building_id, id, campus_id, timestamp, consumption, current, voltage, power, power_factor                          
        ) as total_count
    FROM submeter_consumption
)
SELECT * 
FROM duplicate_cte 
WHERE total_count > 1
ORDER BY building_id, id, campus_id, timestamp, row_num;

/* Check that submeter consumption totals are consistently lower than building consumption totals. This helps us decide
whether we should consider submeter consumption totals redundant to building totals. */

SELECT b.meter_id,
	   b.timestamp::DATE,
	   ROUND(SUM(b.consumption), 2) AS total_consumption,
	   ROUND(SUM(s.consumption), 2) AS submeter_total
FROM building_consumption b
LEFT JOIN submeter_consumption s
		ON b.meter_id::TEXT = s.building_id
		AND b.timestamp::DATE = s.timestamp::DATE
WHERE b.meter_id = '30'
	AND s.consumption IS NOT NULL
GROUP BY b.meter_id, b.timestamp::DATE
ORDER BY b.meter_id, b.timestamp::DATE
LIMIT 10;

--======================
-- Gas Consumption
--======================

WITH duplicate_cte AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER (
            PARTITION BY campus_id, timestamp, consumption 
            ORDER BY campus_id                          
        ) as row_num
    FROM gas_consumption
)
SELECT * 
FROM duplicate_cte 
WHERE row_num > 1;

-- Use subquery to delete 1,417 duplicate rows from dataset

DELETE FROM gas_consumption
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT ctid, 
        ROW_NUMBER() OVER (
            PARTITION BY campus_id, timestamp, consumption 
            ORDER BY campus_id                          
        ) as row_num
    FROM gas_consumption
    ) d
    WHERE d.row_num > 1
	);

--========================
-- Water Consumption
--========================

-- Set default NULL value for water consumption to 0

SELECT
	CASE
		WHEN consumption IS NULL THEN 0
		ELSE consumption
	END AS clean_consumption
FROM water_consumption

--

WITH duplicate_cte AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER (
            PARTITION BY campus_id, meter_id, timestamp, consumption 
            ORDER BY meter_id                          
        ) as row_num
    FROM water_consumption
)
SELECT * 
FROM duplicate_cte 
WHERE row_num > 1;

-- Use subquery to delete 13 duplicate rows from dataset

DELETE FROM water_consumption
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT ctid, 
        ROW_NUMBER() OVER (
            PARTITION BY campus_id, meter_id, timestamp, consumption 
            ORDER BY meter_id                          
        ) as row_num
    FROM water_consumption
    ) d
    WHERE d.row_num > 1
	);
