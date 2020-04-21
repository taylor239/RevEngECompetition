package com.data;

import java.io.File;
import java.io.InputStream;
import java.io.BufferedInputStream;
import java.io.FileInputStream;
import java.io.PrintWriter;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Random;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;

public class CodeGenerator
{
	
	public CodeGenerator()
	{
		
	}
	
	public void generateCode(DatabaseConnector myConnector, DBObj myUser, ServletContext sc, String challengeName) throws Exception
	{
		ArrayList myChallengesFull = myConnector.getChallenge(challengeName, (String)myUser.getAttribute("email"));
        ArrayList myChallengesEvaluation = myConnector.getChallengeEvaluation(challengeName, (String)myUser.getAttribute("email"));
        ServerManager nativeInterface = ServerManager.getInstance();
        String nativeOutput = "";
        String nativeOutput2 = "";
        
        byte[] challengeMD5Bytes=(challengeName).getBytes();
        String challengeMD5="problem";
        MessageDigest m = MessageDigest.getInstance("MD5");
        m.reset();
        m.update(challengeMD5Bytes);
        byte[] digest = m.digest();
        java.math.BigInteger bigInt = new java.math.BigInteger(1, digest);
        challengeMD5 = bigInt.toString(16);
        
        String outputDir = myUser.getAttribute("email")+"/"+challengeMD5+"/";
        String prevFile = "empty.c";
        File emptyFile = new File(sc.getRealPath("/WEB-INF/generated_code/")+"/"+outputDir+prevFile);
        //System.out.println("Creating file "+emptyFile.getAbsolutePath());
        emptyFile.getParentFile().mkdirs();
        emptyFile.createNewFile();
        boolean first=true;
        boolean firstEval=true;
        String firstFile="";
        String firstPath="";
        String finalFile="";
        String finalPath="";
        String firstEvalFile="";
        String firstEvalPath="";
        String finalEvalFile="";
        String finalEvalPath="";
        
        String gradingFile="grading.c";
        String gradingFilePath="";
        
        int seed = 0;
        
        boolean randSeed = (boolean)((DBObj)myChallengesFull.get(0)).getAttribute("randomSeed");
        
		boolean isCached = false;
        
        if(randSeed)
        {
        	Random rand = new SecureRandom();
        	seed = rand.nextInt();
        }
        else
        {
        	seed = new Integer((String)((DBObj)myChallengesFull.get(0)).getAttribute("seed"));
        	isCached = (((DBObj)myChallengesFull.get(0)).containsKey("cachedOriginal") && ((DBObj)myChallengesFull.get(0)).getAttribute("cachedOriginal") != null && ((DBObj)myChallengesFull.get(0)).getAttribute("cachedOriginal") instanceof byte[]);
        }
        
        System.out.println("Has cached files: " + isCached);
        //System.out.println(((DBObj)myChallengesFull.get(0)).getAttribute("cachedOriginal"));
        
        if(isCached)
        {
        	ArrayList myChallenges = new ArrayList();
            myChallenges.add(myChallengesFull.get(0));
        	myConnector.challengeParticipantCodeWritten((String)((DBObj)myChallenges.get(0)).getAttribute("challenge_name"), (String)((DBObj)myChallenges.get(0)).getAttribute("email"), ((byte[])((DBObj)myChallengesFull.get(0)).getAttribute("cachedOriginal")), ((byte[])((DBObj)myChallengesFull.get(0)).getAttribute("cachedGrading")), ((byte[])((DBObj)myChallengesFull.get(0)).getAttribute("cachedObfuscated")), seed);
        }
        else
        {
        
        String initText = "#include <stdio.h>\n#include <time.h>\n#include <pthread.h>\n";
        PrintWriter initWriter = new PrintWriter(emptyFile);
        initWriter.println(initText);
        initWriter.close();
        	
        boolean isCompiled = false;
        for(int x=0; x<myChallengesFull.size()+myChallengesEvaluation.size(); x++)
        {
        	boolean evaluating=false;
        	if(x>=myChallengesFull.size())
        	{
        		evaluating=true;
        		if(x==myChallengesFull.size())
        		{
	        		firstEvalFile=firstFile;
	                firstEvalPath=firstPath;
	                finalEvalFile=finalFile;
	                finalEvalPath=finalPath;
        		}
        	}
        	String outputFile = "challenge_"+x+".c";
        	if(evaluating)
        	{
        		outputFile = "evaluate_"+(x-myChallengesFull.size())+".c";
        	}
        	File tmpFile = new File(sc.getRealPath("/WEB-INF/local_bin/tigress/"));
        	File genDir = new File(sc.getRealPath("/WEB-INF/generated_code/"+outputDir));
        	//String[] environmentalVars = {"TIGRESS_HOME="+tmpFile.getAbsolutePath(), "PATH="+tmpFile.getAbsolutePath()};
        	Map<String, String> env = System.getenv();
        	String[] environmentalVars = new String[env.keySet().size()+2];
        	boolean hasPath=false;
        	int envNum=0;
        	for(String envName : env.keySet())
        	{
        		////System.out.println(envName+"="+env.get(envName));
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
        	if(!evaluating)
        	{
	        	//String configCommands = "sudo -s\rexport TIGRESS_HOME="+tmpFile.getAbsolutePath()+"\rexport PATH=$PATH:"+tmpFile.getAbsolutePath();
	        	//String configCommands = "";
	        	////System.out.println(configCommands);
	        	//String command = "sudo -s\r"+configCommands+"\r./tigress "+((DBObj)myChallengesFull.get(x)).getAttribute("command")+" --out="+genDir.getAbsolutePath()+"/"+outputFile+" "+genDir.getAbsolutePath()+"/"+prevFile;
	        	//String command = ""+configCommands+""+"printenv\rls\rpwd\r";//./tigress "+((DBObj)myChallengesFull.get(x)).getAttribute("command")+" --out="+genDir.getAbsolutePath()+"/"+outputFile+" "+genDir.getAbsolutePath()+"/"+prevFile;
	        	////System.out.println(command);
	        	//String[] cmdArray = {"ps", "aux"};
	        	//String[] splitString = ((String)((DBObj)myChallengesFull.get(x)).getAttribute("command")).split(" ");
	        	String totalString = (String)((DBObj)myChallengesFull.get(x)).getAttribute("command");
	        	List<String> stringList = new ArrayList<String>();
	        	java.util.regex.Matcher match = java.util.regex.Pattern.compile("(([^\"]\\S*(\".+?\")+)|([^\"]\\S*))\\s*").matcher(totalString);
	        	while (match.find())
	        	{
	        		stringList.add(match.group(1).replaceAll("\"", ""));
	        		System.out.println("Got string " + stringList.get(stringList.size()-1));
	        	}
	        	String[] splitString = {""};
	        	if(stringList.size() > 0)
	        	{
	        		splitString = stringList.toArray(new String[stringList.size()]);
	        	}
	        	if(splitString[0].isEmpty())
	        	{
	        		splitString=new String[0];
	        	}
	        	String[] cmdArray = new String[4+splitString.length];
	        	String[] secondCmdArray = null;
	        	if(((DBObj)myChallengesFull.get(x)).getAttribute("commandName").equals("gcc") || ((DBObj)myChallengesFull.get(x)).getAttribute("commandName").equals("clang-5.0"))
	        	{
	        		secondCmdArray = new String[3];
	        		isCompiled=true;
	        		//cmdArray = new String[4+splitString.length];
	        	}
	        	else if(((DBObj)myChallengesFull.get(x)).getAttribute("commandName").equals("./package.sh") || ((DBObj)myChallengesFull.get(x)).getAttribute("commandName").equals("./link.sh"))
	        	{
	        		secondCmdArray = new String[3];
	        		//cmdArray = new String[4+splitString.length];
	        	}
	        	else if(((DBObj)myChallengesFull.get(x)).getAttribute("commandName").equals("./deextern.sh"))
	        	{
	        		secondCmdArray = new String[3];
	        		//cmdArray = new String[4+splitString.length];
	        	}
	        	else if(!((DBObj)myChallengesFull.get(x)).getAttribute("commandName").equals("./tigress"))
	        	{
	        		secondCmdArray = new String[3];
	        	}
	        	
	        	//cmdArray = new String[1];
	        	//cmdArray[0]="cat";
	        	//cmdArray[0]="./tigress";
	        	String curCommandName=(String)((DBObj)myChallengesFull.get(x)).getAttribute("commandName");
	        	
	        	if(curCommandName.equals("gcc") || curCommandName.equals("clang-5.0"))
	        	{
	        		cmdArray = new String[3+splitString.length];
	        	}
	        	else if(curCommandName.equals("./package.sh") || curCommandName.equals("./link.sh"))
	        	{
	        		cmdArray = new String[4+splitString.length];
	        	}
	        	else if(curCommandName.equals("./deextern.sh"))
	        	{
	        		cmdArray = new String[3+splitString.length];
	        	}
	        	else if(!curCommandName.equals("./tigress"))
	        	{
	        		cmdArray = new String[3+splitString.length];
	        	}
	        	
	        	cmdArray[0] = curCommandName;
	        	if(!cmdArray[0].equals("./tigress"))
	        	{
	        		for(int y=0; y<splitString.length; y++)
	        		{
	        			cmdArray[y+3]=splitString[y];
	        		}
	        	}
	        	else
	        	{
	        		for(int y=0; y<splitString.length; y++)
	        		{
	        			cmdArray[y+1]=splitString[y];
	        		}
	        	}
	        	
	        	
	        	if(cmdArray[0].equals("./tigress"))
	        	{
	        		cmdArray[splitString.length+1]="--Seed=" + seed;
		        	cmdArray[splitString.length+2]="--out="+genDir.getAbsolutePath()+"/"+outputFile;
		        	cmdArray[splitString.length+3]=genDir.getAbsolutePath()+"/"+prevFile;
	        	}
	        	else if(cmdArray[0].equals("gcc") || cmdArray[0].equals("clang-5.0"))
	        	{
	        		//outputFile = "./"+outputFile;
	        		cmdArray[2]="-o"+outputFile;
	        		//cmdArray[splitString.length+3]=outputFile;
		        	cmdArray[1]=prevFile;
		        	tmpFile=new File(genDir.getAbsolutePath());
		        	//String weirdOutputFile="\\ "+outputFile;
		        	//secondCmdArray[0]="mv";
		        	//secondCmdArray[1]=weirdOutputFile;
		        	//secondCmdArray[2]=outputFile;
		        	secondCmdArray=null;
	        	}
	        	else if(cmdArray[0].equals("./package.sh") || cmdArray[0].equals("./link.sh"))
	        	{
	        		//outputFile = "./"+outputFile;
	        		cmdArray[splitString.length+2]=genDir.getAbsolutePath()+"/"+outputFile;
	        		//cmdArray[splitString.length+3]=outputFile;
		        	cmdArray[splitString.length+1]=genDir.getAbsolutePath()+"/"+prevFile;
		        	cmdArray[splitString.length+3]=tmpFile.getAbsolutePath() + "/" + "jitter-amd64.c";
		        	//tmpFile=new File(genDir.getAbsolutePath());
		        	//String weirdOutputFile="\\ "+outputFile;
		        	//secondCmdArray[0]="mv";
		        	//secondCmdArray[1]=weirdOutputFile;
		        	//secondCmdArray[2]=outputFile;
		        	secondCmdArray=null;
	        	}
	        	else if(cmdArray[0].equals("./deextern.sh"))
	        	{
	        		//outputFile = "./"+outputFile;
	        		cmdArray[splitString.length+2]=genDir.getAbsolutePath()+"/"+outputFile;
	        		//cmdArray[splitString.length+3]=outputFile;
		        	cmdArray[splitString.length+1]=genDir.getAbsolutePath()+"/"+prevFile;
		        	//tmpFile=new File(genDir.getAbsolutePath());
		        	//String weirdOutputFile="\\ "+outputFile;
		        	//secondCmdArray[0]="mv";
		        	//secondCmdArray[1]=weirdOutputFile;
		        	//secondCmdArray[2]=outputFile;
		        	secondCmdArray=null;
	        	}
	        	else
	        	{
	        		//outputFile = "./"+outputFile;
	        		cmdArray[2]="-o"+outputFile;
	        		//cmdArray[splitString.length+3]=outputFile;
		        	cmdArray[1]=prevFile;
		        	tmpFile=new File(genDir.getAbsolutePath());
		        	//String weirdOutputFile="\\ "+outputFile;
		        	//secondCmdArray[0]="mv";
		        	//secondCmdArray[1]=weirdOutputFile;
		        	//secondCmdArray[2]=outputFile;
		        	secondCmdArray=null;
	        	}
	        	////System.out.println("./tigress "+(String)((DBObj)myChallengesFull.get(x)).getAttribute("command")+" --out="+genDir.getAbsolutePath()+"/"+outputFile+" "+genDir.getAbsolutePath()+"/"+prevFile);
	        	//String[] cmdArray = {"./tigress ", (String)((DBObj)myChallengesFull.get(x)).getAttribute("command"), "--out="+genDir.getAbsolut;ePath()+"/"+outputFile, genDir.getAbsolutePath()+"/"+prevFile};//{"printenv"};//, "export TIGRESS_HOME="+tmpFile.getAbsolutePath(), "printenv"};
	        	nativeOutput = nativeInterface.executeCommand(cmdArray, tmpFile, environmentalVars);//, environmentalVars);
	        	
	        	if(first)
	        	{
	        		String[] gradingFileGenerator = new String[cmdArray.length + 1];
	        		System.arraycopy(cmdArray, 0, gradingFileGenerator, 0, cmdArray.length);
	        		gradingFileGenerator[splitString.length+2]="--out="+genDir.getAbsolutePath()+"/" + "grading.c";
	        		gradingFileGenerator[splitString.length+4]="--RandomFunsDummyFailure=true";
	        		nativeOutput2 = nativeInterface.executeCommand(gradingFileGenerator, tmpFile, environmentalVars);
	        	}
	        	
	        	//System.out.println(nativeOutput);
	        	if(secondCmdArray != null)
	        	{
		        	nativeOutput = nativeInterface.executeCommand(secondCmdArray, tmpFile, environmentalVars);//, environmentalVars);
		        	//System.out.println(nativeOutput);
	        	}
	        	
	        	tmpFile = new File(sc.getRealPath("/WEB-INF/local_bin/tigress/"));
	        	
	        	if(first)
	        	{
	        		firstFile=outputFile;
	        		firstPath=genDir.getAbsolutePath();
	        		gradingFilePath=firstPath;
	        		first=false;
	        	}
	        	finalFile=outputFile;
	        	finalPath=genDir.getAbsolutePath();
	        	prevFile = outputFile;
        	}
	        else
	        {
	        	int z = x-myChallengesFull.size();
	        	String[] splitString = ((String)((DBObj)myChallengesEvaluation.get(z)).getAttribute("command")).split(" ");
	        	if(splitString[0].isEmpty())
	        	{
	        		splitString=new String[0];
	        	}
	        	String[] cmdArray = new String[4+splitString.length];
	        	if(((Integer)((DBObj)myChallengesEvaluation.get(z)).getAttribute("input_output"))==0)
	        	{
	        		cmdArray = new String[1+splitString.length];
	        	}
	        	String[] secondCmdArray = null;
	        	if(((DBObj)myChallengesEvaluation.get(z)).getAttribute("commandName").equals("gcc") || ((DBObj)myChallengesEvaluation.get(z)).getAttribute("commandName").equals("clang-5.0"))
	        	{
	        		//secondCmdArray = new String[3];
	        		isCompiled=true;
	        		//cmdArray = new String[4+splitString.length];
	        	}
	        	
	        	//cmdArray = new String[1];
	        	//cmdArray[0]="cat";
	        	//cmdArray[0]="./tigress";
	        	String curCommandName=(String)((DBObj)myChallengesFull.get(x)).getAttribute("commandName");
	        	
	        	if(!curCommandName.equals("./tigress"))
	        	{
	        		cmdArray = new String[3+splitString.length];
	        	}
	        	
	        	cmdArray[0] = curCommandName;
	        	for(int y=0; y<splitString.length; y++)
	        	{
	        		cmdArray[y+1]=splitString[y];
	        	}
	        	if(cmdArray[0].equals("./tigress"))
	        	{
	        		cmdArray[splitString.length+1]="--Seed=" + seed;
		        	cmdArray[splitString.length+2]="--out="+genDir.getAbsolutePath()+"/"+outputFile;
		        	cmdArray[splitString.length+3]=genDir.getAbsolutePath()+"/"+prevFile;
	        	}
	        	else if(cmdArray[0].equals("gcc") || cmdArray[0].equals("clang-5.0"))
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
		        	//secondCmdArray=null;
	        	}
	        	else
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
		        	//secondCmdArray=null;
	        	}
	        	////System.out.println("./tigress "+(String)((DBObj)myChallengesFull.get(x)).getAttribute("command")+" --out="+genDir.getAbsolutePath()+"/"+outputFile+" "+genDir.getAbsolutePath()+"/"+prevFile);
	        	//String[] cmdArray = {"./tigress ", (String)((DBObj)myChallengesFull.get(x)).getAttribute("command"), "--out="+genDir.getAbsolut;ePath()+"/"+outputFile, genDir.getAbsolutePath()+"/"+prevFile};//{"printenv"};//, "export TIGRESS_HOME="+tmpFile.getAbsolutePath(), "printenv"};
	        	nativeOutput = nativeInterface.executeCommand(cmdArray, tmpFile, environmentalVars);//, environmentalVars);
	        	//System.out.println(nativeOutput);
	        	//if(secondCmdArray != null)
	        	//{
		        //	nativeOutput = nativeInterface.executeCommand(secondCmdArray, tmpFile, environmentalVars);//, environmentalVars);
		        //	//System.out.println(nativeOutput);
	        	//}
	        	
	        	tmpFile = new File(sc.getRealPath("/WEB-INF/local_bin/tigress/"));
	        	
	        	if(firstEval)
	        	{
	        		firstEvalFile=outputFile;
	        		firstEvalPath=genDir.getAbsolutePath();
	        		firstEval=false;
	        	}
	        	finalEvalFile=outputFile;
	        	finalEvalPath=genDir.getAbsolutePath();
	        	if(((Integer)((DBObj)myChallengesEvaluation.get(z)).getAttribute("input_output"))>0)
	        	{
	        		prevFile = outputFile;
	        	}
	        }	
        }
        
        
        //System.out.println(finalFile);
        //System.out.println(firstFile);
        firstFile = "challenge_0.c";
        
        System.out.println();
        System.out.println("Files and paths:");
        
        System.out.println(firstPath + "/" + finalFile);
        System.out.println(finalPath + "/" + firstFile);
        
       	
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
        	//System.out.println("Read "+bytesRead+" bytes from last");
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
        	//System.out.println("Read "+bytesRead+" bytes from first");
        }
        catch(Exception e)
        {
        	e.printStackTrace();
        }
        
        File gradingFileDone=new File(firstPath+"/"+firstFile);
        byte[] gradingFileData=new byte[(int)gradingFileDone.length()];
        try
        {
        	int bytesRead=0;
        	InputStream fileInput = new BufferedInputStream(new FileInputStream(gradingFileDone));
        	while(bytesRead < gradingFileData.length)
        	{
        		int remaining = gradingFileData.length - bytesRead;
        		int tmpBytesRead = fileInput.read(gradingFileData, bytesRead, remaining);
        		if(tmpBytesRead > 0)
        		{
        			bytesRead = bytesRead + tmpBytesRead;
        		}
        	}
        	//System.out.println("Read "+bytesRead+" bytes from first");
        }
        catch(Exception e)
        {
        	e.printStackTrace();
        }
        
        ArrayList myChallenges = new ArrayList();
        myChallenges.add(myChallengesFull.get(0));
        myConnector.challengeParticipantCodeWritten((String)((DBObj)myChallenges.get(0)).getAttribute("challenge_name"), (String)((DBObj)myChallenges.get(0)).getAttribute("email"), firstFileData, gradingFileData, finalFileData, seed);
        if(!randSeed)
        {
        	myConnector.cacheChallengeCode((String)((DBObj)myChallenges.get(0)).getAttribute("challenge_name"), firstFileData, gradingFileData, finalFileData);
        }
        System.out.println("Seed was: " + seed);
        //String forwardURL = "viewChallenge.jsp?challengeName="+((DBObj)myChallenges.get(0)).getAttribute("challenge_name");
        }
	}
	
	
}
