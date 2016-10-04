package com.data;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

/**
 * Servlet implementation class ChallengeDeobfuscatedSubmissionServlet
 */
@WebServlet("/ChallengeDeobfuscatedSubmissionServlet")
@MultipartConfig(fileSizeThreshold=1024*1024*2, // 2MB
					maxFileSize=1024*1024*10,      // 10MB
					maxRequestSize=1024*1024*50)   // 50MB
public class ChallengeDeobfuscatedSubmissionServlet extends HttpServlet
{
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ChallengeDeobfuscatedSubmissionServlet()
    {
        super();
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
		
		
		String challengeName = (request.getParameter("challengeName"));
		//if(ServletFileUpload.isMultipartContent(request))
		HashMap dataMap = new HashMap();
		{
			for(Part part : request.getParts())
			{
				String name = part.getName();
				System.out.println(name);
				System.out.println(part.getContentType());
				InputStream partData = part.getInputStream();
				byte[] fileBytes = new byte[(int) part.getSize()];
				int bytesRead=0;
				while(bytesRead < fileBytes.length)
				{
					int remaining = fileBytes.length - bytesRead;
					int tmpBytesRead = partData.read(fileBytes, bytesRead, remaining);
					if(tmpBytesRead > 0)
	        		{
	        			bytesRead = bytesRead + tmpBytesRead;
	        		}
				}
				dataMap.put(name, fileBytes);
			}
		}
		
		myConnector.challengeParticipantCodeSubmitted(challengeName, (String)myUser.getAttribute("email"), (byte[])dataMap.get("writeFile"), (byte[])dataMap.get("codeFile"));
		//response.getWriter().append("Served at: ").append(request.getContextPath());
		response.sendRedirect("viewChallenge.jsp?challengeName="+challengeName);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		doGet(request, response);
	}

}
