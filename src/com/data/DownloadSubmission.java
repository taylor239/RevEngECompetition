package com.data;

import java.io.IOException;
import java.util.ArrayList;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet implementation class DownloadSubmission
 */
@WebServlet({ "/DownloadSubmission", "/downloadSubmission" })
public class DownloadSubmission extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public DownloadSubmission()
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
		
		ArrayList challengeAssignment = myConnector.getChallengeAssignment((String)myUser.getAttribute("email"), (String)request.getParameter("challengeName"));
		
		String studentEmail = (String)request.getParameter("email");
		
		boolean found = false;
		for(int x=0; x<challengeAssignment.size(); x++)
		{
			DBObj curObj = (DBObj) challengeAssignment.get(x);
			if(curObj.getAttribute("email").equals(studentEmail))
			{
				found = true;
				break;
			}
		}
		
		if(!found)
		{
			return;
		}
		
		ArrayList myChallengesFull = myConnector.getChallengeSubmission((String)request.getParameter("challengeName"), studentEmail);
        //ArrayList myChallenges = new ArrayList();
        //myChallenges.add(myChallengesFull.get(0));
        //DBObj descriptor = (DBObj)myChallenges.get(0);
        //byte[] output=(byte[])descriptor.getAttribute("obfuscatedFile");
		//System.out.println(myChallengesFull);
		DBObj submission = (DBObj) myChallengesFull.get(0);
		
        
		response.setHeader("Content-Disposition", "attachment;filename="+((String)request.getParameter("challengeName") + "_" + (String)request.getParameter("email") + ".zip").replaceAll("\\s+",""));
		//response.getWriter().append("Served at: ").append(request.getContextPath());
		ServletOutputStream out=response.getOutputStream();
		
		ZipOutputStream zipOut = new ZipOutputStream(out);
		
		if((Boolean)submission.getAttribute("auto_grade"))
		{
			ZipEntry autoGrade = new ZipEntry("auto_grades.txt");
			zipOut.putNextEntry(autoGrade);
			byte[] autoGradeData = null;
			String gradeOutput = "";
			gradeOutput += "Validation Tests Passed:\n" + submission.getAttribute("auto_grade_score") + "\n";
			gradeOutput += "Total Validation Tests:\n" + submission.getAttribute("num_grading_iterations");
			autoGradeData = gradeOutput.getBytes();
			
			zipOut.write(autoGradeData);
			zipOut.closeEntry();
		}
		
		ZipEntry originalFile = new ZipEntry("original.c");
		zipOut.putNextEntry(originalFile);
		byte[] originalOut=null;
		if(submission.getAttribute("originalFile") == null || submission.getAttribute("originalFile") instanceof String)
		{
			originalOut = new byte[0];
		}
		else
		{
			originalOut = (byte[])submission.getAttribute("originalFile");
		}
		//(byte[])submission.getAttribute("originalFile");
		zipOut.write(originalOut);
		zipOut.closeEntry();
		
		ZipEntry obfuscatedFile = new ZipEntry("obfuscated");
		zipOut.putNextEntry(obfuscatedFile);
		byte[] obfuscatedOut=null;//(byte[])submission.getAttribute("obfuscatedFile");
		if(submission.getAttribute("obfuscatedFile") == null || submission.getAttribute("obfuscatedFile") instanceof String)
		{
			obfuscatedOut = new byte[0];
		}
		else
		{
			obfuscatedOut = (byte[])submission.getAttribute("obfuscatedFile");
		}
		zipOut.write(obfuscatedOut);
		zipOut.closeEntry();
		
		ZipEntry answerFile = new ZipEntry("answer");
		zipOut.putNextEntry(answerFile);
		byte[] answerOut=null;//(byte[])submission.getAttribute("submittedFile");
		if(submission.getAttribute("submittedFile") == null || submission.getAttribute("submittedFile") instanceof String)
		{
			answerOut = new byte[0];
		}
		else
		{
			answerOut = (byte[])submission.getAttribute("submittedFile");
		}
		zipOut.write(answerOut);
		zipOut.closeEntry();
		
		ZipEntry writeupFile = new ZipEntry("writeup.txt");
		zipOut.putNextEntry(writeupFile);
		byte[] writeupOut=null;//(byte[])submission.getAttribute("submittedWrittenFile");
		if(submission.getAttribute("submittedWrittenFile") == null || submission.getAttribute("submittedWrittenFile") instanceof String)
		{
			writeupOut = new byte[0];
		}
		else
		{
			writeupOut = (byte[])submission.getAttribute("submittedWrittenFile");
		}
		zipOut.write(writeupOut);
		zipOut.closeEntry();
		
		zipOut.close();
		//out.write(output);
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
