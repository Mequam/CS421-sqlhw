CREATE VIEW ALL_POSSIBLE_FLIGHTS AS
	WITH RECURSIVE countDates AS 
	(
		SELECT min(flight_date) AS n FROM SCHEDULE_TABLE_DATA 
	
		UNION ALL
			
		SELECT datetime(n,'+1 days') FROM countDates WHERE n < (SELECT max(flight_date) FROM SCHEDULE_TABLE_DATA)
	)
	
	SELECT * FROM countDates;

