<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
<%@include file="./WEB-INF/includes/includes.jsp" %>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>RevEngE</title>

</head>

<body>
        <%
        
        if(!hasUser || !(myUser.getAttribute("role").equals("admin")))
        {
        	
        }
        else if(request.getParameter("num_tests") == null)
        {
        	
        }
        else
        {
        	//http://localhost:8080/ObfuscationChallenge/uploadTestCase.jsp?email=cgtboy1988@yahoo.com&password=password&challenge_name=Grading%20test&num_tests=0&iterations_0=5&performance_0=2&num_args_0=0&arg_type_0_0=int
        	String challengeName = (String)request.getParameter("challenge_name");
        	int numTestCases = new Integer((String)request.getParameter("num_tests"));
        	boolean success = true;
        	long testCount = (Long)myConnector.getTestCount(challengeName).getAttribute("count");
        	int curTestCount = (int)testCount;
        	
	        for(int x=0; success && x<=numTestCases; x++)
	        {
	        	String numIterations = (String)request.getParameter("iterations_" + x);
	        	String performance = (String)request.getParameter("performance_" + x);
	        	int numArgs = new Integer((String)request.getParameter("num_args_" + x));
	        	myConnector.addGradeTest(challengeName, x + curTestCount, numIterations, performance);
	        	for(int y=0; y<=numArgs; y++)
	        	{
	        		String curType = (String)request.getParameter("arg_type_" + x + "_" + y);
	        		if(curType.equals("literal"))
	        		{
	        			String curValue = (String)request.getParameter("arg_value_" + x + "_" + y);
	        			myConnector.addGradeTestArg(challengeName, x + curTestCount, y, curType, curValue);
	        		}
	        		else
	        		{
	        			myConnector.addGradeTestArg(challengeName, x + curTestCount, y, curType);
	        		}
	        	}
	        }
	   %>
	   Success: <%=success %>
	   <%
       }
	   %>
</body>

</html>