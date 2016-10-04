<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<%
if(!hasUser)
{
%>
<table id="login_table" style="text-align:right;">
	<form action="loginSubmit.jsp" method="GET" name="login">
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
    	<td style="text-align:right;">
        		<div align="right"><input name="email" value="Email" type="text" size="20" onfocus="clearText(this)" /></div>
        </td>
    </tr>
    <tr>
        <td style="text-align:right;">
        		<div align="right"><input name="password" value="Password" type="text" size="20" onfocus="passwordClick(this)" /></div>
        </td>
    </tr>
    <tr>
        <td colspan="2" align="right" style="text-align:right;">
        		<input name="submit_login" type="submit" value="Submit" />
        </td>
    </tr>
    </form>
    <tr>
    	<td style="text-align:right;">
        	<div align="right">Not a member?  Sign up <a href="#">here</a>.</div>
        </td>
    </tr>
</table>
<%
}
%>