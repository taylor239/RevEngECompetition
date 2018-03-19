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
    
	<tr>
    	<td width="25%">
        
        <%
        ArrayList myChallengesFull = new ArrayList();
        ArrayList myChallengesFullGrade = new ArrayList();
        ArrayList challengeAssignment = new ArrayList();
        ArrayList alreadyAssignedList = new ArrayList();
        ArrayList allStudents = new ArrayList();
        
        boolean detailed = true;
        String nonDetailedAppend = "style=\"display:none;\"";
        String detailedAppend = "";
        
        if(!hasUser || !(myUser.getAttribute("role").equals("admin")))
        {
        	%>
        	<meta http-equiv="refresh" content="0; url=index.jsp" />
        	<%
        }
        else
        {
        	if(verbose)
        	{
        		System.out.println((String)request.getParameter("challengeName"));
        		System.out.println((String)myUser.getAttribute("email"));
        	}
        	
	        myChallengesFull = myConnector.getChallenge((String)request.getParameter("challengeName"), (String)myUser.getAttribute("email"));
	        
	        if(((DBObj)myChallengesFull.get(0)).getAttribute("auto_grade").equals(true))
	        {
	        	System.out.println("getting grading");
	        	myChallengesFullGrade = myConnector.getChallengeAutoGrade((String)myUser.getAttribute("email"), (String)request.getParameter("challengeName"));
	        	System.out.println(myChallengesFullGrade);
	        }
	        	
	        allStudents = myConnector.getAdminStudents((String)myUser.getAttribute("email"));
	        
	        if(verbose)
	        {
	        	System.out.println(myChallengesFull);
	        }
	        
	        DBObj challengeHead = (DBObj)myChallengesFull.get(0);
	        //boolean detailed = true;
	        //if((((DBObj)myChallengesFull.get(0)).getAttribute("type")).equals("assignment"))
	        //{
	        	detailed = false;
	        //}
	        //String nonDetailedAppend = "style=\"display:none;\"";
	        if(detailed)
	        {
	        	nonDetailedAppend = "";
	        	detailedAppend = "style=\"display:none;\"";
	        }
	        
	        ArrayList courseNames = new ArrayList();
	        HashMap allStudentsMap = new HashMap();
	        HashMap assignedMap = new HashMap();
	        
	        for(int x=0; x<challengeAssignment.size(); x++)
	        {
	        	DBObj curObj = (DBObj)challengeAssignment.get(x);
	        	String course = (String)curObj.getAttribute("course");
	        	if(course.equals(""))
	        	{
	        		continue;
	        	}
	        	
	        	if(!courseNames.contains(course))
	        	{
	        		courseNames.add(course);
	        	}
	        	
	        	ArrayList assignList = new ArrayList();
	        	if(assignedMap.containsKey(course))
	        	{
	        		assignList = (ArrayList)assignedMap.get(course);
	        	}
	        	assignList.add(curObj);
	        	assignedMap.put(course, assignList);
	        }
	        
	        for(int x=0; x<allStudents.size(); x++)
	        {
	        	DBObj curObj = (DBObj)allStudents.get(x);
	        	String course = (String)curObj.getAttribute("course");
	        	if(course.equals(""))
	        	{
	        		continue;
	        	}
	        	
	        	if(!courseNames.contains(course))
	        	{
	        		courseNames.add(course);
	        	}
	        	
	        	ArrayList allList = new ArrayList();
	        	if(allStudentsMap.containsKey(course))
	        	{
	        		allList = (ArrayList)allStudentsMap.get(course);
	        	}
	        	allList.add(curObj);
	        	allStudentsMap.put(course, allList);
	        }
	        
	        int count = 0;
	        
	        %>
	    <table class="inner_content_table"<%=" " + detailedAppend %>>
        <tr<%=" " + detailedAppend %>>
        <td>
        </td>
        </tr>
        </table>
        </td>
        <td width="50%">
        <table class="inner_content_table" width="100%">
        <tr>
        <td>
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td align="center">
        Assignment: <%=(String)request.getParameter("challengeName") %>
        </td>
        </tr>
        <tr width="100%:">
        <td>
        <table class="news_item_table" width="100%">
        <tr>
        <td width="50%">
        <div align="center">
        <a href="viewGrades.jsp?challengeName=<%=(String)request.getParameter("challengeName") %>">
        View Submission Details
        </a>
        </div>
        </td>
        
        <td width="50%">
        <div align="center">
        <a href="deleteChallenge.jsp?challengeName=<%=(String)request.getParameter("challengeName") %>">
        Delete Assignment
        </a>
        </div>
        </td>
    	</tr>
    	</table>
    	</td>
    	</tr>
    	</table>
    	</td>
    	</tr>
        </table>
        <table class="inner_content_table">
        <tr>
        <td>
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        Edit Assignment
        </td>
    	</tr>
        <tr colspan="2" width="100%">
        <td>
        <table class="news_item_table" width="100%" id="challengeTable">
        <tr>
        <td width="10%" style="vertical-align:middle;">
        Name:
        </td>
        <td width="90%">
        <input form="updateForm" type="hidden" name="prev_challenge_name" value="<%=challengeHead.getAttribute("challenge_name") %>"></input>
        <input form="updateForm" style="width:90%" type="text" name="challenge_name" value="<%=challengeHead.getAttribute("challenge_name") %>"></input>
        </td>
        </tr>
        <tr>
        <td width="10%" style="vertical-align:middle;">
        Open:
        </td>
        <td width="90%">
        <input form="updateForm" style="width:90%" type="datetime-local" name="open_time" value="<% out.print(challengeHead.getAttribute("open_time").toString().replaceAll(" ", "T")); %>"></input>
        </td>
        </tr>
        <tr>
        <td width="10%" style="vertical-align:middle;">
        End:
        </td>
        <td width="90%">
        <input form="updateForm" style="width:90%" type="datetime-local" name="end_time" value="<% out.print(challengeHead.getAttribute("end_time").toString().replaceAll(" ", "T")); %>"></input>
        </td>
        </tr>
        <tr>
        <td width="10%" style="vertical-align:middle;">
        Description:
        </td>
        <td width="90%">
        <textarea rows="10" form="updateForm" style="width:90%" name="description"><%=challengeHead.getAttribute("description") %></textarea>
        </td>
        </tr>
        <tr>
        <td width="10%" style="vertical-align:middle;">
        Seed:
        </td>
        <td width="90%">
        <input form="updateForm" style="width:90%" type="text" name="seed" value="<%=challengeHead.getAttribute("seed") %>"></input>
        </td>
        </tr>
        <tr>
        <td width="10%" style="vertical-align:middle;">
        Challenge Set:
        </td>
        <td width="90%">
        <input form="updateForm" style="width:90%" type="text" name="challengeSet" value="<%=challengeHead.getAttribute("challenge_set_name") %>"></input>
        </td>
        </tr>
        <tr<%=" " + nonDetailedAppend %>>
        <td colspan="2">
        &nbsp;
        </td>
        </tr>
        <tr class="title_general"<%=" " + nonDetailedAppend %>>
        <td colspan="2" align="center">
        Enter Obfuscation Instructions
        </td>
    	</tr>
        <%
        boolean didCompile = false;
        for(int x=0; x<myChallengesFull.size() || x<3; x++)
        {
        	if(x >= myChallengesFull.size())
        	{
        		if(x >= 2)
            	{
            		//didCompile = true;
            		//boolean isCompiled = challengeHead.getAttribute("commandName").equals("gcc");
            		//String isCompiledString = "checked=\"checked\"";
            		//if(!isCompiled)
            		//{
            		//	isCompiledString = "";
            		//}
            		%>
            		<tr<%=" " + nonDetailedAppend %>>
            		<td colspan="2">
            		<table class="news_item_table" width="100%"<%=" " + nonDetailedAppend %>>
            		<tr<%=" " + nonDetailedAppend %>>
    	        	<td colspan="2">
    	        	<div align="center">
    	        	<b>
    	        	Compile for Binary Challenge
    	        	</b>
    	        	</div>
    	        	</td>
    	        	</tr>
    	        	<tr<%=" " + nonDetailedAppend %>>
    	        	<td width="33%">
    		        Compile:
    		        </td>
    		        <td width="67%">
    		        <input type="checkbox" form="updateForm"></input>
    		        </td>
    		        </tr>
    		        </table>
            		</td>
            		</tr>
            		<%
            	}
        	}
        	else
        	{
        	challengeHead = (DBObj)myChallengesFull.get(x);
        	if(x >= 2)
        	{
        		didCompile = true;
        		boolean isCompiled = challengeHead.getAttribute("commandName").equals("gcc");
        		String isCompiledString = "checked=\"checked\"";
        		if(!isCompiled)
        		{
        			isCompiledString = "";
        		}
        		%>
        		<tr<%=" " + nonDetailedAppend %>>
        		<td colspan="2">
        		<table class="news_item_table" width="100%"<%=" " + nonDetailedAppend %>>
        		<tr<%=" " + nonDetailedAppend %>>
	        	<td colspan="2">
	        	<div align="center">
	        	<b>
	        	Compile for Binary Challenge
	        	</b>
	        	</div>
	        	</td>
	        	</tr>
	        	<tr<%=" " + nonDetailedAppend %>>
	        	<td width="33%">
		        Compile:
		        </td>
		        <td width="67%">
		        <input type="checkbox" form="updateForm" <%=isCompiledString %>></input>
		        </td>
		        </tr>
		        </table>
        		</td>
        		</tr>
        		<%
        	}
        	else
        	{
        		String step = "";
        		if(x==0)
        		{
        			step = "Generate Code Step";
        		}
        		else
        		{
        			step = "Obfuscate Code Step";
        		}
        	%>
        	<tr<%=" " + nonDetailedAppend %>>
        	<td colspan="2">
        	<div align="center">
        	<b>
        	<%=step %>
        	</b>
        	</div>
        	</td>
        	</tr>
        	<tr<%=" " + nonDetailedAppend %>>
        	<td colspan="2">
        	<table class="news_item_table" width="100%"<%=" " + nonDetailedAppend %>>
        	<tr<%=" " + nonDetailedAppend %>>
        	<td width="33%">
	        Command Number:
	        </td>
	        <td width="67%">
	        <input form="updateForm" style="width:90%" type="text" name="command_order_<%=x %>" value="<%=challengeHead.getAttribute("command_order") %>"></input>
	        </td>
        	</tr>
        	<tr<%=" " + nonDetailedAppend %>>
        	<td width="33%">
	        Command:
	        </td>
	        <td width="67%">
	        <input form="updateForm" style="width:90%" type="text" name="commandName_<%=x %>" value="<%=challengeHead.getAttribute("commandName") %>"></input>
	        </td>
        	</tr>
        	<tr<%=" " + nonDetailedAppend %>>
        	<td width="33%">
	        Arguments:
	        </td>
	        <td width="67%">
	        <textarea form="updateForm" style="width:90%" name="command_<%=x %>"><%=challengeHead.getAttribute("command") %></textarea>
	        </td>
        	</tr>
        	</table>
        	</td>
        	</tr>
        	<%
        	}
        	}
        }
        %>
        </table>
        </td>
        </tr>
        
        <tr>
        <td>
        <table width="100%">
        <tr>
        <td width="50%">
        <input form="updateForm" type="hidden" name="totalAdd" id="totalAdd" value="<%=myChallengesFull.size() - 1 %>"></input>
        <input form="updateForm" type="hidden" value="Add Another Command" onclick="addAnotherCommand()"></input>
        </td>
        <td width="50%">
        </td>
        </tr>
        </table>
        </td>
        </tr>
        
        <%
        if(!myChallengesFullGrade.isEmpty())
        {
        	int numTests = 0;
        	for(int x=0; x<myChallengesFullGrade.size(); x++)
    		{
				
    			DBObj curTest = (DBObj)myChallengesFullGrade.get(x);
    			ArrayList argList = new ArrayList();
    			argList.add(curTest);
    			if(x + 1 < myChallengesFullGrade.size())
    			{
    				int y = x + 1;
    				DBObj nextTest = (DBObj)myChallengesFullGrade.get(y);
    				while(y < myChallengesFullGrade.size() && nextTest.getAttribute("test_number").equals(curTest.getAttribute("test_number")))
    				{
    					argList.add(nextTest);
    					y++;
    					if(y < myChallengesFullGrade.size())
    					{
    						nextTest = (DBObj)myChallengesFullGrade.get(y);
    					}
    				}
    				numTests++;
    				x = y;
    			}
    		}
        %>
        		<tr style="display:none;">
            	<td colspan="2">
            	<table class="news_item_table" width="100%" style="display:none;">
            	<tr style="display:none;">
            	<td width="33%">
    	        Number of Tests:
    	        </td>
    	        <td width="67%">
    	        <input form="updateForm" style="width:90%" type="hidden" name="numTests" value="<%=numTests %>"></input>
    	        </td>
            	</tr>
            	</table>
            	</td>
            	</tr>
        		<%
        		for(int x=0; x<myChallengesFullGrade.size(); x++)
        		{

        			DBObj curTest = (DBObj)myChallengesFullGrade.get(x);
        			ArrayList argList = new ArrayList();
        			argList.add(curTest);
        			if(x + 1 < myChallengesFullGrade.size())
        			{
        				int y = x + 1;
        				DBObj nextTest = (DBObj)myChallengesFullGrade.get(y);
        				while(y < myChallengesFullGrade.size() && nextTest.getAttribute("test_number").equals(curTest.getAttribute("test_number")))
        				{
        					argList.add(nextTest);
        					y++;
        					if(y < myChallengesFullGrade.size())
        					{
        						nextTest = (DBObj)myChallengesFullGrade.get(y);
        					}
        				}
        			}
        		%>
        		<tr style="display:none;">
            	<td colspan="2">
            	<table class="news_item_table" width="100%" style="display:none;">
            	<tr style="display:none;">
            	<td width="33%">
    	        Test Number:
    	        </td>
    	        <td width="67%">
    	        <input form="updateForm" style="width:90%" type="hidden" name="test_order_<%=curTest.getAttribute("test_number") %>" value="<%=curTest.getAttribute("test_number") %>"></input>
    	        </td>
            	</tr>
            	<tr style="display:none;">
            	<td width="33%">
    	        Iterations:
    	        </td>
    	        <td width="67%">
    	        <input form="updateForm" style="width:90%" type="hidden" name="testIterations_<%=curTest.getAttribute("test_number") %>" value="<%=curTest.getAttribute("num_iterations") %>"></input>
    	        </td>
            	</tr>
            	<tr style="display:none;">
            	<td width="33%">
    	        Performance:
    	        </td>
    	        <td width="67%">
    	        <input type="hidden" form="updateForm" style="width:90%" name="testPerformance_<%=curTest.getAttribute("test_number") %>" value="<%=curTest.getAttribute("performance_multiplier") %>">
    	        </td>
            	</tr>
            	<tr style="display:none;">
            	<td width="33%">
    	        Number of Arguments:
    	        </td>
    	        <td width="67%">
    	        <input type="hidden" form="updateForm" style="width:90%" name="testArguments_<%=curTest.getAttribute("test_number") %>" value="<%=argList.size() - 1 %>">
    	        </td>
            	</tr>
        		<%
        			for(int y=0; y<argList.size(); y++)
        			{
        				DBObj curArg = (DBObj)argList.get(y);
        				%>
        				<tr style="display:none;">
	                	<td width="33%">
	        	        Argument Number:
	        	        </td>
	        	        <td width="67%">
	        	        <input type="hidden" form="updateForm" style="width:90%" name="argNum_<%=curTest.getAttribute("test_number") %>_<%=curArg.getAttribute("arg_order") %>" value="<%=curArg.getAttribute("arg_order") %>">
	        	        </td>
	                	</tr>
	                	<tr style="display:none;">
	                	<td width="33%">
	        	        Argument Type:
	        	        </td>
	        	        <td width="67%">
	        	        <input type="hidden" form="updateForm" style="width:90%" name="argType_<%=curTest.getAttribute("test_number") %>_<%=curArg.getAttribute("arg_order") %>" value="<%=curArg.getAttribute("arg_type") %>">
	        	        </td>
	                	</tr>
	                	<tr style="display:none;">
	                	<td width="33%">
	        	        Argument Value:
	        	        </td>
	        	        <td width="67%">
	        	        <input type="hidden" form="updateForm" style="width:90%" name="argValue_<%=curTest.getAttribute("test_number") %>_<%=curArg.getAttribute("arg_order") %>" value="<%=curArg.getAttribute("arg_value") %>">
	        	        </td>
	                	</tr>
        				<%
        			}
        			%>
        			</table>
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
        <%
        if(!detailed)
        {
        %>
        <form id="updateForm" action="updateChallenge.jsp">
        <table class="news_table" width="100%"<%=" " + detailedAppend %> style="display:none;">
        <tr class="title_general"<%=" " + detailedAppend %>>
        <td colspan="3" align="center">
        Assign To
        </td>
    	</tr>
	        
	        <script>
	        
	        	function selectAllStudents()
	        	{
	        		for(var x=0; x<<%=allStudents.size() %>; x++)
        			{
        				document.getElementById("studentCheck_" + x).checked = true;
        			}
	        	}
	        	
	        	function deselectAllStudents()
	        	{
	        		for(var x=0; x<<%=allStudents.size() %>; x++)
        			{
        				document.getElementById("studentCheck_" + x).checked = false;
        			}
	        	}
	        
	        </script>
	        
	    	<tr colspan="3">
	    	<td width="100%">
	    	<table class="news_item_table" width="100%">
	    	<tr style="display:none">
	    	<td width="45%">
	    	<input type="button" value="Select All" onclick="selectAllStudents()"></input>
	    	</td>
	    	<td width="10%">
	    	</td>
	    	<td width="45%">
	    	<div align="right">
	    	<input type="button" value="Deselect All" onclick="deselectAllStudents()"></input>
	    	</div>
	    	</td>
	    	</tr>
	    	</table>
	    	</td>
	    	</tr>
	        
	        <%
	        for(int x=0; x<courseNames.size(); x++)
	        {
	        	String courseName = (String)courseNames.get(x);
	        	
	        	%>
		        <script>
		        
		        	function select<%=courseName %>()
		        	{
		        		var courseEles = document.getElementsByClassName("<%=courseName %>");
		        		for(var x=0; x<courseEles.length; x++)
	        			{
	        				courseEles[x].checked=true;
	        			}
		        	}
		        	
		        	function selectCheck<%=courseName %>(curCheckbox)
		        	{
		        		var courseEles = document.getElementsByClassName("<%=courseName %>");
		        		for(var x=0; x<courseEles.length; x++)
	        			{
	        				courseEles[x].checked=true;
	        			}
		        		curCheckbox.checked=true;
		        		curCheckbox.setAttribute("onclick", "deselectCheck<%=courseName %>(this)");
		        	}
		        	
		        	function deselectCheck<%=courseName %>(curCheckbox)
		        	{
		        		var courseEles = document.getElementsByClassName("<%=courseName %>");
		        		for(var x=0; x<courseEles.length; x++)
	        			{
	        				courseEles[x].checked=false;
	        			}
		        		curCheckbox.checked=false;
		        		curCheckbox.setAttribute("onclick", "selectCheck<%=courseName %>(this)");
		        	}
		        	
		        	function deselect<%=courseName %>()
		        	{
		        		var courseEles = document.getElementsByClassName("<%=courseName %>");
		        		for(var x=0; x<courseEles.length; x++)
	        			{
	        				courseEles[x].checked=false;
	        			}
		        	}
		        	
		        	function show<%=courseName %>()
		        	{
		        		var courseEles = document.getElementsByClassName("table_<%=courseName %>");
		        		for(var x=0; x<courseEles.length; x++)
	        			{
		        			courseEles[x].style.display="table-row";
	        			}
		        	}
		        	
		        	function showPlus<%=courseName %>(curElement)
		        	{
		        		var courseEles = document.getElementsByClassName("table_<%=courseName %>");
		        		for(var x=0; x<courseEles.length; x++)
	        			{
		        			courseEles[x].style.display="table-row";
	        			}
		        		curElement.src = "minus.png";
		        		curElement.setAttribute("onclick", "hideMinus<%=courseName %>(this)");
		        		//curElement.onclick = hideMinus<%=courseName %>(curElement);
		        	}
		        	
		        	function hideMinus<%=courseName %>(curElement)
		        	{
		        		var courseEles = document.getElementsByClassName("table_<%=courseName %>");
		        		for(var x=0; x<courseEles.length; x++)
	        			{
		        			courseEles[x].style.display="none";
	        			}
		        		curElement.src="plus.png";
		        		curElement.setAttribute("onclick", "showPlus<%=courseName %>(this)");
		        		//curElement.onclick = showPlus<%=courseName %>(curElement);
		        	}
		        	
		        	function hide<%=courseName %>()
		        	{
		        		var courseEles = document.getElementsByClassName("table_<%=courseName %>");
		        		for(var x=0; x<courseEles.length; x++)
	        			{
	        				courseEles[x].style.display="none";
	        			}
		        	}
		        
		        </script>
		        
		    	
	        	<%
	        }
	        
	        for(int y=0; y<courseNames.size(); y++)
	        {
	        
	        String courseName = (String)courseNames.get(y);
	        
	        %>
	        
	        <tr colspan="3">
	    	<td width="100%">
	    	<table class="news_item_table" width="100%">
	    	<tr>
	    	<td width="10%">
	    	<img src="plus.png" class="boxedChar" onclick="showPlus<%=courseName %>(this)" />
	    	</td>
	    	<td width="40%">
	    	<b><%=courseName %></b>
	    	</td>
	    	<td width="25%">
	    	
	    	</td>
	    	<td width="25%">
	    	<div align="right">
	    	<%
	    	String classChecked = "";
	    	if(assignedMap.containsKey(courseName) && ((ArrayList) assignedMap.get(courseName)).size() == ((ArrayList) allStudentsMap.get(courseName)).size())
	    	{
	    		classChecked = "checked";
	    	%>
	    	<input type="checkbox" onclick="deselectCheck<%=courseName %>(this)" <%=classChecked %>></input>
	    	<%
	    	}
	    	else
	    	{
	    	%>
	    	<input type="checkbox" onclick="selectCheck<%=courseName %>(this)" <%=classChecked %>></input>
	    	<%
	    	}
	    	%>
	    	</div>
	    	</td>
	    	</tr>
	    	</table>
	    	</td>
	    	</tr>
	        
	        <%
	        
	        challengeAssignment = (ArrayList) assignedMap.get(courseName);
	        allStudents = (ArrayList) allStudentsMap.get(courseName);
	        
	        for(int x=0; challengeAssignment != null && x<challengeAssignment.size(); x++)
	        {
	        	DBObj curObj = (DBObj)challengeAssignment.get(x);
	        	if(curObj.getAttribute("email").equals(myUser.getAttribute("email")))
	        	{
	        		continue;
	        	}
	        	alreadyAssignedList.add(curObj.getAttribute("email"));
		        %>
		        <tr colspan="3" width="100%" class="table_<%=courseName %>" style="display:none;">
		        <td>
		        <table class="news_item_table break_table" width="100%">
		        <tr>
		        <td width="90%">
		        <%=curObj.getAttribute("email") %>
		        </td>
		        <td width="10%">
		        <div align="right">
		        <input type="checkbox" name="assign_<%=curObj.getAttribute("email") %>" id="studentCheck_<%=count++ %>" checked="checked" class="<%=curObj.getAttribute("course") %>"></input>
		        </div>
		        </td>
		    	</tr>
		    	</table>
		    	</td>
		    	</tr>
		        <%
	        }
	        
	        for(int x=0; allStudents != null && x<allStudents.size(); x++)
	        {
	        	DBObj curObj = (DBObj)allStudents.get(x);
	        	if(curObj.getAttribute("email").equals(myUser.getAttribute("email")))
	        	{
	        		continue;
	        	}
	        	if(alreadyAssignedList.contains(curObj.getAttribute("email")))
	        	{
	        		continue;
	        	}
		        %>
		        <tr colspan="3" width="100%" class="table_<%=courseName %>" style="display:none;">
		        <td>
		        <table class="news_item_table break_table" width="100%">
		        <tr>
		        <td width="90%">
		        <%=curObj.getAttribute("email") %>
		        </td>
		        <td width="10%">
		        <div align="right">
		        <input type="checkbox" name="assign_<%=curObj.getAttribute("email") %>" id="studentCheck_<%=count++ %>" class="<%=curObj.getAttribute("course") %>"></input>
		        </div>
		        </td>
		    	</tr>
		    	</table>
		    	</td>
		    	</tr>
		        <%
	        }
	        }
        %>
        <script>
        totalCommands = <%=myChallengesFull.size() - 1 %>;
        <%
        challengeHead = (DBObj)myChallengesFull.get(0);
        //boolean detailed = true;
        if((((DBObj)myChallengesFull.get(0)).getAttribute("type")).equals("assignment"))
        {
        	detailed = false;
        }
        //String nonDetailedAppend = "style=\"display:none;\"";
        if(detailed)
        {
        	nonDetailedAppend = "";
        }
        %>
        </script>
    	</table>
    	</form>
    	<%
        }
        }
    	%>
    	<div align="right">
        <input form="updateForm" type="submit" value="Submit"></input>
        </div>
        </td>
        <td width="25%">
       	
        </td>
    </tr>
</table>
<%@include file="./WEB-INF/includes/footer.jsp" %>
</body>

</html>