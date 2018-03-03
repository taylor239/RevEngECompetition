package com.data;

import java.io.ByteArrayOutputStream;
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
 * Servlet implementation class DownloadAllSubmissions
 */
@WebServlet({ "/DownloadAllSubmissions", "/downloadAll" })
public class DownloadAllSubmissions extends HttpServlet
{
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public DownloadAllSubmissions()
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
		
		//String studentEmail = (String)request.getParameter("email");
		
		boolean found = false;
		for(int x=0; x<challengeAssignment.size(); x++)
		{
			DBObj curObj = (DBObj) challengeAssignment.get(x);
			if(curObj.getAttribute("admin_email").equals(myUser.getAttribute("email")))
			{
				found = true;
				break;
			}
		}
		
		if(!found)
		{
			return;
		}
		
		ArrayList myChallengesFull = myConnector.getChallengeSubmissions((String)request.getParameter("challengeName"));
        //ArrayList myChallenges = new ArrayList();
        //myChallenges.add(myChallengesFull.get(0));
        //DBObj descriptor = (DBObj)myChallenges.get(0);
        //byte[] output=(byte[])descriptor.getAttribute("obfuscatedFile");
		//System.out.println(myChallengesFull);
		
		
        
		response.setHeader("Content-Disposition", "attachment;filename="+((String)request.getParameter("challengeName") + "_submissions" + ".zip").replaceAll("\\s+",""));
		//response.getWriter().append("Served at: ").append(request.getContextPath());
		ServletOutputStream out=response.getOutputStream();
		
		ZipOutputStream zipOut = new ZipOutputStream(out);
		Object previousID = "";
		
		
		for(int x=0; x<myChallengesFull.size(); x++)
		{
			DBObj submission = (DBObj) myChallengesFull.get(x);
			System.out.println(submission.getAttribute("email"));
			if(submission.getAttribute("email").equals(previousID))
			{
				continue;
			}
			
			
			previousID = submission.getAttribute("email");
			
			
			ByteArrayOutputStream byteOut = new ByteArrayOutputStream();
			ZipOutputStream nestedZipOut = new ZipOutputStream(byteOut);
			
			
			
			//System.out.println(submission.getAttributes());
			
			
			
			ZipEntry originalFile = new ZipEntry("original.c");
			nestedZipOut.putNextEntry(originalFile);
			byte[] originalOut = null;
			//(byte[])submission.getAttribute("originalFile");
			if(submission.getAttribute("originalFile") == null || submission.getAttribute("originalFile") instanceof String)
			{
				originalOut = new byte[0];
			}
			else
			{
				originalOut = (byte[])submission.getAttribute("originalFile");
			}
			nestedZipOut.write(originalOut);
			nestedZipOut.closeEntry();
			
			ZipEntry obfuscatedFile = new ZipEntry("obfuscated");
			nestedZipOut.putNextEntry(obfuscatedFile);
			byte[] obfuscatedOut = null;//(byte[])submission.getAttribute("obfuscatedFile");
			if(submission.getAttribute("obfuscatedFile") == null || submission.getAttribute("obfuscatedFile") instanceof String)
			{
				obfuscatedOut = new byte[0];
			}
			else
			{
				obfuscatedOut = (byte[])submission.getAttribute("obfuscatedFile");
			}
			nestedZipOut.write(obfuscatedOut);
			nestedZipOut.closeEntry();
			
			ZipEntry answerFile = new ZipEntry("answer");
			nestedZipOut.putNextEntry(answerFile);
			byte[] answerOut = null;//(byte[])submission.getAttribute("submittedFile");
			if(submission.getAttribute("submittedFile") == null || submission.getAttribute("submittedFile") instanceof String)
			{
				answerOut = new byte[0];
			}
			else
			{
				answerOut = (byte[])submission.getAttribute("submittedFile");
			}
			nestedZipOut.write(answerOut);
			nestedZipOut.closeEntry();
			
			ZipEntry writeupFile = new ZipEntry("writeup.txt");
			nestedZipOut.putNextEntry(writeupFile);
			byte[] writeupOut = null;//(byte[])submission.getAttribute("submittedWrittenFile");
			if(submission.getAttribute("submittedWrittenFile") == null || submission.getAttribute("submittedWrittenFile") instanceof String)
			{
				writeupOut = new byte[0];
			}
			else
			{
				writeupOut = (byte[])submission.getAttribute("submittedWrittenFile");
			}
			nestedZipOut.write(writeupOut);
			nestedZipOut.closeEntry();
			
			
			if((Boolean)submission.getAttribute("auto_grade"))
			{
				ZipEntry autoGrade = new ZipEntry("auto_grades.txt");
				nestedZipOut.putNextEntry(autoGrade);
				byte[] autoGradeData = null;
				String gradeOutput = "";
				
				if(submission.getAttribute("test_number") == null || submission.getAttribute("test_number").equals(""))
				{
					gradeOutput += "Not yet submitted";
				}
				else
				{
					gradeOutput += "Test Number: " + submission.getAttribute("test_number") + "\n";
					gradeOutput += "Passed: " + submission.getAttribute("iterations_passed") + "/" + submission.getAttribute("num_iterations") + "\n";
					if(submission.getAttribute("in_progress").equals(true))
					{
						gradeOutput += "Test still in progress";
					}
					else if(submission.getAttribute("iterations_passed").equals(submission.getAttribute("num_iterations")))
					{
						gradeOutput += "Test passed!\n";
					}
					else
					{
						gradeOutput += "Failed on: ";
						if(submission.getAttribute("correct").equals(false))
						{
							gradeOutput += "correctness";
							if(submission.getAttribute("performance").equals(false))
							{
								gradeOutput += " and performance";
							}
						}
						else if(submission.getAttribute("performance").equals(false))
						{
							gradeOutput += " performance";
						}
						gradeOutput += "\n";
					}
					
					for(int y = x + 1; y<myChallengesFull.size(); y++)
					{
						DBObj nextSubmission = (DBObj) myChallengesFull.get(y);
						if(!nextSubmission.getAttribute("email").equals(submission.getAttribute("email")))
						{
							//x = y;
							break;
						}
						
						
						gradeOutput += "Test Number: " + nextSubmission.getAttribute("test_number") + "\n";
						gradeOutput += "Passed: " + nextSubmission.getAttribute("iterations_passed") + "/" + nextSubmission.getAttribute("num_iterations") + "\n";
						if(nextSubmission.getAttribute("in_progress").equals(true))
						{
							gradeOutput += "Test still in progress";
						}
						else if(nextSubmission.getAttribute("iterations_passed").equals(nextSubmission.getAttribute("num_iterations")))
						{
							gradeOutput += "Test passed!\n";
						}
						else
						{
							gradeOutput += "Failed on: ";
							if(nextSubmission.getAttribute("correct").equals(false))
							{
								gradeOutput += "correctness";
								if(nextSubmission.getAttribute("performance").equals(false))
								{
									gradeOutput += " and performance";
								}
							}
							else if(nextSubmission.getAttribute("performance").equals(false))
							{
								gradeOutput += " performance";
							}
							gradeOutput += "\n";
						}
					}
				}
				
				//gradeOutput += "Validation Tests Passed:\n" + submission.getAttribute("auto_grade_score") + "\n";
				//gradeOutput += "Total Validation Tests:\n" + submission.getAttribute("num_grading_iterations");
				autoGradeData = gradeOutput.getBytes();
				
				nestedZipOut.write(autoGradeData);
				nestedZipOut.closeEntry();
			}
			
			nestedZipOut.close();
			byteOut.close();
			
			byte[] zipFileBytes = byteOut.toByteArray();
			ZipEntry overallEntry = new ZipEntry((String)submission.getAttribute("email") + ".zip");
			zipOut.putNextEntry(overallEntry);
			zipOut.write(zipFileBytes);
			zipOut.closeEntry();
		}
		
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