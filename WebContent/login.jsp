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
        
        </td>
        <td width="50%">
        <div width="40%" align="center" style="width:40%; text-align:center; margin:auto;">
        <table class="inner_content_table">
        <tr>
        <td>
        <%
		if(!hasUser)
		{
		%>
        	<div align="center">Login<br /></div>
        	<%@include file="./WEB-INF/includes/loginWindow.jsp" %>
        <%
		}
		else
		{
		%>
        	<div align="center">Hi there, <%=displayName %>! Your last logon was <%
				java.util.Date logonDate=(java.util.Date)myUser.getAttribute("previousLogin");
				out.print(dateFormat.format(logonDate));
				%>.<br />Not you?<br /></div>
            <%@include file="./WEB-INF/includes/logoutWindow.jsp" %>
        <%
		}
		%>
        </td>
        </tr>
        </table>
        </div>
        </td>
        <td width="25%">
        
        </td>
    </tr>
</table>
<%@include file="./WEB-INF/includes/footer.jsp" %>
</body>

</html>