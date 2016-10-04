package com.data;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;


public class ProfileImageServlet extends HttpServlet
{
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException
	{
		HttpSession session = request.getSession(true);
		TrafficAnalyzer accessor=TrafficAnalyzerPool.getAnalyzer();
		if(!accessor.allowImage(request.getRemoteAddr()+"image"))
		{
			return;
		}
		DatabaseConnector myConnector=(DatabaseConnector)session.getAttribute("connector");
		if(myConnector==null)
		{
			myConnector=new DatabaseConnector("pillar");
			session.setAttribute("connector", myConnector);
		}
		String user=request.getParameter("username");
		//String user="jstaylor7@sbcglobal.net";
		ImageDataHolder toSend=myConnector.getProfileImage(user);
		String ext="";
		String tmp=toSend.getName();
		for(int x=tmp.length()-1; x>0; x--)
		{
			if(tmp.charAt(x)=='.')
			{
				break;
			}
			else
			{
				ext=tmp.charAt(x)+ext;
			}
			if(x==1 && tmp.charAt(x)!='.')
			{
				ext="";
			}
		}
		if(!ext.equals(""))
		{
			ext="/"+ext;
		}
		response.setContentType("image"+ext);
		ServletOutputStream out=response.getOutputStream();
		out.write(toSend.getData());
		out.close();
	}
}
