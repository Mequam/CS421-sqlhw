SELECT seat_number 
FROM
	SCHEDULE_TABLE as st
INNER JOIN 
	ALL_POSSIBLE_FLIGHTS AS apf
ON
	st.flight_date = apf.flight_date 
	AND 
	st.flight_tuid = apf.flight_tuid
WHERE 
	--get the proper vip flight
	vip_count_wanted < max_luxury+max_vip 
	AND NOT 
	(
		DATE(st.flight_date) 
		= DATE(new.flight_date)
		AND 
		depart_time < (
			SELECT depart_time 
			FROM FLIGHT_TABLE 
			WHERE tuid = new.flight_tuid
		)
	)
	AND
	requested_section = 'L' 
ORDER BY 
st.flight_date,
depart_time,
seat_number DESC;
