--this file is used to CREATE the database
--and contains all sql commands required for that task

--sqllite does not include foreign_keys by default
--we need to enable this for the behavior
--note on some systems very rarely sql lite will NOT include
--foreign_keys, with the packaged version of sql lite we 
--SHOULD be ok
PRAGMA foreign_keys = ON;

--if the tables exist, remove them before creating
DROP TABLE IF EXISTS SCHEDULE_TABLE;
DROP TABLE IF EXISTS FEE_TABLE;
DROP TABLE IF EXISTS PASSENGER_TABLE;
DROP TABLE IF EXISTS FLIGHT_TABLE;
DROP TABLE IF EXISTS PLANE_TABLE;

-- sql lite does auto incriment
-- automatically with INTEGER PRIMARY KEY

--contains info about each individual plane
CREATE TABLE PLANE_TABLE(
	TUID INTEGER PRIMARY KEY, 
	PLANE_ID VARCHAR,
	MAX_VIP INT,
	MAX_LUXURY INT
);


--contains info about which plane flies 
--at what time and from where
CREATE TABLE FLIGHT_TABLE (
	TUID INTEGER PRIMARY KEY, 
	PLANE_TUID INTEGER ,
	AIRPORT_CODE VARCHAR,
	DEPART_GATE VARCHAR,
	DEPART_TIME DATE,
	FOREIGN KEY (PLANE_TUID)
       REFERENCES PLANE_TABLE(TUID)
	);

----person who could be in the airport
CREATE TABLE PASSENGER_TABLE(
	TUID INTEGER PRIMARY KEY,
	FIRST_INITIAL CHAR,
	MIDDLE_INITIAL CHAR,
	LASTNAME VARCHAR,
	PHONE_NUMBER VARCHAR
);

--contains info on what does everything cost.
CREATE TABLE FEE_TABLE (
	TUID INTEGER PRIMARY KEY,
	FEE_TYPE VARCHAR,
	COST DECIMAL
);


--information about whos on what plane
CREATE TABLE SCHEDULE_TABLE_DATA (
	tuid INTEGER PRIMARY KEY,
	passenger_tuid INTEGER ,
	flight_tuid INTEGER ,
	flight_date DATE,
	requested_section CHAR,
	seated_section CHAR,
	seat_number INTEGER,

	FOREIGN KEY(PASSENGER_TUID) 
		 REFERENCES PASSENGER_TABLE(TUID),
	FOREIGN KEY(FLIGHT_TUID)
		 REFERENCES FLIGHT_TABLE(TUID)
	);

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

