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
        	
	        myChallengesFull = myConnector.getChallengeDefault((String)request.getParameter("challengeName"), (String)myUser.getAttribute("email"));
	        //challengeAssignment = myConnector.getChallengeAssignment((String)myUser.getAttribute("email"), (String)request.getParameter("challengeName"));
	        //allStudents = myConnector.getAdminStudents((String)myUser.getAttribute("email"));
	        
	        if(verbose)
	        {
	        	System.out.println(myChallengesFull);
	        }
	        
	        DBObj challengeHead = (DBObj)myChallengesFull.get(0);
	        //boolean detailed = true;
	        //if((((DBObj)myChallengesFull.get(0)).getAttribute("type")).equals("assignment"))
	        //{
	        //	detailed = false;
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
	    
	        
	        
	        
	    	
	        
	        <%
	        
        }
        %>
        <%
        DBObj challengeHead = (DBObj)myChallengesFull.get(0);
        //boolean detailed = true;
        //if((((DBObj)myChallengesFull.get(0)).getAttribute("type")).equals("assignment"))
        //{
        //	detailed = false;
        //}
        //String nonDetailedAppend = "style=\"display:none;\"";
        if(detailed)
        {
        	nonDetailedAppend = "";
        }
        %>
        
        </td>
        <td width="50%">
        <form id="updateForm" action="updateChallengeDefault.jsp">
        <table class="inner_content_table" width="100%">
        <tr>
        <td>
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td align="center">
        Challenge: <%=(String)request.getParameter("challengeName") %>
        </td>
        </tr>
        <tr width="100%:">
        <td>
        <table class="news_item_table" width="100%">
        <tr>
        <td width="33%">
        <div align="center">
        </div>
        </td>
        <td width="34%">
        <div align="center">
        <a href="deleteChallengeDefault.jsp?challengeName=<%=(String)request.getParameter("challengeName") %>">
        Delete Challenge
        </a>
        </div>
        </td>
        <td width="33%">
        <div align="center">
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
        <%
        //out.print("Enter " + ((String)((DBObj)myChallengesFull.get(0)).getAttribute("type")).substring(0, 1).toUpperCase() + ((String)((DBObj)myChallengesFull.get(0)).getAttribute("type")).substring(1) + " Information");
        %>
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
        Description:
        </td>
        <td width="90%">
        <textarea rows="10" form="updateForm" style="width:90%" name="description"><%=challengeHead.getAttribute("description") %></textarea>
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
    	        	<td width="10%" style="vertical-align:middle;">
    		        Compile:
    		        </td>
    		        <td width="90%" style="vertical-align:middle;">
			         <input type="checkbox" form="updateForm" onchange="toggleGcc(this)"></input>
				        <script>
				        function toggleGcc(theBox)
				        {
				        	//console.log(document.getElementById("totalAdd"));
				        	if(theBox.checked)
			        		{
				        		document.getElementById("totalAdd").value = "<%=myChallengesFull.size() %>";
			        		}
				        	else
			        		{
			        			document.getElementById("totalAdd").value = "<%=myChallengesFull.size() - 1 %>";
			        		}
				        	//console.log(document.getElementById("totalAdd"));
				        }
				        cc = "<%=myChallengesFull.size() - 1 %>";
				        </script>
				        <input form="updateForm" style="display:none;" type="text" name="command_order_2" value="2"></input>
				        <input form="updateForm" style="display:none;" type="hidden" name="commandName_2" value="gcc"></input>
				        <textarea form="updateForm" style="display:none;" name="command_2"></textarea>
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
	        	<td width="10%" style="vertical-align:middle;">
		        Compile:
		        </td>
		        <td width="90%" style="vertical-align:middle;">
			         <input type="checkbox" form="updateForm" onchange="toggleGcc(this)" checked></input>
				        <script>
				        function toggleGcc(theBox)
				        {
				        	//console.log(document.getElementById("totalAdd"));
				        	if(theBox.checked)
			        		{
				        		document.getElementById("totalAdd").value = "<%=myChallengesFull.size() - 1 %>";
			        		}
				        	else
			        		{
			        			document.getElementById("totalAdd").value = "<%=myChallengesFull.size() - 2 %>";
			        		}
				        	//console.log(document.getElementById("totalAdd"));
				        }
				        document.getElementById("totalAdd").value = "<%=myChallengesFull.size() - 1 %>";
				        </script>
				        <input form="updateForm" style="display:none;" type="text" name="command_order_2" value="2"></input>
				        <input form="updateForm" style="display:none;" type="hidden" name="commandName_2" value="gcc"></input>
				        <textarea form="updateForm" style="display:none;" name="command_2"></textarea>
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
        	<tr<%=" " + nonDetailedAppend %> style="display:none;">
        	<td width="10%" style="vertical-align:middle;">
	        Number:
	        </td>
	        <td width="90%">
	        <input form="updateForm" style="width:90%" type="hidden" name="command_order_<%=x %>" value="<%=challengeHead.getAttribute("command_order") %>"></input>
	        <%=x %>
	        </td>
        	</tr>
        	<tr<%=" " + nonDetailedAppend %>>
        	<td width="10%" style="vertical-align:middle;">
	        Command:
	        </td>
	        <td width="90%">
	        <input form="updateForm" style="width:90%" type="hidden" name="commandName_<%=x %>" value="<%=challengeHead.getAttribute("commandName") %>"></input>
	        <%=challengeHead.getAttribute("commandName") %>
	        </td>
        	</tr>
        	<tr<%=" " + nonDetailedAppend %>>
        	<td width="10%" style="vertical-align:middle;">
	        Arguments:
	        </td>
	        <td width="90%">
	        <textarea rows="10" form="updateForm" style="width:90%" name="command_<%=x %>"><%=challengeHead.getAttribute("command") %></textarea>
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
        </table>
        </td>
        </tr>
        </table>
        <%
        if(!detailed)
        {
        %>
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        Assign To
        </td>
    	</tr>
    	</table>
    	<%
        }
    	%>
    	<div align="right">
        <input form="updateForm" type="submit" value="Submit"></input>
        </div>
        </form>
        </td>
        <td width="25%">
       	
        </td>
    </tr>
</table>
<%@include file="./WEB-INF/includes/footer.jsp" %>
</body>

</html>