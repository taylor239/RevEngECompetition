<script>
var currentTimeout;
var expanded=false;

function showSideButtons()
{
	clearTimeout(currentTimeout);
	if(expanded)
	{
		return;
	}
	expanded=true;
	var theContent=document.getElementById("content");
	theContent.style.width="85%";
	var theOtherRow=document.getElementById("side_other_row");
	theOtherRow.style.width="7.5%";
	theOtherRow.style.background="linear-gradient(to left, #FFEAEA 95%, red, black)";
	var theRow=document.getElementById("side_nav_row");
	theRow.style.width="7.5%";
	theRow.style.background="linear-gradient(to right, #FFEAEA 95%, red, black)";
	var theTable=document.getElementById("side_nav");
	theTable.style.width="100%";
	var theOtherTable=document.getElementById("side_news");
	theOtherTable.style.width="100%";
	var theInnerContent=document.getElementById("inner_content");
	currentTimeout=setTimeout("showItems();", 300);
	if(theInnerContent)
	{
		theInnerContent.style.width="100%"
	}
}

function showItems()
{
	var buttons=document.getElementsByClassName('side_button');
	var news=document.getElementsByClassName('side_news_item');
	var lines=document.getElementsByClassName('space');
	for(var x=0; x<buttons.length; x++)
	{
		buttons[x].style.display="table-row";
		if(x<news.length)
		{
			news[x].style.display="table-row";
		}
		if(x==buttons.length-1)
		{
			for(var y=x+1; y<news.length; y++)
			{
				news[y].style.display="table-row";
			}
		}
	}
	for(var x=0; x<lines.length; x++)
	{
		lines[x].style.display="table-row";
	}
	currentTimeout=setTimeout("fadeInItems();", 10);
}

function fadeInItems()
{
	var buttons=document.getElementsByClassName('side_button');
	var news=document.getElementsByClassName('side_news_item');
	var lines=document.getElementsByClassName('space');
	for(var x=0; x<buttons.length; x++)
	{
		buttons[x].style.transition="none";
		buttons[x].style.visibility="hidden";
		buttons[x].setAttribute("visibility", "hidden");
		buttons[x].style.opacity="0";
		buttons[x].style.transition="300ms linear";
		buttons[x].style.visibility="visible";
		buttons[x].setAttribute("visibility", "visible");
		buttons[x].style.opacity="1";
		buttons[x].style.width="100%";
		if(x<news.length)
		{
			news[x].style.transition="none";
			news[x].style.visibility="hidden";
			news[x].setAttribute("visibility", "hidden");
			news[x].style.opacity="0";
			news[x].style.transition="300ms linear";
			news[x].style.visibility="visible";
			news[x].setAttribute("visibility", "visible");
			news[x].style.opacity="1";
			news[x].style.width="100%";
		}
		if(x==buttons.length-1)
		{
			for(var y=x+1; y<news.length; y++)
			{
				news[y].style.transition="none";
				news[y].style.visibility="hidden";
				news[y].setAttribute("visibility", "hidden");
				news[y].style.opacity="0";
				news[y].style.transition="300ms linear";
				news[y].style.visibility="visible";
				news[y].setAttribute("visibility", "visible");
				news[y].style.opacity="1";
				news[y].style.width="100%";
			}
		}
	}
	for(var x=0; x<lines.length; x++)
	{
		lines[x].style.visibility="visible";
		lines[x].setAttribute("visibility", "visible");
		lines[x].style.transition="none";
		lines[x].style.opacity="0";
		lines[x].style.transition="300ms linear";
		lines[x].style.opacity="1";
		lines[x].style.display="table-row";
	}
}

function hideSideButtons()
{
	clearTimeout(currentTimeout);
	if(!expanded)
	{
		return;
	}
	expanded=false;
	fadeItems();
	currentTimeout=setTimeout("unshowItems();", 200);
}

function fadeItems()
{
	var buttons=document.getElementsByClassName('side_button');
	var news=document.getElementsByClassName('side_news_item');
	var lines=document.getElementsByClassName('space');
	for(var x=0; x<buttons.length; x++)
	{
		buttons[x].style.visibility="hidden";
		buttons[x].setAttribute("visibility", "hidden");
		buttons[x].style.transition="none";
		buttons[x].style.opacity="1";
		buttons[x].style.transition="300ms linear";
		buttons[x].style.opacity="0";
		buttons[x].style.width="100%";
		if(x<news.length)
		{
			news[x].style.visibility="hidden";
			news[x].setAttribute("visibility", "hidden");
			news[x].style.transition="none";
			news[x].style.opacity="1";
			news[x].style.transition="300ms linear";
			news[x].style.opacity="0";
			news[x].style.width="100%";
		}
		if(x==buttons.length-1)
		{
			for(var y=x+1; y<news.length; y++)
			{
				news[y].style.visibility="hidden";
				news[y].setAttribute("visibility", "hidden");
				news[y].style.transition="none";
				news[y].style.opacity="1";
				news[y].style.transition="300ms linear";
				news[y].style.opacity="0";
				news[y].style.width="100%";
			}
		}
	}
	for(var x=0; x<lines.length; x++)
	{
		lines[x].style.visibility="hidden";
		lines[x].setAttribute("visibility", "hidden");
		lines[x].style.transition="none";
		lines[x].style.opacity="1";
		lines[x].style.transition="300ms linear";
		lines[x].style.opacity="0";
	}
}

function unshowItems()
{
	var buttons=document.getElementsByClassName('side_button');
	var news=document.getElementsByClassName('side_news_item');
	var lines=document.getElementsByClassName('space');
	for(var x=0; x<buttons.length; x++)
	{
		buttons[x].style.display="none";
		if(x<news.length)
		{
			news[x].style.display="none";
		}
		if(x==buttons.length-1)
		{
			for(var y=x+1; y<news.length; y++)
			{
				news[y].style.display="none";
			}
		}
	}
	for(var x=0; x<lines.length; x++)
	{
		lines[x].style.display="none";
	}
	var theContent=document.getElementById("content");
	theContent.style.width="95%";
	var theOtherRow=document.getElementById("side_other_row");
	theOtherRow.style.width="2.5%";
	theOtherRow.style.background="linear-gradient(to left, #FFEAEA 75%, white)";
	var theRow=document.getElementById("side_nav_row");
	theRow.style.width="2.5%";
	theRow.style.background="linear-gradient(to right, #FFEAEA 75%, white)";
	var theTable=document.getElementById("side_nav");
	theTable.style.width="100%";
	var theOtherTable=document.getElementById("side_news");
	theOtherTable.style.width="100%";
	var theInnerContent=document.getElementById("inner_content");
	if(theInnerContent)
	{
		theInnerContent.style.width="91%"
	}
}

function highlight(item)
{
	item.style.background="linear-gradient(#6F6FEA, #757575)";
	item.style.cursor="pointer";
}

function highlightDark(item)
{
	item.style.background="linear-gradient(#D3D3D3, #FFF)";
	item.style.cursor="pointer";
}

function unhighlight(item)
{
	item.style.background="none";
	item.style.cursor="none";
}

function unhighlightTitle(item)
{
	item.style.background="linear-gradient(#D3D3D3, #FFF)";
	item.style.cursor="none";
}
</script>