package ss.connection;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Collections;
import java.util.TreeMap;

public class ConnectionManager {
	static TreeMap<String, String[]> dbConns;
	static {
		dbConns = new TreeMap<String, String[]>();
		dbConns.put("mysql", new String [] {"com.mysql.jdbc.Driver", "jdbc:mysql://localhost/ssdb", "root", "E4nPo2Qt"}); 
		dbConns.put("postgres", new String [] {"org.postgresql.Driver", "jdbc:postgresql://localhost/ssdb", "ebrynne", "z03HsmR8"}); 
	}
	
	
	/*
     * Open database connection
     */
	public Connection getConnection(){
		return getConnection("mysql");
	}
	
    public Connection getConnection(String type) 
    {
    	String [] dbData = dbConns.get(type);
    	Connection conn = null;
	    try {
	    	System.out.println("Db Info: " + dbData[0]);
	    	Class.forName(dbData[0]);
	    	conn = DriverManager.getConnection(dbData[1], dbData[2], dbData[3]);
	    }
	    //TODO: Replace with logging
	    catch (SQLException e) {
	    	System.out.println("Database connection error");
	    	e.printStackTrace();
	    }catch(ClassNotFoundException e){
	    	System.out.println("Driver not found error");
	    	e.printStackTrace();
	    	conn = null;
	    }
	    
	    return conn;
    }
    
    /*
     * Close open database connection
     */
    public void closeConnection(Connection conn) 
    {
	    if (conn != null) 
	    {
	    	try 
	    	{ 
	    		conn.close(); 
	    	}
	      catch (SQLException e) {
	      	System.out.println("Unable to close database connection");
	      	// TODO: Replace with logging.
	      	e.printStackTrace(); }
	    }
    }
    
    /*
     * Close open prepared statement
     */
    public void closePreparedStatement(PreparedStatement ps) 
    {
	    if (ps != null) 
	    {
	    	try 
	    	{ 
	    		ps.close(); 
	    	}
	      catch (SQLException e) {
	      	System.out.println("Unable to close prepared statement");
	      	// TODO: Replace with logging.
	      	e.printStackTrace(); }
	    }
    }

    /*
     * Close open result set
     */
    public void closeResultSet(ResultSet rs) 
    {
	    if (rs != null) 
	    {
	    	try 
	    	{ 
	    		rs.close(); 
	    	}
	      catch (SQLException e) {
	      	System.out.println("Unable to close result set");
	      	// TODO: Replace with logging.
	      	e.printStackTrace(); }
	    }
    }
}
