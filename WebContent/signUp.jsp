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
	<tr>
		<form action="signUpSubmit.jsp" method="post">
    	<td width="25%">
        <table class="inner_content_table" style="display:none;">
        <tr>
        <td>
        <table class="news_table">
        <tr class="title_general">
        <td colspan="3" align="center">
        Options
        </td>
    	</tr>
        <tr>
        <td>
        <table class="news_item_table" width="100%">
        <tr>
        <td width="50%">
        User Type:
        </td>
        <td width="50%">
        <input type="radio" name="userType" value="instructor" CHECKED></input>
        Instructor
        <br></br>
        <input type="radio" name="userType" value="student"></input>
        Participant
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
        <td align="center">
        Request an Account
        </td>
    	</tr>
        </table>
        <table class="news_table">
        <tr>
        <td colspan="3" align="left">
        
        </td>
    	</tr>
        <tr class="title_general">
        <td colspan="3" align="center">
        Enter Information
        </td>
    	</tr>
        <tr>
        <td>
        <table class="news_item_table" width="100%">
        <tr>
        <td width="100%">
        <input type="text" onfocus="clearText(this)" name="email" value="Email" style="width:90%"></input>
        </td>
        </tr>
        <tr>
        <td width="100%">
        <input type="text" onfocus="clearText(this)" name="fname" value="First Name" style="width:90%"></input>
        </td>
        </tr>
        <tr style="display:none;">
        <td width="33%">
        Middle Name:
        </td>
        <td width="67%">
        <input type="hidden" name="mname" value="" style="width:90%"></input>
        </td>
        </tr>
        <tr>
        <td width="100%">
        <input type="text" onfocus="clearText(this)" name="lname" value="Last Name" style="width:90%"></input>
        </td>
        </tr>
        <tr>
        <td width="100%">
        <input type="text" onfocus="toPassword(this)" name="password" value="Password" style="width:90%"></input>
        <script>
        function toPassword(theForm)
        {
        	theForm.setAttribute("type", "password");
        	clearText(theForm);
        }
        </script>
        </td>
        </tr>
        <tr style="display:none;">
        <td width="100%">
        <textarea onfocus="clearText(this)" name="message" rows="5" style="width:90%">Why do you want to use the site? (250 char or less)</textarea>
        </td>
        </tr>
        <tr>
        <td width="100%">
        <div align="center">
        <input type="submit" value="Submit"></input>
        </div>
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
        </form>
        <td width="25%">
        <table class="inner_content_table">
        
        </table>
        </td>
    </tr>
</table>
<%@include file="./WEB-INF/includes/footer.jsp" %>
</body>

</html>