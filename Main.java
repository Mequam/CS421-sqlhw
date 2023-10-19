import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileInputStream;
import java.io.UnsupportedEncodingException;
import java.io.IOException;
import java.util.*;
import java.sql.*;


public class Main {

	/**
	 * rounds a given integer to the next highest integer multiple 
	 *
	 * so if we are using multiple 2
	 *
	 * 3 gets rounded to 4
	 * 5 gets rounded to 6 
	 * ect.
	 *
	 * */
	public static int round_to_highest_multiple(int x, int multiple) {
		return (x+1) - ((x+1) % multiple);
	}


	/**
	 * left padds a string
	 * */
	public static String leftPad(String s, int length,char padder) {
		int padding = length - s.length();
		
		for (int i = 0; i < padding;i++) {
			s = padder + s;
		}

		return s;
	}


	/**
	 * adds a tag to the left of a string, and displays that string to the right 
	 * of the tag
	 * 
	 * basicaly convinence format function to format strings to pretty print in a menu
	 * */
	public static String tableTagString(String label,String entry, int length,char padder) {
		int padding = length - label.length();
		return label+leftPad(entry,padding,padder);
	}


	/**
	 *returns a result set containing all flights with people in them stored in the database
	 * */
	public static ResultSet getAllPopulatedFlights() throws SQLException,ClassNotFoundException {
		Connection con = getConnection();
		PreparedStatement s = con.prepareStatement(
			"SELECT * FROM FLIGHT_SUMMARY_VIEW ORDER BY flight_date, depart_time;" 
		);

		ResultSet rs =  s.executeQuery();


		while (rs.next()) { //this loop runs for every flight in the database

			int flight_tuid = rs.getInt("flight_tuid");
			String flight_date = rs.getString("flight_date");
			double flight_value = rs.getDouble("flight_value");

			int vip_count = rs.getInt("vip_count");
			int luxury_count = rs.getInt("luxury_count");

			int max_vip = rs.getInt("max_vip");
			int max_luxury = rs.getInt("max_luxury");

			drawFlightGraphic(flight_tuid,flight_date);
			System.out.println("");

			System.out.println(
					tableTagString(Integer.toString(vip_count) + "/" + Integer.toString(max_vip) + " ","vip",40,'.')
					);
			System.out.println(
					tableTagString(Integer.toString(luxury_count) + "/" + Integer.toString(max_luxury) + " ","luxury",40,'.')
					);
			System.out.println(
					tableTagString(flight_date + ", " + Integer.toString(flight_tuid) + " ","flight date, plane_id",40,'.')
					);
			System.out.println(
					tableTagString(Double.toString(flight_value) + " ","flight value",40,'.')
					);

			System.out.println();
			System.out.println("-".repeat(6));
		}

		con.close();
		return rs;
	}


	/**
	 * displays a table of the given result set for plane data and limits the output to passengers of a given section
	 *
	 * */
	public static void printFlightSet(
			ResultSet rs,String target_section,
			int section_size,String render_title,
			int plane_row_count
			) throws SQLException {
		

		String requested_section = rs.getString("requested_section");
		String seated_section = rs.getString("seated_section");
		int seat_number = rs.getInt("seat_number");



		ArrayList<ArrayList<String>> vip_section = new ArrayList<>();


		//rounds up to the nearest multiple of the plane_row_count
		//so given plane_count = 2 if we see 3, we get rounded up to 4
		//this is here so we loop over every square in the display
		int nearest_multiple = round_to_highest_multiple(section_size,plane_row_count);

		//this is used for formating the output
		//and indicates the padding we want arount the value
		//in the table
		//
		//TODO: this would make a lot of sense to live in the table library
		String padding = "  ";



		//now we do the luxury


		//get the seats required for luxury
		nearest_multiple = round_to_highest_multiple(section_size,plane_row_count);

		boolean hasValidEntry = true;

		for (int i = 1; i < nearest_multiple; i+=plane_row_count) {
			ArrayList<String> row = new ArrayList();


			//run for the row of the plane
			for (int k = 0; k < plane_row_count;k++) {
				String value = "E"; //e for empty

				//if our seat number matches the loop, and we are VIP
				//note java short circuting

				if (i+k == seat_number && seated_section.equals(target_section) && hasValidEntry) {

					hasValidEntry = rs.next();
					value = requested_section; 

					seated_section = rs.getString("seated_section");
					seat_number = rs.getInt("seat_number");
				}

				//* indicates that seat simply does not exist on the given plane
				if (i+k > section_size) {
					value = "*";
				}

				row.add(padding+value+padding);
			}

			vip_section.add(row);

		}

		System.out.println(GridRender.renderGrid(vip_section,render_title));

			//run for each row of vip

	}
	/**
	 * takes in information about a single flight, and then displays that flight 
	 * out to the terminal after retriving data from the database
	 * */
	public static void  drawFlightGraphic(int flight_tuid,String flight_date)  throws
			SQLException,ClassNotFoundException
	{

		Connection con = getConnection();
		
		String query = "SELECT * FROM SCHEDULE_WITH_PLANE_DATA_VIEW WHERE flight_tuid = ? AND flight_date = ? ORDER BY seated_section DESC,seat_number";
		PreparedStatement prep = con.prepareStatement(query);

		
		prep.setInt(1,flight_tuid);
		prep.setString(2,flight_date);
		
		ResultSet rs = prep.executeQuery();


		PreparedStatement ps = con.prepareStatement("SELECT max_vip,max_luxury FROM FLIGHT_MAX_CAPACITY_VIEW "+
				"WHERE flight_tuid=?");
		ps.setInt(1,flight_tuid);

		ResultSet plane_data = ps.executeQuery();

		int max_luxury;
		int max_vip;
		if (!plane_data.next()) return;

		max_luxury = plane_data.getInt("max_luxury");
		max_vip = plane_data.getInt("max_vip");


		if (rs.next())
		{
			printFlightSet(rs,"V",max_vip,"vip",2);
			printFlightSet(rs,"L",max_luxury,"luxury",2);
		}

		con.close();
	}
	public static ResultSet getSeatings(int flight_tuid,String date) throws SQLException,ClassNotFoundException {
		Connection con = getConnection();
		PreparedStatement s = con.prepareStatement(
			"SELECT * FROM SCHEDULE_TABLE WHERE flight_tuid = ? AND flight_date = ?"
		);

		s.setInt(1,flight_tuid);
		s.setString(2,date);

		ResultSet rs =  s.executeQuery();
		con.close();
		return rs;
	}


	/**
	 *
	 *	takes in the requested tuid and returns the proper plane tuid as an integer 
	 *	this is primarily here to handle the X in the requests
	 * */
	public static int getPlaneTuid(String requested_tuid) throws SQLException,ClassNotFoundException {
		//if they want an X, we re-asign them to the flight with the earliest time,
		//that is then used in the sql insert query to give them the appropriate time
		if (requested_tuid.equals("X")) { 
			Connection con = getConnection();
			Statement s = con.createStatement();
			ResultSet rs = s.executeQuery("SELECT tuid FROM FLIGHT_TABLE ORDER BY depart_time");
			
			int ret_val = rs.getInt("tuid");
			
			con.close();
			
			return ret_val;
		} 
		return Integer.parseInt(requested_tuid);

	}

	/**
	 *	convinence function that stores a schedule into the database 
	 *	from an array containing the appropriate infomration
	 * */
	public static void storeSchedule(String[] data) 
			throws ClassNotFoundException, SQLException {


		storeSchedule(
				Integer.parseInt(data[0]),
				getPlaneTuid(data[1]),
				data[2],
				databaseFormatDate(data[3])
				);

	}


	/**
	 * takes a string in the form of a date specified by an incoming file 
	 * and converts it into a date string in the format that sql lite expects
	 * */
	public static String databaseFormatDate(String date) {
		String [] split_date = date.split("/");
		return split_date[2]+"-"+split_date[0]+"-"+split_date[1];
	}


	/**
	 *	takes in paramaters formated from the .txt files and inputs them into the 
	 *	sql database
	 *
	 * */
	public static void storeSchedule(int customer_tuid,
			int requested_plane_tuid,
			String requested_seating,
			String requested_date) 
		throws ClassNotFoundException, SQLException
	{

		Connection con = getConnection();

		PreparedStatement prep = con.prepareStatement(
				"INSERT INTO SCHEDULE_TABLE(passenger_tuid,flight_tuid,flight_date,requested_section) VALUES(?,?,?,?)"
				);
	
		prep.setInt(1,customer_tuid);
		prep.setInt(2,requested_plane_tuid);
		prep.setString(3,requested_date);
		prep.setString(4,requested_seating);

		
		prep.execute();

		con.close();
	
	}
	public static void loadPassengerFile(String fpath) 
			throws 
				FileNotFoundException,
				ClassNotFoundException,
				SQLException {

		File file = new File(fpath);
		loadPassengerFile(file);
	}

	public static void loadPassengerFile(File file) 
			throws 
				FileNotFoundException,
				ClassNotFoundException,
				SQLException {

		Scanner scan = new Scanner(file);
		
		while (scan.hasNextLine()) {
			String line = scan.nextLine();
			String [] split_string = line.split(" ");
			if (split_string[0].equals("P"))  //are we storing a passenger?
			{
				//store the passenger from the sliced array
				storePassanger(
						Arrays.copyOfRange(
							split_string,
							1,
							split_string.length)
						);
			} 
			else if (split_string[0].equals("S")) 
			{
				storeSchedule((
						Arrays.copyOfRange(
							split_string,
							1,
							split_string.length)
							));
			}
		}
	}
	
	/**
	 *takes in the string representation of a passenger and stores 
	 it in the database
	 * */
	public static void storePassanger(String [] split_string) 
			throws 
				ClassNotFoundException,
			  	SQLException {
		
			int tuid = Integer.parseInt(split_string[0]);
			String first_initial = split_string[1];
			String middle_initial = split_string[2];
			String phone_number = split_string[3];
			String lastname = split_string[4];

			storePassanger(tuid,first_initial,middle_initial,phone_number,lastname);
	}


	/**
	 *	inserts a single passenger into the database
	 * */
	public static void storePassanger(int tuid,
			String first_initial,String middle_initial,
			String lastname, String phone_number) 
				throws ClassNotFoundException,SQLException 
	{
		Connection con = getConnection();
		PreparedStatement prep = con.prepareStatement(
								"INSERT INTO PASSENGER_TABLE("+
								"TUID,FIRST_INITIAL,MIDDLE_INITIAL,LASTNAME,PHONE_NUMBER) " +
								"VALUES(?,?,?,?,?)");

		//translate the incoming variables into arguments sql can understand
		prep.setInt(1,tuid);
		prep.setString(2,String.valueOf(first_initial));
		prep.setString(3,String.valueOf(middle_initial));
		prep.setString(4,lastname);
		prep.setString(5,phone_number);

		
		prep.execute();
		con.close();

	}

	
	public static void clearDatabase() 
			throws FileNotFoundException,ClassNotFoundException,
								  SQLException,UnsupportedEncodingException,
								  IOException
	{
		runSqlFiles("./resources/sql/clearDatabase",";");
	}

	/**
	 *
	 *	purges any and all reference of the database 
	 *	by deleting it
	 * */
	public static void deleteDatabase() {
		File f = new File("./schedule_database.db");
		f.delete();
	}
	/**
	 * creates the database, duh :p
	 * */
	public static void createDatabase()  
			throws FileNotFoundException,ClassNotFoundException,
								  SQLException,UnsupportedEncodingException,
								  IOException
	{
		//create the basic tables and population
		runSqlFiles("./resources/sql/createDatabase/scafolding",";");
		runSqlFileRaw("./resources/sql/createDatabase/triggers/triggers.sql");
	}


	/**
	 * convinience overload of runSqlFileRaw(File) see runSqlFileRaw(file) for more details
	 *
	 * */
	public static void runSqlFileRaw(String f) 
			throws FileNotFoundException,ClassNotFoundException,
								  SQLException,UnsupportedEncodingException,
								  IOException
	{
		runSqlFileRaw(new File(f));
	}
	/**
	 *	takes in the path to a SINGLE sql file, and runs it without significant additional parsing.
	 *
	 *	note: if the tables that you create in the sql file depend on the order of them bieng created, 
	 *	this function will fail, as sql lite parses "everything at once" when it recives the query, 
	 *	so if you have forign key constraints created at the same time as a forign table, the query will fail
	 *	to execute
	 *
	 *	see runSqlFiles for what to do in this case
	 * */
	public static void runSqlFileRaw(File f) 
			throws FileNotFoundException,ClassNotFoundException,
								  SQLException,UnsupportedEncodingException,
								  IOException
	{
					if (f.isDirectory())
						return;  //we do NOT run directories

					//we do NOT run sql on a non sql file
					if (!f.getName().endsWith(".sql"))
						return;

					//prepare the query from the file
					FileInputStream fis = new FileInputStream(f);

					String query = new String(fis.readAllBytes(),"UTF-8");

					query = query.replaceAll("--.*","");
					query = query.replaceAll("\\s+"," ");


						
					//don't run if we get an empty query
					if (query.length() <= 3) return;
						
					//execute the query
					Connection con = getConnection();

					Statement state = con.createStatement();
					state.execute(query); 
					
					con.close();
	}
	/**
	 *  this function takes a folder path, and runs all sql files in that folder path through the sql lite database 
	 *
	 *  NOTE: the sql parser in this function is very primative, it works for basic sql files 
	 *  queries that only insert delete and create things. 
	 *
	 *  For complex queries, the run function very well may file and a special case might need to be used. 
	 * */
	public static void runSqlFiles(File dir,String delimiter)
			throws FileNotFoundException,ClassNotFoundException,
								  SQLException,UnsupportedEncodingException,
								  IOException {
			
			File [] sqlFiles = dir.listFiles();
			Arrays.sort(sqlFiles,(f1,f2)->{
				return f1.getName().compareTo(f2.getName());
			});
			if (sqlFiles != null) {
				for (File currentFile : sqlFiles) {

					//the fact that this is not built in functionality is RIDICULUS
					//I should be able to point java at a sql file and have it run with the
					//driver, but whatever -_-


					if (currentFile.isDirectory()) {
						runSqlFiles(currentFile,delimiter);
						continue; //move onto the next file do NOT run sql
					}

					//we do NOT run sql on a non sql file
					if (!currentFile.getName().endsWith(".sql"))
						continue;

					//prepare the query from the file
					FileInputStream fis = new FileInputStream(currentFile);

					String data = new String(fis.readAllBytes(),"UTF-8");

					data = data.replaceAll("--.*","");
					data = data.replaceAll("\\s+"," ");

					String [] allQueries = data.split(delimiter);

					for (int i = 0; i < allQueries.length; i++)
					{
						String query = allQueries[i];
						if (query.length() <= 3) continue;
						
						query = query + delimiter;
						//execute the query
						Connection con = getConnection();

						Statement state = con.createStatement();
						state.execute(query); 
						con.close();
					}
				}
			} else {
				System.out.println(
						"[WARNING] no sql files detected"
						);
			}
	}
	/**
	 * this function runs the sql files stored in the folder
	 * given on the path variable
	 * note that these files must follow the sql standard 
	 * and be semi colon delimited!
	 * @path the path to the sql files
	 * */
	public static void runSqlFiles(String path,String delimiter) 
			throws FileNotFoundException,ClassNotFoundException,
								  SQLException,UnsupportedEncodingException,
								  IOException
	{
			File dir = new File(path);
			runSqlFiles(dir,delimiter);
	}
	public static Connection getConnection() 
		throws ClassNotFoundException,SQLException
	{
		return DriverManager.getConnection(
			"jdbc:sqlite:schedule_database.db"
			);
	}



	public static void main(String [] args)  
		throws ClassNotFoundException,SQLException, 
							  FileNotFoundException,UnsupportedEncodingException,
							  IOException
	{


		//this is me leaving my longing for c++
		Scanner cin = new Scanner(System.in);

		System.out.print("would you like to clear the database? (y/n) ");


		String responce;
		responce = cin.nextLine();


		if (responce.equals("y")) {
			deleteDatabase();
			createDatabase();
		}

		while (!responce.equals("q")) {

			ArrayList<ArrayList<String>> options = new ArrayList<>();
			
			ArrayList<String> addFile = new ArrayList<String>();
			addFile.add("o to open and store a new database file");
			options.add(addFile);

			ArrayList<String> viewData = new ArrayList<String>();
			viewData.add("v to view the data stored in the database");
			options.add(viewData);

			ArrayList<String> deleteData = new ArrayList<String>();
			deleteData.add("d delete the data in the database");
			options.add(deleteData);

			ArrayList<String> quitData = new ArrayList<String>();
			quitData.add("q to quit");
			options.add(quitData);



			System.out.println("\n"+GridRender.renderGrid(options,"options"));

			responce = cin.nextLine();

			switch (responce) {
				case "o":
					System.out.print("\nfile path:");
					String fpath = cin.nextLine();

					File f = new File(fpath);

					loadPassengerFile(f);
				break;
				case "d":
					System.out.println("\nclearing the database...");
					deleteDatabase();
					createDatabase();
				break;
				case "v":
					System.out.println("\ndisplaying all flight data");
					getAllPopulatedFlights();
				break;
			}

		}
	}
}
