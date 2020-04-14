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
 * Servlet implementation class UpcomingCTFs
 */
@WebServlet("/UpcomingCTFs.json")
public class UpcomingCTFs extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public UpcomingCTFs() {
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
		
		//User myUser = null;
		//System.out.println("Looking for user params");
		//if(request.getParameter("email")!=null && request.getParameter("password")!=null)
		//{
		//	System.out.println("Attempting sign in " + request.getParameter("email"));
		//	myUser=myConnector.signIn(request.getParameter("email"), request.getParameter("password"), request.getRemoteAddr());
		//	session.setAttribute("user", myUser);
		//}
		
		//myUser=(User)session.getAttribute("user");
		
		//if(myUser == null)
		//{
		//	response.getWriter().append("{\n");
	    //    response.getWriter().append("\t\"status\": \"fail\"\n");
	    //    response.getWriter().append("}\n");
		//	return;
		//}
		
		//myConnector.syncChallenges("cgtboy1988@yahoo.com", myUser, request.getServletContext());
		
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
		
        ArrayList myChallenges = myConnector.getUpcomingCTFs();
		
        response.getWriter().append("{\n");
        response.getWriter().append("\t\"challengeList\":\n");
        response.getWriter().append("\t{\n");
        for(int x=0; x<myChallenges.size(); x++)
        {
        	response.getWriter().append("\t\t");
        	DBObj curChallenge = (DBObj) myChallenges.get(x);
        	String ctfName = (String) curChallenge.getAttribute("ctf_name");
        	response.getWriter().append("\"" + ctfName + "\": {");
        	ArrayList keys = curChallenge.getAttributeNames();
        	for(int y=0; y<keys.size(); y++)
        	{
				if(offLimits.contains(keys.get(y)))
				{
					keys.remove(y);
				}
        	}
        	for(int y=0; y<keys.size(); y++)
        	{
        		response.getWriter().append("\"" + keys.get(y) + "\":" + " \"" + curChallenge.getAttribute(keys.get(y)) + "\"");
        		if(y + 1 < keys.size())
        		{
        			response.getWriter().append(", ");
        		}
        	}
        	response.getWriter().append("}");
        	if(x + 1 < myChallenges.size())
        	{
        		response.getWriter().append(",");
        	}
        	response.getWriter().append("\n");
        }
        response.getWriter().append("\t}\n");
        response.getWriter().append("}");
		//response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
