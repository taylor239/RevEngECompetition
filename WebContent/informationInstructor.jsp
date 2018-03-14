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
        How to use RevEngE
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
        <b>1.  Getting your account and logging in</b>
        </td>
        </tr>
        <tr>
        <td width="50%">
        <p>
        Navigate to the login page via the "Login" button on the navigation bar.  If you have an account already, sign in.  If not, request an account via the link on the page.
        </p>
        </td>
        <td width="50%">
        <img onclick="showLightbox('<tr><td><img style=&quot;width:100%;&quot; src=&quot;./img/instructionImages/login.JPG&quot;></img></tr></td>')" style="width:100%; padding-left:1em; cursor:pointer;" src="./img/instructionImages/login.JPG"></img>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <b>2.  Request an account</b>
        </td>
        </tr>
        <tr>
        <td width="50%">
        <p>
        After navigating from the "Login" page to the "Request an Account" page, fill out the forms and push "Submit".  The site admin will approve your account as soon as possible.
        </p>
        </td>
        <td width="50%">
        <img onclick="showLightbox('<tr><td><img style=&quot;width:100%;&quot; src=&quot;./img/instructionImages/admin/admin_signup.JPG&quot;></img></tr></td>')" style="width:100%; padding-left:1em; cursor:pointer;" src="./img/instructionImages/admin/admin_signup.JPG"></img>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <b>3a.  Add students from a CSV</b>
        </td>
        </tr>
        <tr>
        <td width="50%">
        <p>
        Under the "For Instructors" button on the navigation bar, click "Add Students".  This page allows you to upload a CSV with your students' information, creating accounts on this site for them.  Select your CSV file, enter a course name, and click "Submit".  Course names are used to assign assignments in bulk.
        </p>
        </td>
        <td width="50%">
        <img onclick="showLightbox('<tr><td><img style=&quot;width:100%;&quot; src=&quot;./img/instructionImages/admin/admin_add_students.JPG&quot;></img></tr></td>')" style="width:100%; padding-left:1em; cursor:pointer;" src="./img/instructionImages/admin/admin_add_students.JPG"></img>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <b>3b.  Add students manually</b>
        </td>
        </tr>
        <tr>
        <td width="50%">
        <p>
        Under the "For Instructors" button on the navigation bar, click "Add Individual Students".  This page allows you to add students by manually entering their information.  Enter a student's information and click "Add Another" for each additional student, then push "Submit".  Course names are used to assign assignments in bulk.
        </p>
        </td>
        <td width="50%">
        <img onclick="showLightbox('<tr><td><img style=&quot;width:100%;&quot; src=&quot;./img/instructionImages/admin/admin_add_student.JPG&quot;></img></tr></td>')" style="width:100%; padding-left:1em; cursor:pointer;" src="./img/instructionImages/admin/admin_add_student.JPG"></img>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <b>4.  Download students' passwords</b>
        </td>
        </tr>
        <tr>
        <td width="50%">
        <p>
        After adding students, you should download students' login information and send it to them.  On the "Students Added" page (which the "Submit" button navigates you to) for adding students, you can download or copy a table of students' information.  This information can be accessed later (if lost) by navigating to "Get Student Passwords" under the "For Instructors" button on the menu bar.
        </p>
        </td>
        <td width="50%">
        <img onclick="showLightbox('<tr><td><img style=&quot;width:100%;&quot; src=&quot;./img/instructionImages/admin/admin_add_student_submit.JPG&quot;></img></tr></td>')" style="width:100%; padding-left:1em; cursor:pointer;" src="./img/instructionImages/admin/admin_add_student_submit.JPG"></img>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <b>5.  Manage students</b>
        </td>
        </tr>
        <tr>
        <td width="50%">
        <p>
        To view and delete students, click the "Manage Students" link under "For Instructors".  This page contains a list of your students sortable and filterable by student information and course names.  Note that, once a student has been deleted, their assignments and submissions will also be deleted.
        </p>
        </td>
        <td width="50%">
        <img onclick="showLightbox('<tr><td><img style=&quot;width:100%;&quot; src=&quot;./img/instructionImages/admin/admin_manage_students.JPG&quot;></img></tr></td>')" style="width:100%; padding-left:1em; cursor:pointer;" src="./img/instructionImages/admin/admin_manage_students.JPG"></img>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <b>6.  Create an assignment</b>
        </td>
        </tr>
        <tr>
        <td width="50%">
        <p>
        Navigate to the "Enter Assignment Information" page by clicking on the "Create Assignment" link under the "For Instructors" button on the menu bar.  Here, you fill out the administrative information such as the name, open and due dates, and instructions for the students.  Then, you select a "Challenge" under "Select Problem".  This section contains RevEngE default challenges as well as challenges you add (see Step 9).  Each problem you may select contains a description entailing what the problem does.  Finally, assign to courses under "Assign To" and push submit.  The administrative information may be edited at a later time.
        </p>
        </td>
        <td width="50%">
        <img onclick="showLightbox('<tr><td><img style=&quot;width:100%;&quot; src=&quot;./img/instructionImages/admin/admin_create_assignment.JPG&quot;></img></tr></td>')" style="width:100%; padding-left:1em; cursor:pointer;" src="./img/instructionImages/admin/admin_create_assignment.JPG"></img>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <b>7.  View your assignments</b>
        </td>
        </tr>
        <tr>
        <td width="50%">
        <p>
        Navigate to the "Assignments" page by clicking on the "View Assignments" link under the "For Instructors" button on the menu bar.  This table displays all of your assignments with summary information and allows you to download student submissions via the "Download All" link.  This download consists of a .zip file with directories for each student who submitted an an answer.  To edit and manage an assignment, click the "Manage" link.
        </p>
        </td>
        <td width="50%">
        <img onclick="showLightbox('<tr><td><img style=&quot;width:100%;&quot; src=&quot;./img/instructionImages/admin/admin_manage_assignments.JPG&quot;></img></tr></td>')" style="width:100%; padding-left:1em; cursor:pointer;" src="./img/instructionImages/admin/admin_manage_assignments.JPG"></img>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <b>8.  Manage an assignment</b>
        </td>
        </tr>
        <tr>
        <td width="50%">
        <p>
        Once you have navigated to the Manage page via the "Manage" link in step 6, you can edit the administrative information for an assignment such as due dates and problem the assignment description.  You can also delete the assignment or monitor individual students' progress on the "View Submission Details" page. On the "View Submission Details" page, you can download individual students' code and see their submission time.  Late assignments are indicated as such with red font on the "Last Submission" column and an "X" in the "Late" column.  The page also shows whether students have generated code, which would indicate whether they have started the assignment.
        </p>
        </td>
        <td width="50%">
        <img onclick="showLightbox('<tr><td><img style=&quot;width:100%;&quot; src=&quot;./img/instructionImages/admin/admin_manage_assignment.JPG&quot;></img></tr></td>')" style="width:100%; padding-left:1em; cursor:pointer;" src="./img/instructionImages/admin/admin_manage_assignment.JPG"></img>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <b>9.  Create a challenge</b>
        </td>
        </tr>
        <tr>
        <td width="50%">
        <p>
        The default challenges should be a good starting point for making assignments.  For advanced courses or hard problems, you may wish to build your own challenges.  To do this, navigate to the "Enter Challenge Information" page by clicking on "Create Challenge" under the "For Instructors" button.  The way challenges work here is by using either two or three steps: (1) Generate a source program, (2) obfuscate that source program, and optionally (3) compile the source program to a binary.  To create a challenge, you specify arguments to the Tigress program to generate and obfuscate as you desire.  For complete documentation of Tigress' arguments, see <a href="tigress.cs.arizona.edu">the Tigress homepage.</a>  After specifying arguments, select whether you would like to compile to binary and fill in the administrative information such as name and description.  In the "Auto Grade" section at the bottom of the page, you can specify tests for RevEngE to run on students' assignment submissions in order to determine if they match the original, non-obfuscated program in function and performance.  The "Number of Iterations" specifies then number of times to run the test.  The "Performance cutoff" specifies how close the students' answers must be to the original, non-obfuscated source; each instruction type (we use LLVM instructions for this) will have to be within a factor specified in this field.  The "Arguments" section specifies what RevEngE gives students' submissions and the original program as arguments; literal arguments can be specified for things like password protections and random arguments can be used to see if program IO matches.  Once you push "Submit", the challenge should be available in the "Create Assignment" page (see Step 6).
        </p>
        </td>
        <td width="50%">
        <img onclick="showLightbox('<tr><td><img style=&quot;width:100%;&quot; src=&quot;./img/instructionImages/admin/admin_create_challenge.JPG&quot;></img></tr></td>')" style="width:100%; padding-left:1em; cursor:pointer;" src="./img/instructionImages/admin/admin_create_challenge.JPG"></img>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <b>10.  Edit a challenge</b>
        </td>
        </tr>
        <tr>
        <td width="50%">
        <p>
        After making a challenge, it may be edited by clicking on "View Challenges" under the "For Instructors" button.  On that page, select the challenge you would like to edit and click "Manage" to open the editing page.  Note that changes to challenges are not propagated onto the assignments you have already created.
        </p>
        </td>
        <td width="50%">
        <img onclick="showLightbox('<tr><td><img style=&quot;width:100%;&quot; src=&quot;./img/instructionImages/admin/admin_view_challenges.JPG&quot;></img></tr></td>')" style="width:100%; padding-left:1em; cursor:pointer;" src="./img/instructionImages/admin/admin_view_challenges.JPG"></img>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <b>11.  View assignments as a student</b>
        </td>
        </tr>
        <tr>
        <td width="50%">
        <p>
        Your instructor account also acts as a student account which has been assigned each assignment you have created.  To view and try your own assignments, follow <a href="studentInfo.jsp">the instructions on the student information page.</a>
        </p>
        </td>
        <td width="50%">
        
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