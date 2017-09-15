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
        
        </td>
        <td width="50%">
        <table class="inner_content_table" width="100%">
        <tr>
        <td>
        <table class="news_table">
        <tr class="title_general">
        <td align="center">
        Data Collection
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
        <b>About Data Collection</b>
        </td>
        </tr>
        <tr>
        <td width="50%">
        <p>
        Reverse engineering code, cracking code, and removing obfuscation from code are hard problems.  While there exists a large amount of academic work regarding this subject, the actual methods and tools used in practice tend to not be widely known.
        </p>
        </td>
        <td width="50%">
        <img onclick="showLightbox('<tr><td><img style=&quot;width:100%;&quot; src=&quot;computer_science_web_header_artwork_v2.png&quot;></img></tr></td>')" style="width:100%; padding-left:1em; cursor:pointer;" src="computer_science_web_header_artwork_v2.png"></img>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <p>
        One of the primary functions of RevEngE&mdash;a University of Arizona Department of Computer Science research and education project headed by Clark Taylor and Christian Collberg&mdash;is to conduct research on what methods and tools are most effective in accomplishing the tasks listed above, particularly when various types of obfuscation are employed.  
        </p>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <b>Documents</b>
        </td>
        </tr>
        <tr>
        <td colspan="2" width="50%">
        <p>
        <ul>
        	<li><a href="https://www.usenix.org/system/files/conference/ase16/ase16-paper-taylor.pdf">A Tool for Teaching Reverse Engineering</a>, the document outlining the work here</li>
        	<li>The <a href="Students.pdf">consent form for students</a></li>
        	<li>The <a href="Professionals.pdf">consent document and information for professionals and everyone else</a></li>
        	<li>The <a href="approval.pdf">University of Arizona IRB approval letter</a> for this project</li>
        </ul>
        </p>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <b>Instructions</b>
        </td>
        </tr>
        <tr>
        <td colspan="2" width="50%">
        <p>
        The RevEngE team (in conjunction with <a href="https://www.usenix.org/conference/ase17/workshop-program/presentation/taylor">Lawrence Livermore National Laboratory's Catalyst project</a>) created a custom suite of data collection software for monitoring users as they complete RevEngE tasks/assignments.  In brief, the software functions by running in the background, capturing screenshots and window information, mouse and keyboard input, and running process statistics.  This data is sent to the RevEngE server at task/assignment completion.
        </p>
        <p>
        Currently, the data collection suite has only been tested on the <a href="tools.jsp">RevEngE virtual machine</a>.  It should not be run in any other environment; not only has it not been tested, but running this software in non-testing environments (such as the regular operating system you use) poses a significant security risk.  In order to run it, log in to this site on the RevEngE virtual machine, log in, and download and run with root privileges the script located <a href="installDataCollection.sh" download>here</a>.  More specific instructions are below:
        </p>
        <p>
        <ol>
        	<li><a href="tools.jsp">Download and setup the RevEngE virtual machine</a>.  Since the data collection software tends to be resource intensive, make sure you allocate at least 3 GB of memory and 2 processors to the virtual machine, otherwise you may experience significant performance problems.</li>
        	<li>Download the <a href="installDataCollection.sh">install script from here</a>.  Run it with root privileges:</li>
        	<p class="code">sudo ./installDataCollection.sh</p>
        	<li>From now on, your virtual machine will collect data in the background.  If you run into significant performance problems, re-download the virtual machine and proceed without data collection.</li>
        	<li>
        	When you are ready to turn in your assignment/task, check the "Upload" checkbox under the "Upload Data" column.  When you submit with the box checked, your data will be uploaded automatically.
        	</li>
        	<li>
        	Uploads are done in terms of "frames," which are loose time-segments of data.  You do not need to stay on the same webpage while uploading; the upload is being done in the background so it will only stop with an interruption like a restart.
        	</li>
        	<li>
        	Keep track of your upload progress using the <a href="dataUploads.jsp">data uploads page</a>.
        	</li>
        </ol>
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
</body>

</html>