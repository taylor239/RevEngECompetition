package com.data;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.concurrent.ConcurrentHashMap;

public class WebPageCacheHelper
{
	private ConcurrentHashMap cacheData;
	private static int expiration=5000;
	/**
	 * 
	 * @param pool
	 */
	public WebPageCacheHelper(ConcurrentHashMap cache)
	{
		cacheData=cache;
	}
	/**
	 * 
	 * @param url
	 * @param args
	 * @return
	 */
	public String getWebPage(String url, ArrayList args)
	{
		String myReturn;
		Date now=new Date();
		if(cacheData.containsKey(url))
		{
			HashMap tmp=(HashMap)cacheData.get(url);
			if(tmp.containsKey(args))
			{
				ArrayList data=(ArrayList)tmp.get(args);
				Date webDate=(Date)data.get(0);
				if(now.getTime()-webDate.getTime()>expiration)
				{
					//System.out.println("expired");
					myReturn=getWebsiteData(url, args);
					data.set(0, now);
					data.set(1, myReturn);
					return myReturn;
				}
				else
				{
					//System.out.println("good to go");
					myReturn=(String)data.get(1);
					return myReturn;
				}
			}
			else
			{
				//System.out.println("arguments not detected");
				ArrayList data=new ArrayList();
				data.add(now);
				data.add(getWebsiteData(url, args));
				myReturn=(String)data.get(1);
				return myReturn;
			}
		}
		else
		{
			//System.out.println("url not detected");
			HashMap tmp=new HashMap();
			cacheData.put(url, tmp);
			ArrayList data=new ArrayList();
			tmp.put(args, data);
			data.add(now);
			data.add(getWebsiteData(url, args));
			myReturn=(String)data.get(1);
			return myReturn;
		}
	}
	/**
	 * 
	 * @param url
	 * @param args
	 * @return
	 */
	public String getWebsiteData(String url, ArrayList args)
	{
		String myReturn="";
		try
		{
			String arguments="";
		    for(int x=0; args!=null && x<args.size(); x++)
		    {
		    	ArrayList tmp=(ArrayList)args.get(x);
		    	if(x>0)
		    	{
		    		arguments+="&";
		    		arguments+=URLEncoder.encode((String)tmp.get(0), "UTF-8");
		    		arguments+="=";
		    		arguments+=URLEncoder.encode((String)tmp.get(1), "UTF-8");
		    	}
		    	else
		    	{
		    		arguments+="?";
		    		arguments+=URLEncoder.encode((String)tmp.get(0), "UTF-8");
		    		arguments+="=";
		    		arguments+=URLEncoder.encode((String)tmp.get(1), "UTF-8");
		    	}
		    }
			URL myURL=new URL(url+arguments);
			HttpURLConnection myConnection=(HttpURLConnection)myURL.openConnection();
			myConnection.setConnectTimeout(0);
			myConnection.setReadTimeout(0);
			myConnection.setChunkedStreamingMode(1024);
			myConnection.setRequestProperty("Accept-Charset", "UTF-8");
			myConnection.setRequestMethod("POST");
		    myConnection.setRequestProperty("Content-Type","application/x-www-form-urlencoded");
		    myConnection.setUseCaches(false);
		    myConnection.setDoInput(true);
		    myConnection.setDoOutput(true);
			myConnection.connect();
			InputStream myStream=myConnection.getInputStream();
			String buff="";
			BufferedReader myReader=new BufferedReader(new InputStreamReader(myStream));
			buff=myReader.readLine();
			while(buff!=null)
			{
				myReturn+="\n";
				myReturn+=buff;
				buff=myReader.readLine();
			}
			myStream.close();
		}
		catch(Exception e)
		{
			//e.printStackTrace();
		}
		return myReturn;
	}

}
