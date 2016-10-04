<script>
var code_number=1;
function addNewRow()
{
	var theTable=document.getElementById("code_redemption_table").getElementsByTagName("tbody")[0];
	var theForm=document.getElementById("num_codes");
	var newRow=theTable.insertRow(theTable.rows.length);
	var newCell=newRow.insertCell(0);
	newCell.style.textAlign="center";
	code_number++;
	newCell.innerHTML="<input type=\"text\" name=\"code_"+code_number+"\" id=\"code_"+code_number+"\" value=\"Enter code here\" onfocus=\"clearText(this)\" />";
	theForm.value=code_number;
}
</script>