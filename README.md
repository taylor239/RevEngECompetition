# RevEngE
Welcome to the Github repo for the Reverse Engineering Engine—RevEngE.  The code contained here is a webapp which generates reverse engineering exercises for students to solve.  The instructions regarding how to use this software—and associated features such as data collection—run the system on a Tomcat webserver and read the instructions on the resulting web page.  The system is described in detail [here](https://www.usenix.org/conference/ase16/workshop-program/presentation/taylor).

## Requirements
This system is designed to run on Linux, and is tested on Ubuntu in particular.  However, the webapp is Java-based with a MySQL DBMS, and should run in any suitable Java server container.  The data collection software bundled with this webapp is designed to run on Linux operating systems with x86 or ARM hardware; students who are not using Linux containers will be unable to fully run this software.  Additional OS support is planned.

## How to Run
The easiest way to run this program is with Eclipse.  To do that:
1. Install the latest version of Eclipse EE and install a Tomcat server (we use version 8) on the Eclipse installation.
2. Install MySQL.  We install with the optional PhpMyAdmin for easy debugging and manipulation of the database.
3. Clone this repository into your Eclipse installation.
4. Import tigress_challenge.sql from the /sql folder into your MySQL installation. (automation of this step is TODO).
5. Right click index.jsp in the WebContent folder and run it on your Tomcat server.  At this point, Eclipse should launch a browser which navigates to the RevEngE homepage.
