<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
<%@include file="./WEB-INF/includes/includes.jsp" %>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Tigress</title>

</head>

<body>
<%@include file="./WEB-INF/includes/mainPane.jsp" %>
<table id="inner_content">
	<tr>
    	<td width="25%">
        
        </td>
        <td width="50%">
        <table class="inner_content_table" width="100%">
        <tr>
        <td>
        <table class="news_table">
        <tr class="title_general">
        <td align="center">
        Reverse Engineering Resources
        </td>
    	</tr>
        <tr class="title_general">
        <td align="center">
        Downloads
        </td>
    	</tr>
        <tr width="100%">
        <td>
        <table class="news_item_table" width="100%">
        <tr>
        <td>
        <p>
        <a href="../Reversing_Kali_Single.zip">Kali with Reversing Tools</a>
        </p>
        </td>
        </tr>
        </table>
        </td>
        </tr>
        </table>
        </td>
        </tr>
        </table>
        <table class="inner_content_table">
        <tr>
        <td>
        <table class="news_table">
        <tr class="title_general">
        <td colspan="3" align="center">
        Instructions
        </td>
    	</tr>
        <tr>
        <td>
        <table class="news_item_table">
        <tr>
        <td>
        <p>
        Provided here is a virtual machine image equipped with numerous security tools, including several reversing tools.  The image is based on <a href="https://www.kali.org/">Kali Linux</a> but has several additional tools installed, including the angr Python module.
        </p><br />
        <p>
        To use this virtual machine, first download it via the link on the left.  Note that the file is about 4 GB and will take some time to download.  After downloading and extracting the image, use your choice of .OVF compliant virtual machine software to run the distribution.  The password for root is toor.
        </p><br />
        <p>
        For information regarding any of the Kali tools, please view the Kali website (linked above).  Additional information on angr may be found <a href="http://angr.io/">here.</a>
        </p><br />
        <p>
        <table width="100%">
        <tr>
        <td width="100%">
        Installation directions for VMWare:<br />
        <ol style="list-style-position: inside;">
        	<li>Launch VMWare</li>
        	<li>Click "Player" button and navigate to "File" and "Open"</li>
        	<li>Navigate to and select the extracted .ovf file</li>
        	<li>Use default values and click "Import"</li>
        	<li>The file may take a long time to import</li>
        	<li>If prompted, select "I copied it"</li>
        	<li>Select ReversingKali on the VMWare virtual machine list</li>
        	<li>If necessary, adjust the amount of memory allocated to the VM</li>
        	<li>Push play</li>
        	<li>Voila- it should work</li>
        </ol>
        <br />
        </td>
        </tr>
        <tr>
        <td width="100%">
        Installation directions for VirtualBox:<br />
        <ol style="list-style-position: inside;">
        	<li>Launch VirtualBox</li>
        	<li>Push "File" and select "Import Appliance"</li>
        	<li>Navigate to and select the extracted .ovf file</li>
        	<li>Use default values and push "Import"</li>
        	<li>This process may take some time</li>
        	<li>On the VirtualBox VM list, select KaliReversing and click "Settings"</li>
        	<li>On the "General" tab, change "Type" and "Version" to "Linux" and "Debian (64-bit)"; "Other Linux (64-bit)" also works if Debian does not</li>
        	<li>On the "System" tab, adjust "Base Memory" as necessary</li>
        	<li>On the "Display" tab, maximize "Video Memory" to 128 MB</li>
        	<li>On the "Network" tab, disable the "Enable Network Adapter" check box for "Adapter 1" and enable it for "Adapter 2"</li>
        	<li>Push OK and push "Start"</li>
        	<li>Voila- it should be working (though VirtualBox is a bit buggy and may need to be restarted 2 times or so)</li>
        </ol>
        </td>
        </tr>
        </table>
        </p>
        </td>
        </tr>
        </table>
        </td>
        </tr>
        </table>
        </td>
        </tr>
        </table>
        </td>
        <td width="25%">
        <table class="inner_content_table">
        
        </table>
        </td>
    </tr>
</table>
<%@include file="./WEB-INF/includes/footer.jsp" %>
</body>

</html>