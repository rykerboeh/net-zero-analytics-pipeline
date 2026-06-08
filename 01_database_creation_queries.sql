--============================================================
-- Create table schemas to import dataset csv files
--============================================================

-- Campus Meta

CREATE TABLE campus_meta (
	id INT,
	name TEXT,
	capacity INT
);

-- Building Meta

CREATE TABLE building_meta (
	campus_id INT,
	id INT,
	built_year INT,
	category TEXT,	
	gross_floor_area NUMERIC,
	room_area NUMERIC, 
	capacity NUMERIC 
);

-- Building Consumption

CREATE TABLE building_consumption (
	campus_id INT,
	meter_id INT,	
	timestamp TIMESTAMP,	
	consumption NUMERIC
);

-- Building Submeter Consumption

CREATE TABLE submeter_consumption (
	building_id	TEXT, -- Imported as TEXT to prevent data loss from "N/A" values
	id INT,
	campus_id TEXT, -- Imported as TEXT to prevent data loss from "N/A" values
	timestamp TIMESTAMP,	
	consumption	NUMERIC,
	current	NUMERIC,
	voltage NUMERIC,	
	power NUMERIC,	
	power_factor NUMERIC
);
	
-- Gas Consumption

CREATE TABLE gas_consumption (
	campus_id INT,
	timestamp TIMESTAMP,	
	consumption NUMERIC
);

-- Water Consumption

CREATE TABLE water_consumption (
	campus_id INT,
	meter_id INT,	
	timestamp TIMESTAMP,
	consumption NUMERIC
);
