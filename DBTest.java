import java.io.File;
import java.io.FileNotFoundException;
import java.util.*;
import java.sql.*;

public class DBTest {
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
						query = query.replaceAll("\\t","");


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
		runSqlFiles("./resources/sql",";");
		System.out.println(getConnection());
	}
}
