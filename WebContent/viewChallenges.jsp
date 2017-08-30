<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
<%@include file="./WEB-INF/includes/includes.jsp" %>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>RevEngE</title>

</head>

<body>
<%@include file="./WEB-INF/includes/mainPane.jsp" %>
<table id="inner_content">
	<!--
	<tr>
    	<td colspan="3" class="no_bottom_padding">
    	<div align="center">
    	<table id="page_title_table_row">
    	<tr>
    	<td>
        <div align="center" id="inner_content_title">
        <%
        
        if(verbose)
        {
        	System.out.println("Got to hasUser conditional");
        }
		if(!hasUser)
		{
		%>
        Welcome to the Tigress Challenge Engine
        <%
		}
		else
		{
		%>
        Welcome back, <% out.print(displayName); %>!
        <%
		}
		%>
        </div>
        <div align="center" id="inner_content_slogan">
        Obfuscation Made Easy</div>
        </td>
        </tr>
        </table>
        </div>
        </td>
    </tr>
    -->
	<tr>
    	<td width="20%">
    	<!--
        <table class="inner_content_table">
        <tr>
        <td>
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        Options
        </td>
    	</tr>
    	<tr colspan="3" width="100%:">
        <td>
        <table class="news_item_table" width="100%">
        <tr>
        <%
        if(myUser.getAttribute("role").equals("admin") && false)
        {
        %>
        <td>
        <div align="center">
        <a href="makeNew.jsp">Make New Challenge</a><br></br>
        </div>
        </td>
        </tr>
        <tr>
        <td>
        <div align="center">
        <a href="manageStudents.jsp">Manage Students</a>
        </div>
        </td>
        <%
        }
        %>
        </tr>
        </table>
        </td>
        </tr>
    	</table>
        </td>
        </tr>
        </table>
        </td>
        -->
        <td width="60%">
        <table class="inner_content_table">
        <!--
        <tr>
        <td>
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        <div align="center">
        Options
        </div>
        </td>
    	</tr>
    	<tr colspan="2" width="100%:">
        <td>
        <table class="news_item_table" width="100%">
        <tr>
        <%
        if(myUser.getAttribute("role").equals("admin") && false)
        {
        %>
        <td width="33.3%">
        <div align="center">
        <a href="makeNew.jsp">Challenge Quick Start</a><br></br>
        </div>
        </td>
        <td width="33.4%">
        <div align="center">
        <a href="makeNew.jsp">Make New Challenge</a><br></br>
        </div>
        </td>
        <%
        }
        %>
        </tr>
        </table>
        </td>
        </tr>
    	</table>
        </td>
        </tr>
        </table>
        -->
        <table class="inner_content_table">
        <tr>
        <td>
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        Challenges
        </td>
    	</tr>
        <tr colspan="3" width="100%:">
        <td>
        <table class="news_item_table" width="100%">
        <tr>
        <%
        if(!hasUser)
        {
        	%>
        	<meta http-equiv="refresh" content="0; url=index.jsp" />
        	<%
        }
        else if(myUser.getAttribute("role").equals("student") || myUser.getAttribute("role").equals("admin"))
        {
        ArrayList myChallenges = myConnector.getChallenges((String)myUser.getAttribute("email"));
        if(verbose)
        {
        	System.out.println(myChallenges);
        }
        ArrayList keys = ((DBObj)myChallenges.get(0)).getAttributeNames();
        ConcurrentHashMap translationMap = new ConcurrentHashMap();
        translationMap.put("admin_email", "Instructor");
        translationMap.put("challenge_name", "Challenge");
        translationMap.put("open_time", "Open");
        translationMap.put("end_time", "Close");
        translationMap.put("grade", "Grade");
        for(int x=0; x<keys.size(); x++)
        {
        	String tmp=(String)keys.get(x);
        	if(tmp.equals("email") || tmp.equals("code_generated") || tmp.equals("end_time") || tmp.equals("open_time") || tmp.equals("description") || tmp.equals("originalFile") || tmp.equals("obfuscatedFile") || tmp.equals("submittedFile") || tmp.equals("submissionTime") || tmp.equals("submittedWrittenFile") || tmp.equals("type"))
        	{
        		keys.remove(x);
        		x--;
        	}
        }
        keys.add("open_time");
        keys.add("end_time");
        for(int x=0; x<keys.size(); x++)
        {
        %>
        <td width="<% out.print(100/(double)keys.size()); %>%">
        <div align="center">
        <b>
        <%
        	if(translationMap.containsKey(keys.get(x)))
        	{
        		out.print(translationMap.get(keys.get(x)));
        	}
        	else
        	{
        		out.print(keys.get(x));
        	}
        %>
        </b>
        </div>
        </td>
        <%
        }
        %>
        </tr>
        <%
        for(int x=0; x<myChallenges.size(); x++)
        {
        	if(!((DBObj)myChallenges.get(x)).getAttribute("type").equals("challenge"))
        	{
        		continue;
        	}
        %>
        <tr>
	        <%
	        for(int y=0; y<keys.size(); y++)
	        {
	        %>
	        <td width="<% out.print(100/(double)keys.size()); %>%">
	        <div align="left">
	        <%
	        	if(keys.get(y).equals("open_time") || keys.get(y).equals("end_time"))
	        	{
	        		java.util.Date tmpDate = (java.util.Date)((DBObj)myChallenges.get(x)).getAttribute(keys.get(y));
	        		out.print(dateFormat.format(tmpDate));
	        	}
	        	else if(keys.get(y).equals("challenge_name"))
	        	{
	        		%>
	        		<a href="viewChallenge.jsp?challengeName=<%= ((DBObj)myChallenges.get(x)).getAttribute(keys.get(y)) %>">
	        		<%
	        		out.print(((DBObj)myChallenges.get(x)).getAttribute(keys.get(y)));
	        		%>
	        		</a>
	        		<%
	        	}
	        	else
	        	{
	        		out.print(((DBObj)myChallenges.get(x)).getAttribute(keys.get(y)));
	        	}
	        %>
	        </div>
	        </td>
	        <%
	        }
	        %>
        </tr>
        <%
        }
        }
        else if(myUser.getAttribute("role").equals("admin") && false)
        {
        	ArrayList myChallenges = myConnector.getAdminChallenges((String)myUser.getAttribute("email"));
        	if(verbose)
            {
            	System.out.println(myChallenges);
            }
            ArrayList keys = ((DBObj)myChallenges.get(0)).getAttributeNames();
            ConcurrentHashMap translationMap = new ConcurrentHashMap();
            translationMap.put("admin_email", "Instructor");
            translationMap.put("challenge_name", "Challenge");
            translationMap.put("open_time", "Open");
            translationMap.put("end_time", "Close");
            translationMap.put("grade", "Grade");
            for(int x=0; x<keys.size(); x++)
            {
            	String tmp=(String)keys.get(x);
            	if(tmp.equals("email") || tmp.equals("code_generated") || tmp.equals("end_time") || tmp.equals("open_time") || tmp.equals("description") || tmp.equals("originalFile") || tmp.equals("obfuscatedFile") || tmp.equals("submittedFile") || tmp.equals("submissionTime") || tmp.equals("submittedWrittenFile"))
            	{
            		keys.remove(x);
            		x--;
            	}
            }
            keys.add("open_time");
            keys.add("end_time");
            for(int x=0; x<keys.size(); x++)
            {
            %>
            <td width="<% out.print(100/(double)(keys.size() + 1)); %>%">
            <div align="left">
            <b>
            <%
            	if(translationMap.containsKey(keys.get(x)))
            	{
            		out.print(translationMap.get(keys.get(x)));
            	}
            	else
            	{
            		out.print(keys.get(x));
            	}
            %>
            </b>
            </div>
            </td>
            <%
            }
            %>
            <td width="<% out.print(100/(double)(keys.size() + 1)); %>%">
            <div align="left">
            <b>
            Manage
            </b>
            </div>
            </td>
            </tr>
            <%
            String lastName = "";
            for(int x=0; x<myChallenges.size(); x++)
            {
            %>
            <tr>
    	        <%
    	        for(int y=0; y<keys.size(); y++)
    	        {
    	        %>
    	        <td width="<% out.print(100/(double)keys.size()); %>%">
    	        <div align="left">
    	        <%
    	        	if(keys.get(y).equals("open_time") || keys.get(y).equals("end_time"))
    	        	{
    	        		java.util.Date tmpDate = (java.util.Date)((DBObj)myChallenges.get(x)).getAttribute(keys.get(y));
    	        		out.print(dateFormat.format(tmpDate));
    	        	}
    	        	else if(keys.get(y).equals("challenge_name"))
    	        	{
    	        		lastName = (String)((DBObj)myChallenges.get(x)).getAttribute(keys.get(y));
    	        		%>
    	        		<a href="viewChallenge.jsp?challengeName=<%= ((DBObj)myChallenges.get(x)).getAttribute(keys.get(y)) %>">
    	        		<%
    	        		out.print(((DBObj)myChallenges.get(x)).getAttribute(keys.get(y)));
    	        		%>
    	        		</a>
    	        		<%
    	        	}
    	        	else
    	        	{
    	        		out.print(((DBObj)myChallenges.get(x)).getAttribute(keys.get(y)));
    	        	}
    	        %>
    	        </div>
    	        </td>
    	        <%
    	        }
    	        %>
    	        <td width="<% out.print(100/(double)keys.size()); %>%">
    	        <div align="center">
    	        <a href="manageChallenge.jsp?challengeName=<%= lastName %>">
    	        Manage
    	        </a>
    	        </div>
    	        </td>
            </tr>
            <%
            }
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
        <td width="20%">
        <!--
        <table class="inner_content_table">
        <tr>
        <td>
        <%
        if(verbose)
        {
        	System.out.println("Got to hasUser conditional");
        }
		if(!hasUser)
		{
		%>
        	<table class="news_table" width="100%">
            <tr class="title_general">
            <td>
        	<div align="center">Login<br /></div>
            </td>
            </tr>
            </table>
            <table class="news_item_table" width="100%">
            <tr>
            <td>
        	<%@include file="./WEB-INF/includes/loginWindow.jsp" %>
            </td>
            </tr>
            </table>
        <%
		}
		else
		{
		%>
        	<table class="news_table" width="100%">
            <tr class="title_general">
            <td>
        	<div align="center">Logout<br /></div>
            </td>
            </tr>
            </table>
        	<table class="news_item_table" width="100%">
            <tr>
            <td>
        	<div align="center">Hi there, <%=displayName %>! Your last visit was <%
				java.util.Date logonDate=(java.util.Date)myUser.getAttribute("previousVisit");
				out.print(dateFormat.format(logonDate));
				%>.<br />Not you?<br /></div>
            <%@include file="./WEB-INF/includes/logoutWindow.jsp" %>
            </td>
            </tr>
            </table>
        <%
		}
		if(verbose)
        {
        	System.out.println("Got past hasUser conditional");
        }
		%>
        </td>
        </tr>
        </table>
        -->
        </td>
    </tr>
</table>
<%@include file="./WEB-INF/includes/footer.jsp" %>
</body>

</html>