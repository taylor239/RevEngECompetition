package com.data;

import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;


public class Institution extends DBObj
{
	/**
	 * 
	 * @param attribs
	 * @param newRole
	 */
	public Institution(ConcurrentHashMap attribs, boolean newObj, ArrayList table)
	{
		super(attribs, newObj, table);
	}
	
}
