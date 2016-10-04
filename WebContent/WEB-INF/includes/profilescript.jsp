<script id="profileHTML" type="text/x-tmpl">
<%@include file="institutionProfile.jsp" %>
</script>
<script id="newsHTML" type="text/x-tmpl">
<%@include file="institutionNews.jsp" %>
</script>
<script id="eventsHTML" type="text/x-tmpl">
<%@include file="institutionEvents.jsp" %>
</script>
<script id="projectsHTML" type="text/x-tmpl">
<%@include file="institutionProjects.jsp" %>
</script>
<script id="galleryHTML" type="text/x-tmpl">
<%@include file="institutionGallery.jsp" %>
</script>
<script id="profileHTML_unselected" type="text/x-tmpl">
<%@include file="institutionProfileSmall.jsp" %>
</script>
<script id="eventsHTML_unselected" type="text/x-tmpl">
<%@include file="institutionEventsSmall.jsp" %>
</script>
<script id="projectsHTML_unselected" type="text/x-tmpl">
<%@include file="institutionProjectsSmall.jsp" %>
</script>
<script>
var profilePanelTimeout;
var panel0Timeout;
var panel1Timeout;
var panel2Timeout;

function setPanel0(text)
{
	document.getElementById("panel_0").innerHTML=text.innerHTML;
}

function setPanel1(text)
{
	document.getElementById("panel_1").innerHTML=text.innerHTML;
}

function setPanel2(text)
{
	document.getElementById("panel_2").innerHTML=text.innerHTML;
}

function resetSelected()
{
	var items=document.getElementsByClassName("item_selected");
	for(var x=0; x<items.length; x++)
	{
		items[x].className="no_class";
	}
}

function flashPanels()
{
	fadePanels();
	profilePanelTimeout=setTimeout("showPanels();", 300);
}

function fadePanels()
{
	document.getElementById("panel_0").style.opacity="0";
	document.getElementById("panel_1").style.opacity="0";
	document.getElementById("panel_2").style.opacity="0";
}

function showPanels()
{
	document.getElementById("panel_0").style.opacity="1";
	document.getElementById("panel_1").style.opacity="1";
	document.getElementById("panel_2").style.opacity="1";
}

function resetTimeouts()
{
	clearTimeout(profilePanelTimeout);
	clearTimeout(panel0Timeout);
	clearTimeout(panel1Timeout);
	clearTimeout(panel2Timeout);
}

function clickProfile()
{
	resetTimeouts();
	flashPanels();
	panel0Timeout=setTimeout("setPanel0(galleryHTML);", 300);
	panel1Timeout=setTimeout("setPanel1(profileHTML);", 300);
	panel2Timeout=setTimeout("setPanel2(newsHTML);", 300);
	resetSelected();
	document.getElementById("profile_button").className="item_selected";
	document.getElementById("button_left").setAttribute("onClick", "clickGallery();");
	document.getElementById("button_right").setAttribute("onClick","clickNews();");
}

function clickNews()
{
	resetTimeouts();
	flashPanels();
	panel0Timeout=setTimeout("setPanel0(profileHTML_unselected);", 300);
	panel1Timeout=setTimeout("setPanel1(newsHTML);", 300);
	panel2Timeout=setTimeout("setPanel2(eventsHTML_unselected);", 300);
	resetSelected();
	document.getElementById("news_button").className="item_selected";
	document.getElementById("button_left").setAttribute("onClick", "clickProfile();");
	document.getElementById("button_right").setAttribute("onClick","clickEvents();");
}

function clickEvents()
{
	resetTimeouts();
	flashPanels();
	panel0Timeout=setTimeout("setPanel0(newsHTML);", 300);
	panel1Timeout=setTimeout("setPanel1(eventsHTML);", 300)
	panel2Timeout=setTimeout("setPanel2(projectsHTML_unselected);", 300)
	resetSelected();
	document.getElementById("events_button").className="item_selected";
	document.getElementById("button_left").setAttribute("onClick", "clickNews();");
	document.getElementById("button_right").setAttribute("onClick","clickProjects();");
}

function clickProjects()
{
	resetTimeouts();
	flashPanels();
	panel0Timeout=setTimeout("setPanel0(eventsHTML_unselected);", 300);
	panel1Timeout=setTimeout("setPanel1(projectsHTML);", 300);
	panel2Timeout=setTimeout("setPanel2(galleryHTML);", 300);
	resetSelected();
	document.getElementById("projects_button").className="item_selected";
	document.getElementById("button_left").setAttribute("onClick", "clickEvents();");
	document.getElementById("button_right").setAttribute("onClick","clickGallery();");
}

function clickGallery()
{
	resetTimeouts();
	flashPanels();
	panel0Timeout=setTimeout("setPanel0(projectsHTML_unselected);", 300);
	panel1Timeout=setTimeout("setPanel1(galleryHTML);", 300);
	panel2Timeout=setTimeout("setPanel2(profileHTML_unselected);", 300);
	resetSelected();
	document.getElementById("gallery_button").className="item_selected";
	document.getElementById("button_left").setAttribute("onClick", "clickProjects();");
	document.getElementById("button_right").setAttribute("onClick","clickProfile();");
}

</script>