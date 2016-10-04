<%
	ServerManager serverManager=ServerManager.getInstance();
	reportPath=sc.getRealPath("/WEB-INF/");
	reportPath+="/servercommands.xml";
	serverManager.addCommandFile(reportPath);
%>
<meta database="configured">