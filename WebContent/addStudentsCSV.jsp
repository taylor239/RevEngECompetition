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
    	<td width="25%">
        <table class="inner_content_table">
        <tr>
        <td>
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
        CSV Upload
        </td>
    	</tr>
        <tr>
        <td>
        <table class="news_item_table" width="100%">
        <tr>
        <td colspan="2">
        This CSV upload is designed to upload an entire course of students at a time.  Browse for the CSV file and enter the course name below.  Format the CSV as follows:
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <br />
        "[last name], [first name]",[email]<br />
        "[last name], [first name]",[email]<br />
        <br />
        </td>
        </tr>
        <tr>
        <td>
        Note that brackets indicate terms to replace; the format does not use bracket characters.
        </td>
        </tr>
        <tr>
        <td colspan="2">
        &nbsp;
        </td>
        </tr>
        <form enctype="multipart/form-data" action="StudentCSVUpload" method="post">
        <tr>
        <td colspan="2" width="100%">
        <div align="left">
        <input type="file" name="csvFile" style="width:100%;"></input>
        </div>
        </td>
        </tr>
        <tr>
        <td colspan="2" width="100%">
        <div align="left">
        <input type="text" name="courseName" value="Course Name" onfocus="clearText(this);" style="width:100%;"></input>
        </div>
        </td>
        </tr>
        <tr colspan="2">
        <td width="100%">
        <div align="left">
        <input type="submit" value="Submit"></input>
        </div>
        </td>
        </tr>
        </form>
        </table>
        </td>
        </tr>
        </table>
        </td>
        </tr>
        </table>
        </td>
        <td width="25%">
        
        </td>
    </tr>
</table>
<%@include file="./WEB-INF/includes/footer.jsp" %>
</body>

</html>