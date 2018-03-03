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
    	<td colspan="3" class="no_bottom_padding">
    	<div align="center">
    	<table id="page_title_table_row">
    	<tr>
    	<td>
        <div align="center" id="inner_content_title">
        <%
        String refreshChallenge = "";
        String refreshChallengeName = "";
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
        Obfuscation Made Easy
        </div>
        </td>
        </tr>
        </table>
        </div>
        </td>
    </tr>
	<tr>
    	<td width="25%">
        <table class="inner_content_table">
        <tr>
        <td>
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        Assign To
        </td>
    	</tr>
    	<form action="updateChallenge.jsp">
        <%
        ArrayList myChallengesFull = new ArrayList();
        ArrayList challengeAssignment = new ArrayList();
        ArrayList alreadyAssignedList = new ArrayList();
        ArrayList allStudents = new ArrayList();
        if(!hasUser || !(myUser.getAttribute("role").equals("admin")))
        {
        	%>
        	<meta http-equiv="refresh" content="0; url=index.jsp" />
        	<%
        }
        else
        {
        	String newType = "challenge";
        	//newType = (String)request.getParameter("new_type");
        	
        	String prevChallenge = null;
        	prevChallenge = (String)request.getParameter("prev_challenge_name");
        	
        	String challengeName = (String)request.getParameter("challenge_name");
        	refreshChallenge = challengeName;
        	refreshChallengeName = refreshChallenge;
        	//String openTime = (String)request.getParameter("open_time");
        	//String endTime = (String)request.getParameter("end_time");
        	String description = (String)request.getParameter("description");
        	int numCommands = new Integer((String)request.getParameter("totalAdd"));
        	
        	int numTestCases = new Integer((String)request.getParameter("num_tests"));
        	boolean autoGrade = numTestCases >= 0;
        	
        	if(verbose)
        	{
        		System.out.println("Prev challenge: " + prevChallenge);
        		System.out.println("New Name: " + challengeName);
        		System.out.println("Test Cases: " + numTestCases);
        	}
        	
        	boolean success = false;
        	if(prevChallenge != null)
        	{
        		success = myConnector.updateChallengeDefault(prevChallenge, challengeName, description, autoGrade);
        		if(success)
        		{
        			myConnector.deleteCommandsDefault(challengeName, (String)myUser.getAttribute("email"));
        			myConnector.deleteTestsDefault(challengeName, (String)myUser.getAttribute("email"));
        		}
        		if(!success)
            	{
            		refreshChallenge = "Failed to update challenge.";
            	}
        		else
        		{
        			refreshChallenge = "Updated " + refreshChallenge + ".";
        		}
        		
        	}
        	else
        	{
        		if(newType.equals("challenge"))
        		{
        			success = myConnector.createChallengeDefault(challengeName, description, (String)myUser.getAttribute("email"), autoGrade);
        			if(!success)
                	{
                		refreshChallenge = "Failed to create challenge.";
                	}
            		else
            		{
            			refreshChallenge = "Created " + refreshChallenge + ".";
            		}
        		}
        	}
        	
        	//if(newType.equals("assignment"))
        	{
	        	for(int x=0; success && x<=numCommands; x++)
	        	{
	        		String commandOrder = (String)request.getParameter("command_order_" + x);
	        		String commandName = (String)request.getParameter("commandName_" + x);
	        		String command = (String)request.getParameter("command_" + x);
	        		System.out.println("Got command: " + commandOrder + ":" + commandName);
	        		if(command == null)
	        		{
	        			command = "";
	        		}
	        		myConnector.addCommandDefault(commandOrder, commandName, command, challengeName, (String)myUser.getAttribute("email"));
	        	}
	        	
	        	
		        myChallengesFull = myConnector.getChallengeDefault(challengeName, (String)myUser.getAttribute("email"));
		        //challengeAssignment = myConnector.getChallengeAssignment((String)myUser.getAttribute("email"), challengeName);
		        //allStudents = myConnector.getAdminStudents((String)myUser.getAttribute("email"));
		        for(int x=0; success && x<=numTestCases; x++)
		        {
		        	String numIterations = (String)request.getParameter("iterations_" + x);
		        	String performance = (String)request.getParameter("performance_" + x);
		        	int numArgs = new Integer((String)request.getParameter("num_args_" + x));
		        	myConnector.addGradeDefault(challengeName, x, numIterations, performance, (String)myUser.getAttribute("email"));
		        	for(int y=0; y<=numArgs; y++)
		        	{
		        		String curType = (String)request.getParameter("arg_type_" + x + "_" + y);
		        		if(curType.equals("literal"))
		        		{
		        			String curValue = (String)request.getParameter("arg_value_" + x + "_" + y);
		        			myConnector.addGradeDefaultArg(challengeName, x, y, curType, curValue, (String)myUser.getAttribute("email"));
		        		}
		        		else
		        		{
		        			myConnector.addGradeDefaultArg(challengeName, x, y, curType, (String)myUser.getAttribute("email"));
		        		}
		        	}
		        }
        	}
	        
	        HashMap fastLookupMap = new HashMap();
	        for(int x=0; success && x<challengeAssignment.size(); x++)
	        {
	        	DBObj curObj = (DBObj)challengeAssignment.get(x);
	        	fastLookupMap.put(curObj.getAttribute("email"), true);
	        }
	        for(int x=0; success && x<allStudents.size(); x++)
	        {
	        	DBObj curObj = (DBObj)allStudents.get(x);
	        	if(!fastLookupMap.containsKey(curObj.getAttribute("email")))
	        	{
	        		fastLookupMap.put(curObj.getAttribute("email"), false);
	        	}
	        	String curAssign = request.getParameter("assign_" + curObj.getAttribute("email"));
	        	if(curAssign == null && ((boolean)fastLookupMap.get(curObj.getAttribute("email"))) == true)
	        	{
	        		//System.out.println("is unchecked but was checked");
	        		myConnector.unassignChallenge(challengeName, (String)curObj.getAttribute("email"));
	        	}
	        	else if(curAssign != null && ((boolean)fastLookupMap.get(curObj.getAttribute("email"))) == false)
	        	{
	        		//System.out.println("is checked but was unchecked");
	        		myConnector.assignChallenge(challengeName, (String)curObj.getAttribute("email"));
	        	}
	        	//System.out.println(curObj.getAttribute("email"));
	        	//System.out.println(curAssign);
	        }
	        
	        for(int x=0; x<challengeAssignment.size(); x++)
	        {
	        	DBObj curObj = (DBObj)challengeAssignment.get(x);
	        	if(curObj.getAttribute("email").equals(myUser.getAttribute("email")))
	        	{
	        		continue;
	        	}
	        	alreadyAssignedList.add(curObj.getAttribute("email"));
		        %>
		        <tr colspan="3" width="100%:">
		        <td>
		        <table class="news_item_table" width="100%">
		        <tr>
		        <td width="75%">
		        <%=curObj.getAttribute("email") %>
		        </td>
		        <td>
		        <input type="checkbox" name="assign_<%=curObj.getAttribute("email") %>" checked="checked"></input>
		        </td>
		    	</tr>
		    	</table>
		    	</td>
		        <%
	        }
	        
	        for(int x=0; x<allStudents.size(); x++)
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
		        <tr colspan="3" width="100%:">
		        <td>
		        <table class="news_item_table" width="100%">
		        <tr>
		        <td width="75%">
		        <%=curObj.getAttribute("email") %>
		        </td>
		        <td>
		        <input type="checkbox" name="assign_<%=curObj.getAttribute("email") %>"></input>
		        </td>
		    	</tr>
		    	</table>
		    	</td>
		        <%
	        }
        }
        %>
        <script>
        totalCommands = <%=myChallengesFull.size() - 1 %>;
        </script>
        <tr>
        <td colspan="3">
        <div align="center">
        <input type="submit", value="Submit"></input>
        </div>
        </td>
        </tr>
        </tr>
    	</table>
        </td>
        </tr>
        </table>
        </td>
        <td width="50%">
        <table class="inner_content_table">
        <tr>
        <td>
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        Challenge Information
        </td>
    	</tr>
        <tr colspan="2" width="100%">
        <td>
        <table class="news_item_table" width="100%" id="challengeTable">
        <%
        DBObj challengeHead = (DBObj)myChallengesFull.get(0);
        %>
        <tr>
        <td width="33%">
        Challenge Name:
        </td>
        <td width="67%">
        <input form="updateForm" type="hidden" name="prev_challenge_name" value="<%=challengeHead.getAttribute("challenge_name") %>"></input>
        <input form="updateForm" style="width:90%" type="text" name="challenge_name" value="<%=challengeHead.getAttribute("challenge_name") %>"></input>
        </td>
        </tr>
        <tr>
        <td width="33%">
        Open:
        </td>
        <td width="67%">
        <input form="updateForm" style="width:90%" type="text" name="open_time" value="<%=challengeHead.getAttribute("open_time") %>"></input>
        </td>
        </tr>
        <tr>
        <td width="33%">
        End:
        </td>
        <td width="67%">
        <input form="updateForm" style="width:90%" type="text" name="end_time" value="<%=challengeHead.getAttribute("end_time") %>"></input>
        </td>
        </tr>
        <tr>
        <td width="33%">
        Description:
        </td>
        <td width="67%">
        <textarea style="width:90%" name="description"><%=challengeHead.getAttribute("description") %></textarea>
        </td>
        </tr>
        <%
        for(int x=0; x<myChallengesFull.size(); x++)
        {
        	challengeHead = (DBObj)myChallengesFull.get(x);
        	%>
        	<tr>
        	<td colspan="2">
        	<table class="news_item_table" width="100%">
        	<tr>
        	<td width="33%">
	        Command Number:
	        </td>
	        <td width="67%">
	        <input form="updateForm" style="width:90%" type="text" name="command_order_<%=x %>" value="<%=challengeHead.getAttribute("command_order") %>"></input>
	        </td>
        	</tr>
        	<tr>
        	<td width="33%">
	        Command:
	        </td>
	        <td width="67%">
	        <input form="updateForm" style="width:90%" type="text" name="commandName_<%=x %>" value="<%=challengeHead.getAttribute("commandName") %>"></input>
	        </td>
        	</tr>
        	<tr>
        	<td width="33%">
	        Arguments:
	        </td>
	        <td width="67%">
	        <textarea style="width:90%" name="command_<%=x %>"><%=challengeHead.getAttribute("command") %></textarea>
	        </td>
        	</tr>
        	</table>
        	</td>
        	</tr>
        	<%
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
        <input form="updateForm" type="button" value="Add Another Command" onclick="addAnotherCommand()"></input>
        </td>
        <td width="50%">
        <div align="right">
        <input form="updateForm" type="submit" value="Submit"></input>
        </div>
        </td>
        </tr>
        </table>
        </form>
        </td>
        </tr>
        </table>
        </td>
        </tr>
        </table>
        </td>
        <td width="25%">
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
        </td>
    </tr>
</table>
<meta http-equiv="refresh" content="0; url=manageChallengeDefault.jsp?challengeName=<%=refreshChallengeName %>&alert_message=<%=refreshChallenge %>" />
<%@include file="./WEB-INF/includes/footer.jsp" %>
</body>

</html>