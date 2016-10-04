<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<%
if(hasUser)
{
%>
<table id="login_table">
	<form action="logoutSubmit.jsp" method="POST" name="logout">
    <tr>
        <td colspan="2" align="center">
        		<input name="submit_login" type="submit" value="Logout" />
        </td>
    </tr>
    </form>
</table>
<%
}
%>
<%@include file="loginscript.jsp" %>