package com.data;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

public class ServerManager
{
	private static ServerManager instance;
	private ConcurrentHashMap commandMap;
	private ConcurrentHashMap paths;
	private ConcurrentHashMap fileMap;
	/**
	 * 
	 */
	public ServerManager()
	{
		commandMap=new ConcurrentHashMap();
		paths=new ConcurrentHashMap();
		fileMap=new ConcurrentHashMap();
	}
	/**
	 * 
	 * @return
	 */
	public static ServerManager getInstance()
	{
		if(instance==null)
		{
			instance=new ServerManager();
		}
		return instance;
	}
	/**
	 * 
	 * @return
	 */
	public ConcurrentHashMap getCommands()
	{
		return commandMap;
	}
	/**
	 * 
	 * @param path
	 */
	public void addCommandFile(String path)
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
				NodeList nodes=doc.getElementsByTagName("command");
				Element ele;
				ConcurrentHashMap newConn;
				for(int x=0; x<nodes.getLength(); x++)
				{
					ele=(Element)nodes.item(x);
					newConn=new ConcurrentHashMap();
					newConn.put("runtimecode", ele.getElementsByTagName("runtimecode").item(0).getTextContent());
					newConn.put("description", ele.getElementsByTagName("description").item(0).getTextContent());
					String name=ele.getElementsByTagName("name").item(0).getTextContent();
					newConn.put("name",name);
					if(commandMap.containsKey(name))
					{
						ConcurrentLinkedQueue dataQueue=(ConcurrentLinkedQueue)commandMap.get(name);
						dataQueue.add(newConn);
						commandMap.put(name, dataQueue);
						ArrayList tracker=new ArrayList();
						tracker.add(dataQueue);
						tracker.add(newConn);
						((ArrayList)fileMap.get(path)).add(tracker);
					}
					else
					{
						ConcurrentLinkedQueue toAdd=new ConcurrentLinkedQueue();
						toAdd.add(newConn);
						commandMap.put(name, toAdd);
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
	 * @param command
	 * @throws IOException 
	 * @throws InterruptedException 
	 */
	public synchronized String executeCommand(String command) throws IOException, InterruptedException
	{
		String myReturn="";
		if(commandMap.containsKey(command))
		{
			command=(String)((ConcurrentHashMap)((ConcurrentLinkedQueue)commandMap.get(command)).peek()).get("runtimecode");
		}
		Runtime runtime=Runtime.getRuntime();
		//Process restart=rt.exec("C:/xampp/tomcat/catalina_restart.bat");
		//System.out.println("Running "+command);
		Process stopprocess=runtime.exec(command);
		BufferedReader stopprocessinput=new BufferedReader(new InputStreamReader(stopprocess.getInputStream()));
		String line=null;
		while((line=stopprocessinput.readLine()) != null)
		{
			myReturn+='\n';
			myReturn+=line;
			//System.out.println(line);
		}
		int exitVal=stopprocess.waitFor();
		//System.out.println("Exited with error code "+exitVal);
		//myReturn+='\n';
		//myReturn+="Exited with error code "+exitVal;
		return myReturn;
	}
	/**
	 * 
	 * @param command
	 * @throws IOException 
	 * @throws InterruptedException 
	 */
	public synchronized String executeCommand(String command, File dir) throws IOException, InterruptedException
	{
		String myReturn="";
		if(commandMap.containsKey(command))
		{
			command=(String)((ConcurrentHashMap)((ConcurrentLinkedQueue)commandMap.get(command)).peek()).get("runtimecode");
		}
		Runtime runtime=Runtime.getRuntime();
		//Process restart=rt.exec("C:/xampp/tomcat/catalina_restart.bat");
		//System.out.println("Running "+command);
		Process stopprocess=runtime.exec(command, null, dir);
		BufferedReader stopprocessinput=new BufferedReader(new InputStreamReader(stopprocess.getInputStream()));
		String line=null;
		while((line=stopprocessinput.readLine()) != null)
		{
			myReturn+='\n';
			myReturn+=line;
			//System.out.println(line);
		}
		int exitVal=stopprocess.waitFor();
		//System.out.println("Exited with error code "+exitVal);
		//myReturn+='\n';
		//myReturn+="Exited with error code "+exitVal;
		return myReturn;
	}
	
	/**
	 * 
	 * @param command
	 * @throws IOException 
	 * @throws InterruptedException 
	 */
	public synchronized String executeCommand(String command, File dir, String[] environmentalVars) throws IOException, InterruptedException
	{
		String myReturn="";
		if(commandMap.containsKey(command))
		{
			command=(String)((ConcurrentHashMap)((ConcurrentLinkedQueue)commandMap.get(command)).peek()).get("runtimecode");
		}
		Runtime runtime=Runtime.getRuntime();
		//Process restart=rt.exec("C:/xampp/tomcat/catalina_restart.bat");
		//System.out.println("Environment "+environmentalVars);
		//System.out.println("In "+dir.getAbsolutePath());
		//System.out.println("Running "+command);
		Process stopprocess=runtime.exec(command, environmentalVars, dir);
		BufferedReader stopprocessinput=new BufferedReader(new InputStreamReader(stopprocess.getInputStream()));
		String line=null;
		while(stopprocess.isAlive())
		{
			while((line=stopprocessinput.readLine()) != null)
			{
				myReturn+='\n';
				myReturn+=line;
				//System.out.println(line);
			}
		}
		int exitVal=stopprocess.waitFor();
		//System.out.println("Exited with error code "+exitVal);
		//myReturn+='\n';
		//myReturn+="Exited with error code "+exitVal;
		return myReturn;
	}
	
	/**
	 * 
	 * @param command
	 * @param dir
	 * @param environmentalVars
	 * @param timeout
	 * @return
	 * @throws IOException
	 * @throws InterruptedException
	 */
	public synchronized String executeCommand(String command, File dir, String[] environmentalVars, long timeout) throws IOException, InterruptedException
	{
		long startTime = System.nanoTime();
		String myReturn="";
		if(commandMap.containsKey(command))
		{
			command=(String)((ConcurrentHashMap)((ConcurrentLinkedQueue)commandMap.get(command)).peek()).get("runtimecode");
		}
		Runtime runtime=Runtime.getRuntime();
		//Process restart=rt.exec("C:/xampp/tomcat/catalina_restart.bat");
		//System.out.println("Environment "+environmentalVars);
		//System.out.println("In "+dir.getAbsolutePath());
		//System.out.println("Running "+command);
		Process stopprocess=runtime.exec(command, environmentalVars, dir);
		BufferedReader stopprocessinput=new BufferedReader(new InputStreamReader(stopprocess.getInputStream()));
		String line=null;
		while(stopprocess.isAlive() && System.nanoTime() - startTime < timeout)
		{
			while((line=stopprocessinput.readLine()) != null)
			{
				myReturn+='\n';
				myReturn+=line;
				//System.out.println(line);
			}
			Thread.currentThread().sleep(10);
		}
		if(System.nanoTime() - startTime > timeout)
		{
			stopprocess.destroyForcibly();
		}
		int exitVal=stopprocess.waitFor();
		//System.out.println("Exited with error code "+exitVal);
		//myReturn+='\n';
		//myReturn+="Exited with error code "+exitVal;
		return myReturn;
	}
	
	public synchronized String executeCommand(String command, File dir, String[] environmentalVars, long timeout, ArrayList toOutput) throws IOException, InterruptedException
	{
		long startTime = System.nanoTime();
		String myReturn="";
		if(commandMap.containsKey(command))
		{
			command=(String)((ConcurrentHashMap)((ConcurrentLinkedQueue)commandMap.get(command)).peek()).get("runtimecode");
		}
		Runtime runtime=Runtime.getRuntime();
		//Process restart=rt.exec("C:/xampp/tomcat/catalina_restart.bat");
		//System.out.println("Environment "+environmentalVars);
		//System.out.println("In "+dir.getAbsolutePath());
		//System.out.println("Running "+command);
		Process stopprocess=runtime.exec(command, environmentalVars, dir);
		BufferedReader stopprocessinput=new BufferedReader(new InputStreamReader(stopprocess.getInputStream()));
		String line=null;
		int outputIndex = 0;
		while(stopprocess.isAlive() && System.nanoTime() - startTime < timeout)
		{
			while((line=stopprocessinput.readLine()) != null)
			{
				myReturn+='\n';
				myReturn+=line;
				//System.out.println(line);
			}
			stopprocess.getOutputStream().write(((String) toOutput.get(outputIndex)).getBytes());
			outputIndex++;
			Thread.currentThread().sleep(10);
		}
		if(System.nanoTime() - startTime > timeout)
		{
			stopprocess.destroyForcibly();
		}
		int exitVal=stopprocess.waitFor();
		//System.out.println("Exited with error code "+exitVal);
		//myReturn+='\n';
		//myReturn+="Exited with error code "+exitVal;
		return myReturn;
	}
	
	/**
	 * 
	 * @param command
	 * @throws IOException 
	 * @throws InterruptedException 
	 */
	public synchronized String executeCommand(String[] command, File dir, String[] environmentalVars) throws IOException, InterruptedException
	{
		String myReturn="";
		//if(commandMap.containsKey(command))
		//{
		//	command=(String)((ConcurrentHashMap)((ConcurrentLinkedQueue)commandMap.get(command)).peek()).get("runtimecode");
		//}
		Runtime runtime=Runtime.getRuntime();
		//Process restart=rt.exec("C:/xampp/tomcat/catalina_restart.bat");
		for(int x=0; x<environmentalVars.length; x++)
		{
			//System.out.println("Environment "+environmentalVars[x]);
		}
		//System.out.println("In "+dir.getAbsolutePath());
		for(int x=0; x<command.length; x++)
		{
			//System.out.println("Command "+command[x]);
		}
		Process stopprocess=runtime.exec(command, environmentalVars, dir);
		BufferedReader stopprocessinput=new BufferedReader(new InputStreamReader(stopprocess.getInputStream()));
		String line=null;
		while((line=stopprocessinput.readLine()) != null)
		{
			myReturn+='\n';
			myReturn+=line;
			//System.out.println(line);
		}
		stopprocessinput=new BufferedReader(new InputStreamReader(stopprocess.getErrorStream()));
		while((line=stopprocessinput.readLine()) != null)
		{
			myReturn+='\n';
			myReturn+=line;
			//System.out.println(line);
		}
		int exitVal=stopprocess.waitFor();
		//System.out.println("Exited with error code "+exitVal);
		//myReturn+='\n';
		//myReturn+="Exited with error code "+exitVal;
		//System.out.println(myReturn);
		return myReturn;
	}
	
	/**
	 * 
	 * @param command
	 * @param dir
	 * @param environmentalVars
	 * @param timeout
	 * @return
	 * @throws IOException
	 * @throws InterruptedException
	 */
	public synchronized String executeCommand(String[] command, File dir, String[] environmentalVars, long timeout) throws IOException, InterruptedException
	{
		long startTime = System.nanoTime();
		String myReturn="";
		//if(commandMap.containsKey(command))
		//{
		//	command=(String)((ConcurrentHashMap)((ConcurrentLinkedQueue)commandMap.get(command)).peek()).get("runtimecode");
		//}
		Runtime runtime=Runtime.getRuntime();
		//Process restart=rt.exec("C:/xampp/tomcat/catalina_restart.bat");
		for(int x=0; x<environmentalVars.length; x++)
		{
			//System.out.println("Environment "+environmentalVars[x]);
		}
		//System.out.println("In "+dir.getAbsolutePath());
		for(int x=0; x<command.length; x++)
		{
			//System.out.println("Command "+command[x]);
		}
		Process stopprocess=runtime.exec(command, environmentalVars, dir);
		
		while(stopprocess.isAlive() && System.nanoTime() - startTime < timeout)
		{
			BufferedReader stopprocessinput=new BufferedReader(new InputStreamReader(stopprocess.getInputStream()));
			String line=null;
			while(stopprocessinput.ready() && (line=stopprocessinput.readLine()) != null && System.nanoTime() - startTime < timeout)
			{
				myReturn+='\n';
				myReturn+=line;
				//System.out.println(line);
			}
			stopprocessinput=new BufferedReader(new InputStreamReader(stopprocess.getErrorStream()));
			while(stopprocessinput.ready() && (line=stopprocessinput.readLine()) != null && System.nanoTime() - startTime < timeout)
			{
				myReturn+='\n';
				myReturn+=line;
				//System.out.println(line);
			}
			
			Thread.currentThread().sleep(10);
		}
		if(System.nanoTime() - startTime > timeout)
		{
			System.out.println("Process timeout");
			stopprocess.destroy();
			stopprocess.destroyForcibly();
		}
		else
		{
		
		
			int exitVal=stopprocess.waitFor();
		}
		//System.out.println("Exited with error code "+exitVal);
		//myReturn+='\n';
		//myReturn+="Exited with error code "+exitVal;
		//System.out.println(myReturn);
		return myReturn;
	}
	
	public synchronized String executeCommand(String[] command, File dir, String[] environmentalVars, long timeout, ArrayList toOutput) throws IOException, InterruptedException
	{
		long startTime = System.nanoTime();
		String myReturn="";
		//if(commandMap.containsKey(command))
		//{
		//	command=(String)((ConcurrentHashMap)((ConcurrentLinkedQueue)commandMap.get(command)).peek()).get("runtimecode");
		//}
		Runtime runtime=Runtime.getRuntime();
		//Process restart=rt.exec("C:/xampp/tomcat/catalina_restart.bat");
		for(int x=0; x<environmentalVars.length; x++)
		{
			//System.out.println("Environment "+environmentalVars[x]);
		}
		//System.out.println("In "+dir.getAbsolutePath());
		for(int x=0; x<command.length; x++)
		{
			//System.out.println("Command "+command[x]);
		}
		Process stopprocess=runtime.exec(command, environmentalVars, dir);
		int outputIndex = 0;
		
		while(stopprocess.isAlive() && System.nanoTime() - startTime < timeout)
		{
			BufferedReader stopprocessinput=new BufferedReader(new InputStreamReader(stopprocess.getInputStream()));
			String line=null;
			while(stopprocessinput.ready() && (line=stopprocessinput.readLine()) != null && System.nanoTime() - startTime < timeout)
			{
				myReturn+='\n';
				myReturn+=line;
				//System.out.println(line);
			}
			stopprocessinput=new BufferedReader(new InputStreamReader(stopprocess.getErrorStream()));
			while(stopprocessinput.ready() && (line=stopprocessinput.readLine()) != null && System.nanoTime() - startTime < timeout)
			{
				myReturn+='\n';
				myReturn+=line;
				//System.out.println(line);
			}
			if(stopprocess.isAlive() && System.nanoTime() - startTime < timeout && outputIndex < toOutput.size())
			{
				System.out.println("Giving output stream: " + toOutput.get(outputIndex));
				stopprocess.getOutputStream().write(((String)toOutput.get(outputIndex)).getBytes());
				outputIndex++;
			}
			Thread.currentThread().sleep(10);
		}
		if(System.nanoTime() - startTime > timeout)
		{
			stopprocess.destroyForcibly();
		}
		
		
		int exitVal=stopprocess.waitFor();
		//System.out.println("Exited with error code "+exitVal);
		//myReturn+='\n';
		//myReturn+="Exited with error code "+exitVal;
		//System.out.println(myReturn);
		return myReturn;
	}
}
