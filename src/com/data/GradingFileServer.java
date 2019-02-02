package com.data;

import java.io.IOException;
import java.util.ArrayList;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet implementation class ChallengeObfuscatedFileServer
 */
@WebServlet("/GradingFileServer")
public class GradingFileServer extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public GradingFileServer()
    {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		HttpSession session = request.getSession(true);
		TrafficAnalyzer accessor=TrafficAnalyzerPool.getAnalyzer();
		if(!accessor.allowImage(request.getRemoteAddr()+"image"))
		{
			return;
		}
		DatabaseInformationManager manager=DatabaseInformationManager.getInstance();
		ServletContext sc=getServletContext();
		String reportPath=sc.getRealPath("/WEB-INF/");
		reportPath+="/databases.xml";
		manager.addInfoFile(reportPath);
		DatabaseConnector myConnector=(DatabaseConnector)session.getAttribute("connector");
		if(myConnector==null)
		{
			myConnector=new DatabaseConnector("pillar");
			session.setAttribute("connector", myConnector);
		}
		User myUser=(User)session.getAttribute("user");
		
		boolean verbose=true;
		if(request.getParameter("email")!=null && request.getParameter("password")!=null)
		{
			if(verbose)
			{
				System.out.println("Signing in with ");
				System.out.println(request.getParameter("email"));
			}
			myUser=myConnector.signIn(request.getParameter("email"), request.getParameter("password"), request.getRemoteAddr());
		}
		if(verbose)
		{
			System.out.println("Signed in");
		}
		boolean hasUser=myUser!=null;
		if(hasUser)
		{
			/*
			myUser.changeAttribute("previousVisit", myUser.getAttribute("currentVisit"));
			myUser.changeAttribute("currentVisit", new java.sql.Timestamp(today.getTime()));
			myUser=myConnector.updateUser(myUser, myUser, request.getRemoteAddr(), request.getRequestURI());
			*/
			session.setAttribute("user", myUser);
			
		}
		if(verbose)
		{
			System.out.println("Done authenticating: " + hasUser);
		}
		
		
		
		
		
		ArrayList myChallengesFull = myConnector.getChallenge((String)request.getParameter("challengeName"), (String)myUser.getAttribute("email"));
        ArrayList myChallenges = new ArrayList();
        myChallenges.add(myChallengesFull.get(0));
        DBObj descriptor = (DBObj)myChallenges.get(0);
        System.out.println(descriptor.attributes.keySet());
        ServletOutputStream out=response.getOutputStream();
        if(descriptor.getAttribute("admin_email").equals(myUser.getAttribute("email")))
        {
        	byte[] output=(byte[])descriptor.getAttribute("gradingFile");
        
        	response.setHeader("Content-Disposition", "attachment;filename="+(String)request.getParameter("challengeName").replaceAll("\\s+",""));
			//response.getWriter().append("Served at: ").append(request.getContextPath());
			
			out.write(output);
        }
		out.close();
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
