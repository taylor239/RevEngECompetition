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
        <table class="inner_content_table">
        <tr>
        <td>
        <form id="updateForm" action="updateChallenge.jsp">
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        Assign To
        </td>
    	</tr>
        <%
        ArrayList myChallengesFull = new ArrayList();
        //ArrayList challengeAssignment = new ArrayList();
        ArrayList alreadyAssignedList = new ArrayList();
        ArrayList allStudents = new ArrayList();
        ArrayList selectedDefault = new ArrayList();
        
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
        	
        	selectedDefault = myConnector.getChallengeDefault(request.getParameter("default"));
        	
	        myChallengesFull = myConnector.getChallenge((String)request.getParameter("challengeName"), (String)myUser.getAttribute("email"));
	        //challengeAssignment = myConnector.getChallengeAssignment((String)myUser.getAttribute("email"), (String)request.getParameter("challengeName"));
	        allStudents = myConnector.getAdminStudents((String)myUser.getAttribute("email"));
	        
	        if(verbose)
	        {
	        	System.out.println(myChallengesFull);
	        }
	        
	        ArrayList courseNames = new ArrayList();
	        HashMap allStudentsMap = new HashMap();
	        HashMap assignedMap = new HashMap();
	        
	        /*for(int x=0; x<challengeAssignment.size(); x++)
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
	        }*/
	        
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
	    	<tr>
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
	    	<input type="checkbox" onclick="selectCheck<%=courseName %>(this)"></input>
	    	</div>
	    	</td>
	    	</tr>
	    	</table>
	    	</td>
	    	</tr>
	        
	        <%
	        
	        //challengeAssignment = (ArrayList) assignedMap.get(courseName);
	        allStudents = (ArrayList) allStudentsMap.get(courseName);
	        
	        /*for(int x=0; x<challengeAssignment.size(); x++)
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
	        */
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
        }
        %>
        <script>
        totalCommands = 0;
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
    	</form>
        </td>
        </tr>
        </table>
        </td>
        <td width="50%">
        <table class="inner_content_table">
        <tr>
        <td>
        <%
        	DBObj topLevel = (DBObj)selectedDefault.get(0);
        %>
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        Challenge Information
        </td>
    	</tr>
        <tr colspan="2" width="100%">
        <td>
        <table class="news_item_table" width="100%" id="challengeTable">
        <tr>
        <td width="33%">
        Challenge Name:
        </td>
        <td width="67%">
        <input form="updateForm" form="updateForm" style="width:90%" type="text" name="challenge_name" value="<%=topLevel.getAttribute("challenge_name") %> (change this)"></input>
        </td>
        </tr>
        <tr>
        <td width="33%">
        Open:
        </td>
        <td width="67%">
        <input form="updateForm" style="width:90%" type="text" name="open_time" value="Start Time (in YYYY-MM-DD HH:MM:SS.S)"></input>
        </td>
        </tr>
        <tr>
        <td width="33%">
        End:
        </td>
        <td width="67%">
        <input form="updateForm" style="width:90%" type="text" name="end_time" value="End Time (in YYYY-MM-DD HH:MM:SS.S)"></input>
        </td>
        </tr>
        <tr>
        <td width="33%">
        Description:
        </td>
        <td width="67%">
        <textarea form="updateForm" style="width:90%" name="description"><%=topLevel.getAttribute("description") %></textarea>
        </td>
        </tr>
        <script>
        totalCommands = <%=selectedDefault.size() %>;
        </script>
        <%
        for(int x=0; x<selectedDefault.size(); x++)
        {
        	DBObj curObj = (DBObj)selectedDefault.get(x);
        	%>
        	<tr>
        	<td colspan="2">
        	<table class="news_item_table" width="100%">
        	<tr>
        	<td width="33%">
	        Command Number:
	        </td>
	        <td width="67%">
	        <input form="updateForm" style="width:90%" type="text" name="command_order_<%=x %>" value="<%=curObj.getAttribute("command_order") %>"></input>
	        </td>
        	</tr>
        	<tr>
        	<td width="33%">
	        Command:
	        </td>
	        <td width="67%">
	        <input form="updateForm" style="width:90%" type="text" name="commandName_<%=x %>" value="<%=curObj.getAttribute("commandName") %>"></input>
	        </td>
        	</tr>
        	<tr>
        	<td width="33%">
	        Arguments:
	        </td>
	        <td width="67%">
	        <textarea form="updateForm" style="width:90%" name="command_<%=x %>"><%=curObj.getAttribute("command") %></textarea>
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
        <input form="updateForm" type="hidden" name="totalAdd" id="totalAdd" value="<%=selectedDefault.size() - 1 %>"></input>
        <input form="updateForm" type="button" value="Add Another Command" onclick="addAnotherCommand()"></input>
        </td>
        <td width="50%">
        <div align="right">
        <input form="updateForm" type="submit" value="Submit"></input>
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
        </td>
        <td width="25%">
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
        <td width="100%">
        <div align="center">
        <b>
        Load Default Settings
        </b>
        </div>
        </td>
    	</tr>
    	<form action="loadDefault.jsp">
    	<tr>
        <td width="100%">
        <div align="center">
        <select name="default" width="100%">
        <%
        	ArrayList defaultChallenges = myConnector.getChallengeDefaults();
        	HashMap doneMap = new HashMap();
        	for(int x=0; x<defaultChallenges.size(); x++)
        	{
        		DBObj curChallenge = (DBObj)defaultChallenges.get(x);
        		if(doneMap.containsKey(curChallenge.getAttribute("challenge_name")))
        		{
        			continue;
        		}
        		else
        		{
        			doneMap.put(curChallenge.getAttribute("challenge_name"), true);
        		}
        %>
				<option value="<%=curChallenge.getAttribute("challenge_name") %>"><%=curChallenge.getAttribute("challenge_name") %></option>
		<%
        	}
		%>
		</select>
		</div>
		</td>
		</tr>
		<tr>
		<td>
		<div align="center">
		<input type="submit" value="Submit">
		</input>
		</div>
        </td>
    	</tr>
    	</form>
    	</table>
    	</td>
    	</tr>
    	</table>
    	</td>
    	</tr>
        </table>
        </td>
    </tr>
</table>
<%@include file="./WEB-INF/includes/footer.jsp" %>
</body>

</html>