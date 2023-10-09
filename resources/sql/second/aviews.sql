
-- how many vip passengers does a given flight have?
CREATE VIEW FLIGHT_VIP_COUNT AS 
SELECT 
	flight_tuid, 
	flight_date, 
	COUNT(*) AS vip_count
FROM 
	SCHEDULE_TABLE_DATA 
WHERE 
	seated_section = 'V'
GROUP BY 
	flight_tuid,flight_date;

-- tells us how many passengers in each flight WANTED
-- to get vip
CREATE VIEW FLIGHT_VIP_COUNT_WANTED AS 
SELECT 
	flight_tuid, 
	flight_date, 
	COUNT(*) AS vip_count_wanted
FROM 
	SCHEDULE_TABLE_DATA 
WHERE 
	requested_section = 'V'
GROUP BY 
	flight_tuid,flight_date;

-- how many luxary passengers does a flight have?
CREATE VIEW FLIGHT_LUXURY_COUNT AS 
SELECT 
	flight_tuid,
	flight_date,
	COUNT(*) AS luxury_count
FROM 
	SCHEDULE_TABLE_DATA 
WHERE 
	seated_section = 'L'
GROUP BY
	flight_tuid,flight_date;

-- how many luxary passengers does a flight have?
CREATE VIEW FLIGHT_LUXURY_COUNT_WANTED AS 
SELECT 
	flight_tuid,
	flight_date,
	COUNT(*) AS luxury_count_wanted
FROM 
	SCHEDULE_TABLE_DATA 
WHERE 
	requested_section = 'L'
GROUP BY
	flight_tuid,flight_date;

-- returns a list of passenger counts for flight
-- scheduled on a given day
CREATE VIEW FLIGHT_PASSENGER_COUNT AS 
SELECT 
	CASE 
		WHEN FLIGHT_VIP_COUNT.flight_tuid is NULL
			then FLIGHT_LUXURY_COUNT.flight_tuid 
		ELSE 
			FLIGHT_VIP_COUNT.flight_tuid 
	END flight_tuid,
	
	CASE 
		WHEN FLIGHT_VIP_COUNT.flight_date is NULL
			then FLIGHT_LUXURY_COUNT.flight_date 
		ELSE 
			FLIGHT_VIP_COUNT.flight_date 
	END flight_date,
	
	CASE 
		WHEN luxury_count is NULL 
			then 0 
		ELSE 
			luxury_count 
	END luxury_count,
	
	CASE 
		WHEN vip_count is NULL 
			then 0 
		ELSE 
			vip_count 
	END vip_count
	
	FROM 

		FLIGHT_LUXURY_COUNT 
	FULL RIGHT JOIN 
		FLIGHT_VIP_COUNT 
	ON 
		FLIGHT_VIP_COUNT.flight_tuid = 
			FLIGHT_LUXURY_COUNT.flight_tuid 
		AND 
		FLIGHT_VIP_COUNT.flight_date =
			FLIGHT_LUXURY_COUNT.flight_date;

-- contains information about the number of passengers on
-- any given flight, and the max passengers for that flight
-- AND the time for the flight
CREATE VIEW POPULATED_FLIGHT_PASSENGER_COUNT AS 
	SELECT 
		flight_tuid,
		flight_date,
		luxury_count,
		vip_count 
	FROM FLIGHT_PASSENGER_COUNT;

--convinence view that gives us flight
--information with timing information
CREATE VIEW FLIGHT_TIMEING_VIEW AS 
SELECT * 
FROM SCHEDULE_TABLE_DATA 
	INNER JOIN FLIGHT_TABLE 
	ON SCHEDULE_TABLE_DATA.FLIGHT_TUID = FLIGHT_TABLE.tuid;


CREATE VIEW SCHEDULE_TABLE 
AS SELECT * FROM SCHEDULE_TABLE_DATA;

CREATE VIEW SCHEDULE_TABLE_WTIH_DATE AS 
SELECT * 
FROM SCHEDULE_TABLE 
	INNER JOIN FLIGHT_TABLE 
	ON FLIGHT_TABLE.TUID = SCHEDULE_TABLE.FLIGHT_TUID;

-- human readable schedule table
CREATE VIEW HR_SCHEDULE_TABLE AS 
SELECT 
	LASTNAME,
	PLANE_ID, 
	DEPART_TIME,
	FLIGHT_DATE,
	REQUESTED_SECTION,
	SEATED_SECTION,
	SEAT_NUMBER
FROM  
	SCHEDULE_TABLE 
INNER JOIN FLIGHT_TABLE
	ON SCHEDULE_TABLE.flight_tuid = FLIGHT_TABLE.tuid
INNER JOIN PLANE_TABLE
	ON	PLANE_TABLE.tuid = FLIGHT_TABLE.plane_tuid
INNER JOIN PASSENGER_TABLE
	ON PASSENGER_TABLE.tuid = SCHEDULE_TABLE.passenger_tuid;

CREATE TABLE OUTPUT_TABLE(
data VARCHAR
);


--generates a list of all possible date that we could possible have
--a flight from the given table
CREATE VIEW ALL_POSSIBLE_FLIGHT_DATES AS
	WITH RECURSIVE countDates AS 
	(
		SELECT min(flight_date) AS flight_date FROM SCHEDULE_TABLE_DATA 
	
		UNION ALL
			
		SELECT datetime(flight_date,'+1 days') 
			FROM countDates 
			WHERE datetime(flight_date,'-1 days') <= 
				(SELECT max(flight_date) 
					FROM SCHEDULE_TABLE_DATA)
	)
	
	SELECT * FROM countDates;

--creates a populated view of every possible flight
--that could be flown in
CREATE VIEW ALL_POSSIBLE_FLIGHTS AS 
SELECT 
	FLIGHT_TABLE.tuid,
	ALL_POSSIBLE_FLIGHT_DATES.flight_date,
	FLIGHT_TABLE.DEPART_TIME,
	CASE 
		WHEN vip_count IS null 
			THEN 0 
		ELSE 
			vip_count 
	END vip_count,

	CASE 
		WHEN luxury_count IS null 
			THEN 0 
		ELSE 
			luxury_count 
	END luxury_count
FROM 
	ALL_POSSIBLE_FLIGHT_DATES,
	FLIGHT_TABLE 
	LEFT JOIN FLIGHT_PASSENGER_COUNT 
	ON FLIGHT_PASSENGER_COUNT.flight_tuid =
		FLIGHT_TABLE.tuid 
		AND 
		DATE(FLIGHT_PASSENGER_COUNT.flight_date) =
		DATE(ALL_POSSIBLE_FLIGHT_DATES.flight_date) 
		;



