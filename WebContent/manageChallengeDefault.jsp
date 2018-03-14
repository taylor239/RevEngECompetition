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
        ArrayList headGrading = (ArrayList)challengeHead.getAttribute("grading");
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
        <td colspan="2">
        	<table class="news_item_table" id="test_table" width="100%">
        	<tr>
        	<td colspan="2">
        	<div align="center">
        	<b>
        	Auto Grade
        	</b>
        	</div>
        	</td>
        	</tr>
        	<tr>
        	<td>
        	Test Cases:
        	<%
        	System.out.println("Grading tests:");
        	
        	int numTests = 0;
        	
        	for(int x=0; x<headGrading.size(); x++)
        	{
        		System.out.println("Grading test");
        		DBObj curTest = (DBObj)headGrading.get(x);
        		//System.out.println(curTest.getAttributeNames());
        		System.out.println(curTest.getAttributes());
				int numArgs = 0;
	        	
	        	
	        	while(x + numArgs < headGrading.size())
	        	{
	        		DBObj tmpTest = (DBObj)headGrading.get(x + numArgs);
	        		
	        		if(!tmpTest.getAttribute("test_number").equals(curTest.getAttribute("test_number")))
	        		{
	        			break;
	        		}
	        		
	        		numArgs++;
	        	}
	        	
	        	numArgs--;
	        	
	        	System.out.println("Args: " + numArgs);
	        	
	        	x += numArgs;
	        	numTests++;
        	}
        	numTests--;
        	%>
        	<input form="updateForm" type="hidden" id="num_tests" name="num_tests" value="<%=numTests %>"></input>
        	</td>
        	<td>
        	<div align="right">
        	<script>
        	document.getElementById("num_tests").value = <%=numTests %>;
        	function addCase(element)
        	{
        		var curNum = document.getElementById("num_tests").value;
        		curNum++;
        		document.getElementById("num_tests").value = curNum;
        		var curTable = document.getElementById("test_table");
        		var newElement = document.createElement("tr");
        		var toAppend = '' +
        		'<td colspan="3" width="100%">' +
        		'<table id="test_table_' + curNum + '" width="100%">' +
	        	'<tr>' +
	        	'<td colspan="2">' +
	        	'<table width="100%" id="test_' + curNum + '">' +
	        	'<tr>' +
	        	'<td colspan="3">' +
	        	'<b>Test ' + curNum + '</b>' +
	        	'</td>' +
	        	'</tr>' +
	        	'<tr>' +
	        	'<td width="25%">' +
	        	'Number of iterations:' +
	        	'</td>' +
	        	'<td colspan="2" width="75%">' +
	        	'<div align="right">' +
	        	'<input form="updateForm" style="" type="text" name="iterations_' + curNum + '" value="1"></input>' +
	        	'<input form="updateForm" type="hidden" name="num_args_' + curNum + '" id="num_args_' + curNum + '" value="0"></input>' +
	        	'</div>' +
	        	'</td>' +
	        	'</tr>' +
	        	'<tr>' +
	        	'<td width="25%">' +
	        	'Performance cutoff:' +
	        	'</td>' +
	        	'<td colspan="2" width="75%">' +
	        	'<div align="right">' +
	        	'<input form="updateForm" style="" type="text" name="performance_' + curNum + '" value="2.0"></input>' +
	        	'</div>' +
	        	'</td>' +
	        	'</tr>' +
	        	'<tr>' +
	        	'<td width="25%">' +
	        	'Arguments:' +
	        	'</td>' +
	        	'<td width="75%" colspan="2">' +
	        	'<div align="right">' +
	        	'<img src="plus.png" style="margin-right: 1em;" class="boxedChar" onclick="addCaseArg(this, ' + curNum + ')" />' +
	        	'<img src="minus.png" class="boxedChar" onclick="subtractCaseArg(this, ' + curNum + ')" />' +
	        	'</div>' +
	        	'</td>' +
	        	'</tr>' +
	        	'<tr>' +
	        	'<td colspan="3" width="100%" id="test_arg_row_' + curNum + '">' +
	        	'<div>' +
	        	'<table id="test_arg_table_' + curNum + '_0" width="100%">' +
	        	'<tr>' +
	        	'<td width="25%">' +
	        	'0' +
	        	'</td>' +
	        	'<td width="37.5">' +
	        	'<div align="right">' +
	        	'Type:' +
	        	'<select name="arg_type_' + curNum + '_0" onchange="argTypeChange(this,' + curNum + ',0);" form="updateForm">' +
	        	'<option value="literal">Literal</option>' +
	        	'<option value="int">Integer</option>' +
	        	'<option value="long">Long</option>' +
	        	'</select>' +
	        	'</div>' +
	        	'</td>' +
	        	'<td width="37.5">' +
	        	'<div align="right">' +
	        	'<input form="updateForm" style="" type="text" id="arg_value_' + curNum + '_' + 0 + '" name="arg_value_' + curNum + '_0" value="Value"></input>' +
	        	'</div>' +
	        	'</td>' +
	        	'</tr>' +
	        	'</table>' +
	        	'</div>' +
	        	'</td>' +
	        	'</tr>' +
	        	'</table>' +
	        	'</td>' +
	        	'</tr>' +
	        	'</table>' +
	        	'</td>' +
	        	'';
        		newElement.width="100%"
    	        newElement.innerHTML += toAppend;
            	curTable.appendChild(newElement);
        	}
        	function subtractCase(element)
        	{
        		var curNum = document.getElementById("num_tests").value;
        		if(curNum == -1)
        		{
        			return;
        		}
        		var toRemove = document.getElementById("test_table_" + curNum);
        		toRemove.remove();
        		curNum--;
        		document.getElementById("num_tests").value = curNum;
        	}
        	function addCaseArg(element, testNum)
        	{
        		var curNum = document.getElementById("num_args_" + testNum).value;
        		curNum++;
        		document.getElementById("num_args_" + testNum).value = curNum;
        		var curTable = document.getElementById("test_arg_row_" + testNum);
        		var newElement = document.createElement("div");
        		var toAppend = '<table id="test_arg_table_' + testNum + '_' + curNum + '" width="100%">' +
	        	'<tr>' +
	        	'<td width="25%">' +
	        	curNum +
	        	'</td>' +
	        	'<td width="37.5">' +
	        	'<div align="right">' +
	        	'Type:' +
	        	'<select name="arg_type_' + testNum + '_' + curNum + '" onchange="argTypeChange(this,' + testNum + ',' + curNum + ');" form="updateForm">' +
	        	'<option value="literal">Literal</option>' +
	        	'<option value="int">Integer</option>' +
	        	'<option value="long">Long</option>' +
	        	'</select>' +
	        	'</div>' +
	        	'</td>' +
	        	'<td width="37.5">' +
	        	'<div align="right">' +
	        	'<input form="updateForm" style="" type="text" id="arg_value_' + testNum + '_' + curNum + '" name="arg_value_' + testNum + '_' + curNum + '" value="Value"></input>' +
	        	'</div>' +
	        	'</td>' +
	        	'</tr>' +
	        	'</table>';
	        	newElement.width="100%"
	        	newElement.innerHTML += toAppend;
        		curTable.appendChild(newElement);
        	}
        	function subtractCaseArg(element, testNum)
        	{
        		var curNum = document.getElementById("num_args_" + testNum).value;
        		if(curNum == 0)
        		{
        			return;
        		}
        		var toRemove = document.getElementById("test_arg_table_" + testNum + "_" + curNum);
        		toRemove.parentElement.remove();
        		curNum--;
        		document.getElementById("num_args_" + testNum).value = curNum;
        	}
        	function argTypeChange(element, testNum, argNum)
        	{
        		var curSelected = element.value;
        		var textField = document.getElementById("arg_value_" + testNum + '_' + argNum);
        		if(curSelected == "literal")
        		{
        			textField.value = "Value";
        			textField.disabled = false;
        		}
        		else
        		{
        			textField.value = "";
        			textField.disabled = true;
        		}
        	}
	        </script>
        	<img src="plus.png" style="margin-right: 1em;" class="boxedChar" onclick="addCase(this)" />
        	<img src="minus.png" class="boxedChar" onclick="subtractCase(this)" />
        	</div>
        	</td>
        	</tr>
        	<%
        	System.out.println("Grading tests:");
        	for(int x=0; x<headGrading.size(); x++)
        	{
        		DBObj curTest = (DBObj)headGrading.get(x);
        		System.out.println(curTest.getAttributes());
        	}
        	for(int x=0; x<headGrading.size(); x++)
        	{
        		System.out.println("Grading test");
        		DBObj curTest = (DBObj)headGrading.get(x);
        		//System.out.println(curTest.getAttributeNames());
        		System.out.println(curTest.getAttributes());
        	%>
        		<tr>
        		<td colspan="3" width="100%">
        		<table id="test_table_<%=x %>" width="100%">
	        	<tr>
	        	<td colspan="2">
	        	<table width="100%" id="test_<%=x %>">
	        	<tr>
	        	<td colspan="3">
	        	<b>Test <%=x %></b>
	        	</td>
	        	</tr>
	        	<tr>
	        	<td width="25%">
	        	Number of iterations:
	        	</td>
	        	<td colspan="2" width="75%">
	        	<div align="right">
	        	<input form="updateForm" style="" type="text" name="iterations_<%=x %>" value="<%=curTest.getAttribute("num_iterations") %>"></input>
	        	<%
	        	int numArgs = 0;
	        	
	        	
	        	while(x + numArgs < headGrading.size())
	        	{
	        		DBObj tmpTest = (DBObj)headGrading.get(x + numArgs);
	        		
	        		if(!tmpTest.getAttribute("test_number").equals(curTest.getAttribute("test_number")))
	        		{
	        			break;
	        		}
	        		
	        		numArgs++;
	        	}
	        	
	        	numArgs--;
	        	
	        	System.out.println("Args: " + numArgs);
	        	%>
	        	<input form="updateForm" type="hidden" name="num_args_<%=x %>" id="num_args_<%=x %>" value="<%=numArgs %>"></input>
	        	<script>
	        	document.getElementById("num_args_<%=x %>").value = <%=numArgs %>;
	        	</script>
	        	</div>
	        	</td>
	        	</tr>
	        	<tr>
	        	<td width="25%">
	        	Performance cutoff:
	        	</td>
	        	<td colspan="2" width="75%">
	        	<div align="right">
	        	<input form="updateForm" style="" type="text" name="performance_<%=x %>" value="<%=curTest.getAttribute("performance_multiplier") %>"></input>
	        	</div>
	        	</td>
	        	</tr>
	        	<tr>
	        	<td width="25%">
	        	Arguments:
	        	</td>
	        	<td width="75%" colspan="2">
	        	<div align="right">
	        	<img src="plus.png" style="margin-right: 1em;" class="boxedChar" onclick="addCaseArg(this, <%=x %>)" />
	        	<img src="minus.png" class="boxedChar" onclick="subtractCaseArg(this, <%=x %>)" />
	        	</div>
	        	</td>
	        	</tr>
	        	<tr>
	        	<td colspan="3" width="100%" id="test_arg_row_<%=x %>">
				<%
				for(int y=0; y<=numArgs; y++)
				{
					DBObj curArg = (DBObj)headGrading.get(x + y);
				%>
				<div width="100%">
	        	<table id="test_arg_table_<%=x %>_<%=y %>" width="100%">
	        	<tr>
	        	<td width="25%">
	        	<%=y %>
	        	</td>
	        	<td width="37.5">
	        	<div align="right">
	        	Type:<select name="arg_type_<%=x %>_<%=y %>" id="arg_type_<%=x %>_<%=y %>" onchange="argTypeChange(this,<%=x %>,<%=y %>);" form="updateForm">
	        	<option value="literal" <% if(curArg.getAttribute("arg_type").equals("literal")){ out.print("selected"); } %>>Literal</option>
	        	<option value="int" <% if(curArg.getAttribute("arg_type").equals("int")){ out.print("selected"); } %>>Integer</option>
	        	<option value="long" <% if(curArg.getAttribute("arg_type").equals("long")){ out.print("selected"); } %>>Long</option>
	        	</select>
	        	<script style="display:none;">
	        	
	        	document.getElementById("arg_type_<%=x %>_<%=y %>").value="<%=curArg.getAttribute("arg_type") %>";
	        	
	        	</script>
	        	</div>
	        	</td>
	        	<td width="37.5">
	        	<div align="right">
	        	<input form="updateForm" style="" type="text" id="arg_value_<%=x %>_<%=y %>" name="arg_value_<%=x %>_<%=y %>" value="<%=curArg.getAttribute("arg_value") %>"></input>
	        	</div>
	        	</td>
	        	</tr>
	        	</table>
	        	</div>
	        	<%
				}
	        	%>
	        	</td>
	        	</tr>
	        	</table>
	        	</td>
	        	</tr>
	        	</table>
	        	</td>
	        	</tr>
	        <%
	        	x += numArgs;
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