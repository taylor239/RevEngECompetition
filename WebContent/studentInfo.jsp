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
        How to use the RevEngE Competition Engine
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
        <b>Introduction</b>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        The RevEngE competition engine generates difficult reverse engineering problems, and provides cash prizes for those who (1) solve them by meeting our grading criteria, and (2) meet our reporting criteria.  Both of these are explained below, as are the cash prizes.
        </td>
        </tr>
        
        <tr>
        <td colspan="2">
        <b>&nbsp;</b>
        </td>
        </tr>
        
        <tr>
        <td colspan="2">
        <b>Quick Start</b>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        If you have already read all of the information below, you can follow these steps to get up and running:
        <ul>
        	<li>Download and configure your Debian variant (we test using Kali and Ubuntu, and these are the versions we support) virtual machine</li>
        	<li>Once your VM is running, download and run with admin/sudo/root the following script: <a href="installDataCollection.sh" download>installDataCollection.sh</a></li>
        	<li>With the data collection running, download and solve challenges</li>
        	<li>Upload your challenge submissions, and when you do check the "Upload Collected Data" to submit your data (because this takes a while, you may want to do this only for your final submission)</li>
        </ul>
        </td>
        </tr>
        
        <tr>
        <td colspan="2">
        &nbsp;
        </td>
        </tr>
        
        <tr>
        <td colspan="2">
        <b>1.  Getting your account and logging in</b>
        </td>
        </tr>
        <tr>
        <td width="50%">
        <p>
        Before solving challenges, you need to get an account.  To do this, click the "Login" button above and click the link to sign up.  Fill out the form, and you should receive an account.
        </p>
        </td>
        <td width="50%">
        <img onclick="showLightbox('<tr><td><img style=&quot;width:100%;&quot; src=&quot;./img/newInst/login.png&quot;></img></tr></td>')" style="width:100%; padding-left:1em; cursor:pointer;" src="./img/newInst/login.png"></img>
        </td>
        </tr>
        
        <tr>
        <td colspan="2">
        &nbsp;
        </td>
        </tr>
        
        <tr>
        <td colspan="2">
        <b>2. Setup data collection on your device</b>
        </td>
        </tr>
        <tr>
        <td width="50%">
        <p>
		In order to be eligible for most prizes, you should setup our data collection software.  First, download and run a virtual machine loaded with Kali or Ubuntu Linux, then run the install script available below.  For more details on how to do this, as well as what data is collected, see the data collection information section below.
        </p>
        </td>
        <td width="50%">
        <img onclick="showLightbox('<tr><td><img style=&quot;width:100%;&quot; src=&quot;./img/newInst/kali.png&quot;></img></tr></td>')" style="width:100%; padding-left:1em; cursor:pointer;" src="./img/newInst/kali.png"></img>
        </td>
        </tr>
        <tr>
        
        <tr>
        <td colspan="2">
        &nbsp;
        </td>
        </tr>
        
        <td colspan="2">
        <b>3. Solve challenges</b>
        </td>
        </tr>
        <tr>
        <td width="50%">
        <p>
        In the navigation bar, under the "Challenges" button, click on "View Challenges".  This takes you to the challenge page, where all of the current challenges are listed.  Note that loading this page will take a while on the first time, and may occasionally take a while as new challenges are added because RevEngE is populating your account with the obfuscated programs in the database.  They are arranged in challenge sets, where each challenge in a given set is the same type of problem but generated with a unique random seed.  Only when an entire challenge set is completed is the challenge set's problem considered solved.  In order to solve the challenges, click the "Generate" link to generate the problem code, then download it.  The instructions for a given problem are visible by clicking the challenge name.
        </p>
        </td>
        <td width="50%">
        <img onclick="showLightbox('<tr><td><img style=&quot;width:100%;&quot; src=&quot;./img/newInst/challenges.png&quot;></img></tr></td>')" style="width:100%; padding-left:1em; cursor:pointer;" src="./img/newInst/challenges.png"></img>
        </td>
        </tr>
        
        <tr>
        <td colspan="2">
        &nbsp;
        </td>
        </tr>
        
        <tr>
        <td colspan="2">
        <b>4. Upload your solution</b>
        </td>
        </tr>
        <tr>
        <td width="50%">
        <p>
        After you solve a challenge, you can upload your solution on the "View Challenges" page.  If you select to use the data collection software, checking the "Upload" checkbox will upload your data after submitting the solution.  When you submit your solution, automatic grading will engage, showing test results in real time.  These results may be viewed on the "View Challenges" page, by clicking the challenge name.  If all tests are correct, the problem will be highlighted yellow on the "View Challenges" page, indicating that the site admins will next manually check the solution.
        </p>
        </td>
        <td width="50%">
        <img onclick="showLightbox('<tr><td><img style=&quot;width:100%;&quot; src=&quot;./img/newInst/upload.png&quot;></img></tr></td>')" style="width:100%; padding-left:1em; cursor:pointer;" src="./img/newInst/upload.png"></img>
        </td>
        </tr>
        
        <tr>
        <td colspan="2">
        &nbsp;
        </td>
        </tr>
        
        <tr>
        <td colspan="2">
        <b>5. Wait for manual checking and analysis</b>
        </td>
        </tr>
        <tr>
        <td width="50%">
        <p>
        After you have successfully completed all challenges in a given challenge set, the site admins will check these problems manually in order to further analyze the correctness of the submissions.  If the site admins are satisfied (according to the grading criteria listed below) then they will contact you via email about data collection and rewards.  If the site admins are not satisfied (again, according to the criteria listed), then they will contact you to express why.
        </p>
        </td>
        <td width="50%">
        <img onclick="showLightbox('<tr><td><img style=&quot;width:100%;&quot; src=&quot;./img/newInst/graded.png&quot;></img></tr></td>')" style="width:100%; padding-left:1em; cursor:pointer;" src="./img/newInst/graded.png"></img>
        </td>
        </tr>
        
        <tr>
        <td colspan="2">
        &nbsp;
        </td>
        </tr>
        
        <tr>
        <td colspan="2">
        <b>Grading details and criteria</b>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <p>
        All details specified in a challenge's instructions (viewable on the "View Challenges" page by clicking on the challenge name) supersede the rules given here.  Challenges consist of (1) an original source file, which is not obfuscated, (2) an obfuscated source file, and (3) a submitted, deobfuscated version of (2).  You have, as a participant, access to (2) and generate (3).  Grading consists of two phases: (1) Automatic grading, and (2) manual grading.
        </p>
        
        <p>
        &nbsp;
        </p>
        
        <p>
        Automatic grading consists of two subphases:  (1) Correctness testing, and (2) performance analysis.  In correctness testing, RevEngE tests whether your submission is functionally identical to the original program.  That is, for the set of input given to your program and the original program, the output must be identical.  Functional equivilence, however, is not sufficient to determine whether a given program has been deobfuscated.  Making this determination is not easy, and manual grading is necessary.  However, the performance analysis done automatically filters out submissions which perform (have instruction counts) more similar to an obfuscated program than the original program.
        </p>
        
        <p>
        &nbsp;
        </p>
        
        <p>
        If a submission is determined to be correct and have performance similar to the original (non-obfuscated) program from which a challenge is created, then manual grading is done to determine whether the submission represents a successful deobfuscation of the obfuscated version.  The results of manual grading are sent to you via email.  The criteria for this manual grading includes:  (1) How human readable is the submission?  (2) How well does the program perform?  (3) How does the submitted program's control flow graphs (both static and dynamic) compare to the original control flow graphs?
        </p>
        </tr>
        
        <tr>
        <td colspan="2">
        &nbsp;
        </td>
        </tr>
        
        <tr>
        <td colspan="2">
        <b>Data collection and prizes</b>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <p>
        Details regarding compensation are available on the "consent document and information for professionals and everyone else" below.  A "Problem" is a Challenge Set.  Solving a "Problem" entails solving the entire problem set.  All challenges in the challenge set will include, in the instructions, the difficulty class of the challenge set.
        </p>
        
        <p>
        &nbsp;
        </p>
        
        <p>
        There are two ways to be awarded compensation for solving problems.  The first way requires the submission of a written document detailing how you solved a given problem.  The site admins must be able to understand the methodology you used, based on this written submission.  If the submission is satisfactory, you will be awarded compensation for a "Limited Submission", which is $50 for medium difficulty problems and $100 for hard difficulty problems.  This award is only available for the first successful submission for a given challenge set.
        </p>
        
        <p>
        &nbsp;
        </p>
        
        <p>
        The second way to be awarded compensation requires the submission of a written document, as required for the "Limited Submission", but additionally requires the use and submission of data from our data collection software (as detailed on the Data Collection page).  If the software is used correctly and written document satisfactory, you will be awarded compensation for a "Full Submission", which consists of $500, $200, and $100, respectively, for the first, second, and third successful submissions to a medium difficulty problem, and $1000, $400, and $200, respectively, for the first, second, and third successful submissions to a hard difficulty problem.  Only unique solutions will be given an award; if another submission already employed the same methodology as a subsequent solution, the subsequent solution will not be considered successful.  The same researcher may be awarded multiple successful solutions, but must do so from different accounts and with different methodologies.  For Beta difficulty problems, a $100 prize is available for the first successful, full submission including data collection.
        </p>
        </tr>
        
        <tr>
        <td colspan="2">
        &nbsp;
        </td>
        </tr>
        
        <tr>
        <td colspan="2">
        <b>About the Data Collection Software</b>
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
        &nbsp;
        </td>
        </tr>
        
        <tr>
        <td colspan="2">
        <p>
        One of the primary functions of RevEngE&mdash;a University of Arizona Department of Computer Science research and education project headed by Claire Taylor and Christian Collberg&mdash;is to conduct research on what methods and tools are most effective in accomplishing the tasks listed above, particularly when various types of obfuscation are employed.  
        </p>
        </td>
        </tr>
        
        <tr>
        <td colspan="2">
        &nbsp;
        </td>
        </tr>
        
        <tr>
        <td colspan="2">
        <b>Documents and Links</b>
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
        	<li>The <a href="https://github.com/cgtboy1988/UserMonitor">Github respository</a> for the data collection software</li>
        </ul>
        </p>
        </td>
        </tr>
        
        <tr>
        <td colspan="2">
        &nbsp;
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
        The RevEngE team (in conjunction with <a href="https://www.usenix.org/conference/ase17/workshop-program/presentation/taylor">Lawrence Livermore National Laboratory's Catalyst project</a>) created a custom suite of data collection software for monitoring users as they complete RevEngE tasks/assignments.  In brief, the software functions by running in the background, capturing screenshots and window information, mouse and keyboard input, and running process statistics.  This data is sent to the RevEngE server at task/assignment completion, if you select the "Upload Data" box.
        </p>
        
        <p>
        &nbsp;
        </p>
        
        <p>
        Currently, the data collection suite has only been tested on <a href="https://www.kali.org/">Kali Linux</a> x86/x64 and Ubuntu x86/x64.  Other Debian based distros may also work; if you desire to use a different operating system, contact the administrators first on the <a href="">contact page</a>.  Do not run this software in a host operating system; only use virtual machines in order to minimize security risk.  After installing data collection to a virtual machine, do not enter sensitive data on it.  Once you have your VM set up, download and run with root privileges the script located <a href="installDataCollection.sh" download>here</a>.  More specific instructions are below:
        </p>
        
        <p>
        &nbsp;
        </p>
        
        <p>
        <ol>
        	<li>Download and setup your desired virtual machine.  Since the data collection software tends to be resource intensive, make sure you allocate at least 4 GB of memory and 2 processors to the virtual machine, otherwise you may experience significant performance problems.</li>
        	<li>Download the <a href="installDataCollection.sh" download>install script from here</a>.  Run it with root privileges:</li>
        	<p class="code">sudo ./installDataCollection.sh</p>
        	<li>From now on, your virtual machine will collect data in the background.  If you run into significant performance problems, increase virtual machine hardware allocation or re-download the virtual machine and proceed without data collection.  Note that continuing without data collection impacts compensation eligibility.</li>
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