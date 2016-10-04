<%
	if(myUser==null)
	{
		out.flush();
		session.invalidate();
		%>
			<jsp:forward page="./endsession.jsp" />
        <%
	}
%>
<meta signedin="true" />