--this file is used to CREATE the database
--and contains all sql commands required for that task

--sqllite does not include foreign_keys by default
--we need to enable this for the behavior
--note on some systems very rarely sql lite will NOT include
--foreign_keys, with the packaged version of sql lite we 
--SHOULD be ok
PRAGMA foreign_keys = ON;

--if the tables exist, remove them before creating
--DROP TABLE IF EXISTS SCHEDULE_TABLE;
--DROP TABLE IF EXISTS FEE_TABLE;
--DROP TABLE IF EXISTS PASSENGER_TABLE;
--DROP TABLE IF EXISTS FLIGHT_TABLE;
--DROP TABLE IF EXISTS PLANE_TABLE;

-- sql lite does auto incriment
-- automatically with INTEGER PRIMARY KEY

--contains info about each individual plane
CREATE TABLE IF NOT EXISTS PLANE_TABLE(
	tuid INTEGER PRIMARY KEY, 
	plane_id VARCHAR,
	max_vip INT,
	max_luxury INT
);


--contains info about which plane flies 
--at what time and from where
CREATE TABLE IF NOT EXISTS FLIGHT_TABLE (
	tuid INTEGER PRIMARY KEY, 
	plane_tuid INTEGER ,
	airport_code VARCHAR,
	depart_gate VARCHAR,
	depart_time DATE,
	FOREIGN KEY (PLANE_TUID)
       REFERENCES PLANE_TABLE(TUID)
	);

----person who could be in the airport
CREATE TABLE IF NOT EXISTS PASSENGER_TABLE(
	TUID INTEGER PRIMARY KEY,
	FIRST_INITIAL CHAR,
	MIDDLE_INITIAL CHAR,
	LASTNAME VARCHAR,
	PHONE_NUMBER VARCHAR
);

--contains info on what does everything cost.
CREATE TABLE IF NOT EXISTS FEE_TABLE (
	TUID INTEGER PRIMARY KEY,
	FEE_TYPE VARCHAR,
	COST DECIMAL
);


--information about whos on what plane
CREATE TABLE IF NOT EXISTS SCHEDULE_TABLE_DATA (
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
