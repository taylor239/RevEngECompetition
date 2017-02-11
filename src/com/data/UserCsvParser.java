package com.data;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;
import java.util.UUID;

public class UserCsvParser
{
	public HashMap userMap;
	public ArrayList emailList;
	
	public static void main(String[] args) throws IOException
	{
		DatabaseInformationManager.getInstance().addInfoFile("/home/ubuntu/workspace/ObfuscationChallenge/WebContent/WEB-INF/databases.xml");
		System.out.println(DatabaseInformationManager.getInstance().getConnectionInfo());
		DatabaseConnector myConnector=new DatabaseConnector("pillar");
		
		String fileName = "/home/ubuntu/Desktop/CSC466S16 classlist-Sheet3.csv";
		byte[] encoded = Files.readAllBytes(Paths.get(fileName));
		String contents = new String(encoded);
		UserCsvParser myParser=new UserCsvParser(contents);
		
		myConnector.writeCsvUsers(myParser);
	}
	
	public UserCsvParser(String csv)
	{
		userMap=new HashMap();
		emailList=new ArrayList();
		String lines[] = csv.split("\\r?\\n");
		Random myRandom=new Random();
		for(int x=0; x<lines.length; x++)
		{
			String curLine=lines[x];
			String[] entries=curLine.replace("\"", "").split(",");
			entries[1]=entries[1].substring(1);
			HashMap paramMap=new HashMap();
			paramMap.put("fname", entries[1]);
			paramMap.put("lname", entries[0]);
			paramMap.put("mname", "");
			paramMap.put("email", entries[2]);
			paramMap.put("password", myRandom.nextInt(10000000));
			paramMap.put("salt", UUID.randomUUID());
			userMap.put(entries[2], paramMap);
			emailList.add(entries[2]);
		}
		/*for(int x=0; x<emailList.size(); x++)
		{
			HashMap tmp=(HashMap) userMap.get(emailList.get(x));
			System.out.println(tmp.get("fname")+", "+tmp.get("lname")+", "+tmp.get("email")+", "+tmp.get("password"));
		}*/
	}

}
