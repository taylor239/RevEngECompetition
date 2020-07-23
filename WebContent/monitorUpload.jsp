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
	HashMap replyMap = new HashMap();
	String eventName = "RevEngECompetition";
	try
	{
		
		String addTokenURL = "http://localhost:8080/DataCollectorServer/openDataCollection/TokenStatus?username=" + myUser.getAttribute("email") + "&token=" + myToken + "&verifier=for_revenge&event=" + eventName;
		URL myURL = new URL(addTokenURL);
		InputStream in = myURL.openStream();
		String reply = org.apache.commons.io.IOUtils.toString(in);
		org.apache.commons.io.IOUtils.closeQuietly(in);
		replyMap = myGson.fromJson(reply, HashMap.class);
	}
	catch(Exception e)
	{
		e.printStackTrace();
	}
	
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
		active = "initializing";
	}
%>
<%@include file="./WEB-INF/includes/mainPane.jsp" %>
<table id="inner_content">
	<tr>
    	<td width="25%">
        
        </td>
        <td width="50%">
        <table class="inner_content_table" width="100%">
        <tr>
        <td>
        <table class="news_table">
        <tr class="title_general">
        <td align="center">
        Data Upload Status
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
        <td colspan="2">
        <b>Upload ID: <%=replyMap.get("token") %></b>
        </td>
        </tr>
        <tr>
        <td colspan="2" width="100%">
        <p>
        Data uploads are divided into frames of data, each of which has a particular size and covers a particular time period.  These frames are uploaded from your device to RevEngE, and consist of screenshots, process and window information, mouse clicks, keyboard strokes, and other data from your device.
        <%
        if(!initializing)
        {
        %>
        Your upload is currently <b><%=active %></b>.  You have uploaded <b><%=replyMap.get("framesUploaded") %></b> frames, and you have <b><%=replyMap.get("framesLeft") %></b> frames left.
        <%
        }
        else
        {
        %>
        Initializing upload, thank you for your patience!
        <%
        }
        %>
        </p>
        <p>
        <%
        if(toRefresh)
        {
        %>
        Please do not shut down your computer until the upload has completed.
        <%
        }
        %>
        Thank you for your participation!
        </p>
        </td>
        </tr>
        </table>
        </td>
        </tr>
        </table>
        </td>
        </tr>
        </table>
        </td>
        <td width="25%">
        <table class="inner_content_table">
        
        </table>
        </td>
    </tr>
</table>
<%@include file="./WEB-INF/includes/footer.jsp" %>
<%
if(toRefresh)
{
%>
<meta http-equiv="refresh" content="5" />
<%
}
%>
</body>

</html>