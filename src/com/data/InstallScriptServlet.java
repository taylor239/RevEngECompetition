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
		
		String output = "#!/bin/bash" 
		+ "\r\nclear" 
		+ "\r\n" 
		+ "\r\necho \"You are about to install the data collection suite for the RevEngE Reverse Enginerring Engine.  This data collection suite aims to conduct research by monitoring users as they complete the challenges posted on the RevEngE website (revenge.cs.arizona.edu).  It works by collecting data from the operating system, including screenshots, keyboard and mouse input, and running processes, storing that data in a local database, and uploading that data to revenge.cs.arizona.edu when you run the corresponding upload script.  If you are a student participating in this research while completing a course assignment, please review any consent forms you have been given and, if you agree, return them to the appropriate individual.  Regardless of whether you are doing this for a course or not, please provide consent here as well if you wish to participate in the study. In order to give consent, type \\\"yes\\\" and push enter.  If you do not given consent, please type \\\"no\\\" instead and the software will not be installed.  The consent agreement may be downloaded and read from the following links:\"" 
		+ "\r\n" 
		+ "\r\necho \"\"" 
		+ "\r\n" 
		+ "\r\necho \"For students: revenge.cs.arizona.edu/consent/student.pdf\"" 
		+ "\r\necho \"For anyone else: revenge.cs.arizona.edu/consent/professionals.pdf\"" 
		+ "\r\n" 
		+ "\r\necho \"\"" 
		+ "\r\n" 
		+ "\r\necho \"Do you agree to the appropriate consent document?  Please enter yes or no.  If you enter yes, you agree that you have read and agree to the appropriate consent agreement.  Entering yes will install the data collection software suite.\"" 
		+ "\r\n" 
		+ "\r\nread CONSENT" 
		+ "\r\n" 
		+ "\r\nCONSENT=${CONSENT,,}" 
		+ "\r\necho $CONSENT" 
		+ "\r\n" 
		+ "\r\nif [ \"$CONSENT\" != \"yes\" ]" 
		+ "\r\nthen" 
		+ "\r\n\techo \"You did not enter yes.  Exiting now.\"" 
		+ "\r\n\texit 1" 
		+ "\r\nfi" 
		+ "\r\n" 
		+ "\r\necho \"Starting data collection install\"" 
		+ "\r\n" 
		+ "\r\nsudo apt-get -y install default-jre" 
		+ "\r\nsudo apt-get -y install tomcat8" 
		+ "\r\n"
		+ "\r\nwget http://localhost:8080/DataCollectorServer/endpointSoftware/CybercraftDataCollectionConnector.war -O /usr/share/tomcat8-root/CybercraftDataCollectionConnector.war"
		+ "\r\n"
		+ "\r\n# Copy jar to install dir" 
		+ "\r\n" 
		+ "\r\nmkdir -p /opt/dataCollector/" 
		+ "\r\n#mv ./DataCollector.jar /opt/dataCollector/" 
		+ "\r\nwget http://" + request.getServerName() + ":" + request.getServerPort() + "/DataCollectorServer/endpointSoftware/DataCollector.jar -O /opt/dataCollector/DataCollector.jar" 
		+ "\r\nchmod +777 /opt/dataCollector/DataCollector.jar" 
		+ "\r\nchmod +x /opt/dataCollector/DataCollector.jar" 
		+ "\r\n" 
		+ "\r\n" 
		+ "\r\ntee /opt/dataCollector/DataCollectorStart.sh > /dev/null <<'EOF'" 
		+ "\r\n#!/bin/bash" 
		+ "\r\nwhile true;" 
		+ "\r\ndo" 
		+ "\r\npkill -f \"/usr/bin/java -jar /opt/dataCollector/DataCollector.jar\"" 
		+ "\r\n/usr/bin/java -Xmx1536m -jar /opt/dataCollector/DataCollector.jar -user " + curEmail + " -server " + request.getServerName() + ":" + request.getServerPort() + " >> /opt/dataCollector/log.log 2>&1" 
		+ "\r\necho \"Got a crash: $(date)\" >> /opt/dataCollector/log.log" 
		+ "\r\nsleep 2" 
		+ "\r\ndone" 
		+ "\r\nEOF" 
		+ "\r\n" 
		+ "\r\nchmod +777 /opt/dataCollector/DataCollectorStart.sh" 
		+ "\r\nchmod +x /opt/dataCollector/DataCollectorStart.sh" 
		+ "\r\n" 
		+ "\r\ntouch /opt/dataCollector/log.log" 
		+ "\r\nchmod +777 /opt/dataCollector/log.log" 
		+ "\r\n" 
		+ "\r\n# Launch script" 
		+ "\r\n" 
		+ "\r\ntee ~/.config/autostart/DataCollector.desktop > /dev/null <<'EOF'" 
		+ "\r\n[Desktop Entry]" 
		+ "\r\nType=Application" 
		+ "\r\nExec=\"/opt/dataCollector/DataCollectorStart.sh\"" 
		+ "\r\nHidden=false" 
		+ "\r\nNoDisplay=false" 
		+ "\r\nX-GNOME-Autostart-enabled=true" 
		+ "\r\nName[en_IN]=DataCollector" 
		+ "\r\nName=DataCollector" 
		+ "\r\nComment[en_IN]=Collects data" 
		+ "\r\nComment=Collects data" 
		+ "\r\nEOF" 
		+ "\r\n" 
		+ "\r\n/opt/dataCollector/DataCollectorStart.sh & disown" ;
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
