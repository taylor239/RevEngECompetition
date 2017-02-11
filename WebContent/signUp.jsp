<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
<%@include file="./WEB-INF/includes/includes.jsp" %>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Tigress</title>

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
		%>
        </div>
        <div align="center" id="inner_content_slogan">
        Obfuscation Made Easy</div>
        </td>
        </tr>
        </table>
        </div>
        </td>
    </tr>
	<tr>
		<form action="signUpSubmit.jsp" method="post">
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
        <td>
        <table class="news_item_table" width="100%">
        <tr>
        <td width="50%">
        User Type:
        </td>
        <td width="50%">
        <input type="radio" name="userType" value="instructor" CHECKED></input>
        Instructor
        <br></br>
        <input type="radio" name="userType" value="student"></input>
        Participant
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
        Enter Information
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
        <input type="text" name="email" value="" style="width:90%"></input>
        </td>
        </tr>
        <tr>
        <td width="33%">
        First Name:
        </td>
        <td width="67%">
        <input type="text" name="fname" value="" style="width:90%"></input>
        </td>
        </tr>
        <tr>
        <td width="33%">
        Middle Name:
        </td>
        <td width="67%">
        <input type="text" name="mname" value="" style="width:90%"></input>
        </td>
        </tr>
        <tr>
        <td width="33%">
        Last Name:
        </td>
        <td width="67%">
        <input type="text" name="lname" value="" style="width:90%"></input>
        </td>
        </tr>
        <tr>
        <td width="33%">
        Password:
        </td>
        <td width="67%">
        <input type="password" name="password" value="" style="width:90%"></input>
        </td>
        </tr>
        <tr>
        <td width="33%">
        Message:
        </td>
        <td width="67%">
        <textarea name="message" rows="5" style="width:90%">Why do you want to use the site? (250 char or less)</textarea>
        </td>
        </tr>
        <tr>
        <td colspan="2" width="100%">
        <div align="center">
        <input type="submit" value="Submit"></input>
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
        </form>
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