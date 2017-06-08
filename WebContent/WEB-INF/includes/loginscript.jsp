<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<script>
function passwordClick(theField)
{
	theField.value="";
	theField.type="password";
}

var defaultVals = {};

function clearText(theField)
{
	if(theField in defaultVals)
	{
		
	}
	else
	{
		var tmp = theField.value;
		defaultVals[theField] = tmp;
		theField.value="";
		theField.onblur=function()
		{
			if(!theField.value || 0 === theField.value.length)
			{
				theField.value = defaultVals[theField];
				delete defaultVals[theField];
			}
		};
	}
}

</script>