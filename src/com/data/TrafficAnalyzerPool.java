package com.data;

import java.util.ArrayList;
import java.util.concurrent.ConcurrentLinkedQueue;

public class TrafficAnalyzerPool
{
	private static TrafficAnalyzerPool myPool;
	private static ConcurrentLinkedQueue analyzerList;
	private static int numAnalyzer=100;
	/**
	 * 
	 * @return
	 */
	public static synchronized TrafficAnalyzer getAnalyzer()
	{
		return new TrafficAnalyzer();
		/**
		if(analyzerList==null)
		{
			analyzerList=new ConcurrentLinkedQueue();
			for(int x=0; x<numAnalyzer; x++)
			{
				analyzerList.add(new TrafficAnalyzer());
			}
		}
		TrafficAnalyzer tmp=(TrafficAnalyzer)analyzerList.poll();
		analyzerList.add(tmp);
		return tmp;
		**/
	}
}
