package com.data;

import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;

public class Role extends DBObj
{
	/**
	 * 
	 * @param attribs
	 * @param newObj
	 */
	public Role(ConcurrentHashMap attribs, boolean newObj, ArrayList table)
	{
		super(attribs, newObj, table);
	}
	
}
