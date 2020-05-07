package com.data;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Scanner;
import java.util.Set;

import javax.servlet.ServletContext;
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
import org.apache.commons.io.FileUtils;

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
		if(request.getParameter("email")!=null && request.getParameter("password")!=null)
		{
			System.out.println("Attempting sign in " + request.getParameter("email"));
			myUser=myConnector.signIn(request.getParameter("email"), request.getParameter("password"), request.getRemoteAddr());
			session.setAttribute("user", myUser);
		}
		
		myUser=(User)session.getAttribute("user");
		
		
		String challengeName = (request.getParameter("challengeName"));
		
		String redirectTo = (request.getParameter("redirect"));
		
		String uploadData = "no";
		if(request.getParameterMap().containsKey("uploadData"))
		{
			uploadData = request.getParameter("uploadData");
		}
		
		boolean uploadDataBool = !uploadData.equals("no");
		
		System.out.println(uploadData);
		
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
		
		ArrayList curChallenge = myConnector.getChallenge(challengeName, (String)myUser.getAttribute("email"));
		DBObj topChallenge = (DBObj)curChallenge.get(0);
		String toEmail = "Your submission for " + challengeName + " was received on " + topChallenge.getAttribute("submissionTime") + ".  Your submission output is as follows:\n";
		//System.out.println(((DBObj)curChallenge.get(0)).getAttributes());
		myConnector.removeChallengeParticipantTests(challengeName, (String)myUser.getAttribute("email"));
		
		//Send redirect here, because grading takes a while.
		
		
		if((boolean) ((DBObj)curChallenge.get(0)).getAttribute("auto_grade"))
		{
			PrintWriter redirectWriter = response.getWriter();
			
			request.getRequestDispatcher("./gradeWaiting.jsp").include(request, response);
			
			redirectWriter.flush();
			response.flushBuffer();
			ArrayList gradeChallenge = myConnector.getChallengeAutoGrade(challengeName);
			//System.out.println(((DBObj)gradeChallenge.get(0)).getAttributes());
			ServerManager nativeInterface = ServerManager.getInstance();
			//ServletContext sc=getServletContext();
			try
			{
				byte[] challengeMD5Bytes=challengeName.getBytes();
		        String challengeMD5="problem";
		        MessageDigest m = MessageDigest.getInstance("MD5");
		        m.reset();
		        m.update(challengeMD5Bytes);
		        byte[] digest = m.digest();
		        java.math.BigInteger bigInt = new java.math.BigInteger(1, digest);
		        challengeMD5 = bigInt.toString(16);
		        
		        String outputDir = myUser.getAttribute("email")+"/"+challengeMD5+"/";
		        String prevFile = "empty.c";
		        File emptyFile = new File(sc.getRealPath("/WEB-INF/generated_code/")+"/"+outputDir+prevFile);
		        emptyFile.getParentFile().mkdirs();
		        emptyFile.createNewFile();
		        File tmpFile = new File(sc.getRealPath("/WEB-INF/local_bin/tigress/"));
	        	File genDir = new File(sc.getRealPath("/WEB-INF/generated_code/"+outputDir));
	        	
	        	Map<String, String> env = System.getenv();
	        	String[] environmentalVars = new String[env.keySet().size()+2];
	        	boolean hasPath=false;
	        	int envNum=0;
	        	for(String envName : env.keySet())
	        	{
	        		////System.out.println(envName+"="+env.get(envName));
	        		String varVal=env.get(envName);
	        		if(envName.equals("PATH"))
	        		{
	        			hasPath=true;
	        			environmentalVars[envNum]=envName+"="+env.get(envName)+":"+tmpFile.getAbsolutePath();
	        			envNum++;
	        		}
	        		else
	        		{
	        			environmentalVars[envNum]=envName+"="+env.get(envName);
	        			envNum++;
	        		}
	        	}
	        	environmentalVars[envNum]="TIGRESS_HOME="+tmpFile.getAbsolutePath();
	        	envNum++;
	        	if(!hasPath)
	        	{
	        		environmentalVars[envNum]="PATH="+tmpFile.getAbsolutePath();
	        		envNum++;
	        	}
	        	else
	        	{
	        		String[] tmp=new String[environmentalVars.length-1];
	        		for(int z=0; z<tmp.length; z++)
	        		{
	        			tmp[z]=environmentalVars[z];
	        		}
	        		environmentalVars=tmp;
	        	}
	        	if((byte[])((DBObj)curChallenge.get(0)).getAttribute("gradingFile") != null && ((byte[])((DBObj)curChallenge.get(0)).getAttribute("gradingFile")).length > 0)
	        	{
	        		FileUtils.writeByteArrayToFile(new File(genDir + "/grading.c"), (byte[])((DBObj)curChallenge.get(0)).getAttribute("gradingFile"));
	        	}
	        	else
	        	{
	        		FileUtils.writeByteArrayToFile(new File(genDir + "/grading.c"), (byte[])((DBObj)curChallenge.get(0)).getAttribute("originalFile"));
	        	}
	        	if(((DBObj)curChallenge.get(0)).getAttribute("submittedFile") instanceof String)
	        	{
	        		FileUtils.writeStringToFile(new File(genDir + "/submitted.c"), (String)((DBObj)curChallenge.get(0)).getAttribute("submittedFile"));
	        	}
	        	else
	        	{
	        		FileUtils.writeByteArrayToFile(new File(genDir + "/submitted.c"), (byte[])((DBObj)curChallenge.get(0)).getAttribute("submittedFile"));
	        	}
	        	
	        	boolean isCompiledSubmission = false;
	        	
	        	System.out.println(((DBObj)curChallenge.get(0)).getAttributeNames());
	        	
	        	if(((int)((DBObj)curChallenge.get(0)).getAttribute("is_compiled")) == 1)
	        	{
	        		isCompiledSubmission = true;
	        		if(((DBObj)curChallenge.get(0)).getAttribute("submittedFile") instanceof String)
		        	{
	        			File genFile = new File(genDir + "/submitted.out");
	        			genFile.setExecutable(true, true);
		        		FileUtils.writeStringToFile(genFile, (String)((DBObj)curChallenge.get(0)).getAttribute("submittedFile"));
		        	}
		        	else
		        	{
		        		File genFile = new File(genDir + "/submitted.out");
		        		genFile.setExecutable(true, true);
		        		FileUtils.writeByteArrayToFile(genFile, (byte[])((DBObj)curChallenge.get(0)).getAttribute("submittedFile"));
		        	}
	        	}
	        	
	        	
	        	String[] compileCmdArray;// = new String[3];
	        	
	        	
	        	if(!isCompiledSubmission)
	        	{
		        	//clang-5.0 -emit-llvm -c -o sample.bc sample.c
		        	compileCmdArray = new String[6];
		        	compileCmdArray[0] = "clang-5.0";
		        	compileCmdArray[1] = "-emit-llvm";
		        	compileCmdArray[2] = "-c";
		        	compileCmdArray[3] = "-o";
		        	compileCmdArray[4] = genDir + "/grading.bc";
		        	compileCmdArray[5] = genDir + "/grading.c";
		        	String nativeOutput = nativeInterface.executeCommand(compileCmdArray, tmpFile, environmentalVars);
		        	System.out.println(tmpFile.getAbsolutePath());
		        	System.out.println(nativeOutput);
		        	
		        	//opt-5.0 -load ../passes/llvm-pass-countloads/build/countloads/libCountLoadsPass.so -countloads sample.bc -o sample_count.bc
		        	compileCmdArray = new String[7];
		        	compileCmdArray[0] = "opt-5.0";
		        	compileCmdArray[1] = "-load";
		        	compileCmdArray[2] = genDir + "/../../../local_bin/performanceCounter/build/countloads/libCountLoadsPass.so";
		        	compileCmdArray[3] = "-countloads";
		        	compileCmdArray[4] = genDir + "/grading.bc";
		        	compileCmdArray[5] = "-o";
		        	compileCmdArray[6] = genDir + "/grading_count.bc";
		        	nativeOutput = nativeInterface.executeCommand(compileCmdArray, genDir, environmentalVars);
		        	System.out.println(genDir.getAbsolutePath());
		        	System.out.println(nativeOutput);
		        	
		        	//clang-5.0 -emit-llvm -O3 -c -o exithandler.bc exithandler.c
		        	compileCmdArray[0] = "clang-5.0";
		        	compileCmdArray[1] = "-emit-llvm";
		        	compileCmdArray[2] = "-O3";
		        	compileCmdArray[3] = "-c";
		        	compileCmdArray[4] = "-o";
		        	compileCmdArray[5] = genDir + "/exithandler.bc";
		        	compileCmdArray[6] = genDir + "/exithandler.c";
		        	nativeOutput = nativeInterface.executeCommand(compileCmdArray, tmpFile, environmentalVars);
		        	System.out.println(tmpFile.getAbsolutePath());
		        	System.out.println(nativeOutput);
		        	
		        	//llvm-link-5.0 exithandler.bc sample_count.bc -o sample_linked.bc
		        	compileCmdArray = new String[5];
		        	compileCmdArray[0] = "llvm-link-5.0";
		        	compileCmdArray[1] = genDir + "/exithandler.bc";
		        	compileCmdArray[2] = genDir + "/grading_count.bc";
		        	compileCmdArray[3] = "-o";
		        	compileCmdArray[4] = genDir + "/grading_count_linked.bc";
		        	nativeOutput = nativeInterface.executeCommand(compileCmdArray, tmpFile, environmentalVars);
		        	System.out.println(tmpFile.getAbsolutePath());
		        	System.out.println(nativeOutput);
		        	
		        	//llc-5.0 sample_linked.bc
		        	compileCmdArray = new String[2];
		        	compileCmdArray[0] = "llc-5.0";
		        	compileCmdArray[1] = genDir + "/grading_count_linked.bc";
		        	nativeOutput = nativeInterface.executeCommand(compileCmdArray, tmpFile, environmentalVars);
		        	System.out.println(tmpFile.getAbsolutePath());
		        	System.out.println(nativeOutput);
		        	
		        	//clang-5.0 -O3 sample_linked.s -o sample_linked.out
		        	compileCmdArray = new String[5];
		        	compileCmdArray[0] = "clang-5.0";
		        	compileCmdArray[1] = "-O3";
		        	compileCmdArray[2] = genDir + "/grading_count_linked.s";
		        	compileCmdArray[3] = "-o";
		        	compileCmdArray[4] = genDir + "/grading.out";
		        	nativeOutput = nativeInterface.executeCommand(compileCmdArray, tmpFile, environmentalVars);
		        	System.out.println(tmpFile.getAbsolutePath());
		        	System.out.println(nativeOutput);
		        	
		        	/*
		        	compileCmdArray = new String[3];
		        	compileCmdArray[0] = "gcc";
		        	compileCmdArray[1] = genDir + "/grading.c";
		        	compileCmdArray[2] = "-o"+genDir+"/grading.out";
		        	nativeOutput = nativeInterface.executeCommand(compileCmdArray, tmpFile, environmentalVars);
		        	System.out.println(tmpFile.getAbsolutePath());
		        	System.out.println(compileCmdArray[2]);
		        	System.out.println(nativeOutput);
		        	*/
		        	
		        	//clang-5.0 -emit-llvm -c -o sample.bc sample.c
		        	compileCmdArray = new String[6];
		        	compileCmdArray[0] = "clang-5.0";
		        	compileCmdArray[1] = "-emit-llvm";
		        	compileCmdArray[2] = "-c";
		        	compileCmdArray[3] = "-o";
		        	compileCmdArray[4] = genDir + "/submitted.bc";
		        	compileCmdArray[5] = genDir + "/submitted.c";
		        	nativeOutput = nativeInterface.executeCommand(compileCmdArray, tmpFile, environmentalVars);
		        	System.out.println(tmpFile.getAbsolutePath());
		        	System.out.println(nativeOutput);
		        	
		        	//opt-5.0 -load ../passes/llvm-pass-countloads/build/countloads/libCountLoadsPass.so -countloads sample.bc -o sample_count.bc
		        	compileCmdArray = new String[7];
		        	compileCmdArray[0] = "opt-5.0";
		        	compileCmdArray[1] = "-load";
		        	compileCmdArray[2] = genDir + "/../../../local_bin/performanceCounter/build/countloads/libCountLoadsPass.so";
		        	compileCmdArray[3] = "-countloads";
		        	compileCmdArray[4] = genDir + "/submitted.bc";
		        	compileCmdArray[5] = "-o";
		        	compileCmdArray[6] = genDir + "/submitted_count.bc";
		        	nativeOutput = nativeInterface.executeCommand(compileCmdArray, genDir, environmentalVars);
		        	System.out.println(genDir.getAbsolutePath());
		        	System.out.println(nativeOutput);
		        	
		        	//clang-5.0 -emit-llvm -O3 -c -o exithandler.bc exithandler.c
		        	compileCmdArray[0] = "clang-5.0";
		        	compileCmdArray[1] = "-emit-llvm";
		        	compileCmdArray[2] = "-O3";
		        	compileCmdArray[3] = "-c";
		        	compileCmdArray[4] = "-o";
		        	compileCmdArray[5] = genDir + "/exithandler.bc";
		        	compileCmdArray[6] = genDir + "/exithandler.c";
		        	nativeOutput = nativeInterface.executeCommand(compileCmdArray, tmpFile, environmentalVars);
		        	System.out.println(tmpFile.getAbsolutePath());
		        	System.out.println(nativeOutput);
		        	
		        	//llvm-link-5.0 exithandler.bc sample_count.bc -o sample_linked.bc
		        	compileCmdArray = new String[5];
		        	compileCmdArray[0] = "llvm-link-5.0";
		        	compileCmdArray[1] = genDir + "/exithandler.bc";
		        	compileCmdArray[2] = genDir + "/submitted_count.bc";
		        	compileCmdArray[3] = "-o";
		        	compileCmdArray[4] = genDir + "/submitted_count_linked.bc";
		        	nativeOutput = nativeInterface.executeCommand(compileCmdArray, tmpFile, environmentalVars);
		        	System.out.println(tmpFile.getAbsolutePath());
		        	System.out.println(nativeOutput);
		        	
		        	//llc-5.0 sample_linked.bc
		        	compileCmdArray = new String[2];
		        	compileCmdArray[0] = "llc-5.0";
		        	compileCmdArray[1] = genDir + "/submitted_count_linked.bc";
		        	nativeOutput = nativeInterface.executeCommand(compileCmdArray, tmpFile, environmentalVars);
		        	System.out.println(tmpFile.getAbsolutePath());
		        	System.out.println(nativeOutput);
		        	
		        	//clang-5.0 sample_linked.s -o sample_linked.out
		        	compileCmdArray = new String[5];
		        	compileCmdArray[0] = "clang-5.0";
		        	compileCmdArray[1] = "-O3";
		        	compileCmdArray[2] = genDir + "/submitted_count_linked.s";
		        	compileCmdArray[3] = "-o";
		        	compileCmdArray[4] = genDir + "/submitted.out";
		        	nativeOutput = nativeInterface.executeCommand(compileCmdArray, tmpFile, environmentalVars);
		        	System.out.println(tmpFile.getAbsolutePath());
		        	System.out.println(nativeOutput);
		        	
		        	/*
		        	compileCmdArray = new String[3];
		        	compileCmdArray[0] = "gcc";
		        	compileCmdArray[1] = genDir + "/submitted.c";
		        	compileCmdArray[2] = "-o"+genDir+"/submitted.out";
		        	nativeOutput = nativeInterface.executeCommand(compileCmdArray, tmpFile, environmentalVars);
		        	System.out.println(nativeOutput);
		        	*/
	        	}
	        	else
	        	{
	        		compileCmdArray = new String[5];
		        	compileCmdArray[0] = "clang-5.0";
		        	compileCmdArray[1] = "-O3";
		        	compileCmdArray[2] = genDir + "/grading.c";
		        	compileCmdArray[3] = "-o";
		        	compileCmdArray[4] = genDir + "/grading.out";
		        	String nativeOutput = nativeInterface.executeCommand(compileCmdArray, tmpFile, environmentalVars);
		        	//nativeOutput = nativeInterface.executeCommand(compileCmdArray, tmpFile, environmentalVars);
		        	System.out.println(tmpFile.getAbsolutePath());
		        	System.out.println(nativeOutput);
		        	
	        	}
	        	
	        	DBObj previousMap = (DBObj) gradeChallenge.get(0);
	        	ArrayList testArgs = new ArrayList();
	        	testArgs.add(previousMap);
	        	for(int x=1; x<=gradeChallenge.size(); x++)
	        	{
	        		DBObj curMap = null;
	        		if(x < gradeChallenge.size())
	        		{
	        			curMap = (DBObj) gradeChallenge.get(x);
	        		}
	        		//System.out.println(previousMap.attributes);
	        		//System.out.println(curMap.attributes);
	        		if(curMap != null && curMap.getAttribute("test_number").equals(previousMap.getAttribute("test_number")))
	        		{
	        			testArgs.add(curMap);
	        		}
	        		else
	        		{
	        			ArrayList outputInput = myConnector.getChallengeAutoGradeInput((String)previousMap.getAttribute("challenge_name"), (int)previousMap.getAttribute("test_number"));
	        			int numIterations = (int)previousMap.getAttribute("num_iterations");
	        			int numFailures = 0;
	        			int numPerformanceFailures = 0;
	        			toEmail += "Testing " + numIterations + " values.";
	        			redirectWriter.println("<script>document.getElementById(\"gradeContent\").innerHTML += \"" + "Testing " + numIterations + " values." + " <br />\";</script>");
	        			for(int y=0; y<1000; y++)
	    	        	{
	    	        		redirectWriter.println("<div style=\"display:none\">#</div>");
	    	        	}
	        			redirectWriter.flush();
	    	    		response.flushBuffer();
	        			myConnector.gradeChallengeParticipant(challengeName, (String)myUser.getAttribute("email"), (int)previousMap.getAttribute("test_number"), 0, false, false, true);
	        			for(int y=0; y<numIterations; y++)
	        			{
	        				// Test here
	        				int numArgs = testArgs.size();
    	    	        	System.out.println("Testing with " + numArgs + " args.");
    	    	        	
    	    	        	int numSubmittedArgs = 0;
    	    	        	//System.out.println(testArgs);
    	    	        	for(int z=0; z<testArgs.size(); z++)
    	    	        	{
    	    	        		DBObj gradeObj = (DBObj) testArgs.get(z);
    	    	        		//System.out.println("Got " + gradeObj.getAttributeNames());
    	    	        		int origOnly = (int) gradeObj.getAttribute("orig_only");
    	    	        		if(!(origOnly == 1))
    	    	        		{
    	    	        			numSubmittedArgs++;
    	    	        		}
    	    	        	}
    	    	        	
    	    	        	System.out.println(numArgs + " arguments for orig");
    	    	        	System.out.println(numSubmittedArgs + " arguments for sub");
    	    	        	String[] runCmdArray = new String[numArgs + 5];
    	    	        	String[] runCmdArraySubmitted = new String[numSubmittedArgs + 5];
    	    	        	
    	    	        	runCmdArray[0] = "firejail";
    	    	        	runCmdArray[1] = "--quiet";
    	    	        	runCmdArraySubmitted[0] = "firejail";
    	    	        	runCmdArraySubmitted[1] = "--quiet";
    	    	        	//runCmdArray[2] = "--whitelist="+genDir+"/submitted.out";
    	    	        	//runCmdArray[3] = "--read-write="+genDir+"/submitted.out";
    	    	        	//runCmdArray[2] = "--noprofile";
    	    	        	//runCmdArray[3] = "--private";//=" + sc.getRealPath("/WEB-INF/");
    	    	        	//runCmdArray[4] = "--whitelist="+genDir+"/submitted.out";
    	    	        	runCmdArray[3] = "--overlay-tmpfs";
    	    	        	runCmdArray[2] = "--net=none";
    	    	        	runCmdArraySubmitted[3] = "--overlay-tmpfs";
    	    	        	runCmdArraySubmitted[2] = "--net=none";
    	    	        	//runCmdArray[3] = "--blacklist=/";
    	    	        	//runCmdArray[2] = "--noblacklist="+genDir+"/submitted.out";
    	    	        	int submittedNum = 0;
	        				for(int z=0; z<testArgs.size(); z++)
	        				{
	        					DBObj gradeObj = (DBObj) testArgs.get(z);
	        					int origOnly = (int) gradeObj.getAttribute("orig_only");
	        					//System.out.println(gradeObj.attributes);
	        					String value = (String) gradeObj.getAttribute("arg_value");
	    	        			if(value == null || value.isEmpty())
	    	        			{
	    	        				String type = (String) gradeObj.getAttribute("arg_type");
	    	        				if(type.equals("long"))
	    	        				{
	    	        					Random tmpRand = new SecureRandom();
	    	        					long tmpLong = tmpRand.nextLong();
	    	        					while(Math.abs(tmpLong) > Math.pow(10, y + 1))
	    	        					{
	    	        						tmpLong = tmpLong/2;
	    	        					}
	    	        					value = ((Long)tmpLong).toString();
	    	        				}
	    	        				if(type.equals("integer"))
	    	        				{
	    	        					Random tmpRand = new SecureRandom();
	    	        					int tmpInt = tmpRand.nextInt();
	    	        					while(Math.abs(tmpInt) > Math.pow(10, y + 1))
	    	        					{
	    	        						tmpInt = tmpInt/2;
	    	        					}
	    	        					value = ((Integer)tmpInt).toString();
	    	        				}
	    	        			}
	    	        			runCmdArray[5+z] = value;
	    	        			if(!(origOnly == 1))
    	    	        		{
	    	        				runCmdArraySubmitted[5+submittedNum] = value;
    	    	        			submittedNum++;
    	    	        		}
	    	        			
	        				}
	        				runCmdArray[4] = genDir+"/grading.out";
	    	        		
	    	        		String argString = "Running grading with: ";
	    	        		for(int z=0; z<runCmdArray.length; z++)
	    	        		{
	    	        			argString += "" + z + ":" + runCmdArray[z] + " ";
	    	        		}
	    	        		
	    	        		System.out.println(argString);
	    	        		//System.out.println(tmpFile);
	    	        		//System.out.println(environmentalVars);
	    	        		
	    	        		
	    	        		ArrayList outputForce = new ArrayList();
	    	        		for(int z=0; z<outputInput.size(); z++)
	    	        		{
	    	        			outputForce.add(((DBObj)outputInput.get(z)).getAttribute("input_string"));
	    	        		}
	    	        		
	    	        		String gradingOutput = nativeInterface.executeCommand(runCmdArray, tmpFile, environmentalVars, 500000000, outputForce);
	    	        		
	    	        		runCmdArraySubmitted[4] = genDir+"/submitted.out";
	    	        		String submittedOutput = nativeInterface.executeCommand(runCmdArraySubmitted, tmpFile, environmentalVars, 500000000, outputForce);
	    	        		
	    	        		//System.out.println(gradingOutput);
	    	        		
	    	        		Scanner tmpScanner = new Scanner(gradingOutput);
	    	        		HashMap gradingPerformance = new HashMap();
	    	        		if(tmpScanner.hasNextLine())
	    	        		{
	    	        			//tmpScanner.nextLine();
	    	        			//tmpScanner.nextLine();
	    	        			String finalGraded = "";
	    	        			while(tmpScanner.hasNextLine())
	    	        			{
	    	        				//String tmpString = tmpScanner.nextLine();
	    	        				//if(tmpScanner.hasNextLine())
	    	        				//{
	    	        				//	if(finalGraded.equals(""))
	    	        				//	{
	    	        				//		finalGraded += tmpString;
	    	        				//	}
	    	        				//	else
	    	        				//	{
	    	        				//		finalGraded += "\n" + tmpString;
	    	        				//	}
	    	        				//}
	    	        				String theNextLine = tmpScanner.nextLine();
	    	        				if(theNextLine.equals("PERFORMANCE"))
	    	        				{
	    	        					//System.out.println("Getting performance data:");
	    	        					int total = 0;
	    	        					while(tmpScanner.hasNextLine())
	    	        					{
	    	        						String nextLine = tmpScanner.nextLine();
	    	        						Scanner lineScanner = new Scanner(nextLine);
	    	        						String instructionType = lineScanner.next();
	    	        						int count = Integer.MAX_VALUE;
	    	        						if(lineScanner.hasNextInt())
	    	        						{
		    	        						count = lineScanner.nextInt();
	    	        						}
	    	        						instructionType = instructionType.replace(":", "");
	    	        						//System.out.println(instructionType + ", " + count);
	    	        						gradingPerformance.put(instructionType, count);
	    	        						total += count;
	    	        					}
	    	        					gradingPerformance.put("total", total);
	    	        				}
	    	        				else
	    	        				{
	    	        					finalGraded += "\n" + theNextLine;
	    	        				}
	    	        			}
	    	        			gradingOutput = finalGraded;
	    	        		}
	    	        		
	    	        		HashMap submittedPerformance = new HashMap();
	    	        		tmpScanner = new Scanner(submittedOutput);
	    	        		if(tmpScanner.hasNextLine())
	    	        		{
	    	        			//tmpScanner.nextLine();
	    	        			//tmpScanner.nextLine();
	    	        			String finalSubmitted = "";
	    	        			while(tmpScanner.hasNextLine())
	    	        			{
	    	        				//String tmpString = tmpScanner.nextLine();
	    	        				//if(tmpScanner.hasNextLine())
	    	        				//{
	    	        				//	if(finalSubmitted.equals(""))
	    	        				//	{
	    	        				//		finalSubmitted += tmpString;
	    	        				//	}
	    	        				//	else
	    	        				//	{
	    	        				//		finalSubmitted += "\n" + tmpString;
	    	        				//	}
	    	        				//}
	    	        				String theNextLine = tmpScanner.nextLine();
	    	        				if(theNextLine.equals("PERFORMANCE"))
	    	        				{
	    	        					//System.out.println("Getting performance data:");
	    	        					int total = 0;
	    	        					while(tmpScanner.hasNextLine())
	    	        					{
	    	        						String nextLine = tmpScanner.nextLine();
	    	        						Scanner lineScanner = new Scanner(nextLine);
	    	        						String instructionType = lineScanner.next();
	    	        						int count = lineScanner.nextInt();
	    	        						instructionType = instructionType.replace(":", "");
	    	        						//System.out.println(instructionType + ", " + count);
	    	        						submittedPerformance.put(instructionType, count);
	    	        						total += count;
	    	        					}
	    	        					submittedPerformance.put("total", total);
	    	        				}
	    	        				else
	    	        				{
	    	        					finalSubmitted += "\n" + theNextLine;
	    	        				}
	    	        			}
	    	        			submittedOutput = finalSubmitted;
	    	        		}
	    	        		
	    	        		System.out.println("Grading: " + gradingOutput);
	    	        		System.out.println("Submitted: " + submittedOutput);
	    	        		if(gradingOutput.equals(submittedOutput))
	    	        		{
	    	        			//System.out.println("These are equal!");
	    	        			boolean perfFail = false;
	    	        			for(Object instruction : submittedPerformance.keySet())
		    	        		{
		    	        			//System.out.println("Comparing " + instruction);
		    	        			int submittedCount = (int) submittedPerformance.get(instruction);
		    	        			int gradingCount = 1;
		    	        			if(gradingPerformance.containsKey(instruction))
		    	        			{
		    	        				gradingCount = (int) gradingPerformance.get(instruction);
		    	        				if(gradingCount < 1)
		    	        				{
		    	        					gradingCount = 1;
		    	        				}
		    	        			}
		    	        			double performance = (double) previousMap.getAttribute("performance_multiplier");
		    	        			//System.out.println("Multiplier: " + performance);
		    	        			//System.out.println(submittedCount + ", " + gradingCount);
		    	        			if(submittedCount > performance * gradingCount)
		    	        			{
		    	        				//System.out.println("Failed this instruction");
		    	        				//numFailures++;
		    	        				perfFail = true;
		    	        				break;
		    	        			}
		    	        		}
	    	        			if(perfFail)
	    	        			{
	    	        				numPerformanceFailures++;
	    	        			}
	    	        		}
	    	        		else
	    	        		{
	    	        			numFailures++;
	    	        		}
	        			}
	        			System.out.println("Failed " + numFailures + " out of " + numIterations);
	        			System.out.println("Performance Failed " + numPerformanceFailures + " out of " + numIterations);
	        			
	        			boolean correct = numFailures == 0;
	        			boolean performance = numPerformanceFailures == 0;
	    	        	myConnector.gradeChallengeParticipant(challengeName, (String)myUser.getAttribute("email"), (int)previousMap.getAttribute("test_number"), numIterations - (numFailures + numPerformanceFailures), correct, performance, false);
	        			
	    	        	String textToInsert = "";
	    	        	if(correct && performance)
	    	        	{
	    	        		textToInsert = "<font color='green'>Test " + previousMap.getAttribute("test_number") + ": Passed " + (numIterations - numFailures) + "/" + numIterations + "</font>";
	    	        	}
	    	        	else
	    	        	{
	    	        		textToInsert = "<font color='red'>Test " + previousMap.getAttribute("test_number") + ": Passed " + (numIterations - numFailures) + "/" + numIterations + "</font><br />Failed on ";
	    	        		if(!correct)
	    	        		{
	    	        			textToInsert += " correctness";
	    	        			if(!performance)
	    	        			{
	    	        				textToInsert += " and ";
	    	        			}
	    	        			else
	    	        			{
	    	        				textToInsert += ".";
	    	        			}
	    	        		}
	    	        		if(!performance)
	    	        		{
	    	        			textToInsert += "performance.";
	    	        		}
	    	        	}
	    	        	toEmail += "\n" + textToInsert;
	    	        	redirectWriter.println("<script>document.getElementById(\"gradeContent\").innerHTML += \"" + textToInsert + " <br />\";</script>");
	    	        	for(int y=0; y<1000; y++)
	    	        	{
	    	        		redirectWriter.println("<div style=\"display:none\">#</div>");
	    	        	}
	    	        	redirectWriter.flush();
	    	    		response.flushBuffer();
	    	        	
	    	        	String[] firejailClean = new String[2];
	    	        	firejailClean[0] = "firejail";
	    	        	firejailClean[1] = "--overlay-clean";
	    	        	String clean = nativeInterface.executeCommand(firejailClean, tmpFile, environmentalVars);
	    	        	System.out.println("Cleaning..." + clean);
	        			previousMap = curMap;
	    	        	testArgs = new ArrayList();
	    	        	testArgs.add(curMap);
	        		}
	        	}
	        	
	        	/*
	        	int numFailures = 0;
	        	int numIterations = (int) ((DBObj)curChallenge.get(0)).getAttribute("num_grading_iterations");
	        	for(int x=0; x<numIterations; x++)
	        	{
	        		for(int y=0; y<gradeChallenge.size(); y++)
	        		{
	        			DBObj gradeObj = (DBObj) gradeChallenge.get(y);
	        			String value = (String) gradeObj.getAttribute("arg_value");
	        			if(value == null || value.isEmpty())
	        			{
	        				String type = (String) gradeObj.getAttribute("arg_type");
	        				if(type.equals("long"))
	        				{
	        					Random tmpRand = new SecureRandom();
	        					long tmpLong = tmpRand.nextLong();
	        					while(tmpLong > Math.pow(10, x + 1) || -tmpLong > Math.pow(10, x + 1))
	        					{
	        						tmpLong = tmpLong/2;
	        					}
	        					value = ((Long)tmpLong).toString();
	        				}
	        				if(type.equals("integer"))
	        				{
	        					Random tmpRand = new SecureRandom();
	        					int tmpInt = tmpRand.nextInt();
	        					while(tmpInt > Math.pow(10, x + 1) || -tmpInt > Math.pow(10, x + 1))
	        					{
	        						tmpInt = tmpInt/2;
	        					}
	        					value = ((Integer)tmpInt).toString();
	        				}
	        			}
	        			runCmdArray[6+y] = value;
	        		}
	        		
	        		runCmdArray[5] = genDir+"/grading.out";
	        		
	        		String argString = "Running grading with: ";
	        		for(int y=0; y<runCmdArray.length; y++)
	        		{
	        			argString += runCmdArray[y] + " ";
	        		}
	        		
	        		System.out.println(argString);
	        		
	        		String gradingOutput = nativeInterface.executeCommand(runCmdArray, tmpFile, environmentalVars);
	        		
	        		runCmdArray[5] = genDir+"/submitted.out";
	        		String submittedOutput = nativeInterface.executeCommand(runCmdArray, tmpFile, environmentalVars);
	        		
	        		System.out.println(gradingOutput);
	        		
	        		Scanner tmpScanner = new Scanner(gradingOutput);
	        		if(tmpScanner.hasNextLine())
	        		{
	        			tmpScanner.nextLine();
	        			tmpScanner.nextLine();
	        			String finalGraded = "";
	        			while(tmpScanner.hasNextLine())
	        			{
	        				String tmpString = tmpScanner.nextLine();
	        				if(tmpScanner.hasNextLine())
	        				{
	        					if(finalGraded.equals(""))
	        					{
	        						finalGraded += tmpString;
	        					}
	        					else
	        					{
	        						finalGraded += "\n" + tmpString;
	        					}
	        				}
	        			}
	        			gradingOutput = finalGraded;
	        		}
	        		
	        		tmpScanner = new Scanner(submittedOutput);
	        		if(tmpScanner.hasNextLine())
	        		{
	        			tmpScanner.nextLine();
	        			tmpScanner.nextLine();
	        			String finalSubmitted = "";
	        			while(tmpScanner.hasNextLine())
	        			{
	        				String tmpString = tmpScanner.nextLine();
	        				if(tmpScanner.hasNextLine())
	        				{
	        					if(finalSubmitted.equals(""))
	        					{
	        						finalSubmitted += tmpString;
	        					}
	        					else
	        					{
	        						finalSubmitted += "\n" + tmpString;
	        					}
	        				}
	        			}
	        			submittedOutput = finalSubmitted;
	        		}
	        		
	        		System.out.println("Grading: " + gradingOutput);
	        		System.out.println("Submitted: " + submittedOutput);
	        		if(gradingOutput.equals(submittedOutput))
	        		{
	        			System.out.println("These are equal!");
	        		}
	        		else
	        		{
	        			numFailures++;
	        		}
	        	}
	        	System.out.println("Failed " + numFailures + " out of " + numIterations);
	        	
	        	myConnector.gradeChallengeParticipant(challengeName, (String)myUser.getAttribute("email"), numIterations - numFailures);
	        	
	        	String[] firejailClean = new String[2];
	        	firejailClean[0] = "firejail";
	        	firejailClean[1] = "--overlay-clean";
	        	String clean = nativeInterface.executeCommand(firejailClean, tmpFile, environmentalVars);
	        	System.out.println("Cleaning..." + clean);
	        	*/
	        	//FileUtils.deleteDirectory(genDir);
			}
			catch(Exception e)
			{
				e.printStackTrace();
			}
			//redirectWriter.println("<script>document.getElementById(\"gradeContent\").innerHTML += \"Grading done.  Now redirecting... <br />\";</script>");
			//redirectWriter.println("<script>document.getElementById(\"gradeContent\").innerHTML += \"" + "Done!" + " <br />\";</script>");
			redirectWriter.flush();
			response.flushBuffer();
			if(uploadDataBool)
			{
				//response.sendRedirect("activateDataUpload.jsp");
				redirectWriter.println("<script>document.getElementById(\"gradeContent\").innerHTML += \"" + "Done!  Beginning data upload." + " <br />\";</script>");
				if(redirectTo == null || redirectTo.equals(""))
				{
					redirectWriter.println("<meta http-equiv=\"refresh\" content=\"2; url=activateDataUpload.jsp\" />");
				}
				else
				{
					redirectWriter.println("<meta http-equiv=\"refresh\" content=\"2; url=activateDataUpload.jsp?redirect=" + redirectTo + "\" />");
				}
				redirectWriter.flush();
				response.flushBuffer();
			}
			else
			{
				//response.sendRedirect("myChallenges.jsp");
				//redirectWriter.println("<html><head><meta http-equiv=\"refresh\" content=\"2; url=myChallenges.jsp\" /></head></html>");
				toEmail += "\nDone!";
				redirectWriter.println("<script>document.getElementById(\"gradeContent\").innerHTML += \"" + "Done!" + " <br />\";</script>");
				if(redirectTo != null && (!redirectTo.equals("")))
				{
					redirectWriter.println("<meta http-equiv=\"refresh\" content=\"2; url=" + redirectTo + "\" />");
				}
				
				redirectWriter.flush();
				response.flushBuffer();
			}
			redirectWriter.flush();
			response.flushBuffer();
			mySender.sendEmail((String)myUser.getAttribute("email"), "Submission Received for " + challengeName, toEmail);
		}
		else
		{
			PrintWriter redirectWriter = response.getWriter();
			//redirectWriter.println("<html><head><meta http-equiv=\"refresh\" content=\"0; url=myChallenges.jsp\" /></head></html>");
			redirectWriter.flush();
			response.flushBuffer();
		}
		response.flushBuffer();
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		doGet(request, response);
	}

}
