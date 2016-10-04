package com.data;

import java.io.IOException;
import java.util.ArrayList;

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
@WebServlet("/ChallengeObfuscatedFileServer")
public class ChallengeObfuscatedFileServer extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ChallengeObfuscatedFileServer()
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
		DatabaseConnector myConnector=(DatabaseConnector)session.getAttribute("connector");
		if(myConnector==null)
		{
			myConnector=new DatabaseConnector("pillar");
			session.setAttribute("connector", myConnector);
		}
		User myUser=(User)session.getAttribute("user");
		ArrayList myChallengesFull = myConnector.getChallenge((String)request.getParameter("challengeName"), (String)myUser.getAttribute("email"));
        ArrayList myChallenges = new ArrayList();
        myChallenges.add(myChallengesFull.get(0));
        DBObj descriptor = (DBObj)myChallenges.get(0);
        byte[] output=(byte[])descriptor.getAttribute("obfuscatedFile");
        
		response.setHeader("Content-Disposition", "attachment;filename="+(String)request.getParameter("challengeName"));
		//response.getWriter().append("Served at: ").append(request.getContextPath());
		ServletOutputStream out=response.getOutputStream();
		out.write(output);
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
