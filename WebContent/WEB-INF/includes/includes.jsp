<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*, java.io.FileInputStream, com.data.User, com.data.*, java.util.ArrayList, java.net.URL, java.io.DataInputStream, java.io.InputStream, java.io.InputStreamReader, java.io.File, java.io.BufferedReader, java.net.URLConnection, java.io.BufferedInputStream, java.security.*, java.net.*, java.util.*, java.util.concurrent.ConcurrentHashMap, java.util.Locale, java.text.DateFormat, java.text.NumberFormat, com.google.gson.Gson, com.google.gson.GsonBuilder, java.io.*" errorPage="" %>
<%
	boolean verbose = true;
	session.setMaxInactiveInterval(0);
	boolean hasUser=false;
	boolean protect=true;
	User myUser=null;
	Order myBasket=null;
	String displayName="";
	Locale locale = request.getLocale();
	DateFormat dateFormat=java.text.DateFormat.getDateTimeInstance(java.text.DateFormat.LONG, java.text.DateFormat.LONG, locale);
	java.util.Date today = new java.util.Date();
	NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance();
	GoogleMapPrinter myPrinter=new GoogleMapPrinter();
	
	ConcurrentHashMap roleMap=null;
	ArrayList roleList=null;
%>
<meta generatedAt="<%=today.toString() %>">
<%
	if(protect)
	{
		//System.out.println("protecting");
%>
<%@include file="./protect.jsp" %>
<%
	}
	//System.out.println("databasing");
%>
<%@include file="./databaseconfig.jsp" %>
<%@include file="./emailconfig.jsp" %>
<%
	boolean authenticate=true;
	if(authenticate)
	{
		//System.out.println("authenticating");
%>
<%@include file="./authenticate.jsp" %>
<%
	}
	//System.out.println("commanding");
%>

<%@include file="./checkpermissions.jsp" %>

<%@include file="./populatecommands.jsp" %>
<%
	//System.out.println("styling");
%>

<%@include file="functionLibrary.jsp" %>

<%@include file="addCommandScript.jsp" %>

<%@include file="addUserScript.jsp" %>

<%@include file="style.jsp" %>

<%@include file="gallerystyle.jsp" %>

<%@include file="newsbox.jsp" %>

<%@include file="loginscript.jsp" %>

<%@include file="navscript.jsp" %>

<%@include file="pointsscript.jsp" %>

<%
	if(verbose)
	{
		System.out.println("Done with includes");
	}
%>

