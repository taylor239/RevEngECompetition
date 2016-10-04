package com.data;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

public class DBObj
{
	/**
	 * 
	 */
	protected ArrayList table;
	/**
	 * 
	 */
	protected ConcurrentHashMap attributes;
	/**
	 * 
	 */
	protected ConcurrentHashMap attributeChanges;
	/**
	 * 
	 */
	protected boolean written;
	/**
	 * 
	 * @param attribs
	 * @param newRole
	 */
	public DBObj(ConcurrentHashMap attribs, boolean newObj, ArrayList tables)
	{
		table=tables;
		if(!newObj)
		{
			attributes=attribs;
			attributeChanges=new ConcurrentHashMap();
			written=true;
		}
		else
		{
			attributes=new ConcurrentHashMap();
			attributeChanges=attribs;
			attributeChanges.put("salt", UUID.randomUUID().toString());
			written=false;
		}
	}
	
	protected DBObj()
	{
		attributes=new ConcurrentHashMap();
		attributeChanges=new ConcurrentHashMap();
		written=false;
		table=new ArrayList();
	}
	/**
	 * 
	 * @param newTable
	 */
	public void setTable(ArrayList newTable)
	{
		table=newTable;
	}
	/**
	 * 
	 * @return
	 */
	public ArrayList getTable()
	{
		return table;
	}
	/**
	 * 
	 * @return
	 */
	public ConcurrentHashMap getAttributes()
	{
		return attributes;
	}
	/**
	 * 
	 * @return
	 */
	public ArrayList getAttributeNames()
	{
		Set mySet=attributes.keySet();
		ArrayList myReturn = new ArrayList();
		myReturn.addAll(mySet);
		return myReturn;
	}
	/**
	 * 
	 * @return
	 */
	public ConcurrentHashMap getAttributeChanges()
	{
		return attributeChanges;
	}
	/**
	 * 
	 * @param key
	 * @return
	 */
	public boolean containsKey(Object key)
	{
		return attributes.containsKey(key) | attributeChanges.containsKey(key);
	}
	/**
	 * 
	 * @param key
	 * @return
	 */
	public Object getAttribute(Object key)
	{
		if(attributeChanges.containsKey(key))
		{
			return attributeChanges.get(key);
		}
		else
		{
			return attributes.get(key);
		}
	}
	/**
	 * 
	 * @param key
	 * @param value
	 */
	public synchronized void changeAttribute(Object key, Object value)
	{
		written=false;
		if(key.equals("password"))
		{
			attributeChanges.put("salt", UUID.randomUUID().toString());
		}
		attributeChanges.put(key, value);
	}
	/**
	 * 
	 * @return
	 */
	public boolean getWritten()
	{
		return written;
	}
	/**
	 * 
	 * @param write
	 */
	public synchronized void setWritten(boolean write)
	{
		written=write;
		if(write)
		{
			Iterator myIter=attributeChanges.keySet().iterator();
			while(myIter.hasNext())
			{
				Object key=myIter.next();
				if(!key.equals("password") && !key.equals("salt"))
				{
					Object tmp=attributeChanges.get(key);
					attributes.put(key, tmp);
				}
			}
			attributeChanges=new ConcurrentHashMap();
		}
	}
}
