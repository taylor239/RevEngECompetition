package com.data;

import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.ObjectInputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.Scanner;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import javax.imageio.ImageIO;
import javax.servlet.ServletContext;
import javax.servlet.http.Part;



/**
 * 
 * @author Mi Laptop
 *
 */
public class DatabaseConnector
{
	//private String userName, password, address;
	//private String baseAddr="localhost";
	private String theName = "tigress_challenge_competition";
	private ConcurrentHashMap databaseMap;
	private TestingConnectionSource mySource;
	/**
	 * This is the driver to be used.  It is default a mySql driver, but can be set later.
	 */
	//private String driver="com.mysql.jdbc.Driver";
	/**
	 * 
	 */
	//private int maxConnections=100;
	private boolean verbose = true;
	/**
	 * This is my connection.  It connects to the desired database.
	 */
	//private Connection connection=null;
	/**
	 * 
	 */
	//private DatabaseConnectionPool myPool=null;
	/**
	 * 
	 */
	private String databaseName="";
	/**
	 * 
	 */
	public DatabaseConnector(String name)
	{
		databaseName = name;
		databaseMap = DatabaseInformationManager.getInstance().getNext(databaseName);
		mySource = new TestingConnectionSource((String)databaseMap.get("username"), (String)databaseMap.get("password"), (String)databaseMap.get("address"));
	}
	
	/**
	 * 
	 * @return
	 * @throws Exception
	 */
	public synchronized String connect() throws Exception
	{
		String myReturn="";
		
		return myReturn;
	}
	public synchronized Connection getConnection()
	{
		if(verbose)
		{
			System.out.println("Getting a connection");
		}
		//String myReturn="";
		return mySource.getDatabaseConnection();
		//myPool=DatabaseConnectionPool.getInstance((String)tmp.get("address"), (String)tmp.get("driver"), (String)tmp.get("username"), (Integer)tmp.get("maxconnections"), (String)tmp.get("password"));
		//while(connection==null)
		//{
			//System.out.println("Getting connection");
		//	connection=myPool.getConnection();
		//}
		
		/*
		try
		{
			Class.forName(driver);
			connection=DriverManager.getConnection(address, userName, password);
		}
		catch(Exception e)
		{
			myReturn=e.toString();
			throw e;
		}
		*/
		//return myReturn;
	}
	public synchronized void disconnect(Connection myConnection)
	{
		try {
			if(myConnection != null)
			{
			myConnection.close();
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	/**
	 * 
	 * @return
	 */
	public synchronized int getNumConnections()
	{
		return 0;
		//return myPool.getNumConnections();
	}
	/**
	 * 
	 * @return
	 */
	public synchronized int getNumConnectionsInPool()
	{
		return 0;
		//return myPool.getNumConnectionsInPool();
	}
	/**
	 * 
	 * @return
	 */
	public synchronized int getNumConnectionsCheckedOut()
	{
		return 0;
		//return myPool.getNumConnectionsCheckedOut();
	}
	/**
	 * 
	 * @return
	 */
	public synchronized String getErrors()
	{
		return "";
		//return myPool.errors;
	}
	/**
	 * 
	 */
	public synchronized void finalize()
	{
		/*
		try
		{
			connection.close();
		}
		catch(SQLException e1)
		{
			e1.printStackTrace();
		}
		*/
		try
		{
			super.finalize();
		}
		catch(Throwable e)
		{
			e.printStackTrace();
		}
	}
	/**
	 * 
	 * @param table
	 * @return
	 */
	public synchronized ArrayList getColumnNames(String table)
	{
		ArrayList myReturn=new ArrayList();
		Connection connection = getConnection();
		try
		{
			System.out.println(theName);
			System.out.println(table);
			PreparedStatement myStmt=connection.prepareStatement("SELECT `COLUMN_NAME` FROM `INFORMATION_SCHEMA`.`COLUMNS` WHERE  `TABLE_SCHEMA` = '"+theName+"' AND  `TABLE_NAME` =  ?");
			myStmt.setString(1, table);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			while(myResults.next())
			{
				myReturn.add(myResults.getObject(1));
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			disconnect(connection);
			return null;
		}
		disconnect(connection);
		return myReturn;
	}
	
	/**
	 * 
	 * @param username
	 * @param password
	 * @return
	 */
	public synchronized User signIn(String username, String password, String ipAddress)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		//if(verbose)
		//{
		//	System.out.println("Connector got connection");
		//}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM user INNER JOIN role ON user.email = role.email WHERE user.email = ? AND password = SHA2((SELECT CONCAT(?, (SELECT salt FROM user WHERE email = ?))), 512)");
			myStmt.setString(1, username);
			myStmt.setString(2, password);
			myStmt.setString(3, username);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			if(myResults.next())
			{
				System.out.println("Got a user");
				for(int x=1; x<=columns; x++)
				{
					if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
					{
						
					}
					else
					{
						if(myResults.getObject(x)!=null)
						{
							attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
						}
						else
						{
							attributes.put(meta.getColumnLabel(x), "");
						}
					}
				}
			}
			else
			{
				System.out.println("No user found");
				disconnect(connection);
				return null;
			}
		}
		catch(Exception e)
		{
			disconnect(connection);
			return null;
		}
		User myReturn=new User(attributes, false, tables);
		disconnect(connection);
		return myReturn;
	}
	
	/**
	 * 
	 * @param username
	 * @param password
	 * @return
	 */
	public synchronized User getUser(String username)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM user INNER JOIN role ON user.email = role.email WHERE user.email = ?");
			myStmt.setString(1, username);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			if(myResults.next())
			{
				for(int x=1; x<=columns; x++)
				{
					if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
					{
						
					}
					else
					{
						if(myResults.getObject(x)!=null)
						{
							attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
						}
						else
						{
							attributes.put(meta.getColumnLabel(x), "");
						}
					}
				}
			}
			else
			{
				disconnect(connection);
				return null;
			}
		}
		catch(Exception e)
		{
			disconnect(connection);
			return null;
		}
		User myReturn=new User(attributes, false, tables);
		disconnect(connection);
		return myReturn;
	}
	
	
	/**
	 * 
	 * @param username
	 * @param password
	 * @return
	 */
	public synchronized DBObj getTestCount(String testname)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT COUNT(*) AS 'count' FROM `auto_grade_tests` WHERE `challenge_name` = ?");
			myStmt.setString(1, testname);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			if(myResults.next())
			{
				for(int x=1; x<=columns; x++)
				{
					if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
					{
						
					}
					else
					{
						if(myResults.getObject(x)!=null)
						{
							attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
						}
						else
						{
							attributes.put(meta.getColumnLabel(x), "");
						}
					}
				}
			}
			else
			{
				disconnect(connection);
				return null;
			}
		}
		catch(Exception e)
		{
			disconnect(connection);
			return null;
		}
		DBObj myReturn=new DBObj(attributes, false, tables);
		disconnect(connection);
		return myReturn;
	}
	
	/**
	 * 
	 * @param username
	 * @return
	 */
	public synchronized ArrayList getAdminChallenges(String username)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		ArrayList myReturn = new ArrayList();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM challenge WHERE challenge.admin_email = ?");
			myStmt.setString(1, username);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			while(myResults.next())
			{
				attributes=new ConcurrentHashMap();
				for(int x=1; x<=columns; x++)
				{
					if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
					{
						
					}
					else
					{
						if(myResults.getObject(x)!=null)
						{
							attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
						}
						else
						{
							attributes.put(meta.getColumnLabel(x), "");
						}
					}
				}
				DBObj tmp = new DBObj(attributes, false, tables);
				myReturn.add(tmp);
			}
		}
		catch(Exception e)
		{
			disconnect(connection);
			return null;
		}
		disconnect(connection);
		return myReturn;
	}
	
	/**
	 * 
	 * @param username
	 * @return
	 */
	public synchronized ArrayList getAdminStudents(String username)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		ArrayList myReturn = new ArrayList();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM user INNER JOIN role ON user.email = role.email WHERE role.administrator = ? ORDER BY role.course");
			myStmt.setString(1, username);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			while(myResults.next())
			{
				attributes=new ConcurrentHashMap();
				for(int x=1; x<=columns; x++)
				{
					if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
					{
						
					}
					else
					{
						if(myResults.getObject(x)!=null)
						{
							attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
						}
						else
						{
							attributes.put(meta.getColumnLabel(x), "");
						}
					}
				}
				DBObj tmp = new DBObj(attributes, false, tables);
				myReturn.add(tmp);
			}
		}
		catch(Exception e)
		{
			disconnect(connection);
			return null;
		}
		disconnect(connection);
		return myReturn;
	}
	
	
	/**
	 * 
	 * @param username
	 * @return
	 */
	public synchronized ArrayList getAdminStudents(String username, String ordering, boolean asc)
	{
		ArrayList userColumns = getColumnNames("user");
		ArrayList roleColumns = getColumnNames("role");
		
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		ArrayList myReturn = new ArrayList();
		try
		{
			String suffix = " ASC";
			if(!asc)
			{
				suffix=" DESC";
			}
			
			System.out.println(userColumns);
			
			if(userColumns.contains(ordering))
			{
				suffix = "ORDER BY user." + ordering + suffix;
			}
			else if(roleColumns.contains(ordering))
			{
				suffix = "ORDER BY role." + ordering + suffix;
			}
			
			if(verbose)
			{
				System.out.println(ordering);
				System.out.println(asc);
				System.out.println("SELECT * FROM user INNER JOIN role ON user.email = role.email WHERE role.administrator = ? " + suffix);
			}
			
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM user INNER JOIN role ON user.email = role.email WHERE role.administrator = ? " + suffix);
			myStmt.setString(1, username);
			//myStmt.setString(2, ordering);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			while(myResults.next())
			{
				attributes=new ConcurrentHashMap();
				for(int x=1; x<=columns; x++)
				{
					if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
					{
						
					}
					else
					{
						if(myResults.getObject(x)!=null)
						{
							attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
						}
						else
						{
							attributes.put(meta.getColumnLabel(x), "");
						}
					}
				}
				DBObj tmp = new DBObj(attributes, false, tables);
				myReturn.add(tmp);
			}
		}
		catch(Exception e)
		{
			disconnect(connection);
			return null;
		}
		disconnect(connection);
		return myReturn;
	}
	
	
	/**
	 * 
	 * @param username
	 * @param password
	 * @return
	 */
	public synchronized ArrayList getChallenges(String username)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		ArrayList myReturn = new ArrayList();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM challenge_participant INNER JOIN challenge ON challenge_participant.challenge_name = challenge.challenge_name LEFT JOIN challenge_participant_grades ON challenge_participant_grades.email = challenge_participant.email AND challenge_participant_grades.challenge_name = challenge_participant.challenge_name LEFT JOIN auto_grade_tests ON challenge_participant_grades.challenge_name = auto_grade_tests.challenge_name AND challenge_participant_grades.test_number = auto_grade_tests.test_number WHERE challenge_participant.email = ? ORDER BY challenge_set_name ASC, challenge.challenge_name ASC");
			myStmt.setString(1, username);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			int curJoin = 0;
			while(myResults.next())
			{
				if(attributes == null || attributes.isEmpty() || !attributes.get("challenge_name").equals(myResults.getObject("challenge_name")))
				{
					curJoin = 0;
					attributes=new ConcurrentHashMap();
					for(int x=1; x<=columns; x++)
					{
						if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
						{
							
						}
						else
						{
							if(myResults.getObject(x)!=null)
							{
								attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
							}
							else
							{
								if(!attributes.containsKey(meta.getColumnLabel(x)))
								{
									attributes.put(meta.getColumnLabel(x), "");
								}
							}
						}
					}
					DBObj tmp = new DBObj(attributes, false, tables);
					myReturn.add(tmp);
				}
				else
				{
					curJoin++;
					HashMap alreadyUsed = new HashMap();
					for(int x=1; x<=columns; x++)
					{
						if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
						{
							
						}
						else
						{
							if(myResults.getObject(x)!=null)
							{
								if(!alreadyUsed.containsKey(meta.getColumnLabel(x)) && attributes.containsKey(meta.getColumnLabel(x)) && !attributes.get(meta.getColumnLabel(x)).equals(myResults.getObject(x)) && !meta.getColumnLabel(x).equals("challenge_name") && !meta.getColumnLabel(x).equals("email"))
								{
									alreadyUsed.put(meta.getColumnLabel(x), true);
									Object curVal = attributes.get(meta.getColumnLabel(x));
									if(curVal instanceof ArrayList)
									{
										((ArrayList) curVal).add(myResults.getObject(x));
									}
									else
									{
										ArrayList toInsert = new ArrayList();
										for(int z=0; z<curJoin; z++)
										{
											toInsert.add(curVal);
										}
										toInsert.add(myResults.getObject(x));
										attributes.put(meta.getColumnLabel(x), toInsert);
									}
								}
								//attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
							}
							else
							{
								//attributes.put(meta.getColumnLabel(x), "");
							}
						}
					}
				}
			}
		}
		catch(Exception e)
		{
			disconnect(connection);
			return null;
		}
		disconnect(connection);
		return myReturn;
	}
	
	public synchronized ArrayList getCTFChallenges(String username)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		ArrayList myReturn = new ArrayList();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM challenge_participant INNER JOIN challenge ON challenge_participant.challenge_name = challenge.challenge_name INNER JOIN challenge_set_ctf ON challenge_set_ctf.challenge_set_name = challenge.challenge_set_name LEFT JOIN challenge_participant_grades ON challenge_participant_grades.email = challenge_participant.email AND challenge_participant_grades.challenge_name = challenge_participant.challenge_name LEFT JOIN auto_grade_tests ON challenge_participant_grades.challenge_name = auto_grade_tests.challenge_name AND challenge_participant_grades.test_number = auto_grade_tests.test_number WHERE challenge_participant.email = ? AND CURRENT_TIMESTAMP > challenge_set_ctf.open_date AND CURRENT_TIMESTAMP < challenge_set_ctf.close_date ORDER BY challenge.challenge_set_name ASC, challenge.challenge_name ASC");
			myStmt.setString(1, username);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			int curJoin = 0;
			while(myResults.next())
			{
				if(attributes == null || attributes.isEmpty() || !attributes.get("challenge_name").equals(myResults.getObject("challenge_name")))
				{
					curJoin = 0;
					attributes=new ConcurrentHashMap();
					for(int x=1; x<=columns; x++)
					{
						if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
						{
							
						}
						else
						{
							if(myResults.getObject(x)!=null)
							{
								attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
							}
							else
							{
								if(!attributes.containsKey(meta.getColumnLabel(x)))
								{
									attributes.put(meta.getColumnLabel(x), "");
								}
							}
						}
					}
					DBObj tmp = new DBObj(attributes, false, tables);
					myReturn.add(tmp);
				}
				else
				{
					curJoin++;
					HashMap alreadyUsed = new HashMap();
					for(int x=1; x<=columns; x++)
					{
						if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
						{
							
						}
						else
						{
							if(myResults.getObject(x)!=null)
							{
								if(!alreadyUsed.containsKey(meta.getColumnLabel(x)) && attributes.containsKey(meta.getColumnLabel(x)) && !attributes.get(meta.getColumnLabel(x)).equals(myResults.getObject(x)) && !meta.getColumnLabel(x).equals("challenge_name") && !meta.getColumnLabel(x).equals("email"))
								{
									alreadyUsed.put(meta.getColumnLabel(x), true);
									Object curVal = attributes.get(meta.getColumnLabel(x));
									if(curVal instanceof ArrayList)
									{
										((ArrayList) curVal).add(myResults.getObject(x));
									}
									else
									{
										ArrayList toInsert = new ArrayList();
										for(int z=0; z<curJoin; z++)
										{
											toInsert.add(curVal);
										}
										toInsert.add(myResults.getObject(x));
										attributes.put(meta.getColumnLabel(x), toInsert);
									}
								}
								//attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
							}
							else
							{
								//attributes.put(meta.getColumnLabel(x), "");
							}
						}
					}
				}
			}
		}
		catch(Exception e)
		{
			disconnect(connection);
			return null;
		}
		disconnect(connection);
		return myReturn;
	}
	
	public synchronized ArrayList getUpcomingCTFs()
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		ArrayList myReturn = new ArrayList();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM challenge_set_ctf WHERE CURRENT_TIMESTAMP < close_date ORDER BY open_date ASC");
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			int curJoin = 0;
			while(myResults.next())
			{
				if(attributes == null || attributes.isEmpty() || !attributes.get("challenge_set_name").equals(myResults.getObject("challenge_set_name")))
				{
					curJoin = 0;
					attributes=new ConcurrentHashMap();
					for(int x=1; x<=columns; x++)
					{
						if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
						{
							
						}
						else
						{
							if(myResults.getObject(x)!=null)
							{
								attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
							}
							else
							{
								if(!attributes.containsKey(meta.getColumnLabel(x)))
								{
									attributes.put(meta.getColumnLabel(x), "");
								}
							}
						}
					}
					DBObj tmp = new DBObj(attributes, false, tables);
					myReturn.add(tmp);
				}
				else
				{
					curJoin++;
					HashMap alreadyUsed = new HashMap();
					for(int x=1; x<=columns; x++)
					{
						if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
						{
							
						}
						else
						{
							if(myResults.getObject(x)!=null)
							{
								if(!alreadyUsed.containsKey(meta.getColumnLabel(x)) && attributes.containsKey(meta.getColumnLabel(x)) && !attributes.get(meta.getColumnLabel(x)).equals(myResults.getObject(x)) && !meta.getColumnLabel(x).equals("challenge_name") && !meta.getColumnLabel(x).equals("email"))
								{
									alreadyUsed.put(meta.getColumnLabel(x), true);
									Object curVal = attributes.get(meta.getColumnLabel(x));
									if(curVal instanceof ArrayList)
									{
										((ArrayList) curVal).add(myResults.getObject(x));
									}
									else
									{
										ArrayList toInsert = new ArrayList();
										for(int z=0; z<curJoin; z++)
										{
											toInsert.add(curVal);
										}
										toInsert.add(myResults.getObject(x));
										attributes.put(meta.getColumnLabel(x), toInsert);
									}
								}
								//attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
							}
							else
							{
								//attributes.put(meta.getColumnLabel(x), "");
							}
						}
					}
				}
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			disconnect(connection);
			return null;
		}
		disconnect(connection);
		return myReturn;
	}
	
	public synchronized DBObj getCTFChallenge(String username, String challengeName)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		ArrayList myReturn = new ArrayList();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM challenge_participant INNER JOIN challenge ON challenge_participant.challenge_name = challenge.challenge_name INNER JOIN challenge_set_ctf ON challenge_set_ctf.challenge_set_name = challenge.challenge_set_name LEFT JOIN challenge_participant_grades ON challenge_participant_grades.email = challenge_participant.email AND challenge_participant_grades.challenge_name = challenge_participant.challenge_name LEFT JOIN auto_grade_tests ON challenge_participant_grades.challenge_name = auto_grade_tests.challenge_name AND challenge_participant_grades.test_number = auto_grade_tests.test_number WHERE challenge_participant.email = ? AND challenge_participant.challenge_name = ? AND CURRENT_TIMESTAMP > challenge_set_ctf.open_date AND CURRENT_TIMESTAMP < challenge_set_ctf.close_date ORDER BY challenge.challenge_set_name ASC, challenge.challenge_name ASC");
			myStmt.setString(1, username);
			myStmt.setString(2, challengeName);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			int curJoin = 0;
			while(myResults.next())
			{
				if(attributes == null || attributes.isEmpty() || !attributes.get("challenge_name").equals(myResults.getObject("challenge_name")))
				{
					curJoin = 0;
					attributes=new ConcurrentHashMap();
					for(int x=1; x<=columns; x++)
					{
						if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
						{
							
						}
						else
						{
							if(myResults.getObject(x)!=null)
							{
								attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
							}
							else
							{
								if(!attributes.containsKey(meta.getColumnLabel(x)))
								{
									attributes.put(meta.getColumnLabel(x), "");
								}
							}
						}
					}
					DBObj tmp = new DBObj(attributes, false, tables);
					myReturn.add(tmp);
				}
				else
				{
					curJoin++;
					HashMap alreadyUsed = new HashMap();
					for(int x=1; x<=columns; x++)
					{
						if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
						{
							
						}
						else
						{
							if(myResults.getObject(x)!=null)
							{
								if(!alreadyUsed.containsKey(meta.getColumnLabel(x)) && attributes.containsKey(meta.getColumnLabel(x)) && !attributes.get(meta.getColumnLabel(x)).equals(myResults.getObject(x)) && !meta.getColumnLabel(x).equals("challenge_name") && !meta.getColumnLabel(x).equals("email"))
								{
									alreadyUsed.put(meta.getColumnLabel(x), true);
									Object curVal = attributes.get(meta.getColumnLabel(x));
									if(curVal instanceof ArrayList)
									{
										((ArrayList) curVal).add(myResults.getObject(x));
									}
									else
									{
										ArrayList toInsert = new ArrayList();
										for(int z=0; z<curJoin; z++)
										{
											toInsert.add(curVal);
										}
										toInsert.add(myResults.getObject(x));
										attributes.put(meta.getColumnLabel(x), toInsert);
									}
								}
								//attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
							}
							else
							{
								//attributes.put(meta.getColumnLabel(x), "");
							}
						}
					}
				}
				disconnect(connection);
				return (DBObj) myReturn.get(0);
			}
		}
		catch(Exception e)
		{
			disconnect(connection);
			return null;
		}
		disconnect(connection);
		return null;
	}
	
	/**
	 * 
	 * @param username
	 * @return
	 */
	public synchronized ArrayList getChallengeAssignment(String username, String challengeName)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		ArrayList myReturn = new ArrayList();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT `challenge_participant`.*, `challenge`.*, `role`.*, SUM(`challenge_participant_grades`.`correct`) AS `auto_grade_score`, COUNT(`auto_grade_tests`.`test_number`) AS `num_grading_iterations` FROM `challenge_participant` INNER JOIN `challenge` ON `challenge`.`challenge_name` = `challenge_participant`.`challenge_name` INNER JOIN `role` ON `challenge_participant`.`email` = `role`.`email` LEFT JOIN `challenge_participant_grades` ON `challenge_participant_grades`.`challenge_name` = `challenge_participant`.`challenge_name` AND `challenge_participant_grades`.`email` = `challenge_participant`.`email` LEFT JOIN `auto_grade_tests` ON `auto_grade_tests`.`challenge_name` = `challenge_participant_grades`.`challenge_name` AND `auto_grade_tests`.`test_number` = `challenge_participant_grades`.`test_number` WHERE `challenge`.`admin_email` = ? AND `challenge`.`challenge_name` = ? GROUP BY `challenge_participant`.`email`, `role`.`course`, `role`.`role` ORDER BY `role`.`course` ");
			myStmt.setString(1, username);
			myStmt.setString(2, challengeName);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			while(myResults.next())
			{
				attributes=new ConcurrentHashMap();
				for(int x=1; x<=columns; x++)
				{
					if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
					{
						
					}
					else
					{
						if(myResults.getObject(x)!=null)
						{
							if(!attributes.containsKey(meta.getColumnLabel(x)))
							{
								attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
							}
						}
						else
						{
							if(!attributes.containsKey(meta.getColumnLabel(x)))
							{
								attributes.put(meta.getColumnLabel(x), "");
							}
						}
					}
				}
				DBObj tmp = new DBObj(attributes, false, tables);
				myReturn.add(tmp);
			}
		}
		catch(Exception e)
		{
			if(verbose)
				e.printStackTrace();
			disconnect(connection);
			return null;
		}
		disconnect(connection);
		return myReturn;
	}
	
	public synchronized ArrayList getChallenge(String challengeName, String email)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		ArrayList myReturn = new ArrayList();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM challenge INNER JOIN challenge_command ON challenge.challenge_name = challenge_command.challenge_name INNER JOIN challenge_participant ON challenge.challenge_name = challenge_participant.challenge_name WHERE challenge.challenge_name = ? AND challenge_participant.email = ? ORDER BY challenge_command.command_order ASC");
			myStmt.setString(1, challengeName);
			myStmt.setString(2, email);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			while(myResults.next())
			{
				attributes=new ConcurrentHashMap();
				for(int x=1; x<=columns; x++)
				{
					if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
					{
						
					}
					else
					{
						if(myResults.getObject(x)!=null)
						{
							attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
						}
						else
						{
							attributes.put(meta.getColumnLabel(x), "");
						}
					}
				}
				DBObj tmp = new DBObj(attributes, false, tables);
				myReturn.add(tmp);
			}
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
			return null;
		}
		disconnect(connection);
		return myReturn;
	}
	
	/**
	 * 
	 * @param challengeName
	 * @return
	 */
	public synchronized ArrayList getChallengeAutoGrade(String challengeName)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		ArrayList myReturn = new ArrayList();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM challenge INNER JOIN auto_grade_tests ON challenge.challenge_name = auto_grade_tests.challenge_name INNER JOIN auto_grade_args ON auto_grade_tests.challenge_name = auto_grade_args.challenge_name AND auto_grade_tests.test_number = auto_grade_args.test_number WHERE challenge.challenge_name = ? ORDER BY auto_grade_tests.test_number ASC, auto_grade_args.arg_order ASC");
			myStmt.setString(1, challengeName);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			while(myResults.next())
			{
				attributes=new ConcurrentHashMap();
				for(int x=1; x<=columns; x++)
				{
					if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
					{
						
					}
					else
					{
						if(myResults.getObject(x)!=null)
						{
							attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
						}
						else
						{
							attributes.put(meta.getColumnLabel(x), "");
						}
					}
				}
				DBObj tmp = new DBObj(attributes, false, tables);
				myReturn.add(tmp);
			}
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
			return null;
		}
		disconnect(connection);
		return myReturn;
	}
	
	/**
	 * 
	 * @param challengeName
	 * @return
	 */
	public synchronized ArrayList getChallengeAutoGrade(String username, String challengeName)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		ArrayList myReturn = new ArrayList();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM challenge INNER JOIN auto_grade_tests ON challenge.challenge_name = auto_grade_tests.challenge_name INNER JOIN auto_grade_args ON auto_grade_tests.challenge_name = auto_grade_args.challenge_name AND auto_grade_tests.test_number = auto_grade_args.test_number WHERE challenge.challenge_name = ? AND challenge.admin_email = ? ORDER BY auto_grade_tests.test_number ASC, auto_grade_args.arg_order ASC");
			myStmt.setString(1, challengeName);
			myStmt.setString(2, username);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			while(myResults.next())
			{
				attributes=new ConcurrentHashMap();
				for(int x=1; x<=columns; x++)
				{
					if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
					{
						
					}
					else
					{
						if(myResults.getObject(x)!=null)
						{
							attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
						}
						else
						{
							attributes.put(meta.getColumnLabel(x), "");
						}
					}
				}
				DBObj tmp = new DBObj(attributes, false, tables);
				myReturn.add(tmp);
			}
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
			return null;
		}
		disconnect(connection);
		return myReturn;
	}
	
	/**
	 * 
	 * @param challengeName
	 * @param testNumber
	 * @return
	 */
	public synchronized ArrayList getChallengeAutoGradeInput(String challengeName, int testNumber)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		ArrayList myReturn = new ArrayList();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM challenge INNER JOIN auto_grade_tests ON challenge.challenge_name = auto_grade_tests.challenge_name INNER JOIN auto_grade_input ON auto_grade_tests.challenge_name = auto_grade_input.challenge_name AND auto_grade_tests.test_number = auto_grade_input.test_number WHERE challenge.challenge_name = ? AND auto_grade_tests.test_number = ? ORDER BY auto_grade_tests.test_number ASC, auto_grade_input.input_order ASC");
			myStmt.setString(1, challengeName);
			myStmt.setInt(2, testNumber);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			while(myResults.next())
			{
				attributes=new ConcurrentHashMap();
				for(int x=1; x<=columns; x++)
				{
					if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
					{
						
					}
					else
					{
						if(myResults.getObject(x)!=null)
						{
							attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
						}
						else
						{
							attributes.put(meta.getColumnLabel(x), "");
						}
					}
				}
				DBObj tmp = new DBObj(attributes, false, tables);
				myReturn.add(tmp);
			}
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
			return null;
		}
		disconnect(connection);
		return myReturn;
	}
	
	public synchronized ArrayList getChallengeDefault(String challengeName, String email)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		ArrayList myReturn = new ArrayList();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM challenge_default INNER JOIN challenge_command_default ON challenge_default.challenge_name = challenge_command_default.challenge_name WHERE challenge_default.challenge_name = ? AND challenge_default.administrator = ? ORDER BY challenge_command_default.command_order ASC");
			myStmt.setString(1, challengeName);
			myStmt.setString(2, email);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			while(myResults.next())
			{
				attributes=new ConcurrentHashMap();
				for(int x=1; x<=columns; x++)
				{
					if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
					{
						
					}
					else
					{
						if(myResults.getObject(x)!=null)
						{
							attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
						}
						else
						{
							attributes.put(meta.getColumnLabel(x), "");
						}
					}
				}
				if(attributes.get("auto_grade").equals(true))
				{
					email = (String)attributes.get("administrator");
					attributes.put("grading", getChallengeDefaultGrading((String)attributes.get("challenge_name"), email));
				}
				DBObj tmp = new DBObj(attributes, false, tables);
				myReturn.add(tmp);
			}
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
			return null;
		}
		disconnect(connection);
		return myReturn;
	}
	
	/**
	 * 
	 * @param challengeName
	 * @param email
	 * @return
	 */
	public synchronized ArrayList getChallengeSubmission(String challengeName, String email)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		ArrayList myReturn = new ArrayList();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM `challenge` INNER JOIN `challenge_participant` ON `challenge`.`challenge_name` = `challenge_participant`.`challenge_name` WHERE `challenge_participant`.`challenge_name`=? AND `challenge_participant`.`email`=?");
			myStmt.setString(1, challengeName);
			myStmt.setString(2, email);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			while(myResults.next())
			{
				attributes=new ConcurrentHashMap();
				for(int x=1; x<=columns; x++)
				{
					if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
					{
						
					}
					else
					{
						if(myResults.getObject(x)!=null)
						{
							attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
						}
						else
						{
							attributes.put(meta.getColumnLabel(x), "");
						}
					}
				}
				DBObj tmp = new DBObj(attributes, false, tables);
				myReturn.add(tmp);
			}
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
			return null;
		}
		disconnect(connection);
		return myReturn;
	}
	
	public synchronized ArrayList getChallengeSubmissions(String challengeName)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		ArrayList myReturn = new ArrayList();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM `challenge` INNER JOIN `challenge_participant` ON `challenge`.`challenge_name` = `challenge_participant`.`challenge_name` LEFT JOIN `challenge_participant_grades` ON `challenge_participant`.`challenge_name` = `challenge_participant_grades`.`challenge_name` AND `challenge_participant`.`email` = `challenge_participant_grades`.`email` LEFT JOIN `auto_grade_tests` ON `challenge_participant_grades`.`challenge_name` = `auto_grade_tests`.`challenge_name` AND `challenge_participant_grades`.`test_number` = `auto_grade_tests`.`test_number` WHERE `challenge_participant`.`challenge_name`=? ORDER BY `challenge_participant_grades`.`email` ASC, `challenge_participant_grades`.`test_number` ASC");
			myStmt.setString(1, challengeName);
			if(verbose)
			{
				System.out.println(myStmt);
			}
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			while(myResults.next())
			{
				attributes=new ConcurrentHashMap();
				for(int x=1; x<=columns; x++)
				{
					if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
					{
						
					}
					else
					{
						if(myResults.getObject(x)!=null)
						{
							if(!attributes.containsKey(meta.getColumnLabel(x)))
							{
								attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
							}
						}
						else
						{
							if(!attributes.containsKey(meta.getColumnLabel(x)))
							{
								attributes.put(meta.getColumnLabel(x), "");
							}
						}
					}
				}
				if(verbose)
				{
					System.out.println(attributes.get("email"));
				}
				DBObj tmp = new DBObj(attributes, false, tables);
				myReturn.add(tmp);
			}
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
			return null;
		}
		disconnect(connection);
		return myReturn;
	}
	
	public synchronized ArrayList getChallengeDefaults(String username)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		ArrayList myReturn = new ArrayList();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM challenge_default INNER JOIN challenge_command_default ON challenge_default.challenge_name = challenge_command_default.challenge_name AND challenge_default.administrator = challenge_command_default.administrator WHERE challenge_default.administrator = '' OR challenge_default.administrator = ? ORDER BY challenge_default.administrator ASC, challenge_command_default.command_order ASC");
			myStmt.setString(1, username);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			while(myResults.next())
			{
				if(verbose)
				{
					System.out.println("Got a result");
				}
				attributes=new ConcurrentHashMap();
				for(int x=1; x<=columns; x++)
				{
					if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
					{
						
					}
					else
					{
						if(myResults.getObject(x)!=null)
						{
							attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
						}
						else
						{
							attributes.put(meta.getColumnLabel(x), "");
						}
					}
				}
				if(attributes.get("auto_grade").equals(true))
				{
					String curAdmin = (String)attributes.get("administrator");
					attributes.put("grading", getChallengeDefaultGrading((String)attributes.get("challenge_name"), curAdmin));
				}
				DBObj tmp = new DBObj(attributes, false, tables);
				myReturn.add(tmp);
			}
		}
		catch(Exception e)
		{
			disconnect(connection);
			return null;
		}
		disconnect(connection);
		return myReturn;
	}
	
	public synchronized ArrayList getChallengeDefaultGrading(String challengeName, String username)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		ArrayList myReturn = new ArrayList();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM auto_grade_tests_default INNER JOIN auto_grade_args_default ON auto_grade_tests_default.challenge_name = auto_grade_args_default.challenge_name AND auto_grade_tests_default.administrator = auto_grade_args_default.administrator AND auto_grade_tests_default.test_number = auto_grade_args_default.test_number WHERE (auto_grade_tests_default.administrator = ?) AND auto_grade_tests_default.challenge_name = ? ORDER BY auto_grade_args_default.test_number ASC, auto_grade_args_default.arg_order ASC");
			myStmt.setString(1, username);
			myStmt.setString(2, challengeName);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			while(myResults.next())
			{
				if(verbose)
				{
					System.out.println("Got a grade result for " + challengeName + ", " + username);
				}
				attributes=new ConcurrentHashMap();
				for(int x=1; x<=columns; x++)
				{
					if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
					{
						
					}
					else
					{
						if(myResults.getObject(x)!=null)
						{
							attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
						}
						else
						{
							attributes.put(meta.getColumnLabel(x), "");
						}
					}
				}
				DBObj tmp = new DBObj(attributes, false, tables);
				myReturn.add(tmp);
			}
		}
		catch(Exception e)
		{
			if(verbose)
			{
				e.printStackTrace();
			}
			//disconnect(connection);
			return null;
		}
		//disconnect(connection);
		return myReturn;
	}
	
	public synchronized ArrayList getChallengeDefault(String challengeName)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		ArrayList myReturn = new ArrayList();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM challenge_default INNER JOIN challenge_command_default ON challenge_default.challenge_name = challenge_command_default.challenge_name WHERE challenge_default.challenge_name = ? ORDER BY challenge_command_default.command_order ASC");
			myStmt.setString(1, challengeName);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			while(myResults.next())
			{
				if(verbose)
				{
					System.out.println("Got a result");
				}
				attributes=new ConcurrentHashMap();
				for(int x=1; x<=columns; x++)
				{
					if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
					{
						
					}
					else
					{
						if(myResults.getObject(x)!=null)
						{
							attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
						}
						else
						{
							attributes.put(meta.getColumnLabel(x), "");
						}
					}
				}
				DBObj tmp = new DBObj(attributes, false, tables);
				myReturn.add(tmp);
			}
		}
		catch(Exception e)
		{
			disconnect(connection);
			return null;
		}
		disconnect(connection);
		return myReturn;
	}
	
	public synchronized ArrayList getChallengeEvaluation(String challengeName, String email)
	{
		if(verbose)
		{
			System.out.println("Connector signing in");
		}
		ArrayList tables=new ArrayList();
		tables.add("user");
		Connection connection = getConnection();
		if(verbose)
		{
			System.out.println("Connector got connection");
		}
		ConcurrentHashMap attributes=new ConcurrentHashMap();
		ArrayList myReturn = new ArrayList();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement("SELECT * FROM challenge INNER JOIN challenge_evaluate_command ON challenge.challenge_name = challenge_evaluate_command.challenge_name INNER JOIN challenge_participant ON challenge.challenge_name = challenge_participant.challenge_name WHERE challenge.challenge_name = ? AND challenge_participant.email = ? ORDER BY challenge_evaluate_command.command_order ASC");
			myStmt.setString(1, challengeName);
			myStmt.setString(2, email);
			ResultSet myResults=myStmt.executeQuery();
			//disconnect(connection);
			ResultSetMetaData meta=myResults.getMetaData();
			int columns=meta.getColumnCount();
			while(myResults.next())
			{
				attributes=new ConcurrentHashMap();
				for(int x=1; x<=columns; x++)
				{
					if(meta.getColumnLabel(x).equals("password") || meta.getColumnLabel(x).equals("salt"))
					{
						
					}
					else
					{
						if(myResults.getObject(x)!=null)
						{
							attributes.put(meta.getColumnLabel(x), myResults.getObject(x));
						}
						else
						{
							attributes.put(meta.getColumnLabel(x), "");
						}
					}
				}
				DBObj tmp = new DBObj(attributes, false, tables);
				myReturn.add(tmp);
			}
		}
		catch(Exception e)
		{
			disconnect(connection);
			return null;
		}
		disconnect(connection);
		return myReturn;
	}
	
	public synchronized void syncChallenges(String admin, User myUser, ServletContext sc)
	{
		ArrayList allChallenges = getAdminChallenges(admin);
		ArrayList assigned = (ArrayList)getChallenges((String) myUser.getAttribute("email"));
		ArrayList challengeNames = new ArrayList();
		for(int x=0; x<assigned.size(); x++)
		{
			DBObj curObj = (DBObj)assigned.get(x);
			String curName = (String)curObj.getAttribute("challenge_name");
			challengeNames.add(curName);
		}
		for(int x=0; x<allChallenges.size(); x++)
		{
			DBObj curObj = (DBObj)allChallenges.get(x);
			String curName = (String)curObj.getAttribute("challenge_name");
			if(!assigned.contains(curName))
			{
				assignChallenge(curName, (String) myUser.getAttribute("email"));
				CodeGeneratorPool curPool = CodeGeneratorPool.getInstance();
	        	curPool.insertGeneration(this, myUser, sc, curName);
			}
		}
	}
	
	public void assignChallenge(String challengeName, String email)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("INSERT INTO `challenge_participant`(`challenge_name`, `email`) VALUES (?,?)");
			myStmt.setString(1, challengeName);
			myStmt.setString(2, email);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
		}
		disconnect(connection);
	}
	
	public void unassignChallenge(String challengeName, String email)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("DELETE FROM `challenge_participant` WHERE `challenge_name`=? AND `email`=?");
			myStmt.setString(1, challengeName);
			myStmt.setString(2, email);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
		}
		disconnect(connection);
	}
	
	public void removeChallengeParticipantTests(String challengeName, String email)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("DELETE FROM `challenge_participant_grades` WHERE `challenge_name`=? AND `email`=?");
			myStmt.setString(1, challengeName);
			myStmt.setString(2, email);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
		}
		disconnect(connection);
	}
	
	
	public User dataCollectEnable(String email)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("UPDATE `user` SET `downloadedDataCollection` = '1' WHERE `user`.`email` = ?");
			myStmt.setString(1, email);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
			return getUser(email);
		}
		disconnect(connection);
		return getUser(email);
	}
	
	public boolean updateChallenge(String prevName, String newName, String openTime, String endTime, String description, boolean randomSeed, String seed, String challengeSet)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("UPDATE `challenge` SET `challenge_name`=?,`open_time`=?,`end_time`=?,`description`=?, `randomSeed`=?, `seed`=?, `challenge_set_name`=? WHERE `challenge_name`=?");
			myStmt.setString(1, newName);
			myStmt.setString(2, openTime);
			myStmt.setString(3, endTime);
			myStmt.setString(4, description);
			myStmt.setBoolean(5, randomSeed);
			myStmt.setString(6, seed);
			myStmt.setString(7, challengeSet);
			myStmt.setString(8, prevName);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
			return false;
		}
		disconnect(connection);
		return true;
	}
	
	public boolean updateChallenge(String prevName, String newName, String openTime, String endTime, String description, boolean autoGrade, boolean randomSeed, String seed, String challengeSet)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("UPDATE `challenge` SET `challenge_name`=?,`open_time`=?,`end_time`=?,`description`=?,`auto_grade`=?, `randomSeed`=?, `seed`=?, `challenge_set_name`=? WHERE `challenge_name`=?");
			myStmt.setString(1, newName);
			myStmt.setString(2, openTime);
			myStmt.setString(3, endTime);
			myStmt.setString(4, description);
			myStmt.setBoolean(5, autoGrade);
			myStmt.setBoolean(6, randomSeed);
			myStmt.setString(7, seed);
			myStmt.setString(8, challengeSet);
			myStmt.setString(9, prevName);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
			return false;
		}
		disconnect(connection);
		return true;
	}
	
	public boolean updateChallengeDefault(String prevName, String newName, String description)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("UPDATE `challenge_default` SET `challenge_name`=?,`description`=? WHERE `challenge_name`=?");
			myStmt.setString(1, newName);
			myStmt.setString(2, description);
			myStmt.setString(3, prevName);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
			return false;
		}
		disconnect(connection);
		return true;
	}
	
	public boolean updateChallengeDefault(String prevName, String newName, String description, boolean autoGrade)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("UPDATE `challenge_default` SET `challenge_name`=?,`description`=?,`auto_grade`=? WHERE `challenge_name`=?");
			myStmt.setString(1, newName);
			myStmt.setString(2, description);
			myStmt.setObject(2, autoGrade);
			myStmt.setString(3, prevName);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
			return false;
		}
		disconnect(connection);
		return true;
	}
	
	public boolean setGrade(String challenge, String email, String grade)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("UPDATE `challenge_participant` SET `grade`=? WHERE `challenge_name`=? AND `email`=?");
			myStmt.setString(1, grade);
			myStmt.setString(2, challenge);
			myStmt.setString(3, email);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
			return false;
		}
		disconnect(connection);
		return true;
	}
	
	public boolean createChallenge(String newName, String openTime, String endTime, String description, String email, String type, boolean randomSeed, String seed, String challengeSet)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("INSERT INTO `challenge`(`challenge_name`, `open_time`, `end_time`, `description`, `admin_email`, `type`, `randomSeed`, `seed`, `challenge_set_name`) VALUES (?,?,?,?,?,?,?,?,?)");
			myStmt.setString(1, newName);
			myStmt.setString(2, openTime);
			myStmt.setString(3, endTime);
			myStmt.setString(4, description);
			myStmt.setString(5, email);
			myStmt.setString(6, type);
			myStmt.setBoolean(7, randomSeed);
			myStmt.setString(8, seed);
			myStmt.setString(9, challengeSet);
			
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
			return false;
		}
		disconnect(connection);
		assignChallenge(newName, email);
		return true;
	}
	
	public boolean createChallenge(String newName, String openTime, String endTime, String description, String email, String type, boolean autoGrade, boolean randomSeed, String seed, String challengeSet)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("INSERT INTO `challenge`(`challenge_name`, `open_time`, `end_time`, `description`, `admin_email`, `type`, `auto_grade`, `randomSeed`, `seed`, `challenge_set_name`) VALUES (?,?,?,?,?,?,?,?,?,?)");
			myStmt.setString(1, newName);
			myStmt.setString(2, openTime);
			myStmt.setString(3, endTime);
			myStmt.setString(4, description);
			myStmt.setString(5, email);
			myStmt.setString(6, type);
			myStmt.setBoolean(7, autoGrade);
			myStmt.setBoolean(8, randomSeed);
			myStmt.setString(9, seed);
			myStmt.setString(10, challengeSet);
			
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
			return false;
		}
		disconnect(connection);
		assignChallenge(newName, email);
		return true;
	}
	
	public boolean createChallengeDefault(String newName, String description, String email)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("INSERT INTO `challenge_default`(`challenge_name`, `description`, `administrator`) VALUES (?,?,?)");
			myStmt.setString(1, newName);
			//myStmt.setString(2, openTime);
			//myStmt.setString(3, endTime);
			myStmt.setString(2, description);
			myStmt.setString(3, email);
			//myStmt.setString(6, type);
			
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
			return false;
		}
		disconnect(connection);
		//assignChallenge(newName, email);
		return true;
	}
	
	public boolean createChallengeDefault(String newName, String description, String email, boolean autoGrade)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("INSERT INTO `challenge_default`(`challenge_name`, `description`, `administrator`, `auto_grade`) VALUES (?,?,?,?)");
			myStmt.setString(1, newName);
			//myStmt.setString(2, openTime);
			//myStmt.setString(3, endTime);
			myStmt.setString(2, description);
			myStmt.setString(3, email);
			myStmt.setObject(4, autoGrade);
			//myStmt.setString(6, type);
			
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
			return false;
		}
		disconnect(connection);
		//assignChallenge(newName, email);
		return true;
	}
	
	public void deleteCommands(String prevChallengeName)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("DELETE FROM `challenge_command` WHERE `challenge_name` = ?");
			myStmt.setString(1, prevChallengeName);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
		}
		disconnect(connection);
	}
	
	public void deleteCommandsDefault(String prevChallengeName, String administrator)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("DELETE FROM `challenge_command_default` WHERE `challenge_name` = ? AND `administrator` = ?");
			myStmt.setString(1, prevChallengeName);
			myStmt.setString(2, administrator);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
		}
		disconnect(connection);
	}
	
	public void deleteTestsDefault(String prevChallengeName, String administrator)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("DELETE FROM `auto_grade_tests_default` WHERE `challenge_name` = ? AND `administrator` = ?");
			myStmt.setString(1, prevChallengeName);
			myStmt.setString(2, administrator);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
		}
		disconnect(connection);
	}
	
	public void deleteTests(String prevChallengeName)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("DELETE FROM `auto_grade_tests` WHERE `challenge_name` = ?");
			myStmt.setString(1, prevChallengeName);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
		}
		disconnect(connection);
	}
	
	public void deleteChallenge(String prevChallengeName, String email)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("DELETE FROM `challenge` WHERE `challenge_name` = ? AND `admin_email` = ?");
			myStmt.setString(1, prevChallengeName);
			myStmt.setString(2, email);
			
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
		}
		disconnect(connection);
	}
	
	public void addCommand(String commandOrder, String commandName, String command, String challengeName)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("INSERT INTO `challenge_command`(`command_order`, `commandName`, `command`, `challenge_name`) VALUES (?, ?, ?, ?)");
			myStmt.setString(1, commandOrder);
			myStmt.setString(2, commandName);
			myStmt.setString(3, command);
			myStmt.setString(4, challengeName);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
		}
		disconnect(connection);
	}
	
	public void addCommandDefault(String commandOrder, String commandName, String command, String challengeName, String email)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("INSERT INTO `challenge_command_default`(`command_order`, `commandName`, `command`, `challenge_name`, `administrator`) VALUES (?, ?, ?, ?, ?)");
			myStmt.setString(1, commandOrder);
			myStmt.setString(2, commandName);
			myStmt.setString(3, command);
			myStmt.setString(4, challengeName);
			myStmt.setString(5, email);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
		}
		disconnect(connection);
	}
	
	public void addGradeDefault(String challengeName, int testNum, String numIterations, String performance, String email)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("INSERT INTO `auto_grade_tests_default`(`challenge_name`, `test_number`, `num_iterations`, `performance_multiplier`, `administrator`) VALUES (?,?,?,?,?)");
			myStmt.setString(1, challengeName);
			myStmt.setObject(2, testNum);
			myStmt.setString(3, numIterations);
			myStmt.setString(4, performance);
			myStmt.setString(5, email);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
		}
		disconnect(connection);
	}
	
	
	public void addGradeTest(String challengeName, int testNum, String numIterations, String performance)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("INSERT INTO `auto_grade_tests`(`challenge_name`, `test_number`, `num_iterations`, `performance_multiplier`) VALUES (?,?,?,?)");
			myStmt.setString(1, challengeName);
			myStmt.setObject(2, testNum);
			myStmt.setString(3, numIterations);
			myStmt.setString(4, performance);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
		}
		disconnect(connection);
	}
	
	
	public void addGradeDefaultArg(String challengeName, int testNum, int argNum, String argType, String argVal, String email)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("INSERT INTO `auto_grade_args_default`(`challenge_name`, `test_number`, `arg_order`, `arg_type`, `arg_value`, `administrator`) VALUES (?,?,?,?,?,?)");
			myStmt.setString(1, challengeName);
			myStmt.setObject(2, testNum);
			myStmt.setObject(3, argNum);
			myStmt.setString(4, argType);
			myStmt.setString(5, argVal);
			myStmt.setString(6, email);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
		}
		disconnect(connection);
	}
	
	public void addGradeTestArg(String challengeName, int testNum, int argNum, String argType, String argVal)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("INSERT INTO `auto_grade_args`(`challenge_name`, `test_number`, `arg_order`, `arg_type`, `arg_value`) VALUES (?,?,?,?,?)");
			myStmt.setString(1, challengeName);
			myStmt.setObject(2, testNum);
			myStmt.setObject(3, argNum);
			myStmt.setString(4, argType);
			myStmt.setString(5, argVal);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
		}
		disconnect(connection);
	}
	
	public void addGradeDefaultArg(String challengeName, int testNum, int argNum, String argType, String email)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("INSERT INTO `auto_grade_args_default`(`challenge_name`, `test_number`, `arg_order`, `arg_type`, `arg_value`, `administrator`) VALUES (?,?,?,?,NULL,?)");
			myStmt.setString(1, challengeName);
			myStmt.setObject(2, testNum);
			myStmt.setObject(3, argNum);
			myStmt.setString(4, argType);
			myStmt.setString(5, email);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
		}
		disconnect(connection);
	}
	
	public void addGradeTestArg(String challengeName, int testNum, int argNum, String argType)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("INSERT INTO `auto_grade_args`(`challenge_name`, `test_number`, `arg_order`, `arg_type`, `arg_value`) VALUES (?,?,?,?,NULL)");
			myStmt.setString(1, challengeName);
			myStmt.setObject(2, testNum);
			myStmt.setObject(3, argNum);
			myStmt.setString(4, argType);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
		}
		disconnect(connection);
	}
	
	
	public void deleteUser(String email)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("DELETE FROM `user` WHERE `email`=?");
			myStmt.setString(1, email);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
		}
		disconnect(connection);
	}
	
	/**
	 * 
	 * @param toUpdate
	 */
	public synchronized User updateUser(User toUpdate, User fromUpdate, String fromIP, String fromRequest)
	{
		ConcurrentHashMap updateMap=toUpdate.getAttributeChanges();
		if(toUpdate.getWritten() || updateMap==null || updateMap.size()==0)
		{
			return getUser((String)toUpdate.getAttribute("email"));
		}
		ConcurrentHashMap oldMap=toUpdate.getAttributes();
		if(verbose)
		{
			System.out.println("Getting column names");
		}
		Connection connection = getConnection();
		ArrayList validColumns=getColumnNames("user");
		Iterator myIter=updateMap.keySet().iterator();
		String stmt="UPDATE user SET ";
		boolean first=true;
		ArrayList parameters=new ArrayList();
		while(myIter.hasNext())
		{
			Object key=myIter.next();
			Object tmp=updateMap.get(key);
			if(validColumns.contains(key))
			{
				if(!(tmp instanceof ArrayList))
				{
					if(first)
					{
						if(key.equals("password"))
						{
							parameters.add(tmp);
							parameters.add(updateMap.get("salt"));
							stmt+=key+" = SHA2(CONCAT(?, ?),512), ";
						}
						else
						{
							parameters.add(tmp);
							stmt+=key+" = ?, ";
						}
					}
					else
					{
						if(key.equals("password"))
						{
							parameters.add(tmp);
							parameters.add(updateMap.get("salt"));
							stmt+=key+" = SHA2(CONCAT(?, ?),512), ";
						}
						else
						{
							parameters.add(tmp);
							stmt+=key+" = ?, ";
						}
					}
				}
				else
				{
					
				}
			}
			else
			{
				if(tmp instanceof ArrayList)
				{
					
				}
			}
		}
		stmt+="changeIP=?, changeURL=?, changeUserEmail=?";
		parameters.add(fromIP);
		parameters.add(fromRequest);
		parameters.add(fromUpdate.getAttribute("email"));
		/*
		stmt+=", changeuseremail=?, changeuserrole=?, changeuserinstitution=?";
		parameters.add(fromUpdate.getAttribute("email"));
		parameters.add(fromUpdate.getCurRole().getAttribute("role"));
		parameters.add(fromUpdate.getCurRole().getAttribute("institution"));
		*/
		stmt+=" WHERE email=?";
		parameters.add(oldMap.get("email"));
		/*
		Role tmp=fromUpdate.getCurRole();
		ArrayList permissions=(ArrayList)tmp.getAttribute("permissions");
		boolean updatepermission=false;
		first=true;
		for(int x=0; x<permissions.size(); x++)
		{
			Permission perm=(Permission)permissions.get(x);
			if(perm.getAttribute("action").equals("update user"))
			{
				String addToStmt=((String)perm.getAttribute("targetrelation"));
				Scanner myScanner=new Scanner(addToStmt);
				String next="";
				String addToStmtFinal="";
				while(myScanner.hasNext())
				{
					next=myScanner.next();
					addToStmtFinal+=" ";
					if(next.equals("actionemail"))
					{
						parameters.add((String)fromUpdate.getAttribute("email"));
						addToStmtFinal+="?";
					}
					else if(next.equals("actionrole"))
					{
						parameters.add((String)(((Role)fromUpdate.getCurRole()).getAttribute("role")));
						addToStmtFinal+="?";
					}
					else if(next.equals("actionsuperroles"))
					{
						ArrayList ownerList=getSuperRoleNames((String)(((Role)fromUpdate.getCurRole()).getAttribute("role")));
						for(int y=0; y<ownerList.size(); y++)
						{
							parameters.add(ownerList.get(y));
							if(y==0)
							{
								addToStmtFinal+="?";
							}
							else
							{
								addToStmtFinal+=", ?";
							}
						}
					}
					else if(next.equals("actioninstitution"))
					{
						parameters.add((String)(((Role)fromUpdate.getCurRole()).getAttribute("institution")));
						addToStmtFinal+="?";
					}
					else if(next.equals("actionownerinstitutions"))
					{
						ArrayList ownerList=getOwnerInstitutionNames((String)(((Role)fromUpdate.getCurRole()).getAttribute("institution")));
						for(int y=0; y<ownerList.size(); y++)
						{
							parameters.add(ownerList.get(y));
							if(y==0)
							{
								addToStmtFinal+="?";
							}
							else
							{
								addToStmtFinal+=", ?";
							}
						}
					}
					else if(next.equals("targetemail"))
					{
						parameters.add((String)toUpdate.getAttribute("email"));
						addToStmtFinal+="?";
					}
					else if(next.equals("targetrole"))
					{
						parameters.add((String)(((Role)toUpdate.getCurRole()).getAttribute("role")));
						addToStmtFinal+="?";
					}
					else if(next.equals("targetsuperroles"))
					{
						ArrayList ownerList=getSuperRoleNames((String)(((Role)toUpdate.getCurRole()).getAttribute("role")));
						for(int y=0; y<ownerList.size(); y++)
						{
							parameters.add(ownerList.get(y));
							if(y==0)
							{
								addToStmtFinal+="?";
							}
							else
							{
								addToStmtFinal+=", ?";
							}
						}
					}
					else if(next.equals("targetinstitution"))
					{
						parameters.add((String)(((Role)toUpdate.getCurRole()).getAttribute("institution")));
						addToStmtFinal+="?";
					}
					else if(next.equals("targetownerinstitutions"))
					{
						ArrayList ownerList=getOwnerInstitutionNames((String)(((Role)toUpdate.getCurRole()).getAttribute("institution")));
						for(int y=0; y<ownerList.size(); y++)
						{
							parameters.add(ownerList.get(y));
							if(y==0)
							{
								addToStmtFinal+="?";
							}
							else
							{
								addToStmtFinal+=", ?";
							}
						}
					}
					else
					{
						addToStmtFinal+=next;
					}
				}
				if(first)
				{
					stmt+="("+addToStmtFinal+")";
					updatepermission=true;
					first=false;
				}
				else
				{
					stmt+=" OR ("+addToStmtFinal+")";
				}
			}
		}
		if(!updatepermission)
		{
			disconnect(connection);
			return null;
		}
		*/
		try
		{
			if(connection == null || connection.isClosed())
			{
				connection = getConnection();
			}
			PreparedStatement myStmt=connection.prepareStatement(stmt);
			for(int x=0; x<parameters.size(); x++)
			{
				myStmt.setObject(x+1, parameters.get(x));
			}
			myStmt.executeUpdate();
			myStmt.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
			disconnect(connection);
			return null;
		}
		toUpdate.setWritten(true);
		disconnect(connection);
		return getUser((String)toUpdate.getAttribute("email"));
	}
	
	/**
	 * 
	 * @param toUpdate
	 */
	public synchronized void challengeParticipantCodeWritten(String challengeName, String email, byte[] originalFile, byte[] gradingFile, byte[] obfuscatedFile, int seed)
	{
		Connection connection = getConnection();
		String stmt="UPDATE `challenge_participant` SET `code_generated` = '1', `originalFile` = ?,  `gradingFile` = ?, `obfuscatedFile` = ?, `codeGeneratedTime` = CURRENT_TIMESTAMP, `participantSeed` = ? WHERE `challenge_participant`.`challenge_name` = ? AND `challenge_participant`.`email` = ?";
		try
		{
			PreparedStatement myStmt=connection.prepareStatement(stmt);
			myStmt.setBytes(1, originalFile);
			myStmt.setBytes(2, gradingFile);
			myStmt.setBytes(3, obfuscatedFile);
			myStmt.setString(4, "" + seed);
			myStmt.setString(5, challengeName);
			myStmt.setString(6, email);
			myStmt.executeUpdate();
			myStmt.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
			disconnect(connection);
			return;
		}
		disconnect(connection);
	}
	
	/**
	 * 
	 * @param challengeName
	 * @param originalFile
	 * @param gradingFile
	 * @param obfuscatedFile
	 */
	public synchronized void cacheChallengeCode(String challengeName, byte[] originalFile, byte[] gradingFile, byte[] obfuscatedFile)
	{
		Connection connection = getConnection();
		String stmt="UPDATE `challenge` SET `cachedOriginal` = ?,  `cachedGrading` = ?, `cachedObfuscated` = ? WHERE `challenge`.`challenge_name` = ?";
		try
		{
			PreparedStatement myStmt=connection.prepareStatement(stmt);
			myStmt.setBytes(1, originalFile);
			myStmt.setBytes(2, gradingFile);
			myStmt.setBytes(3, obfuscatedFile);
			myStmt.setString(4, challengeName);
			myStmt.executeUpdate();
			myStmt.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
			disconnect(connection);
			return;
		}
		disconnect(connection);
	}
	
	/**
	 * 
	 * @param toUpdate
	 */
	public synchronized void challengeParticipantCodeSubmitted(String challengeName, String email, byte[] writeFile, byte[] codeFile)
	{
		Connection connection = getConnection();
		String stmt="UPDATE `challenge_participant` SET `submittedFile` = ?, `submittedWrittenFile` = ?, `submissionTime` = CURRENT_TIME() WHERE `challenge_participant`.`challenge_name` = ? AND `challenge_participant`.`email` = ?";
		try
		{
			PreparedStatement myStmt=connection.prepareStatement(stmt);
			myStmt.setBytes(1, codeFile);
			myStmt.setBytes(2, writeFile);
			myStmt.setString(3, challengeName);
			myStmt.setString(4, email);
			myStmt.executeUpdate();
			myStmt.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
			disconnect(connection);
			return;
		}
		disconnect(connection);
	}
	
	
	public synchronized void gradeChallengeParticipant(String challengeName, String email, int testNumber, int score, boolean correct, boolean performance, boolean inProgress)
	{
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt = connection.prepareStatement("REPLACE INTO `challenge_participant_grades`(`challenge_name`, `email`, `test_number`, `iterations_passed`, `correct`, `performance`, `in_progress`) VALUES (?,?,?,?,?,?,?)");
			myStmt.setString(1, challengeName);
			myStmt.setString(2, email);
			myStmt.setInt(3, testNumber);
			myStmt.setInt(4, score);
			myStmt.setBoolean(5, correct);
			myStmt.setBoolean(6, performance);
			myStmt.setBoolean(7, inProgress);
			myStmt.execute();
		}
		catch(Exception e)
		{
			disconnect(connection);
			e.printStackTrace();
		}
		disconnect(connection);
	}
	
	public synchronized void writeUserRequest(String userName, String email, String fname, String mname, String lname, String pass, String message, String type) throws Exception
	{
		String salt = UUID.randomUUID().toString();
		
		String stmt="INSERT INTO `user_request` (`username`, `email`, `password`, `fName`, `mName`, `lName`, `lastLogon`, `currentVisit`, `previousVisit`, `loginIP`, `salt`, `changeIP`, `changeURL`, `changeUserEmail`, `displayRealName`, `passwordPlaintext`, `message`, `role`) VALUES (?, ?, SHA2(CONCAT(?, ?), 512), ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '', ?, '', '', '', '0', ?, ?, ?)";
		//String stmt2="INSERT INTO `role` (`email`, `role`) VALUES (?, ?)";
		Connection connection = getConnection();
		try
		{
			PreparedStatement myStmt=connection.prepareStatement(stmt);
			myStmt.setString(1, userName);
			myStmt.setString(2, email);
			myStmt.setString(3, pass);
			myStmt.setString(4, salt);
			myStmt.setString(5, fname);
			myStmt.setString(6, mname);
			myStmt.setString(7, lname);
			myStmt.setString(8, salt);
			myStmt.setString(9, pass);
			myStmt.setString(10, message);
			myStmt.setString(11, type);
			
			myStmt.executeUpdate();
			myStmt.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
			disconnect(connection);
			throw e;
			//return;
		}
		disconnect(connection);
	}
	
	public synchronized void writeCsvUsers(UserCsvParser myParser)
	{
		for(int x=0; x<myParser.emailList.size(); x++)
		{
			HashMap tmp=(HashMap) myParser.userMap.get(myParser.emailList.get(x));
			//System.out.println(tmp.get("fname")+", "+tmp.get("lname")+", "+tmp.get("email")+", "+tmp.get("password"));
			String stmt="INSERT INTO `user` (`username`, `email`, `password`, `fName`, `mName`, `lName`, `lastLogon`, `currentVisit`, `previousVisit`, `loginIP`, `salt`, `changeIP`, `changeURL`, `changeUserEmail`, `displayRealName`, `passwordPlaintext`) VALUES (?, ?, SHA2(CONCAT(?, ?), 512), ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '', ?, '', '', '', '0', ?)";
			String stmt2="INSERT INTO `role` (`email`, `role`) VALUES (?, 'student')";
			String stmt3="INSERT INTO `challenge_participant` (`email`, `challenge_name`) VALUES (?, 'Assignment 1 A')";
			String stmt4="INSERT INTO `challenge_participant` (`email`, `challenge_name`) VALUES (?, 'Assignment 1 B')";
			
			Connection connection = getConnection();
			
			try
			{
				PreparedStatement myStmt=connection.prepareStatement(stmt);
				myStmt.setString(1, (String) tmp.get("email"));
				myStmt.setString(2, (String) tmp.get("email"));
				myStmt.setString(3, tmp.get("password").toString());
				myStmt.setString(4, tmp.get("salt").toString());
				myStmt.setString(5, (String) tmp.get("fname"));
				myStmt.setString(6, "");
				myStmt.setString(7, (String) tmp.get("lname"));
				myStmt.setString(8, (String) tmp.get("salt").toString());
				myStmt.setString(9, (String) tmp.get("password").toString());
				
				PreparedStatement myStmt2=connection.prepareStatement(stmt2);
				myStmt2.setString(1, (String) tmp.get("email"));
				
				PreparedStatement myStmt3=connection.prepareStatement(stmt3);
				myStmt3.setString(1, (String) tmp.get("email"));
				
				PreparedStatement myStmt4=connection.prepareStatement(stmt4);
				myStmt4.setString(1, (String) tmp.get("email"));
				
				myStmt.executeUpdate();
				myStmt.close();
				
				myStmt2.executeUpdate();
				myStmt2.close();
				
				myStmt3.executeUpdate();
				myStmt3.close();
				
				myStmt4.executeUpdate();
				myStmt4.close();
			}
			catch(Exception e)
			{
				e.printStackTrace();
				disconnect(connection);
				//return;
			}
			disconnect(connection);
		}
	}
	
	public synchronized void writeCsvUsers(UserCsvParser myParser, String adminEmail)
	{
		for(int x=0; x<myParser.emailList.size(); x++)
		{
			HashMap tmp=(HashMap) myParser.userMap.get(myParser.emailList.get(x));
			//System.out.println(tmp.get("fname")+", "+tmp.get("lname")+", "+tmp.get("email")+", "+tmp.get("password"));
			String stmt="INSERT INTO `user` (`username`, `email`, `password`, `fName`, `mName`, `lName`, `lastLogon`, `currentVisit`, `previousVisit`, `loginIP`, `salt`, `changeIP`, `changeURL`, `changeUserEmail`, `displayRealName`, `passwordPlaintext`) VALUES (?, ?, SHA2(CONCAT(?, ?), 512), ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '', ?, '', '', '', '0', ?)";
			String stmt2="INSERT INTO `role` (`email`, `role`) VALUES (?, 'student')";
			String stmt3="INSERT INTO `challenge_participant` (`email`, `challenge_name`) VALUES (?, 'Assignment 1 A')";
			String stmt4="INSERT INTO `challenge_participant` (`email`, `challenge_name`) VALUES (?, 'Assignment 1 B')";
			
			Connection connection = getConnection();
			
			try
			{
				PreparedStatement myStmt=connection.prepareStatement(stmt);
				myStmt.setString(1, (String) tmp.get("email"));
				myStmt.setString(2, (String) tmp.get("email"));
				myStmt.setString(3, tmp.get("password").toString());
				myStmt.setString(4, tmp.get("salt").toString());
				myStmt.setString(5, (String) tmp.get("fname"));
				myStmt.setString(6, "");
				myStmt.setString(7, (String) tmp.get("lname"));
				myStmt.setString(8, (String) tmp.get("salt").toString());
				myStmt.setString(9, (String) tmp.get("password").toString());
				
				PreparedStatement myStmt2=connection.prepareStatement(stmt2);
				myStmt2.setString(1, (String) tmp.get("email"));
				
				PreparedStatement myStmt3=connection.prepareStatement(stmt3);
				myStmt3.setString(1, (String) tmp.get("email"));
				
				PreparedStatement myStmt4=connection.prepareStatement(stmt4);
				myStmt4.setString(1, (String) tmp.get("email"));
				
				myStmt.executeUpdate();
				myStmt.close();
				
				myStmt2.executeUpdate();
				myStmt2.close();
				
				myStmt3.executeUpdate();
				myStmt3.close();
				
				myStmt4.executeUpdate();
				myStmt4.close();
			}
			catch(Exception e)
			{
				e.printStackTrace();
				disconnect(connection);
				//return;
			}
			disconnect(connection);
		}
	}
	
	public synchronized void writeUser(String username, String email, String fname, String mname, String lname, String password, String role, String administrator, String courseName)
	{
		courseName = courseName.replaceAll(" ", "_");
		String salt = UUID.randomUUID().toString();
		//System.out.println(tmp.get("fname")+", "+tmp.get("lname")+", "+tmp.get("email")+", "+tmp.get("password"));
		String stmt="INSERT INTO `user` (`username`, `email`, `password`, `fName`, `mName`, `lName`, `lastLogon`, `currentVisit`, `previousVisit`, `loginIP`, `salt`, `changeIP`, `changeURL`, `changeUserEmail`, `displayRealName`, `passwordPlaintext`) VALUES (?, ?, SHA2(CONCAT(?, ?), 512), ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '', ?, '', '', '', '0', ?)";
		String stmt2="INSERT INTO `role` (`email`, `role`, `administrator`, `course`) VALUES (?, ?, ?, ?)";
		
		Connection connection = getConnection();
		
		try
		{
			PreparedStatement myStmt=connection.prepareStatement(stmt);
			myStmt.setString(1, username);
			myStmt.setString(2, email);
			myStmt.setString(3, password);
			myStmt.setString(4, salt);
			myStmt.setString(5, fname);
			myStmt.setString(6, mname);
			myStmt.setString(7, lname);
			myStmt.setString(8, salt);
			myStmt.setString(9, password);
			
			PreparedStatement myStmt2=connection.prepareStatement(stmt2);
			myStmt2.setString(1, email);
			myStmt2.setString(2, role);
			myStmt2.setString(3, administrator);
			myStmt2.setString(4, courseName);
			
			myStmt.executeUpdate();
			myStmt.close();
			
			myStmt2.executeUpdate();
			myStmt2.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
			disconnect(connection);
			//return;
		}
		disconnect(connection);
	}
}
