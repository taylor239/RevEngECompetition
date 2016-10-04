<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<div id="topnav">
<div align="center">
  <table width="100%" border="0" id="top_nav_table">
    <tr>
      <td class="top_button" onclick="window.document.location='http://tigress.cs.arizona.edu/';" onMouseOver="highlight(this)" onMouseOut="unhighlight(this)">About Tigress</td>
      <td class="top_button" onclick="window.document.location='search.jsp';" onMouseOver="highlight(this)" onMouseOut="unhighlight(this)">Contact</td>
      <td class="top_button" onclick="window.document.location='myChallenges.jsp';" onMouseOver="highlight(this)" onMouseOut="unhighlight(this)">My Challenges</td>
      <td class="top_button" id="title_image" onclick="window.document.location='<%
	  if(hasUser)
	  {
		out.print("index.jsp");  
	  }
	  else
	  {
		  out.print("index.jsp"); 
	  }
	  %>';" onMouseOver="highlight(this)" onMouseOut="unhighlightTitle(this)"><img height="60em" src="img/tigress-gray.png" /></td>
      <td class="top_button" onclick="window.document.location='<%
	  if(hasUser)
	  {
		  out.print("logoutSubmit.jsp");
	  }
	  else
	  {
		  out.print("index.jsp");
	  }
	  %>';" onMouseOver="highlight(this)" onMouseOut="unhighlight(this)"><%
	  if(hasUser)
	  {
		  out.print("Logout");
	  }
	  else
	  {
		  out.print("Login");
	  }
	  %></td>
      <td class="top_button" onclick="window.document.location='reversing.jsp';" onMouseOver="highlight(this)" onMouseOut="unhighlight(this)">Reversing Tools</td>
      <td class="top_button"><form id="searchform" name="searchform" method="GET" action="search.jsp">
          <input type="text" class="searchbox" name="search_site" id="search_site" value="Search site" onclick="clearText(this)" />
        <input type="submit" class="submit" name="search_site_submit" id="search_site_submit" value="Search" />
      </form></td>
    </tr>
  </table>
  </div>
</div>
