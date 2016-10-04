<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
<%@include file="./WEB-INF/includes/includes.jsp" %>
<%
	String submitRedirect="";
	String submitRedirectParameters="";
	hasUser=myUser!=null;
	if(hasUser)
	{
		session.setAttribute("user", myUser);
		submitRedirect=request.getParameter("redirect");
		submitRedirectParameters=request.getParameter("redirectParameters");
	}
	if(hasUser)
	{
		myUser.changeAttribute("lastLogon", new java.sql.Timestamp(today.getTime()));
		if(((Boolean)myUser.getAttribute("displayRealName")))
		{
			displayName=((String)myUser.getAttribute("fName"))+" "+((String)myUser.getAttribute("mName"))+" "+((String)myUser.getAttribute("lName"));
		}
		else
		{
			displayName=(String)myUser.getAttribute("username");
		}
	}
	else
	{
		displayName="";
	}
%>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Tigress</title>
</head>

<body>
<%@include file="./WEB-INF/includes/mainPane.jsp" %>
<table id="inner_content">
	<tr>
    	<td width="25%">
        </td>
        <td width="50%">
        <div align="center" width="40%" align="center" style="width:40%; text-align:center; margin:auto;">
        <table class="inner_content_table">
        <tr>
        <td>
        <%
		if(hasUser)
		{
		%>
        	Welcome back <% out.print(displayName); %>!
            <meta http-equiv="refresh" content="0;url=index.jsp">
        <%
		}
		else
		{
		%>
        	Email or password incorrect. <br />
            <%@include file="./WEB-INF/includes/loginWindow.jsp" %>
            <meta http-equiv="refresh" content="0;url=index.jsp?alert_message=Email or password incorrect.">
        <%
		}
		%>
        </td>
        </tr>
        </table>
        </div>
        </td>
        <td width="25%">
        <table class="inner_content_table">
        <tr>
        <td>
        <%
		if(!hasUser)
		{
		%>
        	
        <%
		}
		else
		{
		%>
        	<div align="center">Hi there, <%=displayName %>! Your last visit was <%
				java.util.Date logonDate=(java.util.Date)myUser.getAttribute("previousVisit");
				out.print(dateFormat.format(logonDate));
				%>.<br />Not you?<br /></div>
            <%@include file="./WEB-INF/includes/logoutWindow.jsp" %>
        <%
		}
		%>
        </td>
        </tr>
        </table>
        </td>
    </tr>
</table>
<%
	if(submitRedirect!=null && !submitRedirect.equals(""))
	{
		String submitRedirectTest=submitRedirect;
		if(submitRedirect.charAt(0)!='/')
		{
			submitRedirectTest="/"+submitRedirect;
		}
		URL testURL=getServletContext().getResource(submitRedirectTest);
		if(submitRedirectParameters==null)
		{
			submitRedirectParameters="";
		}
		if(testURL!=null)
		{
			%>
            	<meta http-equiv="refresh" content="0;url=<% out.print(submitRedirect+submitRedirectParameters); %>">
            <%
		}
	}
%>
<%@include file="./WEB-INF/includes/footer.jsp" %>
</body>
</html>
