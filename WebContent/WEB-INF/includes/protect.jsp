<%
	if(false)//!request.isSecure())
	{
		%>
       <jsp:forward page="./nonprotected.jsp" />
        <%
	}
	TrafficAnalyzer accessor=TrafficAnalyzerPool.getAnalyzer();
	if(!accessor.allow(request.getRemoteAddr()))
	{
		if(accessor.disallowNum(request.getRemoteAddr())==1)
		{
			%>
            <jsp:include page="./databaseconfig.jsp" />
            <%
			DatabaseConnector myConnector=(DatabaseConnector)session.getAttribute("connector");
		}
		%>
        <jsp:forward page="./disallow.jsp" />
        <%
		return;
	}
	if(verbose)
	{
		System.out.println("Done protecting");
	}
%>
<meta ip="allowed">