package com.data;

import java.io.File;
import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;

import javax.servlet.Servlet;
import org.w3c.dom.*;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

public class DatabaseInformationManager
{
	private static DatabaseInformationManager instance;
	private ConcurrentHashMap connectionList;
	private ConcurrentHashMap paths;
	private ConcurrentHashMap fileMap;
	/**
	 * 
	 */
	private DatabaseInformationManager()
	{
		connectionList=new ConcurrentHashMap();
		paths=new ConcurrentHashMap();
		fileMap=new ConcurrentHashMap();
	}
	/**
	 * 
	 * @return
	 */
	public ConcurrentHashMap getConnectionInfo()
	{
		return connectionList;
	}
	/**
	 * 
	 * @return
	 */
	public synchronized ConcurrentHashMap getNext(String name)
	{
		if(!connectionList.containsKey(name))
		{
			
			//System.err.println("Does not have that key: "+name);
			//System.err.println(connectionList);
			return null;
		}
		ConcurrentLinkedQueue tmp=(ConcurrentLinkedQueue)connectionList.get(name);
		ConcurrentHashMap myReturn=(ConcurrentHashMap)tmp.poll();
		tmp.add(myReturn);
		connectionList.put(name, tmp);
		return myReturn;
	}
	/**
	 * 
	 */
	public void emptyConnections()
	{
		connectionList=new ConcurrentHashMap();
		paths=new ConcurrentHashMap();
		fileMap=new ConcurrentHashMap();
	}
	/**
	 * 
	 * @param path
	 */
	public synchronized void addInfoFile(String path)
	{
		File tmp=new File(path);
		if(paths.containsKey(path) && tmp.lastModified()<=(Long)paths.get(path))
		{
			
		}
		else
		{
			if(paths.containsKey(path) && tmp.lastModified()>(Long)paths.get(path))
			{
				ArrayList fileContents=(ArrayList)fileMap.get(path);
				ArrayList connList;
				for(int x=0; x<fileContents.size(); x++)
				{
					connList=(ArrayList)fileContents.get(x);
					((ConcurrentLinkedQueue)connList.get(0)).remove(connList.get(1));
				}
				fileMap.remove(path);
			}
			paths.put(path, tmp.lastModified());
			fileMap.put(path, new ArrayList());
			DocumentBuilderFactory factory=DocumentBuilderFactory.newInstance();
			try
			{
				DocumentBuilder builder=factory.newDocumentBuilder();
				Document doc=(Document)builder.parse(tmp);
				NodeList nodes=doc.getElementsByTagName("database");
				Element ele;
				ConcurrentHashMap newConn;
				for(int x=0; x<nodes.getLength(); x++)
				{
					ele=(Element)nodes.item(x);
					newConn=new ConcurrentHashMap();
					newConn.put("address", ele.getElementsByTagName("address").item(0).getTextContent());
					newConn.put("username",ele.getElementsByTagName("username").item(0).getTextContent());
					newConn.put("password",ele.getElementsByTagName("password").item(0).getTextContent());
					newConn.put("driver",ele.getElementsByTagName("driver").item(0).getTextContent());
					newConn.put("maxconnections",new Integer(ele.getElementsByTagName("maxconnections").item(0).getTextContent()));
					String name=ele.getElementsByTagName("name").item(0).getTextContent();
					newConn.put("name",name);
					if(connectionList.containsKey(name))
					{
						ConcurrentLinkedQueue dataQueue=(ConcurrentLinkedQueue)connectionList.get(name);
						dataQueue.add(newConn);
						connectionList.put(name, dataQueue);
						ArrayList tracker=new ArrayList();
						tracker.add(dataQueue);
						tracker.add(newConn);
						((ArrayList)fileMap.get(path)).add(tracker);
					}
					else
					{
						ConcurrentLinkedQueue toAdd=new ConcurrentLinkedQueue();
						toAdd.add(newConn);
						connectionList.put(name, toAdd);
						ArrayList tracker=new ArrayList();
						tracker.add(toAdd);
						tracker.add(newConn);
						((ArrayList)fileMap.get(path)).add(tracker);
					}
				}
			}
			catch(Exception e)
			{
				
			}
		}
	}
	/**
	 * 
	 * @return
	 */
	public static DatabaseInformationManager getInstance()
	{
		if(instance==null)
		{
			instance=new DatabaseInformationManager();
		}
		return instance;
	}
}
