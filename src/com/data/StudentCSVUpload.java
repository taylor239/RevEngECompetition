package com.data;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Scanner;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

/**
 * Servlet implementation class StudentCSVUpload
 */
@WebServlet("/StudentCSVUpload")
@MultipartConfig(fileSizeThreshold=1024*1024*2, // 2MB
					maxFileSize=1024*1024*10,      // 10MB
					maxRequestSize=1024*1024*50)   // 50MB
public class StudentCSVUpload extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public StudentCSVUpload() {
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
		
		if(myUser == null || !(myUser.getAttribute("role").equals("admin")))
		{
			request.getRequestDispatcher("index.jsp").forward(request, response);
			return;
		}
		
		
		String challengeName = (request.getParameter("challengeName"));
		String courseName = (request.getParameter("courseName"));
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
		
		byte[] csvFileData = (byte[])dataMap.get("csvFile");
		String csvString = new String(csvFileData);
		UserCsvParser myParser = new UserCsvParser(csvString);
		ArrayList finalList = new ArrayList();
		for(int x=0; x<myParser.emailList.size(); x++)
		{
			HashMap tmp=(HashMap) myParser.userMap.get(myParser.emailList.get(x));
			String password = UUID.randomUUID().toString();
			tmp.put("password", password);
			
			myConnector.writeUser((String)tmp.get("email"), (String)tmp.get("email"), (String)tmp.get("fname"), "", (String)tmp.get("lname"), password, "student", (String)myUser.getAttribute("email"), courseName);
			
			finalList.add(tmp);
		}
		
		request.setAttribute("studentsAdded", finalList);
		
		request.getRequestDispatcher("postCsvUpload.jsp").forward(request, response);
		//Scanner myScanner = new Scanner(csvString);
		//while(myScanner.hasNextLine())
		//{
		//	String curLine = myScanner.nextLine();
		//	System.out.println(curLine);
		//}
		//System.out.println(csvString);
		//myConnector.challengeParticipantCodeSubmitted(challengeName, (String)myUser.getAttribute("email"), (byte[])dataMap.get("writeFile"), (byte[])dataMap.get("codeFile"));
		//response.getWriter().append("Served at: ").append(request.getContextPath());
		//response.sendRedirect("viewChallenge.jsp?challengeName="+challengeName);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
