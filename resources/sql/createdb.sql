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
CREATE TABLE SCHEDULE_TABLE (
	TUID INTEGER PRIMARY KEY,
	PASSENGER_TUID INTEGER ,
	FLIGHT_TUID INTEGER ,
	FLIGHT_DATE DATE,
	REQUESTED_SECTION INTEGER,
	SEATED_SECTION INTEGER,
	SEAT_NUMBER INTEGER,

	FOREIGN KEY(PASSENGER_TUID) 
		 REFERENCES PASSENGER_TABLE(TUID),
	FOREIGN KEY(FLIGHT_TUID)
		 REFERENCES FLIGHT_TABLE(TUID)
	);
