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
        //ArrayList challengeAssignment = new ArrayList();
        ArrayList selectedDefault = new ArrayList();
        ArrayList defaultChallenges = new ArrayList();
        
        ArrayList headGrading = new ArrayList();
        
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
        	
        	System.out.println("Head is: " + headChallenge.getAttribute("challenge_name") + ", " + headChallenge.getAttribute("administrator"));
        	
        	//selectedDefault = myConnector.getChallengeDefault(request.getParameter("default"));
        	
        	if(selectedDefault == null || selectedDefault.isEmpty())
        	{
        		selectedDefault = myConnector.getChallengeDefault((String)headChallenge.getAttribute("challenge_name"), (String)headChallenge.getAttribute("administrator"));
        	}
	        
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
        	headGrading = (ArrayList)topLevel.getAttribute("grading");
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
	        Argument Number:
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
        	System.out.println(headGrading);
        	
        	int numTests = 0;
        	
        	for(int x=0; headGrading != null && x<headGrading.size(); x++)
        	{
        		System.out.println("Test num " + numTests);
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
	        	'Argument Number:' +
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
        	for(int x=0; headGrading != null && x<headGrading.size(); x++)
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
	        	Argument Number:
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
	        	<script>
	        	
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
    	        Argument Number:\
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