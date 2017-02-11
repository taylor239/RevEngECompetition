<script>

var totalCommands = 0;

function addAnotherCommand()
{
	totalCommands++;
	document.getElementById("totalAdd").value = totalCommands;
	var toAdd = "<tr>\
    <td colspan=\"2\">\
	<table class=\"news_item_table\" width=\"100%\">\
	<tr>\
	<td width=\"33%\">\
    Command Number:\
    </td>\
    <td width=\"67%\">\
    <input style=\"width:90%\" form=\"updateForm\" type=\"text\" id=\"command_order_" + totalCommands + "\" name=\"command_order_" + totalCommands + "\" value=\"\"></input>\
    </td>\
	</tr>\
	<tr>\
	<td width=\"33%\">\
    Command:\
    </td>\
    <td width=\"67%\">\
    <input style=\"width:90%\" form=\"updateForm\" type=\"text\" id=\"commandName_" + totalCommands + "\" name=\"commandName_" + totalCommands + "\" value=\"\"></input>\
    </td>\
	</tr>\
	<tr>\
	<td width=\"33%\">\
    Arguments:\
    </td>\
    <td width=\"67%\">\
    <textarea style=\"width:90%\" form=\"updateForm\" id=\"command_" + totalCommands + "\" name=\"command_" + totalCommands + "\"></textarea>\
    </td>\
	</tr>\
	</table>\
	</td>\
	</tr>";
	document.getElementById("challengeTable").innerHTML += toAdd;
	//document.getElementById("updateForm").appendChild(document.getElementById("command_order_" + totalCommands));
}

</script>