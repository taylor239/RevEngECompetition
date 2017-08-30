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
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        Actions
        </td>
        </tr>
        <tr colspan="3" width="100%:">
        <td>
        <table class="news_item_table" width="100%">
        <tr>
        <td width="100%">
        <a href="manageChallenge.jsp?challengeName=<%=(String)request.getParameter("challengeName") %>">
        Back
        </a>
        </td>
    	</tr>
    	<tr>
    	<td>
    	&nbsp;
    	</td>
    	</tr>
    	<tr>
        <td width="100%">
        <a href="downloadAll?challengeName=<%=(String)request.getParameter("challengeName") %>">
        Download All
        </a>
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
        String refreshChallengeName = (String)request.getParameter("challengeName");
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
        	if(verbose)
        	{
        		System.out.println("Challenge name: " + (String)request.getParameter("challengeName"));
        		System.out.println("Email: " + (String)myUser.getAttribute("email"));
        	}
        	
	        myChallengesFull = myConnector.getChallenge((String)request.getParameter("challengeName"), (String)myUser.getAttribute("email"));
	        challengeAssignment = myConnector.getChallengeAssignment((String)myUser.getAttribute("email"), (String)request.getParameter("challengeName"));
	        allStudents = myConnector.getAdminStudents((String)myUser.getAttribute("email"));
	        
	        if(verbose)
	        {
	        	System.out.println(myChallengesFull);
	        }
	        
	        for(int x=0; x<challengeAssignment.size(); x++)
	        {
	        	DBObj curObj = (DBObj)challengeAssignment.get(x);
	        	String grade = request.getParameter("grade_" + curObj.getAttribute("email"));
	        	myConnector.setGrade((String)request.getParameter("challengeName"), (String)curObj.getAttribute("email"), grade);
	        }
	        
	        for(int x=0; x<challengeAssignment.size(); x++)
	        {
	        	DBObj curObj = (DBObj)challengeAssignment.get(x);
	        	if(curObj.getAttribute("email").equals(myUser.getAttribute("email")))
	        	{
	        		continue;
	        	}
	        	alreadyAssignedList.add(curObj.getAttribute("email"));
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
	        }
        }
        %>
        </td>
        <td width="50%">
        <table class="inner_content_table">
        <tr>
        <td>
        <form id="updateForm" action="submitGrades.jsp">
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        <%
        DBObj challengeHead = (DBObj)myChallengesFull.get(0);
        %>
        Submissions for <%=challengeHead.getAttribute("challenge_name") %>
        </td>
    	</tr>
        <tr colspan="2" width="100%">
        <td>
        <table class="news_item_table" width="100%" id="challengeTable">
        <tr>
        <td width="20%">
        <div align="center">
        <b>
        Student
        </b>
        </div>
        </td>
        <td width="20%">
        <div align="center">
        <b>
        Gen
        </b>
        </div>
        </td>
        <td width="20%">
        <div align="center">
        <b>
        Timestamp
        </b>
        </div>
        </td>
        <td width="20%">
        <div align="center">
        <b>
        Download
        </b>
        </div>
        </td>
        <td width="20%">
        <div align="center">
        <b>
        Grade
        </b>
        </div>
        </td>
        </tr>
        <%
	        for(int x=0; x<challengeAssignment.size(); x++)
	        {
	        	DBObj curObj = (DBObj)challengeAssignment.get(x);
	        	%>
	        	<tr style="vertical-align:middle">
	        	<td style="vertical-align:middle">
	        	<%=curObj.getAttribute("email") %>
	        	</td>
	        	<td style="vertical-align:middle">
	        	<div align="center">
	        	<b>
	        	<%
	        	if((Integer)curObj.getAttribute("code_generated") == 1)
	        	{
	        		out.print("X");
	        	}
	        	%>
	        	</b>
	        	</div>
	        	</td>
	        	<td style="vertical-align:middle">
	        	<div align="center">
	        	<%
	        	//if(curObj.getAttribute("submission_time") != null)
	        	{
	        		if(curObj.getAttribute("submissionTime") instanceof java.sql.Timestamp)
	        		{
	        			java.sql.Timestamp endTime = (java.sql.Timestamp)challengeHead.getAttribute("end_time");
	        			java.sql.Timestamp submitTime = (java.sql.Timestamp)curObj.getAttribute("submissionTime");
	        			if(endTime.before(submitTime))
	        			{
	        				%>
	        				<font color="red">
	        				<%
	        			}
	        			out.print(curObj.getAttribute("submissionTime"));
	        			if(endTime.before(submitTime))
	        			{
	        				%>
	        				</font>
	        				<%
	        			}
	        		}
	        	}
	        	%>
	        	</div>
	        	</td>
	        	<td style="vertical-align:middle">
	        	<div align="center">
	        	<%
	        	//if(curObj.getAttribute("submission_time") != null)
	        	{
	        		if(curObj.getAttribute("submissionTime") != null && !(curObj.getAttribute("submissionTime").toString().isEmpty()))
	        		{
	        			%>
	        			<a href="downloadSubmission?challengeName=<%=challengeHead.getAttribute("challenge_name") %>&email=<%=curObj.getAttribute("email") %>">Download</a>
	        			<%
	        		}
	        	}
	        	%>
	        	</div>
	        	</td>
	        	<td style="vertical-align:middle">
	        	<input form="updateForm" style="width:90%" type="text" value="<%=curObj.getAttribute("grade") %>"></input>
	        	</td>
	        	</tr>
	        	<%
	        	if(x + 1 <challengeAssignment.size())
	        	{
	        	%>
	        	<tr>
	        	<td colspan="5">
	        	&nbsp;
	        	</td>
	        	</tr>
	        	<tr>
	        	<td colspan="5">
	        	<hr></hr>
	        	</td>
	        	</tr>
	        	<tr>
	        	<td colspan="5">
	        	&nbsp;
	        	</td>
	        	</tr>
	        	<%
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
        <td width="100%">
        <div align="center">
        <input form="updateForm" type="submit" value="Submit Grades"></input>
        </div>
        </td>
        </tr>
        </table>
        </td>
        </tr>
        </table>
        </form>
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
<meta http-equiv="refresh" content="0; url=viewGrades.jsp?challengeName=<%=refreshChallengeName %>&alert_message=<%="Grades updated." %>" />
<%@include file="./WEB-INF/includes/footer.jsp" %>
</body>

</html>