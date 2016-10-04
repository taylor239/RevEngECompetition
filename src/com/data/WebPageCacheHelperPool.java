package com.data;

import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;

public class WebPageCacheHelperPool
{
	private ConcurrentHashMap cacheData;
	private ConcurrentLinkedQueue helperQueue;
	private int numHelpers=100;
	/**
	 * 
	 */
	public WebPageCacheHelperPool()
	{
		cacheData=new ConcurrentHashMap();
		helperQueue=new ConcurrentLinkedQueue();
		for(int x=0; x<numHelpers; x++)
		{
			helperQueue.add(new WebPageCacheHelper(cacheData));
		}
	}
	/**
	 * 
	 * @return
	 */
	public WebPageCacheHelper getHelper()
	{
		if(helperQueue.isEmpty())
		{
			return new WebPageCacheHelper(cacheData);
		}
		return (WebPageCacheHelper)helperQueue.poll();
	}
	/**
	 * 
	 */
	public void returnHelper(WebPageCacheHelper toReturn)
	{
		helperQueue.add(toReturn);
	}
	/**
	 * 
	 * @return
	 */
	public ConcurrentHashMap getCacheData()
	{
		return cacheData;
	}
}
