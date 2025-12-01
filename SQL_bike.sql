

SELECT * FROM
	bike
LIMIT 100;



-- adding new columns by splititng the date and time: 

SELECT
    started_at,
	ended_at,
    TO_TIMESTAMP(started_at, 'DD/MM/YYYY HH24:MI')::DATE AS Start_Date,
	TO_TIMESTAMP(ended_at, 'DD/MM/YYYY HH24:MI')::DATE AS Ended_Date,
    TO_TIMESTAMP(started_at, 'DD/MM/YYYY HH24:MI')::TIME AS Start_Time,
	TO_TIMESTAMP(ended_at, 'DD/MM/YYYY HH24:MI')::TIME AS Ended_Time
FROM 
	bike;



-- adding date columns:

ALTER TABLE bike
ADD COLUMN started_date TIMESTAMP,
ADD COLUMN ended_date TIMESTAMP;



-- updating:

UPDATE bike
SET 
	started_date = TO_TIMESTAMP (started_at, 'DD/MM/YYYY HH24:MI')::DATE,
	ended_date = TO_TIMESTAMP (ended_at, 'DD/MM/YYYY HH24:MI')::DATE;



-- adding time columns:

ALTER TABLE bike
ADD COLUMN started_time TIME,
ADD COLUMN ended_time TIME;



-- updating: 

UPDATE bike
SET 
	started_time = TO_TIMESTAMP (started_at, 'DD/MM/YYYY HH24:MI')::TIME,
	ended_time = TO_TIMESTAMP (ended_at, 'DD/MM/YYYY HH24:MI')::TIME;



-- drop unwanted columns:

ALTER TABLE bike
DROP COLUMN started_at,
DROP COLUMN ended_at,
DROP COLUMN start_station_id,
DROP COLUMN end_station_id;



-- adding new column from trip dauration:

ALTER TABLE bike
ADD COLUMN trip_duration_min NUMERIC;



-- subtract end time by start time to get the trip duration:

UPDATE bike
SET trip_duration_min = ROUND(EXTRACT(EPOCH FROM (ended_time - started_time)) / 60, 0);



-- removing any trip_duration that = 0:

SELECT
	trip_duration_min,
	COUNT(*) AS Total_Trips_Below_Zero
FROM
	bike
WHERE
	trip_duration_min <= 0
GROUP BY
	trip_duration_min
ORDER BY 
	Total_Trips_Below_zero DESC;



-- removing

DELETE FROM bike
WHERE
	trip_duration_min <= 0;



-- outlier detection with chatgpt help:

WITH stats AS (
    SELECT
        PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY trip_duration_min) AS q1,
        PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY trip_duration_min) AS q3
    FROM bike
),
bounds AS (
    SELECT
        (q1 - 1.5 * (q3 - q1)) AS lower,
        (q3 + 1.5 * (q3 - q1)) AS upper
    FROM stats
)
SELECT *
FROM bike, bounds
WHERE trip_duration_min < bounds.lower
   OR trip_duration_min > bounds.upper;



-- remove the outliers : 

WITH stats AS (
    SELECT
        PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY trip_duration_min) AS q1,
        PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY trip_duration_min) AS q3
    FROM bike
),
bounds AS (
    SELECT
        (q1 - 1.5 * (q3 - q1)) AS lower,
        (q3 + 1.5 * (q3 - q1)) AS upper
    FROM stats
)
DELETE FROM bike
USING bounds
WHERE trip_duration_min < bounds.lower
   OR trip_duration_min > bounds.upper;



-- check the null values:

SELECT *
FROM 
	bike
WHERE 
	ride_id IS NULL
   OR rideable_type IS NULL
   OR start_station_name IS NULL
   OR end_station_name IS NULL
   OR start_lat IS NULL
   OR start_lng IS NULL
   OR end_lat IS NULL
   OR end_lng IS NULL
   OR member_casual IS NULL
   OR started_date IS NULL
   OR ended_date IS NULL
   OR started_time IS NULL
   OR ended_time IS NULL
   OR trip_duration_min IS NULL;



-- remove null values 

DELETE FROM 
	bike
WHERE 
	ride_id IS NULL
   OR rideable_type IS NULL
   OR start_station_name IS NULL
   OR end_station_name IS NULL
   OR start_lat IS NULL
   OR start_lng IS NULL
   OR end_lat IS NULL
   OR end_lng IS NULL
   OR member_casual IS NULL
   OR started_date IS NULL
   OR ended_date IS NULL
   OR started_time IS NULL
   OR ended_time IS NULL
   OR trip_duration_min IS NULL;


SELECT
	*
FROM
	bike;






