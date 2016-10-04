package com.data;

import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;

public class Permission extends DBObj
{
	/**
	 * 
	 * @param attribs
	 * @param newObj
	 */
	public Permission(ConcurrentHashMap attribs, boolean newObj, ArrayList table)
	{
		super(attribs, newObj, table);
	}
	
}
