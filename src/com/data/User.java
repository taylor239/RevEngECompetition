package com.data;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

public class User extends DBObj
{
	/**
	 * 
	 * @param attribs
	 * @param newObj
	 */
	public User(ConcurrentHashMap attribs, boolean newObj, ArrayList tables)
	{
		super(attribs, newObj, tables);
	}
	/**
	 * 
	 */
	private Role currentRole;
	/**
	 * 
	 * @param toSet
	 */
	public synchronized void setCurRole(Role toSet)
	{
		ArrayList tmp=(ArrayList)attributes.get("roles");
		if(tmp.contains(toSet))
		{
			currentRole=toSet;
		}
	}
	/**
	 * 
	 * @return
	 */
	public Role getCurRole()
	{
		return currentRole;
	}
	/**
	 * 
	 * @param role
	 * @param institution
	 * @return
	 */
	public synchronized Role getRole(String role, String institution)
	{
		ArrayList tmp=(ArrayList) getAttribute("roles");
		Role tmpRole=null;
		for(int x=0; x<tmp.size(); x++)
		{
			tmpRole=(Role)tmp.get(x);
			if(tmpRole.getAttribute("role").equals(role) && tmpRole.getAttribute("institution").equals(institution))
			{
				return tmpRole;
			}
		}
		return null;
	}
}
