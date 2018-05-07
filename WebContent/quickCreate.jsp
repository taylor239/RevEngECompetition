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
        <form id="updateForm" action="updateChallenge.jsp">
        <input type="hidden" name="new_type" value="assignment"></input>
        <table class="inner_content_table">
        <tr>
        <td>
        <%
        	
        	if(selectedDefault != null && !selectedDefault.isEmpty())
        	{
        	DBObj topLevel = (DBObj)selectedDefault.get(0);
        %>
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        Enter Assignment Information
        </td>
    	</tr>
        <tr colspan="2" width="100%">
        <td>
        <table class="news_item_table" width="100%" id="challengeTable">
        <tr>
        <td width="100%" colspan="2">
        <input form="updateForm" form="updateForm" style="width:100%" onfocus="clearText(this);" type="text" name="challenge_name" value="Assignment Name"></input>
        </td>
        </tr>
        <tr>
        <td width="10%" style="vertical-align:middle;">
        Open
        </td>
        <td width="90%">
        <input form="updateForm" style="width:100%" type="datetime-local" placeholder="yyyy-mm-dd hh:mm:ss" name="open_time"></input>
        </td>
        </tr>
        <tr>
        <td width="10%" style="vertical-align:middle;">
        Close
        </td>
        <td width="90%">
        <input form="updateForm" style="width:100%" type="datetime-local" placeholder="yyyy-mm-dd hh:mm:ss" name="end_time"></input>
        </td>
        </tr>
        <tr>
        <td width="100%" colspan="2">
        <textarea rows="10" form="updateForm" style="width:100%" onfocus="clearText(this);" name="description">Instructions for students</textarea>
        </td>
        </tr>
        <tr>
        <td width="100%" colspan="2">
        <input form="updateForm" form="updateForm" style="width:100%" onfocus="clearText(this);" type="text" name="seed" value="Seed (0 for random)"></input>
        </td>
        </tr>
        <tr>
        <td width="100%" colspan="2">
        <input form="updateForm" form="updateForm" style="width:100%" onfocus="clearText(this);" type="text" name="challengeSet" value="Challenge Set"></input>
        </td>
        </tr>
        <script>
        totalCommands = <%=selectedDefault.size() %>;
        </script>
        <tr>
        <td>
        <table id="hiddenTable">
        <%
        for(int x=0; x<selectedDefault.size(); x++)
        {
        	DBObj curObj = (DBObj)selectedDefault.get(x);
        	%>
        	<tr style="display:none;">
        	<td colspan="2">
        	<table class="news_item_table" width="100%" style="display:none;">
        	<tr style="display:none;">
        	<td width="33%">
	        Command Number:
	        </td>
	        <td width="67%">
	        <input form="updateForm" style="width:90%" type="hidden" name="command_order_<%=x %>" value="<%=curObj.getAttribute("command_order") %>"></input>
	        </td>
        	</tr>
        	<tr style="display:none;">
        	<td width="33%">
	        Command:
	        </td>
	        <td width="67%">
	        <input form="updateForm" style="width:90%" type="hidden" name="commandName_<%=x %>" value="<%=curObj.getAttribute("commandName") %>"></input>
	        </td>
        	</tr>
        	<tr style="display:none;">
        	<td width="33%">
	        Arguments:
	        </td>
	        <td width="67%">
	        <input type="hidden" form="updateForm" style="width:90%" name="command_<%=x %>" value="<%=curObj.getAttribute("command") %>">
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
        
        </div>
        </td>
        </tr>
        </table>
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
        <tr>
        <td width="100%">
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        Select Problem
        </td>
    	</tr>
    	<tr>
        <td width="100%">
        <div align="center">
        <table>
        <!--<select name="default" onchange="changeProblem(this)" width="100%">-->
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
        		
        		String isSiteDefault = "";
        		if(((String)curChallenge.getAttribute("administrator")).isEmpty())
        		{
        			isSiteDefault = " <b>(Tigress default)</b>";
        		}
        		
        		String selectedItem = "";
        		String id = "";
        		if(x==0)
        		{
        			selectedItem = "checked";
        			id = "id=\"selectedRadioButton\"";
        		}
        %>
        		<tr>
        		<td>
				<input onclick="changeProblem(this)" <%=id %> type="radio" name="default" value="<%=curChallenge.getAttribute("challenge_name") %>" <%=selectedItem %>><%=curChallenge.getAttribute("challenge_name") %><%=isSiteDefault %>
				</input>
				</td>
				</tr>
		<%
        	}
        	
		%>
		<!--</select>-->
		</table>
		</div>
		</td>
		</tr>
		<script>
		var problemDescs = {};
		
		var problemCommands = {};
		var problemCommandNum = {};
		var problemCommandName = {};
		
		
		var problemGradeTestsPerformance = {};
		var problemGradeTestsIterations = {};
		var problemGradeTestsArgNum = {};
		
		var problemGradeTestsArgValue = {};
		var problemGradeTestsArgType = {};
		
		var problemGradeNum = {};
		
		<%
			doneMap = new HashMap();
			HashMap problemMaxMap = new HashMap();
        	for(int x=0; x<defaultChallenges.size(); x++)
        	{
        		DBObj curChallenge = (DBObj)defaultChallenges.get(x);
        		ArrayList grading = new ArrayList();
        		if(curChallenge.getAttribute("auto_grade").equals(true))
        		{
        			grading = (ArrayList)curChallenge.getAttribute("grading");
        		}
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
				int numTests = 0;
				int curTestNum = -1;
				int curLength = 0;
				if(grading.isEmpty())
				{
					numTests = -1;
				}
				for(int y=0; y<grading.size(); y++)
				{
					DBObj curTest = (DBObj)grading.get(y);
					if(curTestNum < 0)
					{
						curLength = 0;
						curTestNum = (int)curTest.getAttribute("test_number");
						%>
						problemGradeTestsPerformance["<%=(String)curChallenge.getAttribute("challenge_name") + "_" + curTestNum %>"] = <%=curTest.getAttribute("performance_multiplier") %>
						problemGradeTestsIterations["<%=(String)curChallenge.getAttribute("challenge_name") + "_" + curTestNum %>"] = <%=curTest.getAttribute("num_iterations") %>;
						<%
					}
					else if(!curTest.getAttribute("test_number").equals(curTestNum))
					{
						curLength = 0;
						curTestNum = (int)curTest.getAttribute("test_number");
						numTests++;
						%>
						problemGradeTestsPerformance["<%=(String)curChallenge.getAttribute("challenge_name") + "_" + curTestNum %>"] = <%=curTest.getAttribute("performance_multiplier") %>
						problemGradeTestsIterations["<%=(String)curChallenge.getAttribute("challenge_name") + "_" + curTestNum %>"] = <%=curTest.getAttribute("num_iterations") %>;
						<%
					}
					
					
					
					if(curTest.containsKey("arg_value") && !((String)curTest.getAttribute("arg_value")).isEmpty())
					{
					%>
					problemGradeTestsArgValue["<%=(String)curChallenge.getAttribute("challenge_name") + "_" + curTestNum + "_" + curLength %>"] = "<%=curTest.getAttribute("arg_value") %>";
					<%
					}
					%>
					problemGradeTestsArgType["<%=(String)curChallenge.getAttribute("challenge_name") + "_" + curTestNum + "_" + curLength %>"] = "<%=curTest.getAttribute("arg_type") %>";
					<%
					
					
					if(y+1 >= grading.size())
					{
						%>
						problemGradeTestsArgNum["<%=(String)curChallenge.getAttribute("challenge_name") + "_" + curTestNum %>"] = <%=curLength %>;
						<%
					}
					else
					{
						DBObj nextTest = (DBObj)grading.get(y + 1);
						if(!nextTest.getAttribute("test_number").equals(curTestNum))
						{
							%>
							problemGradeTestsArgNum["<%=(String)curChallenge.getAttribute("challenge_name") + "_" + curTestNum %>"] = <%=curLength %>;
							<%
						}
					}
					
					curLength++;
				}
				%>
				problemGradeNum["<%=curChallenge.getAttribute("challenge_name") %>"] = <%=numTests %>;
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
    		document.getElementById("totalAdd").value = numCommands;
    		var hiddenTableHTML = "";
    		for(var x=0; x<=numCommands; x++)
    		{
    			console.log(x);
    			//console.log(problemCommandName[selectEle.value + "Command" + x]);
    			//console.log(problemCommands[selectEle.value + "Command" + x]);
    			hiddenTableHTML += "<tr style=\"display:none;\">\
            	<td colspan=\"2\">\
            	<table class=\"news_item_table\" width=\"100%\" style=\"display:none;\">\
            	<tr style=\"display:none;\">\
            	<td width=\"33%\">\
    	        Command Number:\
    	        </td>\
    	        <td width=\"67%\">\
    	        <input form=\"updateForm\" style=\"width:90%\" type=\"hidden\" name=\"command_order_" + x + "\" value=\"" + x + "\"></input>\
    	        </td>\
            	</tr>\
            	<tr style=\"display:none;\">\
            	<td width=\"33%\">\
    	        Command:\
    	        </td>\
    	        <td width=\"67%\">\
    	        <input form=\"updateForm\" style=\"width:90%\" type=\"hidden\" name=\"commandName_" + x + "\" value=\"" + problemCommandName[selectEle.value + "Command" + x] + "\"></input>\
    	        </td>\
            	</tr>\
            	<tr style=\"display:none;\">\
            	<td width=\"33%\">\
    	        Arguments:\
    	        </td>\
    	        <td width=\"67%\">\
    	        <input type=\"hidden\" form=\"updateForm\" style=\"width:90%\" name=\"command_" + x + "\" value=\"" + problemCommands[selectEle.value + "Command" + x] + "\">\
    	        </td>\
            	</tr>\
            	</table>\
            	</td>\
            	</tr>\
            	"
    		}
    		
    		var numTests = problemGradeNum[selectEle.value];
    		
    		hiddenTableHTML += "<tr style=\"display:none;\">\
            	<td colspan=\"2\">\
            	<table class=\"news_item_table\" width=\"100%\" style=\"display:none;\">\
            	<tr style=\"display:none;\">\
            	<td width=\"33%\">\
    	        Number of Tests:\
    	        </td>\
    	        <td width=\"67%\">\
    	        <input form=\"updateForm\" style=\"width:90%\" type=\"hidden\" name=\"numTests\" value=\"" + numTests + "\"></input>\
    	        </td>\
            	</tr>\
            	</table>\
            	</td>\
            	</tr>\
            	"
    		
    		for(var x=0; x<=numTests; x++)
    		{
    			console.log(x);
    			//console.log(problemCommandName[selectEle.value + "Command" + x]);
    			//console.log(problemCommands[selectEle.value + "Command" + x]);
    			hiddenTableHTML += "<tr style=\"display:none;\">\
            	<td colspan=\"2\">\
            	<table class=\"news_item_table\" width=\"100%\" style=\"display:none;\">\
            	<tr style=\"display:none;\">\
            	<td width=\"33%\">\
    	        Test Number:\
    	        </td>\
    	        <td width=\"67%\">\
    	        <input form=\"updateForm\" style=\"width:90%\" type=\"hidden\" name=\"test_order_" + x + "\" value=\"" + x + "\"></input>\
    	        </td>\
            	</tr>\
            	<tr style=\"display:none;\">\
            	<td width=\"33%\">\
    	        Iterations:\
    	        </td>\
    	        <td width=\"67%\">\
    	        <input form=\"updateForm\" style=\"width:90%\" type=\"hidden\" name=\"testIterations_" + x + "\" value=\"" + problemGradeTestsIterations[selectEle.value + "_" + x] + "\"></input>\
    	        </td>\
            	</tr>\
            	<tr style=\"display:none;\">\
            	<td width=\"33%\">\
    	        Performance:\
    	        </td>\
    	        <td width=\"67%\">\
    	        <input type=\"hidden\" form=\"updateForm\" style=\"width:90%\" name=\"testPerformance_" + x + "\" value=\"" + problemGradeTestsPerformance[selectEle.value + "_" + x] + "\">\
    	        </td>\
            	</tr>\
            	<tr style=\"display:none;\">\
            	<td width=\"33%\">\
    	        Number of Arguments:\
    	        </td>\
    	        <td width=\"67%\">\
    	        <input type=\"hidden\" form=\"updateForm\" style=\"width:90%\" name=\"testArguments_" + x + "\" value=\"" + problemGradeTestsArgNum[selectEle.value + "_" + x] + "\">\
    	        </td>\
            	</tr>";
            	
            	var numArgs = problemGradeTestsArgNum[selectEle.value + "_" + x];
            	
            	for(var y=0; y<=numArgs; y++)
            	{
            		hiddenTableHTML += "<tr style=\"display:none;\">\
                	<td width=\"33%\">\
        	        Argument Number:\
        	        </td>\
        	        <td width=\"67%\">\
        	        <input type=\"hidden\" form=\"updateForm\" style=\"width:90%\" name=\"argNum_" + x + "_" + y + "\" value=\"" + y + "\">\
        	        </td>\
                	</tr>\
                	<tr style=\"display:none;\">\
                	<td width=\"33%\">\
        	        Argument Type:\
        	        </td>\
        	        <td width=\"67%\">\
        	        <input type=\"hidden\" form=\"updateForm\" style=\"width:90%\" name=\"argType_" + x + "_" + y + "\" value=\"" + problemGradeTestsArgType[selectEle.value + "_" + x + "_" + y] + "\">\
        	        </td>\
                	</tr>\
                	<tr style=\"display:none;\">\
                	<td width=\"33%\">\
        	        Argument Value:\
        	        </td>\
        	        <td width=\"67%\">\
        	        <input type=\"hidden\" form=\"updateForm\" style=\"width:90%\" name=\"argValue_" + x + "_" + y + "\" value=\"" + problemGradeTestsArgValue[selectEle.value + "_" + x + "_" + y] + "\">\
        	        </td>\
                	</tr>";
            	}
            	
            	hiddenTableHTML += "</table>\
            	</td>\
            	</tr>\
            	"
    		}
    		
    		document.getElementById("hiddenTable").innerHTML = hiddenTableHTML;
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
        <tr>
        <td width="100%">
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        Assign To
        </td>
    	</tr>
    	<%
        //ArrayList myChallengesFull = new ArrayList();
        //ArrayList challengeAssignment = new ArrayList();
        //ArrayList alreadyAssignedList = new ArrayList();
        //ArrayList allStudents = new ArrayList();
        //ArrayList selectedDefault = new ArrayList();
        
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
        	
        	//selectedDefault = myConnector.getChallengeDefault(request.getParameter("default"));
        	
	        //myChallengesFull = myConnector.getChallenge((String)request.getParameter("challengeName"), (String)myUser.getAttribute("email"));
	        //challengeAssignment = myConnector.getChallengeAssignment((String)myUser.getAttribute("email"), (String)request.getParameter("challengeName"));
	        //allStudents = myConnector.getAdminStudents((String)myUser.getAttribute("email"));
	        
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
	        		for(var x=0; x<numCourses; x++)
	        		{
	        			document.getElementById("courseCheck" + x).checked = true;
	        		}
	        	}
	        	
	        	function deselectAllStudents()
	        	{
	        		for(var x=0; x<<%=allStudents.size() %>; x++)
        			{
        				document.getElementById("studentCheck_" + x).checked = false;
        			}
	        		for(var x=0; x<numCourses; x++)
	        		{
	        			document.getElementById("courseCheck" + x).checked = false;
	        		}
	        	}
	        
	        </script>
	        
	    	<tr colspan="3">
	    	<td width="100%">
	    	<table class="news_item_table" width="100%">
	    	<tr style="display:none;">
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
	        
	        <script>
	        var numCourses = <%=courseNames.size() %>;
	        </script>
	        
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
	    	<input type="checkbox" id="courseCheck<%=y %>" onclick="selectCheck<%=courseName %>(this)"></input>
	    	<!-- <img src="plus.png" class="boxedChar" onclick="showPlus<%=courseName %>(this)" /> -->
	    	</td>
	    	<td width="40%">
	    	<b><%=courseName %></b>
	    	</td>
	    	<td width="25%">
	    	
	    	</td>
	    	<td width="25%">
	    	<div align="right">
	    	<!-- <input type="checkbox" onclick="selectCheck<%=courseName %>(this)"></input> -->
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
        </table>
        </td>
        </tr>
        <tr>
        <td width="100%">
        <div align="right">
        <input form="updateForm" type="submit" value="Submit"></input>
        </div>
        </td>
        </tr>
        </table>
        </form>
        </td>
        <td width="25%">
        <script>
		document.getElementById("selectedRadioButton").checked="true";
		changeProblem(document.getElementById("selectedRadioButton"));
		</script>
        </td>
    </tr>
</table>
<%@include file="./WEB-INF/includes/footer.jsp" %>
</body>

</html>