package com.data;

import java.net.InetAddress;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;

public class TrafficAnalyzer implements Runnable
{
	private static ConcurrentHashMap ipmap, previousMap, disallowMap;
	private static TrafficAnalyzer maintainer;
	/**
	 * 
	 */
	public TrafficAnalyzer()
	{
		if(maintainer==null)
		{
			maintainer=new TrafficAnalyzer(false);
		}
	}
	private TrafficAnalyzer(boolean diff)
	{
		ipmap=new ConcurrentHashMap();
		previousMap=new ConcurrentHashMap();
		disallowMap=new ConcurrentHashMap();
		Thread tmp=new Thread(this);
		tmp.start();
	}
	/**
	 * 
	 * @param myAddr
	 * @return
	 */
	public synchronized boolean allow(String myAddr)
	{
		boolean myReturn=true;
		if(myAddr.contains("localhost"))
		{
			return myReturn;
		}
		Counter tmp=(Counter)ipmap.get(myAddr);
		if(tmp==null)
		{
			tmp=new Counter();
			ipmap.put(myAddr, tmp);
		}
		synchronized(tmp)
		{
			tmp.count++;
		}
		if(tmp.count>15)
		{
			myReturn=false;
		}
		if(!myReturn)
		{
			if(disallowMap.contains(myAddr))
			{
				int tmpInt=(Integer)disallowMap.get(myAddr);
				disallowMap.put(myAddr, tmpInt++);
			}
			else
			{
				disallowMap.put(myAddr, 1);
			}
		}
		return myReturn;
	}
	/**
	 * 
	 * @param myAddr
	 * @return
	 */
	public synchronized int disallowNum(String myAddr)
	{
		return (Integer)disallowMap.get(myAddr);
	}
	/**
	 * 
	 * @param myAddr
	 * @return
	 */
	public synchronized boolean allowImage(String myAddr)
	{
		boolean myReturn=true;
		if(myAddr.contains("localhost"))
		{
			return myReturn;
		}
		Counter tmp=(Counter)ipmap.get(myAddr);
		if(tmp==null)
		{
			tmp=new Counter();
			ipmap.put(myAddr, tmp);
		}
		synchronized(tmp)
		{
			tmp.count++;
		}
		if(tmp.count>45)
		{
			myReturn=false;
		}
		if(!myReturn)
		{
			if(disallowMap.contains(myAddr))
			{
				int tmpInt=(Integer)disallowMap.get(myAddr);
				disallowMap.put(myAddr, tmpInt++);
			}
			else
			{
				disallowMap.put(myAddr, 1);
			}
		}
		return myReturn;
	}
	/**
	 * 
	 * @author Mi Laptop
	 *
	 */
	private class Counter
	{
		public int count;
		public Counter()
		{
			count=0;
		}
	}
	@Override
	public void run()
	{
		while(true)
		{
			try
			{
				Thread.currentThread().sleep(5000);
			}
			catch(InterruptedException e)
			{
				e.printStackTrace();
			}
			maintain();
		}
	}
	/**
	 * 
	 */
	public void maintain()
	{
		Set tmp1=ipmap.keySet();
		String tmpString="";
		Object tmpObject;
		Counter tmpCounter;
		Counter tmpCounter2;
		Iterator x=tmp1.iterator();
		while(x.hasNext())
		{
			tmpString=(String)x.next();
			tmpCounter2=(Counter)ipmap.get(tmpString);
			if(tmpCounter2.count>100)
			{
				if(previousMap.containsKey(tmpString))
				{
					tmpCounter=(Counter)previousMap.get(tmpString);
					tmpCounter2.count=15;
				}
				else
				{
					tmpCounter=new Counter();
					tmpCounter.count=tmpCounter2.count;
					previousMap.put(tmpString, tmpCounter);
					ipmap.remove(tmpString);
				}
			}
			else
			{
				previousMap.remove(tmpString);
				ipmap.remove(tmpString);
			}
		}
	}
}
