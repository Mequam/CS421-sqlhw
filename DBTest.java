import java.io.File;
import java.io.FileNotFoundException;
import java.util.*;
import java.sql.*;

public class DBTest {

	public static void loadPassengerFile(String fpath) 
			throws 
				FileNotFoundException,
				ClassNotFoundException,
				SQLException {
		File file = new File(fpath);
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
			scan.nextLine();
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
	/**
	 * this function runs the sql files stored in the folder
	 * given on the path variable
	 * note that these files must follow the sql standard 
	 * and be semi colon delimited!
	 * @path the path to the sql files
	 * */
	public static void runSqlFiles(String path,
											String delimiter) 
			throws FileNotFoundException,ClassNotFoundException,SQLException
		{
			File dir = new File(path);
			File [] sqlFiles = dir.listFiles();
			if (sqlFiles != null) {
				for (File c : sqlFiles) {

					Connection con = getConnection();

					Scanner sqlScanner = new Scanner(c);
					sqlScanner.useDelimiter(delimiter);
					while (sqlScanner.hasNext()) {
						String query = sqlScanner.next();
						
						//filter out whitespace and comments
						//for some reason these crash the
						//driver 
						query = query.replaceAll("--.*","");
						query = query.replaceAll("\\n","");
						//drop tabs, this is for cleanlyness
						//and optional
						//query = query.replaceAll("\\t","");


						if (query.length() > 1) {
							Statement state = con.createStatement();
							System.out.println(query + delimiter);
							//scanner.next removes the delimiters
							state.execute(query + delimiter); 
						}
					}
					con.close();
				}
			} else {
				System.out.println(
						"[WARNING] no sql files detected"
						);
			}
	}
	public static Connection getConnection() 
		throws ClassNotFoundException,SQLException
	{
		return DriverManager.getConnection(
			"jdbc:sqlite:SQLITETest1.db"
			);
	}

	public static void main(String [] args)  
		throws ClassNotFoundException,SQLException, 
							  FileNotFoundException
	{
		//runSqlFiles("./resources/sql",";");
		loadPassengerFile("./project_files/plane.txt");
		System.out.println(getConnection());
	}
}
