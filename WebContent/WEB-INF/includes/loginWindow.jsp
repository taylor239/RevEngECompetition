<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<%
if(!hasUser)
{
%>
<table id="login_table">
	<form action="loginSubmit.jsp" method="POST" name="login">
    <%
		if(pageContext.getAttribute("loginRedirect")!=null)
		{
			String redirectPage=(String)pageContext.getAttribute("loginRedirect");
			String redirectParameters=(String)pageContext.getAttribute("loginRedirectParameters");
			%>
            	<input name="redirect" id="redirect" value="<% out.print(redirectPage); %>" type="hidden" />
                <input name="redirectParameters" id="redirectParameters" value="<% out.print(redirectParameters); %>" type="hidden" />
            <%
		}
	%>
	<tr>
    	<td>
        		<div align="center"><input name="email" value="Email" type="text" size="20" onfocus="clearText(this)" /></div>
        </td>
    </tr>
    <tr>
        <td>
        		<div align="center"><input name="password" value="Password" type="text" size="20" onfocus="passwordClick(this)" /></div>
        </td>
    </tr>
    <tr>
        <td colspan="2" align="center">
        		<input name="submit_login" type="submit" value="Submit" />
        </td>
    </tr>
    </form>
    <tr>
    	<td>
        	<div align="center">Not a member?  Request an account <a href="signUp.jsp">here</a>.</div>
        </td>
    </tr>
</table>
<%
}
%>