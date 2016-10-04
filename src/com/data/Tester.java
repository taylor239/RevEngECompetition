package com.data;


import java.io.File;
import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;


public class Tester
{

	/**
	 * @param args
	 */
	public static void main(String[] args)
	{
		DatabaseInformationManager.getInstance().addInfoFile("H:\\xampp\\tomcat\\webapps\\Campus-Key\\WEB-INF\\databases.xml");
		System.out.println(DatabaseInformationManager.getInstance().getConnectionInfo());
		DatabaseConnector myConnector=new DatabaseConnector("pillar");
		try
		{
			//User tmp=myConnector.signIn("cgtboy1988@yahoo.com", "password");
			//System.out.println(tmp.getAttributes());
			//ArrayList tmpList=(ArrayList)tmp.getAttribute("roles");
			//for(int x=0; x<tmpList.size(); x++)
			//{
			//	System.out.println(((Role)tmpList.get(x)).getAttributes());
			//}
			//ConcurrentHashMap passMap=new ConcurrentHashMap();
			//ConcurrentHashMap systemUserHashMap=new ConcurrentHashMap();
			//systemUserHashMap.put("systemuser", "password");
			//passMap.put("systemuser", systemUserHashMap);
			//tmp=myConnector.authenticateRole(tmp, tmp.getRole("systemuser", "Campus-Key Administration"), passMap);
			//tmp.changeAttribute("fname", "Clark");
			//myConnector.updateUser(tmp, tmp, "", "");
			//System.out.println(tmp.getAttributes());
			//tmpList=(ArrayList)tmp.getAttribute("roles");
			//for(int x=0; x<tmpList.size(); x++)
			//{
			//	System.out.println(((Role)tmpList.get(x)).getAttributes());
			//}
			//ConcurrentHashMap roleList=myConnector.getRoleParameters("systemuser");
			//System.out.println(roleList);
			System.out.println(myConnector.getSuperRoleNames("systemuser"));
			System.out.println(myConnector.getOwnerInstitutionNames("California Department of Education"));
			//ConcurrentHashMap passMap=new ConcurrentHashMap();
			//ConcurrentHashMap systemUserHashMap=new ConcurrentHashMap();
			//systemUserHashMap.put("systemuser", "password");
			//passMap.put("systemuser", systemUserHashMap);
			//tmp=myConnector.authenticateRole(tmp, tmp.getRole("systemuser", "Campus-Key Administration"), passMap);
			//System.out.println(tmp.getAttributes());
			//tmpList=(ArrayList)tmp.getAttribute("roles");
			//for(int x=0; x<tmpList.size(); x++)
			//{
			//	System.out.println(((Role)tmpList.get(x)).getAttributes());
			//}
			//System.out.println(tmp.getCurRole().getAttributes());
			//System.out.println(tmp.getCurRole()==tmp.getRole("systemuser", "Campus-Key Administration"));
			//System.out.println("stuff");
			//System.out.println(myConnector.getColumnNames("user"));
			//File tmp=new File("C:\\xampp\\tomcat\\webapps\\TaylorWiley\\industrialphoto.jpg");
			//FileInputStream myStream=new FileInputStream(tmp);
			//byte[]data=new byte[myStream.available()];
			//myStream.read(data);
			//System.out.println(tmp.exists());
			//System.out.println(myConnector.setProjectImage("Industrial Projects", data, "industrialphoto.jpg"));
			
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		
	}

}
