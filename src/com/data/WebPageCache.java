package com.data;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.concurrent.ConcurrentHashMap;

public class WebPageCache
{
	private static ConcurrentHashMap cacheData;
	private static int expiration=2500;
	private static WebPageCacheHelperPool myPool;
	/**
	 * 
	 * @param url
	 * @param args
	 * @return
	 */
	public static String getWebPage(String url, ArrayList args)
	{
		if(cacheData==null)
		{
			cacheData=new ConcurrentHashMap();
		}
		WebPageCacheHelper tmp=new WebPageCacheHelper(cacheData);
		String myReturn=tmp.getWebPage(url, args);
		return myReturn;
	}
}
