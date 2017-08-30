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
        GDB: The GNU Debugger Tutorial
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
        <b>Background</b>
        </td>
        </tr>
        <tr>
        <td width="50%">
        <p>
        <a href="https://www.gnu.org/software/gdb/">GDB</a> is a debugger&mdash;a tool which runs executable programs while tracing the execution.  Different debuggers offer different features and different levels of tracing.  GDB, developed as part of the GNU suite of software, is a flexible debugger with quite a few features, many of which are useful in reverse engineering binaries.  It can (as can objdump) act as a disassembler as well&mdash;turning binaries into assembly.  It can execute programs step-by-step and can execute until user-defined breakpoints.  It also has several graphical (GUI) front-ends, though it is often used as a command-line tool&mdash;we will be using it on the command line for the demo here.
        </p>
        </td>
        <td width="50%">
        <img onclick="showLightbox('<tr><td><img style=&quot;width:100%;&quot; src=&quot;https://www.gnu.org/software/gdb/images/archer.jpg&quot;></img></tr></td>')" style="width:100%; padding-left:1em; cursor:pointer;" src="https://www.gnu.org/software/gdb/images/archer.jpg"></img>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <b>Downloads</b>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <p>
        For this demo, we will be attempting to crack a program with a built-in timecheck.  That program is available <a href="./example_code/a.out">here</a>.
        </p>
        <p>
        It is assumed that you are running this program on the RevEngE-provided virtual machine (located <a href="reversing.jsp">here</a>) or have configured your own environment to support GDB and objdump.
        </p>
        </tr>
        <tr>
        <td colspan="2">
        <b>1. Run the program</b>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <p>
        To get an idea of what we need to do, we first run the program.  In practice, it is important to be careful when running binaries so that one does not run a virus.  We know that our program here is benign, and we are operating in a virtual machine, so it is OK to execute.  First, download the sample code and make sure its permissions allow execution.  Then, after launching a terminal and entering the directory with the example problem:
        </p>
        <p class="code">
        chmod +x ./a.out
        </p>
        <p class="code">
        ./a.out
        </p>
        <p>
        The program needs 1 argument:
        </p>
        <p class="code">
        ./a.out 12
        </p>
        <p>
        We should get a segmentation fault, so we know that this is the behavior of the program when it fails the time check.
        </p>
        </tr>
        <tr>
        <td colspan="2">
        <b>2. Disassemble the program</b>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <p>
        Disassembly is a form of static analysis.  It specifies the instructions that a program executes, but does so by examining the binary without execution.  Many things can be done to analyze disassembled code; for the purposes here we use the disassembly as a map of where we step in GDB.  To disassemble with objdump:
        </p>
        <p class="code">
        objdump -d ./a.out
        </p>
        <p>
        The output of this command should be saved, either by copy and pasting it or by piping the output to a file:
        </p>
        <p class="code">
        objdump -d ./a.out > disassembled.txt
        </p>
        <p>
        We now have the disassembled assembly code of the example program.  Because we know this program contains a timecheck, we can hack around intensive analysis and look for the time check code.  Immediately, we can see that the instruction at address 4004d0 calls gettimeofday, which is the standard library call to get the time.
        </p>
        </tr>
        <tr>
        <td colspan="2">
        <b>3. Run with GDB</b>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <p>
        Now we run the program in GDB:
        </p>
        <p class="code">
        gdb ./a.out
        </p>
        <p class="code">
        run 12
        </p>
        <p class="code">
        where
        </p>
        <p>
        This runs the program with an argument of 12.  The "where" command lets us know where the segmentation fault occurs&mdash;in this case, at instruction 400791.  This particular error means that the program attempted to read or write to an address that is not in a valid memory location.  We know that this is not a bug, because we assume the program has been debugged and is functioning correctly; as a RevEngE-generated program, this is a safe assumption.  This means that the seg fault was intentional, and, because we know the program does a time check, we can assume that the time check is causing the seg fault.  Further, because the gettimeofday call and the seg fault instruction occur in the same function, we can look in between these for the cause of the seg fault.  From here, we can either look forward from the gettimeofday call or backward from the seg fault cause.  Looking forward, we can find the cause by looking for control flow&mdash;instructions that change the way a program executes, such as branches or jumps&mdash;after the gettimeofday call.  At instruction 4006e8, there is a cmp; cmp instructions compare two values and are generally used in control flow.  In this instruction, the program compares the output of gettimeofday to the value 0x535d6479, which is 1398629497 in decimal.  To see how this works in action:
        </p>
        <p class="code">
        gdb ./a.out
        </p>
        <p>
        Now, set a breakpoint for the instruction right after the return from gettimeofday.  These initial instructions handle the return value from the gettimeofday function.
        </p>
        <p class="code">
        break *0x4006d9
        </p>
        <p>
        Next, run until you get to that point in the code.
        </p>
        <p class="code">
        run 12
        </p>
        <p>
        GDB has stopped executing at the instruction you told it; from here, you can step using the stepi command and look at registers as you do it.
        </p>
        <p class="code">
        info registers \\Look at all of the registers<br />
        info registers eax       \\Look at the eax register
        </p>
        <p>
        As we can see, eax has not yet been assigned.  So, we step.
        </p>
        <p class="code">
        stepi<br />
        stepi<br />
        stepi<br />
        info registers eax<br />
        info registers rax
        </p>
        <p>
        Both of these registers now contain the value 1494739794 in my execution.  Looking at the definition of gettimeofday, this is a number of seconds since the epoch&mdash;a way of telling time on a computer.  This corresponds to May 14, 2017, at 10:29:54, the exact time when this tutorial was updated last.  Go ahead and check your time online at <a href="currentmillis.com">currentmilis.com</a>.  Keep in mind that you have to convert from seconds to milliseconds to use their website.
        </p>
        <p>
        We should now be at instruction 4006e4.  Let's continue executing through the cmp instruction and look at the flags it sets:
        </p>
        <p class="code">
        stepi<br />
        stepi<br />
        info registers eflags
        </p>
        <p>
        The AF and IF flags should be set.  The next instruction is seta, which sets a byte if the CF and ZF flags are not set; as we have seen, these flags are not set here, so it should set the al register to 1, as we can see:
        </p>
        <p class="code">
        stepi<br />
        info registers al<br />
        info registers eax
        </p>
        <p>
        So far, we have seen the return value from the gettimeofday alter control flow by causing the seta instruction to execute after the cmp instruction.  While we may need to do additional analysis, we can now try changing that instruction to see if it disables the time check.
        </p>
        </tr>
        <tr>
        <td colspan="2">
        <b>4. Alter instructions in GDB</b>
        </td>
        </tr>
        <tr>
        <td colspan="2">
        <p>
        Now that we have an idea regarding which instructions need to be changed, we can test those changes in GDB.  After exiting the run from 3. above, we can go ahead and restart GDB from the beginning:
        </p>
        <p class="code">
        gdb ./a.out
        </p>
        <p>
        Now, we can set the breakpoint to get us to right before we change the instructions:
        </p>
        <p class="code">
        break *0x4006e8<br />
        run 12
        </p>
        <p>
        We can now either change the instruction itself or change the value of rax, which the instruction uses.  To do the latter, set rax to 1 less than the cmp value and run:
        </p>
        <p class="code">
        set $rax = 0x535d6478
        continue
        </p>
        <p>
        The program completes without any seg fault, so we have cracked it!  However, we may want to disable the timecheck altogether in the binary so that it may be run anywhere.  We can do this with GDB!  First, start the program in GDB with the write option:
        </p>
        <p class="code">
        gdb -write -q a.out
        </p>
        <p>
        Now, follow the steps above.  After changing $rax, quit.  Then try running the program.  If all went well, it should run fine now!
        </p>
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