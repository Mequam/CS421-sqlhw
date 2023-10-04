import java.sql.*;

public class DBTest {
	public static Connection getConnection() 
		throws ClassNotFoundException,SQLException
	{
		return DriverManager.getConnection(
			"jdbc:sqlite:SQLITETest1.db"
			);
	}
	public static void main(String [] args)  
		throws ClassNotFoundException,SQLException
	{
		System.out.println("test!");
		System.out.println(getConnection());
	}
}
