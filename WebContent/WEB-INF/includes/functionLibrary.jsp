<script>

function getRequest(theURL)
{
	var xmlHttp=null;
	xmlHttp=new XMLHttpRequest();
	xmlHttp.open("GET", theURL, false);
	xmlHttp.send(null);
	return xmlHttp.responseText;
}

Element.prototype.remove = function() {
    this.parentElement.removeChild(this);
}
NodeList.prototype.remove = HTMLCollection.prototype.remove = function() {
    for(var i = this.length - 1; i >= 0; i--) {
        if(this[i] && this[i].parentElement) {
            this[i].parentElement.removeChild(this[i]);
        }
    }
}

</script>