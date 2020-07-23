package com.data;

import java.io.IOException;
import java.util.UUID;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet implementation class InstallScriptServlet
 */
@WebServlet("/installDataCollection.sh")
public class InstallScriptServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public InstallScriptServlet()
    {
        super();
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		HttpSession session = request.getSession(true);
		TrafficAnalyzer accessor=TrafficAnalyzerPool.getAnalyzer();
		if(!accessor.allowImage(request.getRemoteAddr()+"image"))
		{
			return;
		}
		
		DatabaseInformationManager manager=DatabaseInformationManager.getInstance();
		ServletContext sc=getServletContext();
		String reportPath=sc.getRealPath("/WEB-INF/");
		reportPath+="/databases.xml";
		manager.addInfoFile(reportPath);
		DatabaseConnector myConnector=(DatabaseConnector)session.getAttribute("connector");
		if(myConnector==null)
		{
			myConnector=new DatabaseConnector("pillar");
			try {
				myConnector.connect();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			session.setAttribute("connector", myConnector);
		}
		
		User myUser = null;
		System.out.println("Looking for user params");
		if(request.getParameter("email")!=null && request.getParameter("password")!=null)
		{
			System.out.println("Attempting sign in " + request.getParameter("email"));
			myUser=myConnector.signIn(request.getParameter("email"), request.getParameter("password"), request.getRemoteAddr());
			session.setAttribute("user", myUser);
		}
		
		myUser=(User)session.getAttribute("user");
		
		if(myUser == null)
		{
			String noUserOutput = "#!/bin/bash" 
			+ "\necho \"You must be signed in on revenge.cs.arizona.edu when you download this script.\"";
			response.getWriter().append(noUserOutput);
			return;
		}
		
		String curEmail = (String) myUser.getAttribute("email");
		
		myUser = myConnector.dataCollectEnable((String)myUser.getAttribute("email"));
		session.setAttribute("user", myUser);
		
		String mySqlPassword = "for_revenge";
		
		String serverName = "revenge.cs.arizona.edu";
		String port = "80";
		
		int screenshotTime = 60000;
		
		String mariaPassword = "LFgVMrQ8rqR41StN";;
		
		String output = "#!/bin/bash" 
		+ "\nclear" 
		+ "\n" 
		+ "\necho \"You are about to install the data collection suite for the RevEngE Reverse Enginerring Engine.  This data collection suite aims to conduct research by monitoring users as they complete the challenges posted on the RevEngE website (revenge.cs.arizona.edu).  It works by collecting data from the operating system, including screenshots, keyboard and mouse input, and running processes, storing that data in a local database, and uploading that data to revenge.cs.arizona.edu when you run the corresponding upload script.  If you are a student participating in this research while completing a course assignment, please review any consent forms you have been given and, if you agree, return them to the appropriate individual.  Regardless of whether you are doing this for a course or not, please provide consent here as well if you wish to participate in the study. In order to give consent, type \\\"yes\\\" and push enter.  If you do not given consent, please type \\\"no\\\" instead and the software will not be installed.  The consent agreement may be downloaded and read from the following links:\"" 
		+ "\n" 
		+ "\necho \"\"" 
		+ "\n" 
		+ "\necho \"For students: revenge.cs.arizona.edu/RevEngECompetition/Students.pdf\"" 
		+ "\necho \"For anyone else: revenge.cs.arizona.edu/RevEngECompetition/Professionals.pdf\"" 
		+ "\n" 
		+ "\necho \"\"" 
		+ "\n" 
		+ "\necho \"Do you agree to the appropriate consent document?  Please enter yes or no.  If you enter yes, you agree that you have read and agree to the appropriate consent agreement.  Entering yes will install the data collection software suite.\"" 
		+ "\n" 
		+ "\nread CONSENT" 
		+ "\n" 
		+ "\nCONSENT=${CONSENT,,}" 
		+ "\necho $CONSENT" 
		+ "\n" 
		+ "\nif [ \"$CONSENT\" != \"yes\" ]" 
		+ "\nthen" 
		+ "\n\techo \"You did not enter yes.  Exiting now.\"" 
		+ "\n\texit 1" 
		+ "\nfi" 
		+ "\n" 
		+ "\necho \"Starting data collection install\"" 
		+ "\n" 
		+ "\nsudo rm /var/lib/dpkg/lock"
		+ "\nsudo rm /var/cache/apt/archives/lock"
		+ "\nsudo dpkg --configure -a" 
		+ "\nsudo apt-get -y clean" 
		+ "\nsudo rm /var/lib/dpkg/lock"
		+ "\nsudo rm /var/cache/apt/archives/lock"
		+ "\nsudo dpkg --configure -a" 
		+ "\nsudo apt-get -y update --fix-missing" 
		+ "\nsudo rm /var/lib/dpkg/lock"
		+ "\nsudo rm /var/cache/apt/archives/lock"
		+ "\nsudo dpkg --configure -a" 
		+ "\nsudo apt-get -y upgrade" 
		+ "\nsudo rm /var/lib/dpkg/lock"
		+ "\nsudo rm /var/cache/apt/archives/lock"
		+ "\nsudo dpkg --configure -a" 
		+ "\nsudo apt-get -y update --fix-missing" 
		+ "\nsudo rm /var/lib/dpkg/lock"
		+ "\nsudo rm /var/cache/apt/archives/lock"
		+ "\nsudo dpkg --configure -a" 
		+ "\nsudo apt-get -y dist-upgrade" 
		+ "\nsudo rm /var/lib/dpkg/lock"
		+ "\nsudo rm /var/cache/apt/archives/lock"
		+ "\nsudo dpkg --configure -a" 
		+ "\nsudo apt-get -y update --fix-missing" 
		+ "\nsudo rm /var/lib/dpkg/lock"
		+ "\nsudo rm /var/cache/apt/archives/lock"
		+ "\nsudo dpkg --configure -a" 
		+ "\nsudo apt-get -y install default-jre" 
		+ "\nsudo apt-get -y install mariadb-server" 
		+ "\nsudo apt-get -y install tomcat8" 
		+ "\nsudo apt-get -y install tomcat9" 
		//+ "\nsudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password " + mySqlPassword + "'" 
		//+ "\nsudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password " + mySqlPassword + "'" 
		//+ "\nsudo apt-get -y install mysql-server" 
		//+ "\nsudo apt-get -y install mysql-client" 
		
+ "\n\nservice mysql start"
+ "\nmkdir -p /opt/dataCollector/" 
+ "\n\nwget http://" + serverName + ":" + port + "/DataCollectorServer/openDataCollection/endpointSoftware/dataCollection.sql -O /opt/dataCollector/dataCollection.sql"
+ "\n\nmariadb -u root < /opt/dataCollector/dataCollection.sql"
+ "\nmariadb -u root -e \"CREATE USER 'dataCollector'@'localhost' IDENTIFIED BY '" + mariaPassword + "';\""
+ "\nmariadb -u root -e \"GRANT USAGE ON *.* TO 'dataCollector'@'localhost' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;\""
+ "\nmariadb -u root -e \"GRANT ALL PRIVILEGES ON dataCollection.* TO 'dataCollector'@'localhost';\""
+ "\n"
+ "\nwget http://" + serverName + ":" + port + "/DataCollectorServer/openDataCollection/endpointSoftware/CybercraftDataCollectionConnector.war -O /var/lib/tomcat8/webapps/CybercraftDataCollectionConnector.war"
+ "\nwget http://" + serverName + ":" + port + "/DataCollectorServer/openDataCollection/endpointSoftware/CybercraftDataCollectionConnector.war -O /var/lib/tomcat9/webapps/CybercraftDataCollectionConnector.war"
+ "\n"
+ "\n# Copy jar to install dir" 
+ "\n" 
+ "\n#mv ./DataCollector.jar /opt/dataCollector/" 
+ "\nwget http://" + serverName + ":" + port + "/DataCollectorServer/openDataCollection/endpointSoftware/DataCollector.jar -O /opt/dataCollector/DataCollector.jar" 
+ "\nchmod +777 /opt/dataCollector/DataCollector.jar" 
+ "\nchmod +x /opt/dataCollector/DataCollector.jar" 
+ "\n" 
+ "\n" 
+ "\ntee /opt/dataCollector/DataCollectorStart.sh > /dev/null <<'EOF'" 
+ "\n#!/bin/bash" 
//+ "\nservice mysql start" 
//+ "\nservice tomcat8 start"
//+ "\nservice tomcat9 start"
+ "\nwhile true;" 
+ "\ndo" 
+ "\npkill -f \"/usr/bin/java -jar -XX:+IgnoreUnrecognizedVMOptions /opt/dataCollector/DataCollector.jar\"" 
//+ "\n/usr/bin/java -Xmx1536m -jar /opt/dataCollector/DataCollector.jar -user " + curEmail + " -server " + serverName + ":" + port + " -event " + curEvent + " -continuous "+ myNewToken + " http://revenge.cs.arizona.edu/DataCollectorServer/openDataCollection/UploadData" + " >> /opt/dataCollector/log.log 2>&1" 
+ "\n/usr/bin/java -Xmx1536m -jar -XX:+IgnoreUnrecognizedVMOptions /opt/dataCollector/DataCollector.jar -user " + curEmail + " -server " + serverName + ":" + port + " -event RevEngECompetition -screenshot " + screenshotTime + " -adminemail cgtboy1988@yahoo.com >> /opt/dataCollector/log.log 2>&1" 
+ "\necho \"Got a crash: $(date)\" >> /opt/dataCollector/log.log" 
+ "\nsleep 2" 
+ "\ndone" 
+ "\nEOF" 
+ "\n" 
+ "\nchmod +777 /opt/dataCollector/DataCollectorStart.sh" 
+ "\nchmod +x /opt/dataCollector/DataCollectorStart.sh" 
+ "\n" 
+ "\ntouch /opt/dataCollector/log.log" 
+ "\nchmod +777 /opt/dataCollector/log.log" 
+ "\n" 
+ "\n# Launch script" 
+ "\n" 
+ "\nLOG_NAME=$(logname)" 
+ "\nmkdir /home/$LOG_NAME/.config/autostart/"
+ "\ntee /home/$LOG_NAME/.config/autostart/DataCollector.desktop > /dev/null <<'EOF'" 
+ "\n[Desktop Entry]" 
+ "\nType=Application" 
+ "\nExec=\"/opt/dataCollector/DataCollectorStart.sh\"" 
+ "\nHidden=false" 
+ "\nNoDisplay=false" 
+ "\nX-GNOME-Autostart-enabled=true" 
+ "\nName[en_IN]=DataCollector" 
+ "\nName=DataCollector" 
+ "\nComment[en_IN]=Collects data" 
+ "\nComment=Collects data" 
+ "\nEOF" 
+ "\n" 
//+ "\nservice mysql start" 
//+ "\nservice tomcat8 start"
//+ "\nservice tomcat9 start"
+ "\n"
//+ "\n/opt/dataCollector/DataCollectorStart.sh & disown" ;
+ "\nreboot" ;
		
		
		/*
		+ "\n\nservice mysql start"
		+ "\nmkdir -p /opt/dataCollector/" 
		+ "\n\nwget http://" + serverName + ":" + port + "/DataCollectorServer/openDataCollection/endpointSoftware/dataCollection.sql -O /opt/dataCollector/dataCollection.sql"
		+ "\n\nmariadb -u root < /opt/dataCollector/dataCollection.sql"
		+ "\nmariadb -u root -e \"CREATE USER 'dataCollector'@'localhost' IDENTIFIED BY '" + mariaPassword + "';\""
		+ "\nmariadb -u root -e \"GRANT USAGE ON *.* TO 'dataCollector'@'localhost' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;\""
		+ "\nmariadb -u root -e \"GRANT ALL PRIVILEGES ON dataCollection.* TO 'dataCollector'@'localhost';\""
		+ "\n"
		+ "\nwget http://" + serverName + ":" + port + "/DataCollectorServer/openDataCollection/endpointSoftware/CybercraftDataCollectionConnector.war -O /var/lib/tomcat8/webapps/CybercraftDataCollectionConnector.war"
		+ "\n"
		+ "\n# Copy jar to install dir" 
		+ "\n" 
		+ "\n#mv ./DataCollector.jar /opt/dataCollector/" 
		+ "\nwget http://" + serverName + ":" + port + "/DataCollectorServer/openDataCollection/endpointSoftware/DataCollector.jar -O /opt/dataCollector/DataCollector.jar" 
		+ "\nchmod +777 /opt/dataCollector/DataCollector.jar" 
		+ "\nchmod +x /opt/dataCollector/DataCollector.jar" 
		+ "\n" 
		+ "\n" 
		+ "\ntee /opt/dataCollector/DataCollectorStart.sh > /dev/null <<'EOF'" 
		+ "\n#!/bin/bash" 
		+ "\nwhile true;" 
		+ "\ndo" 
		//+ "\nservice mysql start" 
		//+ "\nservice tomcat8 start"
		+ "\npkill -f \"/usr/bin/java -jar -XX:+IgnoreUnrecognizedVMOptions /opt/dataCollector/DataCollector.jar\"" 
		+ "\n/usr/bin/java -Xmx1536m -jar -XX:+IgnoreUnrecognizedVMOptions /opt/dataCollector/DataCollector.jar -user " + curEmail + " -server " + serverName + ":" + port + " -databasePassword " + mariaPassword + " -event RevEngECompetition >> /opt/dataCollector/log.log 2>&1" 
		+ "\necho \"Got a crash: $(date)\" >> /opt/dataCollector/log.log" 
		+ "\nsleep 2" 
		+ "\ndone" 
		+ "\nEOF" 
		+ "\n" 
		+ "\nchmod +777 /opt/dataCollector/DataCollectorStart.sh" 
		+ "\nchmod +x /opt/dataCollector/DataCollectorStart.sh" 
		+ "\n" 
		+ "\ntouch /opt/dataCollector/log.log" 
		+ "\nchmod +777 /opt/dataCollector/log.log" 
		+ "\n" 
		+ "\n# Launch script" 
		+ "\n" 
		+ "\nmkdir ~/.config/autostart/"
		+ "\ntee ~/.config/autostart/DataCollector.desktop > /dev/null <<'EOF'" 
		+ "\n[Desktop Entry]" 
		+ "\nType=Application" 
		+ "\nExec=\"/opt/dataCollector/DataCollectorStart.sh\"" 
		+ "\nHidden=false" 
		+ "\nNoDisplay=false" 
		+ "\nX-GNOME-Autostart-enabled=true" 
		+ "\nName[en_IN]=DataCollector" 
		+ "\nName=DataCollector" 
		+ "\nComment[en_IN]=Collects data" 
		+ "\nComment=Collects data" 
		+ "\nEOF" 
		+ "\n" 
		+ "\nservice mysql start" 
		+ "\nservice tomcat8 start"
		+ "\n"
		+ "\n/opt/dataCollector/DataCollectorStart.sh & disown" ;*/
		response.getWriter().append(output);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		doGet(request, response);
	}

}
