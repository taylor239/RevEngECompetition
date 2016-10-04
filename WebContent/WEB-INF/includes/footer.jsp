<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
        </td>
        
    </tr>
    <tr>
   	  <td colspan="3">
			<div id="footer">
			  <p>Copyright 2016, All Rights Reserved</p>
			</div>
        </td>
    </tr>
</table>

<%@include file="postscript.jsp" %>

<%
	String alertString=(String)request.getParameter("alert_message");
	if(alertString!=null && (!alertString.equals("")))
	{
%>
		<script>
		showMessageBox('<tr height=90%><td><% out.print(alertString); %></td></tr>');
		//alert("<% out.print(alertString); %>");
		</script>
<%
	}
%>
		<%
        if(verbose)
        {
        	System.out.println("Footer printed");
        }
        %>