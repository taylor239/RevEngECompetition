<%
	ArrayList sideNewsItems=new ArrayList();
	if(hasUser)
	{
		//sideNewsItems=(ArrayList)myUser.getAttribute("userNews");
	}
	else
	{
		//sideNewsItems=myConnector.selectAllNews();
	}
%>
<table id="side_news">
	<tr id="side_news_title" onclick="window.document.location='index.jsp';" onMouseOver="highlight(this)" onMouseOut="unhighlight(this)">
		<td><img src="img/pillarsmallcropped.png" width="40em" /></td>
	</tr>
<%
	for(int x=0; x<sideNewsItems.size(); x++)
	{
		DBObj curItem=(DBObj)sideNewsItems.get(x);
%>
	<tr class="space">
    	<td><hr />
        </td>
    </tr>
	<form id="side_news_item<% out.print(x); %>" name="side_news_item<% out.print(x); %>" method="GET" action="viewInstitution.jsp">
    <input type="hidden" name="institution_name" id="institution_name" value="<% out.print(curItem.getAttribute("name")); %>" />
    <tr class="side_news_item">
    	<td onclick="document.getElementById('side_news_item<% out.print(x); %>').submit();" onMouseOver="highlight(this)" onMouseOut="unhighlight(this)">
		<% out.print(curItem.getAttribute("title")); %>
    </td>
    </tr>
    </form>
<%
	}
%>
</table>