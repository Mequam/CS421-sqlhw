--this file is used to POPULATE the database
--with default values that we know are going to be static
--over the course of 99% of the program


--create the planes

INSERT INTO 
PLANE_TABLE(PLANE_ID,MAX_VIP,MAX_LUXURY) 
VALUES('RC 407',4,6);

	--include the planes schedule
	INSERT INTO FLIGHT_TABLE(PLANE_TUID,
					DEPART_TIME,
					DEPART_GATE)
					VALUES(
						(
							SELECT TUID FROM 
							PLANE_TABLE WHERE PLANE_ID = 'RC 407'
						)
						,'07:00','Gate 1'
					);

INSERT INTO 
PLANE_TABLE(PLANE_ID,MAX_VIP,MAX_LUXURY) 
VALUES('TR 707',3,5);

	--include the planes schedule
	INSERT INTO FLIGHT_TABLE(PLANE_TUID,
					DEPART_TIME,
					DEPART_GATE)
					VALUES(
						(
							SELECT TUID FROM 
							PLANE_TABLE WHERE PLANE_ID = 'TR 707'
						)
						,'13:00','Gate 2'
					);

INSERT INTO 
PLANE_TABLE(PLANE_ID,MAX_VIP,MAX_LUXURY) 
VALUES('KR 381',6,8);

	--include the planes schedule
	INSERT INTO FLIGHT_TABLE(PLANE_TUID,
					DEPART_TIME,
					DEPART_GATE)
					VALUES(
						(
							SELECT TUID FROM 
							PLANE_TABLE WHERE PLANE_ID = 'KR 381'
						)
						,'21:00','Gate 3'
					);

--store the price of each ticket

INSERT INTO FEE_TABLE(FEE_TYPE,COST) VALUES('V',4000);
INSERT INTO FEE_TABLE(FEE_TYPE,COST) VALUES('L',2500);
