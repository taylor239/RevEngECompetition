package com.data;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

public class GoogleMapPrinter
{
	public String printMap(String height, String width, String key, String street, String city, String province, String postal, String country)
	{
		String myReturn="";
		String formedAddress=street+" "+city+" "+province+" "+postal+" "+country;
		String source="https://www.google.com/maps/embed/v1/place?";
		
		
		myReturn+="<iframe width=\""+width+"\" height=\""+height+"\" frameborder=\"0\" style=\"border:0\" src=\""+source;
		try
		{
			myReturn+="key="+key+"&q="+formedAddress+"\""+URLEncoder.encode(formedAddress, "UTF-8")+"\"></iframe>";
		}
		catch (UnsupportedEncodingException e)
		{
			return "";
		}
		return myReturn;
	}
}
