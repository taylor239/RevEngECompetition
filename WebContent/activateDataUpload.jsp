<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
<%@include file="./WEB-INF/includes/includes.jsp" %>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>RevEngE</title>

</head>

<body>
<%
	String redirectURL = "http://revenge.cs.arizona.edu/RevEngECompetition/monitorUpload.jsp";
	
	boolean foundOK = false;
	String myNewToken = "";
	Gson myGson = new Gson();
	String eventName = "RevEngECompetition";
	try
	{
		while(!foundOK)
		{
			System.out.println("1");
			myNewToken = UUID.randomUUID().toString();
			String verifierURL = "http://localhost:8080/DataCollectorServer/TokenStatus?username=" + myUser.getAttribute("email") + "&token=" + myNewToken + "&verifier=for_revenge&event=" + eventName;
			System.out.println("2");
			URL myURL = new URL(verifierURL);
			System.out.println("3");
			InputStream in = myURL.openStream();
			System.out.println("4");
			String reply = org.apache.commons.io.IOUtils.toString(in);
			System.out.println("5");
			org.apache.commons.io.IOUtils.closeQuietly(in);
			System.out.println(reply);
			HashMap replyMap = myGson.fromJson(reply, HashMap.class);
			if(replyMap.get("result").equals("nokay"))
			{
				foundOK = true;
			}
		}
		
		String addTokenURL = "http://localhost:8080/DataCollectorServer/AddToken?username=" + myUser.getAttribute("email") + "&token=" + myNewToken + "&verifier=for_revenge&event=" + eventName;
		URL myURL = new URL(addTokenURL);
		InputStream in = myURL.openStream();
		String reply = org.apache.commons.io.IOUtils.toString(in);
		org.apache.commons.io.IOUtils.closeQuietly(in);
	}
	catch(Exception e)
	{
		e.printStackTrace();
	}
	String redirectServer = "revenge.cs.arizona.edu";
	String urlRedirect = (String)session.getAttribute("redirect");
	if(urlRedirect != null && !urlRedirect.equals(""))
	{
		//redirectServer = urlRedirect;
	}
%>

<meta http-equiv="refresh" content="0; url=http://localhost:8080/CybercraftDataCollectionConnector/ActivateDataCollection?username=<%=myUser.getAttribute("email") %>&token=<%=myNewToken %>&server=http://<%=redirectServer + ":" + request.getServerPort() %>/DataCollectorServer/UploadData&event=<%=eventName %>&redirect=<%=redirectServer %>" />
</body>

</html>