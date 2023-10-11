
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
	END vip_count,

	CASE 
		WHEN luxury_count_wanted is NULL 
			THEN 0 
		ELSE 
			luxury_count_wanted 
	END luxury_count_wanted,
	
	CASE 
		WHEN vip_count_wanted is NULL 
			THEN 0 
		ELSE 
			vip_count_wanted 
	END vip_count_wanted 

	FROM 

		FLIGHT_LUXURY_COUNT 
	FULL RIGHT JOIN 
		FLIGHT_VIP_COUNT 
	ON 
		FLIGHT_VIP_COUNT.flight_tuid = 
			FLIGHT_LUXURY_COUNT.flight_tuid 
		AND 
		FLIGHT_VIP_COUNT.flight_date =
			FLIGHT_LUXURY_COUNT.flight_date 
	
	FULL LEFT JOIN 
		FLIGHT_LUXURY_COUNT_WANTED AS FLCW
	ON 
		FLCW.flight_tuid = FLIGHT_LUXURY_COUNT.flight_tuid 
	AND 
		FLCW.flight_date = FLIGHT_LUXURY_COUNT.flight_date 
	
	FULL LEFT JOIN 
		FLIGHT_VIP_COUNT_WANTED AS FVCW 
	ON 
		FVCW.flight_tuid = FLIGHT_VIP_COUNT.flight_tuid 
	AND 
		FVCW.flight_date = FLIGHT_VIP_COUNT.flight_date

		;


-- contains information about the number of passengers on
-- any given flight, and the max passengers for that flight
-- AND the time for the flight
CREATE VIEW POPULATED_FLIGHT_PASSENGER_COUNT AS 
	SELECT 
		flight_tuid,
		flight_date,
		luxury_count,
		vip_count,
		luxury_count_wanted,
		vip_count_wanted,
		max_vip,
		max_luxury
	FROM FLIGHT_PASSENGER_COUNT 
	
	LEFT JOIN FLIGHT_TABLE 
	ON 
		FLIGHT_TABLE.tuid 
			= FLIGHT_PASSENGER_COUNT.flight_tuid
	LEFT JOIN PLANE_TABLE 
	ON 
		PLANE_TABLE.tuid = FLIGHT_TABLE.plane_tuid;

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
--that could be flown in and the max and min lux/vip
--that could be or are in that flight
CREATE VIEW ALL_POSSIBLE_FLIGHTS AS 
SELECT 
	FLIGHT_TABLE.tuid as flight_tuid,
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
	END luxury_count,

	CASE 
		WHEN luxury_count_wanted IS null 
			THEN 0 
		ELSE 
			luxury_count_wanted   
	END luxury_count_wanted,

	CASE 
		WHEN vip_count_wanted IS null 
			THEN 0 
		ELSE 
			vip_count_wanted 
	END vip_count_wanted,
	max_vip,
	max_luxury
	
FROM 
	ALL_POSSIBLE_FLIGHT_DATES,
	FLIGHT_TABLE 
	
	LEFT JOIN FLIGHT_PASSENGER_COUNT 
	ON FLIGHT_PASSENGER_COUNT.flight_tuid =
		FLIGHT_TABLE.tuid 
		AND 
		DATE(FLIGHT_PASSENGER_COUNT.flight_date) =
		DATE(ALL_POSSIBLE_FLIGHT_DATES.flight_date) 
	LEFT JOIN PLANE_TABLE 
	ON PLANE_TABLE.tuid = FLIGHT_TABLE.tuid;
	
;

--contains a view of all seats that are double booked by 
--passengers
--this is used in the bumping step of our insert code
--plus its a generally useful thing to have lying around
CREATE VIEW SEATING_CONFLICTS AS 

SELECT 
	st1.flight_date,
	st1.flight_tuid,
	st1.passenger_tuid AS vip_passenger_tuid,
	st2.passenger_tuid AS luxury_passenger_tuid
FROM 
	SCHEDULE_TABLE as st1 
	INNER JOIN 
	SCHEDULE_TABLE as st2

	ON 

	st1.flight_date = st2.flight_date AND 
	st1.flight_tuid = st2.flight_tuid AND 
	st1.passenger_tuid <> st2.passenger_tuid AND 
	st1.seated_section = st2.seated_section AND 
	st1.seat_number = st2.seat_number AND 
	st1.requested_section = 'V'; --ensure vip is from table 1

