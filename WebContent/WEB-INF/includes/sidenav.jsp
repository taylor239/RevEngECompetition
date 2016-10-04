
<table id="side_nav">
	<tr id="side_title" onclick="window.document.location='index.jsp';" onMouseOver="highlight(this)" onMouseOut="unhighlight(this)">
		<td><img src="img/tigress-gray.png" width="40em"/></td>
	</tr>
        <tr class="space">
    	<td><hr />
        </td>
    </tr>
    <tr class="side_button">
    	<td onclick="window.document.location='index.jsp';" onMouseOver="highlight(this)" onMouseOut="unhighlight(this)">
        	Home
        </td>
    </tr>
        <tr class="space">
    	<td><hr />
        </td>
    </tr>
    <tr class="side_button">
    	<td onclick="window.document.location='browse.jsp';" onMouseOver="highlight(this)" onMouseOut="unhighlight(this)">
        	Search
        </td>
    </tr>
        <tr class="space">
    	<td><hr />
        </td>
    </tr>
    <%
	if(!hasUser)
	{
	%>
    <tr class="side_button">
    	<td onclick="window.document.location='login.jsp';" onMouseOver="highlight(this)" onMouseOut="unhighlight(this)">
        	Login
        </td>
    </tr>
    <%
	}
	else
	{
	%>
	
    <%
    if(myUser.getAttribute("role").equals("student"))
    {
    %>
    <tr class="side_button">
    	<td onclick="window.document.location='myChallenges.jsp';" onMouseOver="highlight(this)" onMouseOut="unhighlight(this)">
        	My Challenges
        </td>
    </tr>
    <tr class="space">
    	<td><hr />
        </td>
    </tr>
    <%
    }
    %>
     <tr class="side_button">
    	<td onclick="window.document.location='#';" onMouseOver="highlight(this)" onMouseOut="unhighlight(this)">
        	Messages
        </td>
    </tr>
        <tr class="space">
    	<td><hr />
        </td>
    </tr>
    <%
    if(myUser.getAttribute("role").equals("admin"))
    {
    %>
    <tr class="side_button">
    	<td onclick="window.document.location='administrative.jsp';" onMouseOver="highlight(this)" onMouseOut="unhighlight(this)">
        	Admin
        </td>
    </tr>
        <tr class="space">
    	<td><hr />
        </td>
    </tr>
    <%
    }
    %>
    <tr class="side_button">
    	<td onclick="window.document.location='logoutSubmit.jsp';" onMouseOver="highlight(this)" onMouseOut="unhighlight(this)">
        	Logout
        </td>
    </tr>
    <%
	}
	%>
</table>
