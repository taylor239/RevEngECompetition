<script>

function getRequest(theURL)
{
	var xmlHttp=null;
	xmlHttp=new XMLHttpRequest();
	xmlHttp.open("GET", theURL, false);
	xmlHttp.send(null);
	return xmlHttp.responseText;
}

</script>