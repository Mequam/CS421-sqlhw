-- this file contains the definition 
-- for the triggers that enforce the assignment reqs

--make it so we can use the view to insert
CREATE TRIGGER IF NOT EXISTS SCHEDULE_INSERT
INSTEAD OF INSERT ON SCHEDULE_TABLE BEGIN 

	-- cursed hack I found online for sql lite variables
	--PRAGMA temp_store = 2;
	--CREATE TEMP TABLE _VARS(
	--	name TEXT PRIMARY KEY,
	--	int_val INTEGER,
	--	date_val DATE);


	--get the flight that we want to insert into
	--and store it as a variable
--	INSERT INTO TEMP(name,int_val,date_val) 
--		
--		CASE 
--			WHEN 
--				NEW.flight_tuid IN  
--					(SELECT flight_tuid FROM SCHEDULE_TABLE_DATA)
--				
--				AND 
--				
--				NEW.flight_date IN 
--					(SELECT flight_date FROM SCHEDULE_TABLE_DATA)
--				
--			THEN 
--				--our flight is already in the db, lets find out
--				--if we can insert it
--				(SELECT 1, 1)
--			ELSE 
--				(SELECT NEW.flight_tuid , NEW.flight_date)
--				
--	;
	

	--actually allow inserting into the table
	INSERT INTO SCHEDULE_TABLE_DATA(
		PASSENGER_TUID,
		FLIGHT_TUID,
		FLIGHT_DATE,
		REQUESTED_SECTION,
		SEATED_SECTION,
		SEAT_NUMBER
	) VALUES(
		new.PASSENGER_TUID,
		new.FLIGHT_TUID,
		new.FLIGHT_DATE,
		new.REQUESTED_SECTION,
		new.SEATED_SECTION,
		new.SEAT_NUMBER
	);

	--remove the variables
	--DROP TABLE _VARS;
END;

--CREATE TRIGGER IF NOT EXISTS AFTER_SCHEDULE_ADD 
--AFTER INSERT ON SCHEDULE_TABLE BEGIN
--
--
--
--INSERT INTO TEMP(name,c)
--	SELECT 'count',cast(COUNT(*) as VARCHAR) as data
--		FROM SCHEDULE_TABLE 
--		WHERE flight_tuid = NEW.flight_tuid 
--			AND NEW.flight_date = flight_date 
--			AND NEW.requested_section = requested_section;
--
--
--DROP TABLE TEMP;
--
--END;
