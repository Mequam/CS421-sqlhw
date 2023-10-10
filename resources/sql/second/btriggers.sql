-- this file contains the definition 
-- for the triggers that enforce the assignment reqs

--make it so we can use the view to insert
CREATE TRIGGER IF NOT EXISTS SCHEDULE_INSERT
INSTEAD OF INSERT ON SCHEDULE_TABLE BEGIN 

	-- cursed hack I found online for sql lite variables


	--get the flight that we want to insert into
	--and store it as a variable
--	INSERT INTO VARS(name,int_val,date_val) 
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
		new.PASSENGER_TUID, --this is passed straight in as long as the proff is honest >_>
		
		--begin flight tuid computation
		CASE 
			--if we are not already in the system insert ourselfs into the system
			WHEN (SELECT COUNT(*)=0 AS new_data 
					FROM ALL_POSSIBLE_FLIGHT_DATES 
					WHERE flight_date = new.flight_date)
			THEN 
				new.flight_tuid
			WHEN new.requested_section = 'V'
			THEN 
				--select the first available flight
				--that we can board
				--REGAURLESS of luxury count
				(SELECT flight_tuid 
					FROM ALL_POSSIBLE_FLIGHTS 
					WHERE 
						--we use vip count wanted
						--because that serves
						--as a total indicator for
						--all vip passengers in the plane
						--basically, this asks
						--"can this plane fit at least one more
						--vip?"
						vip_count_wanted < max_luxury+max_vip 
						AND 
					
						--we need to limit the depart time
						--to ONLY times that are greater than
						--or equal to the depart time of the 
						--insert command
						NOT 
						(
							DATE(flight_date) 
								= DATE(new.flight_date)
						AND 
							depart_time < (
								
								SELECT depart_time 
								FROM FLIGHT_TABLE 
								WHERE tuid = new.flight_tuid
							)
						)
					ORDER BY flight_date, depart_time 
					LIMIT 1)
			
			-- we are a luxury passenger
			-- use the luxury selection logic
			ELSE  
				--select the first flight we can board
				--based on luxury limit
		
				(SELECT flight_tuid 
					FROM ALL_POSSIBLE_FLIGHTS 
					WHERE luxury_count < max_luxury 
						AND 
						NOT (
							
							DATE(flight_date) 
								= DATE(new.flight_date)
						AND 
							depart_time < (
								
								SELECT depart_time 
								FROM FLIGHT_TABLE 
								WHERE tuid = new.flight_tuid
							)
						)
					ORDER BY flight_date, depart_time 
					LIMIT 1)
		END,
		CASE 
			--if we are not already in the system insert ourselfs into the system

			WHEN (SELECT COUNT(*)=0 AS new_data 
					FROM ALL_POSSIBLE_FLIGHT_DATES 
					WHERE flight_date = new.flight_date)
			THEN 
				DATE(new.flight_date)
			WHEN new.requested_section = 'V'
			THEN 
				--select the first available flight
				--that we can board
				--REGAURLESS of luxury count
				(SELECT DATE(flight_date)
					FROM ALL_POSSIBLE_FLIGHTS 
					WHERE 
						--we use vip count wanted
						--because that serves
						--as a total indicator for
						--all vip passengers in the plane
						--basically, this asks
						--"can this plane fit at least one more
						--vip?"
						vip_count_wanted < max_luxury+max_vip 
						AND 
					
						--we need to limit the depart time
						--to ONLY times that are greater than
						--or equal to the depart time of the 
						--insert command
						NOT 
						(
							DATE(flight_date) 
								= DATE(new.flight_date)
						AND 
							depart_time < (
								
								SELECT depart_time 
								FROM FLIGHT_TABLE 
								WHERE tuid = new.flight_tuid
							)
						)
					ORDER BY flight_date, depart_time 
					LIMIT 1)
			-- we are a luxury passenger
			-- use the luxury selection logic
			ELSE  
				--select the first flight we can board
				--based on luxury limit
		
				(SELECT DATE(flight_date) 
					FROM ALL_POSSIBLE_FLIGHTS 
					WHERE luxury_count < max_luxury 
						AND 
						NOT (
							
							DATE(flight_date) 
								= DATE(new.flight_date)
						AND 
							depart_time < (
								
								SELECT depart_time 
								FROM FLIGHT_TABLE 
								WHERE tuid = new.flight_tuid
							)
						)
					ORDER BY flight_date, depart_time 
					LIMIT 1)
		END ,
		
		--what they request is what they request, 
		--no need to change 
		--this around
		new.REQUESTED_SECTION, 
		
		--now which seat they get on the other hand has 
		--MANY things to change around
		CASE 
			WHEN 	
					--luxury is allways in luxury
					new.requested_section = 'L' 
					OR  --really hoping sql has short circuting
			
			--again if they do not yet exist, they can sit 
			--where they want,
			--they are the first person
					(
					SELECT COUNT(*)=0 AS new_data 
						FROM ALL_POSSIBLE_FLIGHT_DATES 
						WHERE flight_date = new.flight_date
					) 
			THEN 
				new.seated_section 

			WHEN 
				(
					SELECT vip_count >= max_vip 
					FROM ALL_POSSIBLE_FLIGHTS 
					WHERE 
						--we use vip count wanted
						--because that serves
						--as a total indicator for
						--all vip passengers in the plane
						--basically, this asks
						--"can this plane fit at least one more
						--vip?"
						vip_count_wanted < max_luxury+max_vip 
						AND 
					
						--we need to limit the depart time
						--to ONLY times that are greater than
						--or equal to the depart time of the 
						--insert command
						NOT 
						(
							DATE(flight_date) 
								= DATE(new.flight_date)
						AND 
							depart_time < (
								
								SELECT depart_time 
								FROM FLIGHT_TABLE 
								WHERE tuid = new.flight_tuid
							)
						)
					ORDER BY flight_date, depart_time 
					LIMIT 1
				) = 1
				THEN  -- if the vip count is full, we will get
						-- bump to get luxury
					'L'
				ELSE 
					'V'
	END,
		new.SEAT_NUMBER
	);

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
