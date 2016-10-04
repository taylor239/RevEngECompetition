<%@include file="./WEB-INF/includes/includes.jsp" %>
        <%
        if(!hasUser)
        {
        	%>
        	<meta http-equiv="refresh" content="0; url=index.jsp" />
        	<%
        }
        else
        {
        ArrayList myChallengesFull = myConnector.getChallenge((String)request.getParameter("challengeName"), (String)myUser.getAttribute("email"));
        ServerManager nativeInterface = ServerManager.getInstance();
        String nativeOutput = "";
        String outputDir = myUser.getAttribute("email")+"/";
        String prevFile = "empty.c";
        File emptyFile = new File(sc.getRealPath("/WEB-INF/generated_code/")+"/"+outputDir+prevFile);
        System.out.println("Creating file "+emptyFile.getAbsolutePath());
        emptyFile.getParentFile().mkdirs();
        emptyFile.createNewFile();
        boolean first=true;
        String firstFile="";
        String firstPath="";
        String finalFile="";
        String finalPath="";
        for(int x=0; x<myChallengesFull.size(); x++)
        {
        	String outputFile = "challenge_"+x+".c";
        	File tmpFile = new File(sc.getRealPath("/WEB-INF/local_bin/tigress/"));
        	File genDir = new File(sc.getRealPath("/WEB-INF/generated_code/"+outputDir));
        	//String[] environmentalVars = {"TIGRESS_HOME="+tmpFile.getAbsolutePath(), "PATH="+tmpFile.getAbsolutePath()};
        	Map<String, String> env = System.getenv();
        	String[] environmentalVars = new String[env.keySet().size()+2];
        	boolean hasPath=false;
        	int envNum=0;
        	for(String envName : env.keySet())
        	{
        		//System.out.println(envName+"="+env.get(envName));
        		String varVal=env.get(envName);
        		if(envName.equals("PATH"))
        		{
        			hasPath=true;
        			environmentalVars[envNum]=envName+"="+env.get(envName)+":"+tmpFile.getAbsolutePath();
        			envNum++;
        		}
        		else
        		{
        			environmentalVars[envNum]=envName+"="+env.get(envName);
        			envNum++;
        		}
        	}
        	environmentalVars[envNum]="TIGRESS_HOME="+tmpFile.getAbsolutePath();
        	envNum++;
        	if(!hasPath)
        	{
        		environmentalVars[envNum]="PATH="+tmpFile.getAbsolutePath();
        		envNum++;
        	}
        	else
        	{
        		String[] tmp=new String[environmentalVars.length-1];
        		for(int z=0; z<tmp.length; z++)
        		{
        			tmp[z]=environmentalVars[z];
        		}
        		environmentalVars=tmp;
        	}
        	//String configCommands = "sudo -s\rexport TIGRESS_HOME="+tmpFile.getAbsolutePath()+"\rexport PATH=$PATH:"+tmpFile.getAbsolutePath();
        	String configCommands = "";
        	//System.out.println(configCommands);
        	//String command = "sudo -s\r"+configCommands+"\r./tigress "+((DBObj)myChallengesFull.get(x)).getAttribute("command")+" --out="+genDir.getAbsolutePath()+"/"+outputFile+" "+genDir.getAbsolutePath()+"/"+prevFile;
        	//String command = ""+configCommands+""+"printenv\rls\rpwd\r";//./tigress "+((DBObj)myChallengesFull.get(x)).getAttribute("command")+" --out="+genDir.getAbsolutePath()+"/"+outputFile+" "+genDir.getAbsolutePath()+"/"+prevFile;
        	//System.out.println(command);
        	//String[] cmdArray = {"ps", "aux"};
        	String[] splitString = ((String)((DBObj)myChallengesFull.get(x)).getAttribute("command")).split(" ");
        	if(splitString[0].isEmpty())
        	{
        		splitString=new String[0];
        	}
        	String[] cmdArray = new String[3+splitString.length];
        	String[] secondCmdArray = null;
        	if(((DBObj)myChallengesFull.get(x)).getAttribute("commandName").equals("gcc"))
        	{
        		secondCmdArray = new String[3];
        		//cmdArray = new String[4+splitString.length];
        	}
        	
        	//cmdArray = new String[1];
        	//cmdArray[0]="cat";
        	//cmdArray[0]="./tigress";
        	cmdArray[0]=(String)((DBObj)myChallengesFull.get(x)).getAttribute("commandName");
        	for(int y=0; y<splitString.length; y++)
        	{
        		cmdArray[y+1]=splitString[y];
        	}
        	if(cmdArray[0].equals("./tigress"))
        	{
	        	cmdArray[splitString.length+1]="--out="+genDir.getAbsolutePath()+"/"+outputFile;
	        	cmdArray[splitString.length+2]=genDir.getAbsolutePath()+"/"+prevFile;
        	}
        	else if(cmdArray[0].equals("gcc"))
        	{
        		//outputFile = "./"+outputFile;
        		cmdArray[splitString.length+2]="-o"+outputFile;
        		//cmdArray[splitString.length+3]=outputFile;
	        	cmdArray[splitString.length+1]=prevFile;
	        	tmpFile=new File(genDir.getAbsolutePath());
	        	//String weirdOutputFile="\\ "+outputFile;
	        	//secondCmdArray[0]="mv";
	        	//secondCmdArray[1]=weirdOutputFile;
	        	//secondCmdArray[2]=outputFile;
	        	secondCmdArray=null;
        	}
        	//System.out.println("./tigress "+(String)((DBObj)myChallengesFull.get(x)).getAttribute("command")+" --out="+genDir.getAbsolutePath()+"/"+outputFile+" "+genDir.getAbsolutePath()+"/"+prevFile);
        	//String[] cmdArray = {"./tigress ", (String)((DBObj)myChallengesFull.get(x)).getAttribute("command"), "--out="+genDir.getAbsolut;ePath()+"/"+outputFile, genDir.getAbsolutePath()+"/"+prevFile};//{"printenv"};//, "export TIGRESS_HOME="+tmpFile.getAbsolutePath(), "printenv"};
        	nativeOutput = nativeInterface.executeCommand(cmdArray, tmpFile, environmentalVars);//, environmentalVars);
        	System.out.println(nativeOutput);
        	if(secondCmdArray != null)
        	{
	        	nativeOutput = nativeInterface.executeCommand(secondCmdArray, tmpFile, environmentalVars);//, environmentalVars);
	        	System.out.println(nativeOutput);
        	}
        	
        	tmpFile = new File(sc.getRealPath("/WEB-INF/local_bin/tigress/"));
        	
        	if(first)
        	{
        		firstFile=outputFile;
        		firstPath=genDir.getAbsolutePath();
        		first=false;
        	}
        	finalFile=outputFile;
        	finalPath=genDir.getAbsolutePath();
        	prevFile = outputFile;
        }
        
        System.out.println(finalFile);
        System.out.println(firstFile);
        
       	
        File finalFinalDone=new File(finalPath+"/"+finalFile);
        int waitTime=0;
        while((!finalFinalDone.exists() || !finalFinalDone.canRead()) && (waitTime < 1000))
        {
        	Thread.sleep(5);
        	waitTime+=5;
        }
        byte[] finalFileData=new byte[(int)finalFinalDone.length()];
        try
        {
        	int bytesRead=0;
        	InputStream fileInput = new BufferedInputStream(new FileInputStream(finalFinalDone));
        	while(bytesRead < finalFileData.length)
        	{
        		int remaining = finalFileData.length - bytesRead;
        		int tmpBytesRead = fileInput.read(finalFileData, bytesRead, remaining);
        		if(tmpBytesRead > 0)
        		{
        			bytesRead = bytesRead + tmpBytesRead;
        		}
        	}
        	System.out.println("Read "+bytesRead+" bytes from last");
        }
        catch(Exception e)
        {
        	e.printStackTrace();
        }
        
        File firstFileDone=new File(firstPath+"/"+firstFile);
        byte[] firstFileData=new byte[(int)firstFileDone.length()];
        try
        {
        	int bytesRead=0;
        	InputStream fileInput = new BufferedInputStream(new FileInputStream(firstFileDone));
        	while(bytesRead < firstFileData.length)
        	{
        		int remaining = firstFileData.length - bytesRead;
        		int tmpBytesRead = fileInput.read(firstFileData, bytesRead, remaining);
        		if(tmpBytesRead > 0)
        		{
        			bytesRead = bytesRead + tmpBytesRead;
        		}
        	}
        	System.out.println("Read "+bytesRead+" bytes from first");
        }
        catch(Exception e)
        {
        	e.printStackTrace();
        }
        
        
        ArrayList myChallenges = new ArrayList();
        myChallenges.add(myChallengesFull.get(0));
        myConnector.challengeParticipantCodeWritten((String)((DBObj)myChallenges.get(0)).getAttribute("challenge_name"), (String)((DBObj)myChallenges.get(0)).getAttribute("email"), firstFileData, finalFileData);
        
        String forwardURL = "viewChallenge.jsp?challengeName="+((DBObj)myChallenges.get(0)).getAttribute("challenge_name");
        
        %>
        <meta http-equiv="refresh" content="0; url=<%=forwardURL %>" />
        <%
        }
        %>