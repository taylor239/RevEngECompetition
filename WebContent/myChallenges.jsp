<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
<%@include file="./WEB-INF/includes/includes.jsp" %>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>RevEngE</title>

</head>

<body>
<%@include file="./WEB-INF/includes/mainPane.jsp" %>
<table id="inner_content">
	<!--
	<tr>
    	<td colspan="3" class="no_bottom_padding">
    	<div align="center">
    	<table id="page_title_table_row">
    	<tr>
    	<td>
        <div align="center" id="inner_content_title">
        <%
        
        if(verbose)
        {
        	System.out.println("Got to hasUser conditional");
        }
		if(!hasUser)
		{
		%>
        Welcome to the Tigress Challenge Engine
        <%
		}
		else
		{
		%>
        Welcome back, <% out.print(displayName); %>!
        <%
		}
		%>
        </div>
        <div align="center" id="inner_content_slogan">
        Obfuscation Made Easy</div>
        </td>
        </tr>
        </table>
        </div>
        </td>
    </tr>
    -->
	<tr>
    	<td width="10%">
    	<!--
        <table class="inner_content_table">
        <tr>
        <td>
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        Options
        </td>
    	</tr>
    	<tr colspan="3" width="100%:">
        <td>
        <table class="news_item_table" width="100%">
        <tr>
        <%
        if(myUser.getAttribute("role").equals("admin") && false)
        {
        %>
        <td>
        <div align="center">
        <a href="makeNew.jsp">Make New Challenge</a><br></br>
        </div>
        </td>
        </tr>
        <tr>
        <td>
        <div align="center">
        <a href="manageStudents.jsp">Manage Students</a>
        </div>
        </td>
        <%
        }
        %>
        </tr>
        </table>
        </td>
        </tr>
    	</table>
        </td>
        </tr>
        </table>
        </td>
        -->
        <td width="80%">
        <table class="inner_content_table">
        <!--
        <tr>
        <td>
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        <div align="center">
        Options
        </div>
        </td>
    	</tr>
    	<tr colspan="2" width="100%:">
        <td>
        <table class="news_item_table" width="100%">
        <tr>
        <%
        if(myUser.getAttribute("role").equals("admin") && false)
        {
        %>
        <td width="33.3%">
        <div align="center">
        <a href="makeNew.jsp">Challenge Quick Start</a><br></br>
        </div>
        </td>
        <td width="33.4%">
        <div align="center">
        <a href="makeNew.jsp">Make New Challenge</a><br></br>
        </div>
        </td>
        <%
        }
        %>
        </tr>
        </table>
        </td>
        </tr>
    	</table>
        </td>
        </tr>
        </table>
        -->
        <table class="inner_content_table">
        <tr>
        <td>
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        Challenges
        </td>
    	</tr>
    	<tr>
    	<td colspan="3">
    	<div align="center">
    	If you are interested in participating in data collection, please see <a href="dataCollection.jsp">this page</a> for more information or download the collection software installer <a href="installDataCollection.sh" download>here</a>.
    	</div>
    	</td>
    	</tr>
        <tr colspan="3" width="100%:">
        <td>
        <table class="news_item_table" width="100%">
        <tr>
        <%
        if(!hasUser)
        {
        	%>
        	<meta http-equiv="refresh" content="0; url=index.jsp" />
        	<%
        }
        else if(myUser.getAttribute("role").equals("student") || myUser.getAttribute("role").equals("admin"))
        {
        myConnector.syncChallenges("cgtboy1988@yahoo.com", myUser, sc);
        ArrayList myChallenges = myConnector.getChallenges((String)myUser.getAttribute("email"));
        if(verbose)
        {
        	System.out.println(myChallenges);
        }
        ArrayList keys = ((DBObj)myChallenges.get(0)).getAttributeNames();
        ConcurrentHashMap translationMap = new ConcurrentHashMap();
        //translationMap.put("admin_email", "Instructor");
        translationMap.put("challenge_name", "Challenge");
        //translationMap.put("open_time", "Open");
        //translationMap.put("end_time", "Close");
        translationMap.put("grade", "Grade");
        translationMap.put("num_grading_iterations", "Total Tests");
        translationMap.put("auto_grade_score", "Tests Passed");
        boolean graded = (Boolean)(((DBObj)myChallenges.get(0)).getAttribute("auto_grade"));
        graded = false;
        for(int x=0; x<keys.size(); x++)
        {
        	String tmp=(String)keys.get(x);
        	if(tmp.equals("email")
        			|| tmp.equals("code_generated")
        			|| tmp.equals("end_time")
        			|| tmp.equals("open_time")
        			|| tmp.equals("description")
        			|| tmp.equals("originalFile")
        			|| tmp.equals("obfuscatedFile")
        			|| tmp.equals("submittedFile")
        			|| tmp.equals("submissionTime")
        			|| tmp.equals("submittedWrittenFile")
        			|| tmp.equals("type")
        			|| tmp.equals("grade")
        			|| tmp.equals("admin_email")
        			|| tmp.equals("gradingFile")
        			|| tmp.equals("auto_grade")
        			|| (!graded && tmp.equals("num_grading_iterations"))
        			|| (!graded && tmp.equals("auto_grade_score"))
        			|| tmp.equals("codeGeneratedTime")
        			|| tmp.equals("correct")
        			|| tmp.equals("in_progress")
        			|| tmp.equals("performance")
        			|| tmp.equals("iterations_passed")
        			|| tmp.equals("test_number")
        			|| tmp.equals("num_iterations")
        			|| tmp.equals("performance_multiplier")
        			|| tmp.equals("seed")
        			|| tmp.equals("randomSeed")
        			|| tmp.equals("participantSeed")
        			|| tmp.equals("challenge_set_name")
        			|| tmp.equals("open_time")
        			|| tmp.equals("end_time")
        			|| tmp.equals("cachedOriginal")
        			|| tmp.equals("cachedObfuscated")
        			|| tmp.equals("cachedGrading")
        			|| tmp.equals("is_compiled")
        			|| tmp.equals("ctf_points"))
        	{
        		keys.remove(x);
        		x--;
        	}
        }
        //keys.add("open_time");
        //keys.add("end_time");
        for(int x=0; x<keys.size(); x++)
        {
        %>
        <td width="<% out.print(100/((double)keys.size() + 5)); %>%">
        <div align="center">
        <b>
        <%
        	if(translationMap.containsKey(keys.get(x)))
        	{
        		out.print(translationMap.get(keys.get(x)));
        	}
        	else
        	{
        		out.print(keys.get(x));
        	}
        %>
        </b>
        </div>
        </td>
        <%
        }
        %>
        <td width="<% out.print(100/((double)keys.size() + 5)); %>%">
        <div align="center"><b>Code</b></div>
        </td>
        <td width="<% out.print(100/((double)keys.size() + 5)); %>%">
        <div align="center"><b>Write-Up</b></div>
        </td>
        <td width="<% out.print(100/((double)keys.size() + 5)); %>%">
        <div align="center"><b>Answer</b></div>
        </td>
        <td width="<% out.print(100/((double)keys.size() + 5)); %>%">
        <div align="center"><b>Submit</b></div>
        </td>
        <td width="<% out.print(100/((double)keys.size() + 5)); %>%">
        <div align="center"><b>Upload Collected Data</b></div>
        </td>
        </tr>
        <%
        String prevSet = "";
        ArrayList passedAllList = new ArrayList();
        for(int x=0; x<myChallenges.size(); x++)
        {
        	if(!((DBObj)myChallenges.get(x)).getAttribute("type").equals("assignment"))
        	{
        		continue;
        	}
        	String curSet = (String)(((DBObj)myChallenges.get(x)).getAttribute("challenge_set_name"));
        	String nextSet = "";
        	if(x + 1<myChallenges.size())
        	{
        		nextSet = (String)(((DBObj)myChallenges.get(x + 1)).getAttribute("challenge_set_name"));
        	}
        	if(!curSet.equals(prevSet))
        	{
        		prevSet = curSet;
        		%>
        		<tr>
        		<td colspan = "<%=keys.size() + 5%>">
        		&nbsp;
        		</td>
        		</tr>
        		<tr>
        		<td colspan = "<%=keys.size() + 5%>">
        		<hr></hr>
        		</td>
        		</tr>
        		<tr>
        		<td colspan = "<%=keys.size() + 5%>">
        		<b>
        		Challenge Set: <%=curSet %>
        		</b>
        		</td>
        		</tr>
        		<%
        	}
        %>
        <form id="uploadForm_<%=x %>" action="ChallengeDeobfuscatedSubmissionServlet" method="post" enctype="multipart/form-data"></form>
        <tr id="challenge_number_<%=x %>">
	        <%
	        for(int y=0; y<keys.size(); y++)
	        {
	        %>
	        <td width="<% out.print(100/((double)keys.size() + 5)); %>%">
	        <div align="left">
	        <%
	        	if(keys.get(y).equals("open_time") || keys.get(y).equals("end_time"))
	        	{
	        		java.util.Date tmpDate = (java.util.Date)((DBObj)myChallenges.get(x)).getAttribute(keys.get(y));
	        		out.print(dateFormat.format(tmpDate));
	        	}
	        	else if(keys.get(y).equals("challenge_name"))
	        	{
	        		%>
	        		<!-- <a href="viewChallenge.jsp?challengeName=<%= ((DBObj)myChallenges.get(x)).getAttribute(keys.get(y)) %>">-->
	        		<script>
	        		<%
	        		String lastSubmission = "";
	        		boolean isGraded = (Boolean)(((DBObj)myChallenges.get(x)).getAttribute("auto_grade"));
	        		if(((DBObj)myChallenges.get(x)).getAttribute("submissionTime")!=null)
	        		{
	        			lastSubmission = "You submitted last on: " + ((DBObj)myChallenges.get(x)).getAttribute("submissionTime");
	        		}
	        		//String totalTests = "" + ((DBObj)myChallenges.get(x)).getAttribute("num_grading_iterations");
	        		//String passedTests = "" + ((DBObj)myChallenges.get(x)).getAttribute("auto_grade_score");
	        		%>
	        		var message_<%=x %> = '<table width="100%"><tr width="100%"><td colspan="2" width="100%" style="vertical-align:bottom;">Challenge Instructions:</td></tr><tr><td colspan="2" style="vertical-align:top;"><table style="width:100%;"><tr><td style="font-size:medium; font-weight:normal; text-align:left;"><%=((DBObj)myChallenges.get(x)).getAttribute("description") %></td></tr><tr><td colspan="2" style="font-size:medium; font-weight:normal; text-align:left;"><%=lastSubmission %></td></tr>' + <%
					
	        		System.out.println("Is graded? " + isGraded);
	        		System.out.println(((DBObj)myChallenges.get(x)).getAttribute("challenge_name"));
	        		
	        		if(isGraded)
	        		{
	        			Object testNums = ((DBObj)myChallenges.get(x)).getAttribute("test_number");
	        			
	        			System.out.println("Test nums " + testNums + ", " + testNums.getClass());
	        			
	        			if(testNums != null && testNums instanceof Integer)
	        			{
	        				ArrayList newTestNums = new ArrayList();
	        				newTestNums.add(testNums);
	        				testNums = newTestNums;
	        			}
	        			
	        			if(testNums != null && testNums instanceof ArrayList)
	        			{
	        				ArrayList testArray = (ArrayList)testNums;
	        				Object passedArray = ((DBObj)myChallenges.get(x)).getAttribute("iterations_passed");
	        				Object correctArray = ((DBObj)myChallenges.get(x)).getAttribute("correct");
	        				Object performanceArray = ((DBObj)myChallenges.get(x)).getAttribute("performance");
	        				Object inProgressArray = ((DBObj)myChallenges.get(x)).getAttribute("in_progress");
	        				Object numIterations = ((DBObj)myChallenges.get(x)).getAttribute("num_iterations");
	        				Object performanceMultiplier = ((DBObj)myChallenges.get(x)).getAttribute("performance_multiplier");
	        				
	        				if(!(passedArray instanceof ArrayList))
	        				{
	        					ArrayList newArray = new ArrayList();
	        					for(int z=0; z<testArray.size(); z++)
	        					{
	        						newArray.add(passedArray);
	        					}
	        					passedArray = newArray;
	        				}
	        				
	        				if(!(correctArray instanceof ArrayList))
	        				{
	        					ArrayList newArray = new ArrayList();
	        					for(int z=0; z<testArray.size(); z++)
	        					{
	        						newArray.add(correctArray);
	        					}
	        					correctArray = newArray;
	        				}
	        				
	        				if(!(performanceArray instanceof ArrayList))
	        				{
	        					ArrayList newArray = new ArrayList();
	        					for(int z=0; z<testArray.size(); z++)
	        					{
	        						newArray.add(performanceArray);
	        					}
	        					performanceArray = newArray;
	        				}
	        				
	        				if(!(inProgressArray instanceof ArrayList))
	        				{
	        					ArrayList newArray = new ArrayList();
	        					for(int z=0; z<testArray.size(); z++)
	        					{
	        						newArray.add(inProgressArray);
	        					}
	        					inProgressArray = newArray;
	        				}
	        				
	        				if(!(numIterations instanceof ArrayList))
	        				{
	        					ArrayList newArray = new ArrayList();
	        					for(int z=0; z<testArray.size(); z++)
	        					{
	        						newArray.add(numIterations);
	        					}
	        					numIterations = newArray;
	        				}
	        				
	        				if(!(performanceMultiplier instanceof ArrayList))
	        				{
	        					ArrayList newArray = new ArrayList();
	        					for(int z=0; z<testArray.size(); z++)
	        					{
	        						newArray.add(performanceMultiplier);
	        					}
	        					performanceMultiplier = newArray;
	        				}
	        				
	        				//System.out.println(testArray);
	        				//System.out.println(performanceMultiplier);
	        				
	        				boolean passedAll = testArray.size() > -1;
	        				
	        				for(int z=0; z<testArray.size(); z++)
	        				{
	        					String styleAppend = "";
	        					if((boolean)(((ArrayList)inProgressArray).get(z)))
	        					{
	        						styleAppend += "color: orange;";
	        						passedAll = false;
	        					}
	        					else if(!((ArrayList)passedArray).get(z).equals(((ArrayList)numIterations).get(z)))
	        					{
	        						styleAppend += "color: red;";
	        						passedAll = false;
	        					}
	        					else
	        					{
	        						styleAppend += "color: green;";
	        					}
	        				%>
	    	        		'<tr><td width="25%" style="font-size:medium; font-weight:normal; text-align:left; <%=styleAppend %>">Test Number: <%=testArray.get(z) %></td><td width=\"75%\" style=\"font-size:medium; font-weight:normal; text-align:left;  <%=styleAppend %>\">Iterations Passed: <%=((ArrayList)passedArray).get(z) %>/<%=((ArrayList)numIterations).get(z) %>' +
	    	        		<%
	    	        		if(!((ArrayList)passedArray).get(z).equals(((ArrayList)numIterations).get(z)))
	    	        		{
	    	        			String failCause = "";
	    	        			if(!(boolean)(((ArrayList)correctArray).get(z)))
	    	        			{
	    	        				failCause += "Correctness";
	    	        				if(!(boolean)(((ArrayList)performanceArray).get(z)))
	    	        				{
	    	        					failCause += " and performance";
	    	        				}
	    	        			}
	    	        			else if(!(boolean)(((ArrayList)performanceArray).get(z)))
    	        				{
    	        					failCause += "Performance";
    	        				}
	    	        			%>'</tr></td><tr><td colspan="2" style="font-size:medium; font-weight:normal; text-align:left;  <%=styleAppend %>">Failed On: <%=failCause %>' +<%
	    	        		}
	    	        		if((boolean)(((ArrayList)inProgressArray).get(z)))
        					{
	    	        			%>'</tr></td><tr><td colspan="2" style="font-size:medium; font-weight:normal; text-align:left;  <%=styleAppend %>">Grading currently in progress; refresh for update.' +<%
        					}
	    	        		%>
	    	        		'</tr></td>' +
	    	        		<%
	        				}
	        				if(passedAll)
	        				{
	        					System.out.println("Passed all tests!");
	        					passedAllList.add(x);
	        				}
	        			}
	        		}
	        		%>'</table></td></tr></table>';
	        		</script>
	        		<a onclick="showMessageBox(message_<%=x %>)">
	        		<%
	        		out.print(((DBObj)myChallenges.get(x)).getAttribute(keys.get(y)));
	        		%>
	        		</a>
	        		<%
	        	}
	        	else
	        	{
	        		out.print(((DBObj)myChallenges.get(x)).getAttribute(keys.get(y)));
	        	}
	        %>
	        </div>
	        </td>
	        <%
	        }
	        %>
	        <td width="<% out.print(100/((double)keys.size() + 5)); %>%">
	        <%
	        if((Integer)((DBObj)myChallenges.get(x)).getAttribute("code_generated") == 0)
	        {
	        	System.out.println("Generating challenge " + ((String)((DBObj)myChallenges.get(x)).getAttribute("challenge_name")));
	        	//CodeGenerator myGenerator = new CodeGenerator();
	        	//try
	        	//{
	        	//	myGenerator.generateCode(myConnector, request, myUser, sc, ((String)((DBObj)myChallenges.get(x)).getAttribute("challenge_name")));
	        	//}
	        	//catch(Exception e)
	        	//{
	        	//	e.printStackTrace();
	        	//}
	        	//System.out.println("Done generating challenge");
	        	//request.getRequestDispatcher("generateCodeOnly.jsp?challengeName=" + ((DBObj)myChallenges.get(x)).getAttribute("challenge_name")).include(request, response);
	        	CodeGeneratorPool curPool = CodeGeneratorPool.getInstance();
	        	curPool.insertGeneration(myConnector, myUser, sc, ((String)((DBObj)myChallenges.get(x)).getAttribute("challenge_name")));
	        %>
	        
	        Generating...
	        
	        <%
	        }
	        else
	        {
	        %>
	        <a href="ChallengeObfuscatedFileServer?challengeName=<%= ((DBObj)myChallenges.get(x)).getAttribute("challenge_name") %>">
	        Download
	        </a>
	        <%
	        }
	        %>
	        </td>
	        <td width="<% out.print(100/((double)keys.size() + 5)); %>%">
	        <input style="width:100% !important;" form="uploadForm_<%=x %>" type="file" name="writeFile" size="50" />
	        </td>
	        <td width="<% out.print(100/((double)keys.size() + 5)); %>%">
	        <input style="width:100% !important;" form="uploadForm_<%=x %>" type="file" name="codeFile" size="50" />
	        </td>
	        <td width="<% out.print(100/((double)keys.size() + 5)); %>%">
	        <input form="uploadForm_<%=x %>" type="hidden" name="challengeName" value="<%= ((DBObj)myChallenges.get(x)).getAttribute("challenge_name") %>" />
            <input form="uploadForm_<%=x %>" type="submit" value="Submit" />
	        </td>
	        <td width="<% out.print(100/((double)keys.size() + 5)); %>%">
	        <%
	        System.out.println(myUser.getAttributeNames());
	        if((boolean)myUser.getAttribute("downloadedDataCollection"))
	        {
	        %>
	        <input form="uploadForm_<%=x %>" type="checkbox" name="uploadData" value="true" /> Upload
	        <%
	        }
	        %>
	        </td>
        </tr>
        <%
        	if(!curSet.equals(nextSet))
        	{
        		%>
        		</tr>
        		<tr>
        		<td colspan = "<%=keys.size() + 5%>">
        		<hr></hr>
        		</td>
        		</tr>
        		<%
        	}
        }
        for(int x=0; x<passedAllList.size(); x++)
        {
        	%>
        	<script>
        	
        	document.getElementById("challenge_number_<%=passedAllList.get(x) %>").style.backgroundColor="#fff9ad";
        	
        	</script>
        	<%
        }
        }
        else if(myUser.getAttribute("role").equals("admin") && false)
        {
        	ArrayList myChallenges = myConnector.getAdminChallenges((String)myUser.getAttribute("email"));
        	if(verbose)
            {
            	System.out.println(myChallenges);
            }
            ArrayList keys = ((DBObj)myChallenges.get(0)).getAttributeNames();
            ConcurrentHashMap translationMap = new ConcurrentHashMap();
            translationMap.put("admin_email", "Instructor");
            translationMap.put("challenge_name", "Assignments");
            translationMap.put("open_time", "Open");
            translationMap.put("end_time", "Close");
            translationMap.put("grade", "Grade");
            translationMap.put("num_grading_iterations", "Total Tests");
            translationMap.put("auto_grade_score", "Tests Passed");
            boolean graded = (int)(((DBObj)myChallenges.get(0)).getAttribute("auto_grade")) == 0;
            graded = false;
            for(int x=0; x<keys.size(); x++)
            {
            	String tmp=(String)keys.get(x);
            	if(tmp.equals("email")
            			|| tmp.equals("code_generated")
            			|| tmp.equals("end_time")
            			|| tmp.equals("open_time")
            			|| tmp.equals("description")
            			|| tmp.equals("originalFile")
            			|| tmp.equals("obfuscatedFile")
            			|| tmp.equals("submittedFile")
            			|| tmp.equals("submissionTime")
            			|| tmp.equals("submittedWrittenFile")
            			|| tmp.equals("type")
            			|| tmp.equals("grade")
            			|| tmp.equals("admin_email")
            			|| tmp.equals("gradingFile")
            			|| tmp.equals("auto_grade")
            			|| (!graded && tmp.equals("num_grading_iterations"))
            			|| (!graded && tmp.equals("auto_grade_score"))
            			|| tmp.equals("codeGeneratedTime")
            			|| tmp.equals("correct")
            			|| tmp.equals("in_progress")
            			|| tmp.equals("performance")
            			|| tmp.equals("iterations_passed")
            			|| tmp.equals("test_number")
            			|| tmp.equals("num_iterations")
            			|| tmp.equals("performance_multiplier")
            			|| tmp.equals("seed")
            			|| tmp.equals("randomSeed")
            			|| tmp.equals("participantSeed")
            			|| tmp.equals("open_time")
            			|| tmp.equals("end_time")
            			|| tmp.equals("cachedOriginal")
            			|| tmp.equals("cachedObfuscated")
            			|| tmp.equals("cachedGrading")
            			|| tmp.equals("is_compiled")
            			|| tmp.equals("ctf_points"))
            	{
            		keys.remove(x);
            		x--;
            	}
            }
            keys.add("open_time");
            keys.add("end_time");
            for(int x=0; x<keys.size(); x++)
            {
            %>
            <td width="<% out.print(100/(double)(keys.size() + 1)); %>%">
            <div align="center">
            <b>
            <%
            	if(translationMap.containsKey(keys.get(x)))
            	{
            		out.print(translationMap.get(keys.get(x)));
            	}
            	else
            	{
            		out.print(keys.get(x));
            	}
            %>
            </b>
            </div>
            </td>
            <%
            }
            %>
            <td width="<% out.print(100/(double)(keys.size() + 1)); %>%">
            <div align="center">
            <b>
            Manage
            </b>
            </div>
            </td>
            </tr>
            <%
            String lastName = "";
            for(int x=0; x<myChallenges.size(); x++)
            {
            %>
            <tr>
    	        <%
    	        for(int y=0; y<keys.size(); y++)
    	        {
    	        %>
    	        <td width="<% out.print(100/(double)keys.size()); %>%">
    	        <div align="left">
    	        <%
    	        	if(keys.get(y).equals("open_time") || keys.get(y).equals("end_time"))
    	        	{
    	        		java.util.Date tmpDate = (java.util.Date)((DBObj)myChallenges.get(x)).getAttribute(keys.get(y));
    	        		out.print(dateFormat.format(tmpDate));
    	        	}
    	        	else if(keys.get(y).equals("challenge_name"))
    	        	{
    	        		lastName = (String)((DBObj)myChallenges.get(x)).getAttribute(keys.get(y));
    	        		%>
    	        		<a href="viewChallenge.jsp?challengeName=<%= ((DBObj)myChallenges.get(x)).getAttribute(keys.get(y)) %>">
    	        		<%
    	        		out.print(((DBObj)myChallenges.get(x)).getAttribute(keys.get(y)));
    	        		%>
    	        		</a>
    	        		<%
    	        	}
    	        	else
    	        	{
    	        		out.print(((DBObj)myChallenges.get(x)).getAttribute(keys.get(y)));
    	        	}
    	        %>
    	        </div>
    	        </td>
    	        <%
    	        }
    	        %>
    	        <td width="<% out.print(100/(double)keys.size()); %>%">
    	        <div align="center">
    	        <a href="manageChallenge.jsp?challengeName=<%= lastName %>">
    	        Manage
    	        </a>
    	        </div>
    	        </td>
            </tr>
            <%
            }
        }
        %>
        </table>
        </td>
        </tr>
        </table>
        </td>
        </tr>
        </table>
        </td>
        <td width="10%">
        <!--
        <table class="inner_content_table">
        <tr>
        <td>
        <%
        if(verbose)
        {
        	System.out.println("Got to hasUser conditional");
        }
		if(!hasUser)
		{
		%>
        	<table class="news_table" width="100%">
            <tr class="title_general">
            <td>
        	<div align="center">Login<br /></div>
            </td>
            </tr>
            </table>
            <table class="news_item_table" width="100%">
            <tr>
            <td>
        	<%@include file="./WEB-INF/includes/loginWindow.jsp" %>
            </td>
            </tr>
            </table>
        <%
		}
		else
		{
		%>
        	<table class="news_table" width="100%">
            <tr class="title_general">
            <td>
        	<div align="center">Logout<br /></div>
            </td>
            </tr>
            </table>
        	<table class="news_item_table" width="100%">
            <tr>
            <td>
        	<div align="center">Hi there, <%=displayName %>! Your last visit was <%
				java.util.Date logonDate=(java.util.Date)myUser.getAttribute("previousVisit");
				out.print(dateFormat.format(logonDate));
				%>.<br />Not you?<br /></div>
            <%@include file="./WEB-INF/includes/logoutWindow.jsp" %>
            </td>
            </tr>
            </table>
        <%
		}
		if(verbose)
        {
        	System.out.println("Got past hasUser conditional");
        }
		%>
        </td>
        </tr>
        </table>
        -->
        </td>
    </tr>
</table>
<%@include file="./WEB-INF/includes/footer.jsp" %>
</body>

</html>