package com.data;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Queue;
import java.util.concurrent.ConcurrentHashMap;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;

public class CodeGeneratorPool
{
	private Queue generatorQueue = new LinkedList();
	private ConcurrentHashMap queueMap = new ConcurrentHashMap();
	private ArrayList threadList = new ArrayList();
	
	private static CodeGeneratorPool singletonPool = null;
	private static int numThreads = 2;
	
	public synchronized static CodeGeneratorPool getInstance()
	{
		if(singletonPool == null)
		{
			singletonPool = new CodeGeneratorPool(numThreads);
		}
		return singletonPool;
	}
	
	private CodeGeneratorPool(int numThreads)
	{
		for(int x = 0; x < numThreads; x++)
		{
			CodeGeneratorWorker curWorker = new CodeGeneratorWorker(this);
			threadList.add(curWorker);
			Thread curThread = new Thread(curWorker);
			curThread.start();
		}
	}
	
	public synchronized void insertGeneration(DatabaseConnector myConnector, DBObj myUser, ServletContext sc, String challengeName)
	{
		System.out.println("Queue size " + generatorQueue.size());
		String userID = (String)myUser.getAttribute("email");
		if(queueMap.containsKey(userID))
		{
			ConcurrentHashMap userMap = (ConcurrentHashMap) queueMap.get(userID);
			if(userMap.containsKey(challengeName))
			{
				
			}
			else
			{
				userMap.put(challengeName, 1);
				HashMap toDoMap = new HashMap();
				toDoMap.put("myConnector", myConnector);
				toDoMap.put("myUser", myUser);
				toDoMap.put("sc", sc);
				toDoMap.put("challengeName", challengeName);
				generatorQueue.add(toDoMap);
			}
		}
		else
		{
			ConcurrentHashMap userMap = new ConcurrentHashMap();
			userMap.put(challengeName, 1);
			queueMap.put(userID, userMap);
			HashMap toDoMap = new HashMap();
			toDoMap.put("myConnector", myConnector);
			toDoMap.put("myUser", myUser);
			toDoMap.put("sc", sc);
			toDoMap.put("challengeName", challengeName);
			generatorQueue.add(toDoMap);
		}
		
		
		for(int x = 0; x < threadList.size(); x++)
		{
			//System.out.println("Synchronizing worker");
			//synchronized((CodeGeneratorWorker)threadList.get(x))
			{
				//System.out.println("Notifying...");
			//((CodeGeneratorWorker)threadList.get(x)).notify();
			}
		}
	}
	
	public synchronized HashMap getNextWork()
	{
		System.out.println(generatorQueue.size() + "to generate");
		HashMap curMap = (HashMap)generatorQueue.poll();
		
		User myUser = (User) curMap.get("myUser");
		String userID = (String)myUser.getAttribute("email");
		ConcurrentHashMap userMap = (ConcurrentHashMap) queueMap.get(userID);
		userMap.remove(curMap.get("challengeName"));
		if(userMap.isEmpty())
		{
			queueMap.remove(userID);
		}
		
		if(queueMap.isEmpty())
		{
			stop();
		}
		
		return curMap;
	}
	
	public void stop()
	{
		singletonPool = null;
		for(int x = 0; x < threadList.size(); x++)
		{
			((CodeGeneratorWorker)threadList.get(x)).stop();
		}
	}
	
	public void finalize()
	{
		stop();
		try
		{
			super.finalize();
		}
		catch (Throwable e)
		{
			e.printStackTrace();
		}
	}
	
	public synchronized boolean hasWork()
	{
		return !(generatorQueue.isEmpty());
	}
	
	private class CodeGeneratorWorker implements Runnable
	{
		private CodeGenerator myGenerator;
		private boolean running = false;
		private CodeGeneratorPool myPool;
		
		public CodeGeneratorWorker(CodeGeneratorPool thePool)
		{
			myGenerator = new CodeGenerator();
			myPool = thePool;
		}
		
		public void stop()
		{
			running = false;
		}
		
		@Override
		public void run()
		{
			running = true;
			while(running)
			{
				//System.out.println("Worker syn");
				synchronized(this)
				{
				//System.out.println(Thread.currentThread() + " is executing");
				while(myPool.hasWork())
				{
					HashMap curWork = myPool.getNextWork();
					try
					{
						System.out.println(Thread.currentThread() + " is generating " + curWork.values());
						myGenerator.generateCode((DatabaseConnector)curWork.get("myConnector"), (DBObj)curWork.get("myUser"), (ServletContext)curWork.get("sc"), (String)curWork.get("challengeName"));
					}
					catch (Exception e)
					{
						e.printStackTrace();
					}
				}
				
				{
					try
					{
						//System.out.println(Thread.currentThread() + " is waiting");
						wait(1000);
					}
					catch(InterruptedException e)
					{
						e.printStackTrace();
					}
				}
			}
			}
		}
		
	}
}
