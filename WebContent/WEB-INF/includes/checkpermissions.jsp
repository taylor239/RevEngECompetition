<%
	//Check URL permission
	//if(!myConnector.checkNavigationPermission((String)myUser.getCurRole().getAttribute("role"), request.getServletPath().substring(1)))
	//Fix this later
	if(false)
	{
		out.flush();
		session.invalidate();
		//Database entry here
		%>
        	<jsp:forward page="./endsession.jsp" />
        <%
	}
	//Check other permissions
	//for(int x=0; x<permissionsToCheck.size(); x++)
	{
		
	}
%>
<meta permission="granted" />