package com.data;

import java.io.IOException;

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
		DatabaseConnector myConnector=(DatabaseConnector)session.getAttribute("connector");
		if(myConnector==null)
		{
			myConnector=new DatabaseConnector("pillar");
			session.setAttribute("connector", myConnector);
		}
		User myUser=(User)session.getAttribute("user");
		String curEmail = (String) myUser.getAttribute("email");
		
		myUser = myConnector.dataCollectEnable((String)myUser.getAttribute("email"));
		session.setAttribute("user", myUser);
		
		String mySqlPassword = "for_revenge";
		
		String serverName = "revenge.cs.arizona.edu";
		String port = "80";
		
		String output = "#!/bin/bash" 
		+ "\nclear" 
		+ "\n" 
		+ "\necho \"You are about to install the data collection suite for the RevEngE Reverse Enginerring Engine.  This data collection suite aims to conduct research by monitoring users as they complete the challenges posted on the RevEngE website (revenge.cs.arizona.edu).  It works by collecting data from the operating system, including screenshots, keyboard and mouse input, and running processes, storing that data in a local database, and uploading that data to revenge.cs.arizona.edu when you run the corresponding upload script.  If you are a student participating in this research while completing a course assignment, please review any consent forms you have been given and, if you agree, return them to the appropriate individual.  Regardless of whether you are doing this for a course or not, please provide consent here as well if you wish to participate in the study. In order to give consent, type \\\"yes\\\" and push enter.  If you do not given consent, please type \\\"no\\\" instead and the software will not be installed.  The consent agreement may be downloaded and read from the following links:\"" 
		+ "\n" 
		+ "\necho \"\"" 
		+ "\n" 
		+ "\necho \"For students: revenge.cs.arizona.edu/consent/student.pdf\"" 
		+ "\necho \"For anyone else: revenge.cs.arizona.edu/consent/professionals.pdf\"" 
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
		+ "\nsudo apt-get -y install default-jre" 
		+ "\nsudo apt-get -y install tomcat8" 
		//+ "\nsudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password " + mySqlPassword + "'" 
		//+ "\nsudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password " + mySqlPassword + "'" 
		//+ "\nsudo apt-get -y install mysql-server" 
		//+ "\nsudo apt-get -y install mysql-client" 
		+ "\nservice mariadb start"
		+ "\nwget http://" + serverName + ":" + port + "/DataCollectorServer/endpointSoftware/dataCollection.sql -O /opt/dataCollector/dataCollection.sql"
		+ "\nmariadb -u root < /opt/dataCollector/dataCollection.sql"
		+ "\nmariadb -u root -e \"CREATE USER 'dataCollector'@'localhost' IDENTIFIED VIA mysql_native_password USING 'uBgiDDGhndviQeEZ';GRANT USAGE ON *.* TO 'dataCollector'@'localhost' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;GRANT ALL PRIVILEGES ON `dataCollection`.* TO 'dataCollector'@'localhost';\""
		+ "\n"
		+ "\nwget http://" + serverName + ":" + port + "/DataCollectorServer/endpointSoftware/CybercraftDataCollectionConnector.war -O /var/lib/tomcat8/webapps/CybercraftDataCollectionConnector.war"
		+ "\n"
		+ "\n# Copy jar to install dir" 
		+ "\n" 
		+ "\nmkdir -p /opt/dataCollector/" 
		+ "\n#mv ./DataCollector.jar /opt/dataCollector/" 
		+ "\nwget http://" + serverName + ":" + port + "/DataCollectorServer/endpointSoftware/DataCollector.jar -O /opt/dataCollector/DataCollector.jar" 
		+ "\nchmod +777 /opt/dataCollector/DataCollector.jar" 
		+ "\nchmod +x /opt/dataCollector/DataCollector.jar" 
		+ "\n" 
		+ "\n" 
		+ "\ntee /opt/dataCollector/DataCollectorStart.sh > /dev/null <<'EOF'" 
		+ "\n#!/bin/bash" 
		+ "\nwhile true;" 
		+ "\ndo" 
		+ "\npkill -f \"/usr/bin/java -jar /opt/dataCollector/DataCollector.jar\"" 
		+ "\n/usr/bin/java -Xmx1536m -jar /opt/dataCollector/DataCollector.jar -user " + curEmail + " -server " + serverName + ":" + port + " >> /opt/dataCollector/log.log 2>&1" 
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
		+ "\nservice tomcat8 start"
		+ "\n"
		+ "\n/opt/dataCollector/DataCollectorStart.sh & disown" ;
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
