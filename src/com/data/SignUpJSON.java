package com.data;

import java.io.IOException;
import java.util.ArrayList;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet implementation class Authenticate
 */
@WebServlet("/SignUpJSON.json")
public class SignUpJSON extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public SignUpJSON() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		EmailSender mySender = EmailSender.getEmailSender("revenge@cs.arizona.edu");
		
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
			try {
				myConnector.connect();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			session.setAttribute("connector", myConnector);
		}
		
		User myUser = null;
		System.out.println("Looking for user params");
		if(request.getParameter("email")!=null && request.getParameter("fname")!=null && request.getParameter("lname")!=null && request.getParameter("password")!=null)
		{
			System.out.println("Attempting sign in " + request.getParameter("email"));
			myConnector.writeUser(request.getParameter("email"), request.getParameter("email"), request.getParameter("fname"), "", request.getParameter("lname"), request.getParameter("password"), "student", "cgtboy1988@yahoo.com", "competition");
			myUser=myConnector.signIn(request.getParameter("email"), request.getParameter("password"), request.getRemoteAddr());
			session.setAttribute("user", myUser);
		}
		
		myUser=(User)session.getAttribute("user");
		
		if(myUser == null)
		{
			response.getWriter().append("{\n");
	        response.getWriter().append("\t\"status\": \"fail\"\n");
	        response.getWriter().append("}\n");
		}
		else
		{
			ArrayList allChallenges = myConnector.getAdminChallenges("cgtboy1988@yahoo.com");
			for(int x=0; x<allChallenges.size(); x++)
			{
				DBObj curObj = (DBObj)allChallenges.get(x);
				String curName = (String)curObj.getAttribute("challenge_name");
				myConnector.assignChallenge(curName, request.getParameter("email"));
			}
			mySender.sendEmail(request.getParameter("email"), "Welcome to RevEngE!", "You have signed up for RevEngE---thank you for your participation!  Your username is " + request.getParameter("email") + ".");
			response.getWriter().append("{\n");
	        response.getWriter().append("\t\"status\": \"success\"\n");
	        response.getWriter().append("}\n");
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
