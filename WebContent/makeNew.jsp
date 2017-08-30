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
        <%
        ArrayList myChallengesFull = new ArrayList();
        //ArrayList challengeAssignment = new ArrayList();
        ArrayList alreadyAssignedList = new ArrayList();
        ArrayList allStudents = new ArrayList();
        ArrayList selectedDefault = new ArrayList();
        ArrayList defaultChallenges = new ArrayList();
        
        
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
        	
        	defaultChallenges = myConnector.getChallengeDefaults((String)myUser.getAttribute("email"));
        	
        	DBObj headChallenge = (DBObj)defaultChallenges.get(0);
        	
        	selectedDefault = myConnector.getChallengeDefault(request.getParameter("default"));
        	
        	if(selectedDefault == null || selectedDefault.isEmpty())
        	{
        		selectedDefault = myConnector.getChallengeDefault((String)headChallenge.getAttribute("challenge_name"));
        	}
        	
	        myChallengesFull = myConnector.getChallenge((String)request.getParameter("challengeName"), (String)myUser.getAttribute("email"));
	        //challengeAssignment = myConnector.getChallengeAssignment((String)myUser.getAttribute("email"), (String)request.getParameter("challengeName"));
	        allStudents = myConnector.getAdminStudents((String)myUser.getAttribute("email"));
	        
	      
        }
        %>
        <script>
        totalCommands = 0;
        </script>
        </table>
        </td>
        <td width="50%">
        <table class="inner_content_table">
        <tr>
        <td>
        <%
        	
        	if(selectedDefault != null && !selectedDefault.isEmpty())
        	{
        	DBObj topLevel = (DBObj)selectedDefault.get(0);
        %>
        <form id="updateForm" action="updateChallengeDefault.jsp">
        <input type="hidden" name="new_type" value="challenge"></input>
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        Enter Challenge Information
        </td>
    	</tr>
        <tr colspan="2" width="100%">
        <td>
        <table class="news_item_table" width="100%" id="challengeTable">
        <tr>
        <td width="100%">
        <input form="updateForm" form="updateForm" style="width:100%" onfocus="clearText(this);" type="text" name="challenge_name" value="Challenge Name"></input>
        </td>
        </tr>
        
        <tr>
        <td width="100%">
        <textarea rows="10" form="updateForm" style="width:100%" onfocus="clearText(this);" name="description">Challenge description/notes.</textarea>
        </td>
        </tr>
        <script>
        totalCommands = <%=selectedDefault.size() %>;
        </script>
        <tr>
        <td colspan="2">
        <table id="hiddenTable" width="100%">
        <tr>
        <td colspan="2">
        &nbsp;
        </td>
        </tr>
        <tr class="title_general">
        <td colspan="2" align="center">
        Enter Obfuscation Instructions
        </td>
    	</tr>
        <%
        boolean didCompile = false;
        for(int x=0; x<selectedDefault.size(); x++)
        {
        	DBObj curObj = (DBObj)selectedDefault.get(x);
        	if(x >= 2)
        	{
        		didCompile = true;
        		boolean isCompiled = curObj.getAttribute("commandName").equals("gcc");
        		String isCompiledString = "checked=\"checked\"";
        		if(!isCompiled)
        		{
        			isCompiledString = "";
        		}
        		%>
        		<tr>
        		<td colspan="2">
        		<table class="news_item_table" width="100%">
        		<tr>
	        	<td colspan="2">
	        	<div align="center">
	        	<b>
	        	Compile for Binary Challenge
	        	</b>
	        	</div>
	        	</td>
	        	</tr>
	        	<tr>
	        	<td width="10%" style="vertical-align:middle;">
		        Compile:
		        </td>
		        <td width="90%" style="vertical-align:middle;">
		        <input type="checkbox" form="updateForm" onchange="toggleGcc(this)" <%=isCompiledString %>></input>
		        <script>
		        function toggleGcc(theBox)
		        {
		        	console.log(theBox);
		        }
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
        	<tr>
        	<td colspan="2">
        	<table class="news_item_table" width="100%">
        	<tr>
        	<td colspan="2">
        	<div align="center">
        	<b>
        	<%=step %>
        	</b>
        	</div>
        	</td>
        	</tr>
        	<tr style="display:none;">
        	<td width="10%" style="vertical-align:middle;">
	        Number:
	        </td>
	        <td width="90%">
	        <input form="updateForm" style="width:100%" type="text" name="command_order_<%=x %>" value="<%=curObj.getAttribute("command_order") %>"></input>
	        </td>
        	</tr>
        	<tr>
        	<td width="10%" style="vertical-align:middle;">
	        Command:
	        </td>
	        <td width="90%">
	        tigress
	        <input form="updateForm" style="width:100%" type="hidden" name="commandName_<%=x %>" value="<%=curObj.getAttribute("commandName") %>"></input>
	        </td>
        	</tr>
        	<tr>
        	<td width="10%" style="vertical-align:middle;">
	        Arguments:
	        </td>
	        <td width="90%">
	        <textarea rows="10" form="updateForm" style="width:100%" name="command_<%=x %>"><%=curObj.getAttribute("command") %></textarea>
	        </td>
        	</tr>
        	</table>
        	</td>
        	</tr>
        	<%
        	}
        }
        if(!didCompile)
        {
        	%>
    		<tr>
    		<td colspan="2">
    		<table class="news_item_table" width="100%">
        	<tr>
        	<td width="10%" style="vertical-align:middle;">
	        Compile:
	        </td>
	        <td width="90%">
	         <input type="checkbox" form="updateForm" onchange="toggleGcc(this)"></input>
		        <script>
		        function toggleGcc(theBox)
		        {
		        	//console.log(document.getElementById("totalAdd"));
		        	if(theBox.checked)
	        		{
		        		document.getElementById("totalAdd").value = "<%=selectedDefault.size() %>";
	        		}
		        	else
	        		{
	        			document.getElementById("totalAdd").value = "<%=selectedDefault.size() - 1 %>";
	        		}
		        	//console.log(document.getElementById("totalAdd"));
		        }
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
        %>
        </table>
        </td>
        </tr>
        </table>
        </td>
        </tr>
        <tr>
        <td>
        <table width="100%">
        <tr>
        <td width="50%">
        <input form="updateForm" type="hidden" name="totalAdd" id="totalAdd" value="<%=selectedDefault.size() - 1 %>"></input>
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
        </form>
        <%
        	}
        	else
        	{
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
        <td width="100%">
        <div align="center">
        Select a problem on the right and push "Submit" to load it.
        </div>
        </td>
        </tr>
        </table>
        </td>
        </tr>
        </table>
        		<%
        	}
        %>
        </td>
        </tr>
        <tr style="display:none;">
        <td width="100%">
        <form id="selectDefault" action="makeNew.jsp">
        <table class="news_table" width="100%" style="display:none;">
        <tr class="title_general">
        <td colspan="3" align="center">
        Load Default Settings
        </td>
    	</tr>
    	<tr>
        <td width="100%">
        <div align="center">
        <select name="default" form="selectDefault" onchange="changeProblem(this)" width="100%">
        <%
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
		<input form="selectDefault" type="submit" value="Load"></input>
		</div>
		</td>
		</tr>
		<script>
		var problemDescs = {};
		var problemCommands = {};
		var problemCommandNum = {};
		var problemCommandName = {};
		<%
			doneMap = new HashMap();
			HashMap problemMaxMap = new HashMap();
        	for(int x=0; x<defaultChallenges.size(); x++)
        	{
        		DBObj curChallenge = (DBObj)defaultChallenges.get(x);
        		int max = 0;
        		if(problemMaxMap.containsKey(curChallenge.getAttribute("challenge_name")))
        		{
        			max = (Integer)problemMaxMap.get(curChallenge.getAttribute("challenge_name"));
        		}
        		
        		int newMax = (Integer)curChallenge.getAttribute("command_order");
        		if(newMax > max)
        		{
        			problemMaxMap.put(curChallenge.getAttribute("challenge_name"), newMax);
        		}
        		
        		%>
        		problemCommands["<%=curChallenge.getAttribute("challenge_name") %>Command<%=curChallenge.getAttribute("command_order") %>"] = "<%=curChallenge.getAttribute("command") %>";
        		problemCommandName["<%=curChallenge.getAttribute("challenge_name") %>Command<%=curChallenge.getAttribute("command_order") %>"] = "<%=curChallenge.getAttribute("commandName") %>";
        		<%
        		if(doneMap.containsKey(curChallenge.getAttribute("challenge_name")))
        		{
        			continue;
        		}
        		else
        		{
        			doneMap.put(curChallenge.getAttribute("challenge_name"), true);
        		}
        		//System.out.println(curChallenge.getAttributes());
        %>
				problemDescs["<%=curChallenge.getAttribute("challenge_name") %>"] = "<%=curChallenge.getAttribute("description") %>";
		<%
        	}
        	
        	Iterator curIterator = problemMaxMap.entrySet().iterator();
        	while(curIterator.hasNext())
        	{
        		Map.Entry curEntry = (Map.Entry)curIterator.next();
        		%>
        		problemCommandNum["<%=curEntry.getKey() %>"] = <%=curEntry.getValue() %>;
        		<%
        	}
        	
		%>
    	
    	function changeProblem(selectEle)
    	{
    		//console.log(selectEle);
    		//console.log(selectEle.value);
    		var numCommands = problemCommandNum[selectEle.value];
    		var hiddenTableHTML = "";
    		for(var x=0; x<=numCommands; x++)
    		{
    			console.log(x);
    			//console.log(problemCommandName[selectEle.value + "Command" + x]);
    			//console.log(problemCommands[selectEle.value + "Command" + x]);
    			hiddenTableHTML += "<tr>\
            	<td colspan=\"2\">\
            	<table class=\"news_item_table\" width=\"100%\">\
            	<tr>\
            	<td width=\"33%\">\
    	        Command Number:\
    	        </td>\
    	        <td width=\"67%\">\
    	        <input form=\"updateForm\" style=\"width:90%\" type=\"text\" name=\"command_order_" + x + "\" value=\"" + x + "\"></input>\
    	        </td>\
            	</tr>\
            	<tr>\
            	<td width=\"33%\">\
    	        Command:\
    	        </td>\
    	        <td width=\"67%\">\
    	        <input form=\"updateForm\" style=\"width:90%\" type=\"text\" name=\"commandName_" + x + "\" value=\"" + problemCommandName[selectEle.value + "Command" + x] + "\"></input>\
    	        </td>\
            	</tr>\
            	<tr>\
            	<td width=\"33%\">\
    	        Arguments:\
    	        </td>\
    	        <td width=\"67%\">\
    	        <input type=\"text\" form=\"updateForm\" style=\"width:90%\" name=\"command_" + x + "\" value=\"" + problemCommands[selectEle.value + "Command" + x] + "\">\
    	        </td>\
            	</tr>\
            	</table>\
            	</td>\
            	</tr>\
            	"
    		}
    		//document.getElementById("hiddenTable").innerHTML = hiddenTableHTML;
    		document.getElementById("descriptionCell").innerHTML = problemDescs[selectEle.value];
    	}
    	
    	</script>
		<tr>
		<td>
		<div align="center">
		<b>Problem Description</b>
		</div>
		</td>
		</tr>
		<tr>
		<td id="descriptionCell">
		<%
		DBObj firstChallenge = (DBObj)defaultChallenges.get(0);
        	%>
        	<%=firstChallenge.getAttribute("description") %>
        	<%
        
        %>
		</td>
		</tr>
    	</table>
    	</form>
        </table>
        </td>
        <td width="25%">
        
        </td>
    </tr>
</table>
<%@include file="./WEB-INF/includes/footer.jsp" %>
</body>

</html>