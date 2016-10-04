<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
<%@include file="./WEB-INF/includes/includes.jsp" %>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Tigress</title>

</head>

<body>
<%@include file="./WEB-INF/includes/mainPane.jsp" %>
<table id="inner_content">
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
	<tr>
    	<td width="25%">
        <table class="inner_content_table">
        <tr>
        <td>
        <table class="news_table">
        <tr class="title_general">
        <td colspan="3" align="center">
        About Tigress
        </td>
    	</tr>
        <tr>
        <td>
        <table class="news_item_table">
        <tr>
        <td>
        <p><a href="http://tigress.cs.arizona.edu/">Tigress</a> is a diversifying virtualizer/obfuscator for the C language that supports many novel defenses against both static and dynamic reverse engineering and de-virtualization attacks.</p><br />
        <p>In particular, Tigress protects against static de-virtualization by generating virtual instruction sets of arbitrary complexity and diversity, by producing interpreters with multiple types of instruction dispatch, and by inserting code for anti alias analysis. Tigress protects against dynamic de-virtualization by merging the real code with bogus functions, by inserting implicit flow, and by creating slowly-executing reenetrant interpreters. Tigress implements its own version of code packing through the use of runtime code generation. </p>
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
        <td width="50%">
        <table class="inner_content_table">
        <tr>
        <td>
        <table class="news_table">
        <tr class="title_general">
        <td colspan="3" align="center">
        Welcome
        </td>
    	</tr>
        <tr>
        <td>
        <table class="news_item_table">
        <tr>
        <td>
        <p>This is the Tigress training and testing engine.  The web application here allows instructors to provide obfuscation challenges to trainees.  It does this by using the Tigress obfuscation program (see left); instructors store Tigress arguments to generate obfuscated code as "challenges."  After linking those challenges to trainees' accounts, the trainees may download the obfuscated code, deobfuscate it, and submit it for grading.</p><br />
        <p>Tigress offers several standard, typical argument sets which make it easy for those unfamiliar with Tigress to generate challenges.  This web application also hosts a virtual machine with several reversing tools preinstalled in order to facilitate trainees' progress.</p><br />
        <p>Currently, Tigress requires students to manually download obfuscated code directly from this web application.  Eventually, the application will automatically provision the code to virtual machines for trainees to download.  Additionally, those virtual machines will have various data collecting tools to determine maximally effective strategies for reversing and training.  Finally, grading must all be done manually at this time, but future work includes automated grading integration.</p><br />
        <p>To use this web application, log in on the right and use the top and left manu bars to navigate.</p>
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
        </td>
    </tr>
</table>
<%@include file="./WEB-INF/includes/footer.jsp" %>
</body>

</html>