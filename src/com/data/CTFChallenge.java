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
 * Servlet implementation class CTFChallenge
 */
@WebServlet("/CTFChallenge.json")
public class CTFChallenge extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CTFChallenge() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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
		if(request.getParameter("email")!=null && request.getParameter("password")!=null)
		{
			System.out.println("Attempting sign in " + request.getParameter("email"));
			myUser=myConnector.signIn(request.getParameter("email"), request.getParameter("password"), request.getRemoteAddr());
			session.setAttribute("user", myUser);
		}
		
		String challengeName = request.getParameter("challenge");
		
		myUser=(User)session.getAttribute("user");
		
		if(myUser == null)
		{
			response.getWriter().append("{\n");
	        response.getWriter().append("\t\"status\": \"fail\"\n");
	        response.getWriter().append("}\n");
			return;
		}
		
		myConnector.syncChallenges("cgtboy1988@yahoo.com", myUser, request.getServletContext());
		
		ArrayList offLimits = new ArrayList();
		offLimits.add("seed");
		offLimits.add("originalFile");
		offLimits.add("num_iterations");
		offLimits.add("submittedWrittenFile");
		offLimits.add("submittedFile");
		offLimits.add("cachedOriginal");
		offLimits.add("obfuscatedFile");
		offLimits.add("cachedObfuscated");
		offLimits.add("randomSeed");
		offLimits.add("cachedGrading");
		offLimits.add("gradingFile");
		offLimits.add("participantSeed");
		
        DBObj myChallenge = myConnector.getCTFChallenge((String)myUser.getAttribute("email"), challengeName);
		
        response.getWriter().append("{\n");
        response.getWriter().append("\t\"" + challengeName + "\":\n");
        response.getWriter().append("\t{\n\t\t");
        ArrayList keys = myChallenge.getAttributeNames();
    	for(int y=0; y<keys.size(); y++)
    	{
			if(offLimits.contains(keys.get(y)))
			{
				keys.remove(y);
			}
    	}
    	for(int y=0; y<keys.size(); y++)
    	{
    		response.getWriter().append("\"" + keys.get(y) + "\":" + " \"" + myChallenge.getAttribute(keys.get(y)) + "\"");
    		if(y + 1 < keys.size())
    		{
    			response.getWriter().append(",\n\t\t");
    		}
    	}
        response.getWriter().append("\n\t}\n");
        response.getWriter().append("}");
		
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
