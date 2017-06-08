<style>

.popimage
{
	
}

.message_black_overlay
{
	transition:300ms linear;
	display: none;
	position: absolute;
	top: 0%;
	left: 0%;
	width: 100%;
	height: 100%;
	background-color: black;
	z-index:1001;
	opacity:0;
	cursor:pointer;
}
 
.message_white_content
{
	transition:300ms linear;
	border-radius:10px;
	display: none;
	position: absolute;
	top: 33%;
	left: 33%;
	width: 33%;
	height: 33%;
	padding: 2px;
	border: 4px solid #006699;
	background-color: white;
	z-index:1002;
	overflow: auto;
	text-align:center;
	cursor:pointer;
	opacity:0;
	vertical-align:middle;
}

.message_white_content td
{
	text-align:center;
	vertical-align:middle;
	font-size:larger;
	font-weight:bolder;
}

</style>

<script>

var messageBoxTimeout;

function showMessageBox(theHTML)
{
	clearTimeout(messageBoxTimeout);
	
	var newWhiteDiv=document.createElement('table');
	newWhiteDiv.className="message_white_content";
	newWhiteDiv.id="light";
	newWhiteDiv.innerHTML=theHTML;
	
	var newBlackDiv=document.createElement('table');
	newBlackDiv.className="message_black_overlay";
	newBlackDiv.id="fade";
	
	document.body.appendChild(newWhiteDiv);
	document.body.appendChild(newBlackDiv);
	
	newWhiteDiv.style.display='table';
	newBlackDiv.style.display='table';
	
	newWhiteDiv.onclick=unshowMessageBox;
	newBlackDiv.onclick=unshowMessageBox;
	
	newWhiteDiv.style.opacity=0;
	newBlackDiv.style.opacity=0;
	messageBoxTimeout=setTimeout("fadeInMessageBox();", 1);
}

function fadeInMessageBox()
{
	var oldWhiteDiv=document.getElementById('light');
	oldWhiteDiv.style.opacity=1;
	
	var oldBlackDiv=document.getElementById('fade');
	oldBlackDiv.style.opacity=.8;
}

function unshowMessageBox()
{
	clearTimeout(messageBoxTimeout);
	
	var oldWhiteDiv=document.getElementById('light');
	oldWhiteDiv.style.opacity=0;
	
	var oldBlackDiv=document.getElementById('fade');
	oldBlackDiv.style.opacity=0;
	
	messageBoxTimeout=setTimeout("fadeOutMessageBox();", 300);
}

function fadeOutMessageBox()
{
	var oldWhiteDiv=document.getElementById('light');
	oldWhiteDiv.display="none";
	
	var oldBlackDiv=document.getElementById('fade');
	oldBlackDiv.display="none";
	
	document.body.removeChild(oldWhiteDiv);
	document.body.removeChild(oldBlackDiv);
}

</script>