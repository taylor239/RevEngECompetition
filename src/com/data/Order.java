package com.data;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

public class Order extends DBObj
{
	private int itemNumber=-1;
	private ConcurrentHashMap numberMap;
	private ConcurrentHashMap reverseNumberMap;

	/**
	 * 
	 * @param attribs
	 * @param newObj
	 * @param tables
	 */
	public Order(String user)
	{
		super();
		table.add("order");
		changeAttribute("user", user);
		numberMap=new ConcurrentHashMap();
		reverseNumberMap=new ConcurrentHashMap();
	}
	
	/**
	 * 
	 * @param institution
	 * @param amount
	 */
	public void addItem(ConcurrentHashMap key, double amount)
	{
		DBObj tmpMap=(DBObj)getAttribute(key);
		if(tmpMap==null)
		{
			itemNumber++;
			changeAttribute("numberitems", itemNumber);
			numberMap.put(itemNumber, key);
			reverseNumberMap.put(key, itemNumber);
			ConcurrentHashMap itemMap=new ConcurrentHashMap();
			itemMap.putAll(key);
			ArrayList tables=new ArrayList();
			tables.add("orderitem");
			tmpMap=new DBObj(itemMap, true, tables);
		}
		else
		{
			amount+=(double)tmpMap.getAttribute("amount");
		}
		tmpMap.changeAttribute("amount", amount);
		changeAttribute(key, tmpMap);
	}
	
	/**
	 * 
	 * @param institution
	 * @param amount
	 */
	public void addItem(ConcurrentHashMap key, double amount, double quantity, String item)
	{
		DBObj tmpMap=(DBObj)getAttribute(key);
		if(tmpMap==null)
		{
			itemNumber++;
			changeAttribute("numberitems", itemNumber);
			numberMap.put(itemNumber, key);
			reverseNumberMap.put(key, itemNumber);
			ConcurrentHashMap itemMap=new ConcurrentHashMap();
			itemMap.putAll(key);
			ArrayList tables=new ArrayList();
			tables.add("orderitem");
			tmpMap=new DBObj(itemMap, true, tables);
		}
		else
		{
			quantity+=(double)tmpMap.getAttribute("quantity");
			amount+=(double)tmpMap.getAttribute("amount");
		}
		tmpMap.changeAttribute("amount", amount);
		tmpMap.changeAttribute("quantity", quantity);
		tmpMap.changeAttribute("item", item);
		changeAttribute(key, tmpMap);
	}
	
	/**
	 * 
	 * @param key
	 */
	public void removeItem(ConcurrentHashMap key)
	{
		attributeChanges.remove(key);
		int oldNumber=(int) reverseNumberMap.get(key);
		for(int x=oldNumber; x<itemNumber; x++)
		{
			Object tmp=numberMap.get(x+1);
			reverseNumberMap.put(tmp, x);
			numberMap.put(x, tmp);
		}
		numberMap.remove(itemNumber);
		itemNumber--;
	}
	
	/**
	 * 
	 * @param key
	 * @param attribute
	 */
	public void addAttributeToChildren(Object key, Object attribute)
	{
		for(int x=0; x<itemNumber; x++)
		{
			((DBObj)getAttribute(numberMap.get(x))).changeAttribute(key, attribute);
		}
	}
	
	/**
	 * 
	 * @return
	 */
	public ArrayList toArray()
	{
		ArrayList myReturn=new ArrayList();
		for(int x=0; x<=itemNumber; x++)
		{
			myReturn.add(getAttribute(numberMap.get(x)));
		}
		return myReturn;
	}
	
	/**
	 * 
	 * @return
	 */
	public double sum()
	{
		double myReturn=0;
		for(int x=0; x<=itemNumber; x++)
		{
			DBObj tmpObject=(DBObj) getAttribute(numberMap.get(x));
			Double tmpQuantity=(Double) tmpObject.getAttribute("quantity");
			double tmpAmount=(double) tmpObject.getAttribute("amount");
			if(tmpQuantity!=null)
			{
				myReturn+=tmpQuantity*tmpAmount;
			}
			else
			{
				myReturn+=tmpAmount;
			}
		}
		return myReturn;
	}
	
}
