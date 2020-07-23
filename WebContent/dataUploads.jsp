<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
<%@include file="./WEB-INF/includes/includes.jsp" %>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>RevEngE</title>

</head>

<body>
<%
	String myToken = request.getParameter("token");
	Gson myGson = new Gson();
	ArrayList replyList = new ArrayList();
	String eventName = "RevEngECompetition";
	try
	{
		
		String addTokenURL = "http://localhost:8080/DataCollectorServer/openDataCollection/GetUploadList?username=" + myUser.getAttribute("email") + "&verifier=for_revenge&event=" + eventName;
		URL myURL = new URL(addTokenURL);
		InputStream in = myURL.openStream();
		String reply = org.apache.commons.io.IOUtils.toString(in);
		org.apache.commons.io.IOUtils.closeQuietly(in);
		replyList = myGson.fromJson(reply, ArrayList.class);
	}
	catch(Exception e)
	{
		e.printStackTrace();
	}
	
	for(int x=0; x<replyList.size(); x++)
	{
	Map replyMap = (Map)replyList.get(x);
	String active ="inactive";
	boolean toRefresh = false;
	if((boolean)replyMap.get("isActive"))
	{
		toRefresh = true;
		active = "active";
	}
	boolean initializing = false;
	if(replyMap.get("framesUploaded").equals(0) && replyMap.get("framesLeft").equals(0))
	{
		initializing = true;
	}
	replyMap.put("initializing", initializing);
	}
%>
<%@include file="./WEB-INF/includes/mainPane.jsp" %>
<table id="inner_content">
	<tr>
    	<td width="15%">
        
        </td>
        <td width="70%">
        <table class="inner_content_table" width="100%">
        <tr>
        <td>
        <table class="news_table">
        <tr class="title_general">
        <td align="center">
        Your Data Collection Upload Status
        </td>
    	</tr>
    	<tr>
        <td align="center">
        Each time you elect to upload your data from the data collection software, a new entry will appear here.  Click on an upload to view its status.
        </td>
    	</tr>
        </table>
        </td>
        </tr>
        </table>
        <table class="inner_content_table">
        <tr>
        <td>
        <table class="news_table">
        <tr>
        <td>
        <table class="news_item_table">
        <tr>
        <td width="35%">
        <div align="center">
        <b>Upload Identifier</b>
        </div>
        </td>
        <td width="22.5%">
        <div align="center">
        <b>Last Active</b>
        </div>
        </td>
        <td width="12.5%">
        <div align="center">
        <b>Complete</b>
        </div>
        </td>
        <td width="15%">
        <div align="center">
        <b>Frames Uploaded</b>
        </div>
        </td>
        <td width="15%">
        <div align="center">
        <b>Frames Left</b>
        </div>
        </td>
        </tr>
        <%
        for(int x=0; x<replyList.size(); x++)
        {
        	Map curMap = (Map)replyList.get(x);
        %>
        <tr>
        <td>
        <a href="monitorUpload.jsp?token=<%=curMap.get("token") %>"><%=curMap.get("token") %></a>
        </td>
        <td>
        <%=curMap.get("lastAltered") %>
        </td>
        <td>
        <%
        String tmp = "";
        if(!(boolean)curMap.get("isActive"))
        {
        	tmp = "X";
        }
        %>
        <div align="center"><b><%=tmp %></b></div>
        </td>
        <td>
        <%=curMap.get("framesUploaded") %>
        </td>
        <td>
        <%=curMap.get("framesLeft") %>
        </td>
        </tr>
        <%
        }
        %>
        </table>
        </td>
        </tr>
        </table>
        </td>
        </tr>
        </table>
        </td>
        <td width="15%">
        <table class="inner_content_table">
        
        </table>
        </td>
    </tr>
</table>
<%@include file="./WEB-INF/includes/footer.jsp" %>
</body>

</html>