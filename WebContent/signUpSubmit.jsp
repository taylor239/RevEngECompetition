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
		
		String newUserEmail = request.getParameter("email");
		String newUserName = request.getParameter("email");
		String newUserFname = request.getParameter("fname");
		String newUserMname = request.getParameter("mname");
		String newUserLname = request.getParameter("lname");
		String newUserPass = request.getParameter("password");
		String newUserMessage = request.getParameter("message");
		String newUserType = request.getParameter("userType");
		
		String messageText = "";
		try
		{
			myConnector.writeUser(newUserName, newUserEmail, newUserFname, newUserMname, newUserLname, newUserPass, "student", "cgtboy1988@yahoo.com", "competition");
			ArrayList allChallenges = myConnector.getAdminChallenges("cgtboy1988@yahoo.com");
			for(int x=0; x<allChallenges.size(); x++)
			{
				DBObj curObj = (DBObj)allChallenges.get(x);
				String curName = (String)curObj.getAttribute("challenge_name");
				myConnector.assignChallenge(curName, newUserEmail);
			}
			messageText = "Thank you for signing up!  You may now use your account.";
			mySender.sendEmail(newUserEmail, "Welcome to RevEngE!", "You have signed up for RevEngE---thank you for your participation!  Your username is " + newUserName + ".");
		}
		catch(Exception e)
		{
			messageText = "There was an error when creating your account.  That error caused the exception " + e;
		}
		
		%>
        </div>
        <div align="center" id="inner_content_slogan">
        <%=messageText %>
        </div>
        </td>
        </tr>
        </table>
        </div>
        </td>
    </tr>
	<tr style="display:none">
    	<td width="25%">
        <table class="inner_content_table">
        <tr>
        <td>
        <table class="news_table">
        <tr class="title_general">
        <td colspan="3" align="center">
        Options
        </td>
    	</tr>
        <tr>
        <td colspan="3" width="100%">
        <table class="news_item_table" width="100%">
        <tr>
        <td width="50%">
        User Type:
        </td>
        <td width="50%">
        <%=newUserType %>
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
        <td width="50%">
        <table class="inner_content_table">
        <tr>
        <td>
        <table class="news_table">
        <tr class="title_general">
        <td colspan="3" align="center">
        Request Submitted
        </td>
    	</tr>
        <tr>
        <td>
        <table class="news_item_table" width="100%">
        <tr>
        <td width="33%">
        Email Address:
        </td>
        <td width="67%">
        <%=newUserEmail %>
        </td>
        </tr>
        <tr>
        <td width="33%">
        First Name:
        </td>
        <td width="67%">
        <%=newUserFname %>
        </td>
        </tr>
        <tr>
        <td width="33%">
        Middle Name:
        </td>
        <td width="67%">
        <%=newUserMname %>
        </td>
        </tr>
        <tr>
        <td width="33%">
        Last Name:
        </td>
        <td width="67%">
        <%=newUserLname %>
        </td>
        </tr>
        <tr>
        <td width="33%">
        Password:
        </td>
        <td width="67%">
        <%
        
        for(int x=0; x<newUserPass.length(); x++)
        {
        	out.print("*");
        }
        	
        %>
        </td>
        </tr>
        <tr>
        <td width="33%">
        Message:
        </td>
        <td width="67%">
        <%=newUserMessage %>
        </td>
        </tr>
        <tr>
        <td colspan="2" width="100%">
        <div align="center">
        The site admin will review and approve/deny your request as soon as possible.
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
				%>.  Your role is <%
				out.print(myUser.getAttribute("role") + ".");
				if(myUser.getAttribute("role").equals("student"))
				{
					out.print("  Your administrator is " + myUser.getAttribute("administrator"));
				}
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
<%@include file="./WEB-INF/includes/footer.jsp" %>
</body>

</html>