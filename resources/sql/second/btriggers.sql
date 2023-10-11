
-- this file contains the definition 
-- for the triggers that enforce the assignment reqs

--make it so we can use the view to insert
CREATE TRIGGER IF NOT EXISTS SCHEDULE_INSERT
INSTEAD OF INSERT ON SCHEDULE_TABLE BEGIN 


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
			--I had to use count(*) to deal with null values
			--properly, theres prolly a way to do this better,
			-- but thats a premium feature and I am currently doing
			--this for FREE :D
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

		--begin flight date computation
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
		
		--begin seated section computation
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
				new.requested_section

			WHEN  --we are vip
				--check if we need to bump
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
					'V' --we do not bump, vip
	END,

		--begin outer case (seat # computation)
		CASE  

			--if we are not already in the system insert ourselfs into the system
			WHEN (SELECT COUNT(*)=0 AS new_data 
					FROM ALL_POSSIBLE_FLIGHT_DATES 
					WHERE flight_date = new.flight_date)
			THEN 
				-- if it is a new passenger
				-- then they obvi get the first seat number
				(SELECT 1) 
			WHEN new.requested_section = 'V'
			THEN 
				--the ordering for these seat #'s 
				--should be from 0 to n and one continous
				--range, but what do I know, I just write
				--code -\ :/ /-

				--anyways heres a disgusting case statement
				--to meet requirements :p
		

			-- figure out if we need to
			-- use luxury numbering or
			-- vip numbering for this passenger
			CASE --begin inner case (vip set # computation)
			--are there more vip's in our plane than allowed?
			--basically, are we bumping?
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
				-- they are bumping a passenger
				-- use luxury logic
				-- for computing seat #
				(SELECT luxury_count_wanted
					FROM ALL_POSSIBLE_FLIGHTS 
					WHERE 
						-- note: we sue the same logic
						-- that we use for computing flight
						-- earlier, as despite us
						-- counting luxury passengers
						-- we are still on a vip flight
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
				)
				ELSE --there is no bumping occuring,
						--use vip logic

				(
				SELECT vip_count + 1 
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

				END  --end inner case (vip seat # computation)
			ELSE  --we are a luxury passenger, use luxury count logic
				(
					SELECT luxury_count + 1
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
					LIMIT 1
				)
	END -- end outer case (seat # compuation)
);

END;
