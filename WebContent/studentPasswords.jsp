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
    	<td width="20%">
        <table class="inner_content_table" style="display:none;">
        <tr>
        <td>
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        Filter
        </td>
    	</tr>
        <tr colspan="3" width="100%:">
        <td>
        <table class="news_item_table" width="100%">
        <tr>
        <td colspan="2">
        <div align="center">
        <b>Course</b>
        </div>
        </td>
        </tr>
        <%
        if(!hasUser)
        {
        	%>
        	<meta http-equiv="refresh" content="0; url=index.jsp" />
        	<%
        }
        else if(myUser.getAttribute("role").equals("admin"))
        {
        	String ordering = request.getParameter("orderBy");
        	String direction = request.getParameter("direction");
        	boolean asc = true;
        	if(direction != null && direction.equals("dsc"))
        	{
        		asc = false;
        	}
        	
        	ArrayList myChallenges = new ArrayList();
        	if(ordering != null && !ordering.isEmpty())
        	{
        		myChallenges = myConnector.getAdminStudents((String)myUser.getAttribute("email"), ordering, asc);
        	}
        	else
        	{
        		myChallenges = myConnector.getAdminStudents((String)myUser.getAttribute("email"));
        	}
        	
        	if(verbose)
            {
            	System.out.println(myChallenges);
            }
        	
        	
        	ArrayList courses = new ArrayList();
        	for(int x=0; x<myChallenges.size(); x++)
        	{
        		DBObj tmpObj = (DBObj)myChallenges.get(x);
        		if(!courses.contains(tmpObj.getAttribute("course")))
        		{
        			courses.add(tmpObj.getAttribute("course"));
        		}
        	}
        	
            ArrayList keys = ((DBObj)myChallenges.get(0)).getAttributeNames();
            ConcurrentHashMap translationMap = new ConcurrentHashMap();
            translationMap.put("admin_email", "Instructor");
            translationMap.put("challenge_name", "Challenge");
            translationMap.put("open_time", "Open");
            translationMap.put("end_time", "Close");
            translationMap.put("grade", "Grade");
            translationMap.put("fName", "First Name");
            translationMap.put("lName", "Last Name");
            translationMap.put("email", "Email");
            translationMap.put("course", "Course");
            for(int x=0; x<keys.size(); x++)
            {
            	String tmp=(String)keys.get(x);
            	if(tmp.equals("passwordPlaintext")
            			|| tmp.equals("username")
            			|| tmp.equals("mName")
            			|| tmp.equals("open_time")
            			|| tmp.equals("end_time")
            			|| tmp.equals("Open")
            			|| tmp.equals("displayRealName")
            			|| tmp.equals("role")
            			|| tmp.equals("loginIP")
            			|| tmp.equals("changeUserEmail")
            			|| tmp.equals("changeIP")
            			|| tmp.equals("administrator")
            			|| tmp.equals("changeURL")
            			|| tmp.equals("currentVisit")
            			|| tmp.equals("lastLogon")
            			|| tmp.equals("previousVisit"))
            	{
            		keys.remove(x);
            		x--;
            	}
            }
            
            for(int x=0; x<courses.size(); x++)
            {
            	%>
            <script>
            
            function hideCourse<%=courses.get(x) %>(checkbox)
            {
            	var courseEles = document.getElementsByClassName("<%=courses.get(x) %>");
        		for(var x=0; x<courseEles.length; x++)
    			{
    				courseEles[x].style.display="none";
    			}
        		checkbox.checked=false;
        		
        		checkbox.setAttribute("onclick", "showCourse<%=courses.get(x) %>(this)");
            }
            
            function showCourse<%=courses.get(x) %>(checkbox)
            {
            	var courseEles = document.getElementsByClassName("<%=courses.get(x) %>");
        		for(var x=0; x<courseEles.length; x++)
    			{
    				courseEles[x].style.display="table-row";
    			}
        		checkbox.checked=true;
        		
        		checkbox.setAttribute("onclick", "hideCourse<%=courses.get(x) %>(this)");
            }
            
            </script>
            <tr>
            <td width="50%">
            <%=courses.get(x) %>
            </td>
            <td width="50%">
            <div align="right">
            <input type="checkbox" checked="checked" onclick="hideCourse<%=courses.get(x) %>(this)"></input>
            </div>
            </td>
            </tr>
            	<%
            }
            %>
        </table>
        </td>
        </tr>
        </table>
        </td>
        </tr>
        </table>
        </td>
        <td width="60%">
        <table class="inner_content_table">
        <tr>
        <td>
        <table class="news_table" width="100%">
        <tr class="title_general">
        <td colspan="3" align="center">
        Download Student Passwords
        </td>
    	</tr>
    	<form id="csvExport" action="StudentCSVExport.csv" method="POST">
    	<tr>
    	<td width="100%">
    	Please export this data using the link below for your records.
    	</td>
    	</tr>
    	<tr>
    	<td width="100%">
    	<div align="center">
    	<input type="hidden" name="numStudents" value="<%=myChallenges.size() %>"></input>
    	<input type="submit" value="CSV Export"></input>
    	</div>
    	</td>
    	</tr>
        <tr>
        <td id="add_user_table">
        <%
        for(int x=0; x<myChallenges.size(); x++)
        {
        	DBObj curStudent = (DBObj)myChallenges.get(x);
        %>
        <input type="hidden" name="studentEmail_<%=x %>" value="<%=curStudent.getAttribute("email") %>"></input>
        <input type="hidden" name="studentFname_<%=x %>" value="<%=curStudent.getAttribute("fName") %>"></input>
        <input type="hidden" name="studentLname_<%=x %>" value="<%=curStudent.getAttribute("lName") %>"></input>
        <input type="hidden" name="studentPassword_<%=x %>" value="<%=curStudent.getAttribute("passwordPlaintext") %>"></input>
        <input type="hidden" name="course_<%=x %>" value="<%=curStudent.getAttribute("course") %>"></input>
        <table class="news_item_table" width="100%">
        <tr>
        <td width="33%">
        Student:
        </td>
        <td width="67%">
        <%=x %>
        </td>
        </tr>
        <tr>
        <td width="33%">
        Email Address:
        </td>
        <td width="67%">
        <%=curStudent.getAttribute("email") %>
        </td>
        </tr>
        <tr>
        <td width="33%">
        First Name:
        </td>
        <td width="67%">
        <%=curStudent.getAttribute("fName") %>
        </td>
        </tr>
        <tr style="display:none;">
        <td width="33%">
        Middle Name:
        </td>
        <td width="67%">
        <%="" %>
        </td>
        </tr>
        <tr>
        <td width="33%">
        Last Name:
        </td>
        <td width="67%">
        <%=curStudent.getAttribute("lName") %>
        </td>
        </tr>
        <tr>
        <td width="33%">
        Course:
        </td>
        <td width="67%">
        <%=curStudent.getAttribute("course") %>
        </td>
        </tr>
        <tr>
        <td width="33%">
        Password:
        </td>
        <td width="67%">
        <%=curStudent.getAttribute("passwordPlaintext") %>
        </td>
        </tr>
        </table>
        <%
        }
        %>
        </td>
        </tr>
        </form>
        <tr colspan="3" width="100%" style="display:none">
        <td>
        <table class="news_item_table" width="100%">
        <tr>
        	<%
            //keys.add("open_time");
            //keys.add("end_time");
            for(int x=0; x<keys.size(); x++)
            {
            %>
            <td width="<% out.print(100/(double)(keys.size() + 1)); %>%">
            <div align="left">
            <%
            	String direct = "asc";
            	if(asc && ordering != null && ordering.equals(keys.get(x)))
            	{
            		direct = "dsc";
            	}
            %>
            <a href="manageStudents.jsp?orderBy=<%=keys.get(x) %>&direction=<%=direct %>">
            <b>
            <%
            	if(translationMap.containsKey(keys.get(x)))
            	{
            		out.print(translationMap.get(keys.get(x)));
            	}
            	else
            	{
            		out.print(keys.get(x));
            	}
            	if(ordering != null && ordering.equals(keys.get(x)))
            	{
	            	if(direct.equals("asc"))
	            	{
	            		out.print("&#8681;");
	            	}
	            	else
	            	{
	            		out.print("&#8679;");
	            	}
            	}
            %>
            </b>
            </a>
            </div>
            </td>
            <%
            }
            %>
            <td width="<% out.print(100/(double)(keys.size() + 1)); %>%">
            <div align="left">
            <b>
            Remove
            </b>
            </div>
            </td>
            </tr>
            <%
            String lastName = "";
            for(int x=0; x<myChallenges.size(); x++)
            {
            %>
            <tr class="<%=((DBObj)myChallenges.get(x)).getAttribute("course") %>">
    	        <%
    	        for(int y=0; y<keys.size(); y++)
    	        {
    	        %>
    	        <td width="<% out.print(100/(double)keys.size()); %>%">
    	        <div align="left">
    	        <%
    	        	if((((DBObj)myChallenges.get(x)).getAttribute(keys.get(y)) != null) && (keys.get(y).equals("open_time") || keys.get(y).equals("end_time")))
    	        	{
    	        		java.util.Date tmpDate = (java.util.Date)((DBObj)myChallenges.get(x)).getAttribute(keys.get(y));
    	        		out.print(dateFormat.format(tmpDate));
    	        	}
    	        	else if(keys.get(y).equals("challenge_name"))
    	        	{
    	        		lastName = (String)((DBObj)myChallenges.get(x)).getAttribute(keys.get(y));
    	        		%>
    	        		<a href="viewChallenge.jsp?challengeName=<%= ((DBObj)myChallenges.get(x)).getAttribute(keys.get(y)) %>">
    	        		<%
    	        		out.print(((DBObj)myChallenges.get(x)).getAttribute(keys.get(y)));
    	        		%>
    	        		</a>
    	        		<%
    	        	}
    	        	else
    	        	{
    	        		out.print(((DBObj)myChallenges.get(x)).getAttribute(keys.get(y)));
    	        	}
	    	        if(keys.get(y).equals("email"))
	    	        {
	    	        	lastName = (String)((DBObj)myChallenges.get(x)).getAttribute(keys.get(y));
	    	        }
    	        %>
    	        </div>
    	        </td>
    	        <%
    	        }
    	        %>
    	        <td width="<% out.print(100/(double)keys.size()); %>%">
    	        <div align="left">
    	        <a href="deleteUser.jsp?userName=<%= lastName %>">
    	        Remove
    	        </a>
    	        </div>
    	        </td>
            </tr>
            <%
            }
        }
        %>
        </table>
        </td>
        </tr>
        </table>
        </td>
        </tr>
        </table>
        </td>
        <td width="20%">
        
        </td>
    </tr>
</table>
<%@include file="./WEB-INF/includes/footer.jsp" %>
</body>

</html>