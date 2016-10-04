<%
	DatabaseInformationManager manager=DatabaseInformationManager.getInstance();
	ServletContext sc=getServletContext();
	String reportPath=sc.getRealPath("/WEB-INF/");
	reportPath+="/databases.xml";
	manager.addInfoFile(reportPath);
	DatabaseConnector myConnector=(DatabaseConnector)session.getAttribute("connector");
	if(myConnector==null)
	{
		myConnector=new DatabaseConnector("pillar");
		myConnector.connect();
		session.setAttribute("connector", myConnector);
	}
	if(verbose)
	{
		System.out.println("Done database config");
	}
%>
<meta database="connected">