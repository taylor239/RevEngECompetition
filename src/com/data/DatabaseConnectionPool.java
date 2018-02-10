package com.data;


import java.util.HashMap;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.concurrent.ConcurrentLinkedQueue;

public class DatabaseConnectionPool implements Runnable
{
	/**
	 * 
	 */
	private static HashMap poolMap;
	private String myAddress, myDriver, myUserName, myPassword;
	private int myMaxConnections=0, myCurConnections=0;
	private ConcurrentLinkedQueue connectionQueue;
	private ArrayList checkedOut;
	private ReturnHelper myHelper;
	public String errors="";
	/**
	 * 
	 * @return
	 */
	public static DatabaseConnectionPool getInstance(String address, String driver, String userName, int maxConnections, String password)
	{
		if(poolMap==null)
		{
			poolMap=new HashMap();
		}
		HashMap driverMap=(HashMap)poolMap.get(driver);
		if(driverMap==null)
		{
			driverMap=new HashMap();
			poolMap.put(driver, driverMap);
		}
		HashMap addressMap=(HashMap)driverMap.get(address);
		if(addressMap==null)
		{
			addressMap=new HashMap();
			driverMap.put(address, addressMap);
		}
		HashMap userMap=(HashMap)addressMap.get(userName);
		if(userMap==null)
		{
			userMap=new HashMap();
			addressMap.put(userName, userMap);
		}
		HashMap maxConnectionsMap=(HashMap)userMap.get(maxConnections);
		if(maxConnectionsMap==null)
		{
			maxConnectionsMap=new HashMap();
			userMap.put(maxConnections, maxConnectionsMap);
		}
		DatabaseConnectionPool instance=(DatabaseConnectionPool) maxConnectionsMap.get(password);
		if(instance==null)
		{
			instance=new DatabaseConnectionPool(address, driver, userName, password, maxConnections);
			maxConnectionsMap.put(password, instance);
		}
		return instance;
	}
	/**
	 * 
	 */
	private DatabaseConnectionPool(String address, String driver, String userName, String password, int maxConnections)
	{
		myAddress=address;
		myDriver=driver;
		myUserName=userName;
		myPassword=password;
		myMaxConnections=maxConnections;
		myCurConnections=0;
		connectionQueue=new ConcurrentLinkedQueue();
		myHelper=new ReturnHelper();
		checkedOut=new ArrayList();
		Thread myThread=new Thread(this);
		myThread.start();
		try
		{
			Class.forName(myDriver);
		}
		catch(ClassNotFoundException e)
		{
			errors+=(e.toString()+"<br>");
		}
	}
	/**
	 * 
	 */
	public synchronized Connection getConnection()
	{
		try
		{
			Connection debugConnection;
			//Class.forName(myDriver);
			debugConnection=DriverManager.getConnection(myAddress, myUserName, myPassword);
			//System.out.println("Cur connections "+myCurConnections);
			if(true)
			{
				return debugConnection;
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		if(connectionQueue.isEmpty() && myCurConnections<myMaxConnections)
		{
			try
			{
				Connection connection;
				//Class.forName(myDriver);
				connection=DriverManager.getConnection(myAddress, myUserName, myPassword);
				//connectionQueue.add(connection);
				myCurConnections++;
				checkedOut.add(new ConnectionPair(connection));
				return connection;
			}
			catch(Exception e)
			{
				
				errors+=(e.toString()+"<br>");
			}
		}
		Connection myReturn=null;
		try
		{
			while((myReturn==null))// || !myReturn.isValid(0)))
			{
				myReturn=(Connection)connectionQueue.poll();
				if(myReturn==null)
				{
					//cycles++;
					continue;
				}
				//else if(!myReturn.isValid(0))
				//{
				//	myReturn.close();
					//Class.forName(myDriver);
				//	myReturn=DriverManager.getConnection(myAddress, myUserName, myPassword);
				//}
				//cycles++;
			}
		}
		catch(Exception e)
		{
			// TODO Auto-generated catch block
			errors+=(e.toString()+"<br>");
		}
		checkedOut.add(new ConnectionPair(myReturn));
		return myReturn;
	}
	private class ReturnHelper
	{
		public synchronized void returnConnection(Connection toReturn)
		{
			synchronized(checkedOut)
			{
				for(int x=0; x<checkedOut.size(); x++)
				{
					if(checkedOut.get(x)==null)
					{
						checkedOut.remove(x);
						continue;
					}
					if(((ConnectionPair)checkedOut.get(x)).equals(toReturn) || ((ConnectionPair)checkedOut.get(x))==(toReturn))
					{
						checkedOut.remove(x);
					}
				}
			}
			connectionQueue.add(toReturn);
		}
	}
	/**
	 * 
	 * @param toReturn
	 */
	public void returnConnection(Connection toReturn)
	{
		try {
			toReturn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		if(true)
		{
			return;
		}
		//synchronized(toReturn)
		{
			myHelper.returnConnection(toReturn);
		}
	}
	/**
	 * 
	 * @return
	 */
	public int getNumConnections()
	{
		return myCurConnections;
	}
	/**
	 * 
	 * @return
	 */
	public int getNumConnectionsInPool()
	{
		if(connectionQueue!=null)
		{
			return connectionQueue.size();
		}
		return 0;
	}
	/**
	 * 
	 * @return
	 */
	public int getNumConnectionsCheckedOut()
	{
		if(checkedOut!=null)
		{
			return checkedOut.size();
		}
		else
		{
			return 0;
		}
	}
	@Override
	public void run()
	{
		ArrayList lastList=new ArrayList();
		while(true)
		{
			synchronized(checkedOut)
			{
				ConnectionPair tmp;
				for(int x=0; x<checkedOut.size(); x++)
				{
					tmp=(ConnectionPair)checkedOut.get(x);
					if(tmp==null)
					{
						x++;
						continue;
					}
					tmp.p2++;
					try
					{
						if(tmp.p1==null)
						{
							returnConnection(tmp.p1);
						}
						//else if(!tmp.p1.isValid(0) || tmp.p2>20)
						//{
							//tmp.p1.close();
						//	returnConnection(tmp.p1);
						//}
					}
					catch(Exception e)
					{
						errors+=e.toString()+"<br>";
					}
				}
			}
			try
			{
				Thread.currentThread().sleep(500);
			}
			catch(InterruptedException e)
			{
				errors+=(e.toString()+"<br>");
			}
		}
	}
	/**
	 * 
	 * @author Mi Laptop
	 *
	 */
	private class ConnectionPair
	{
		public Connection p1;
		public int p2;
		public ConnectionPair(Connection p)
		{
			p1=p;
			p2=0;
		}
		/**
		 * 
		 * @param compare
		 * @return
		 */
		public boolean equals(Object compare)
		{
			if(compare==null)
			{
				return false;
			}
			if(p1==compare)
			{
				return true;
			}
			if(this==compare)
			{
				return true;
			}
			if(compare instanceof ConnectionPair)
			{
				return(p1.equals(((ConnectionPair)compare).p1));
			}
			else if(compare instanceof Connection)
			{
				return(p1.equals(compare));
			}
			return false;
		}
	}
}
