// Javascript for BeefSploit modules
// By Ryan Linn (sussurro@happypacket.net)
// Excuse the mess, we are remodeling

var exploit_delay = 20000;

// --[ MSF GET EXPLOIT LIST
// get the list of exploits
function msf_get_exploit_list() {
	url = 'action=getexploits';
	msf_request(url, 'exploits', msf_get_payload_list);
}

// --[ MSF GET PAYLOAD LIST
// get relevant payload list
function msf_get_payload_list() {
	
	url = 'action=getpayloads&exploit=' + $('exploit').value;
	
	msf_request(url, 'payloads', msf_get_options);
}

// --[ MSG GET OPTIONS
// get relevant options for exploit and payload
function msf_get_options() {

	url = 'action=getoptions&exploit=' + $('exploit').value + "&payload=" + $('payload').value;
		
	msf_request(url, 'options', null);
	
}

// --[ MSF REQUEST
// generic request for msf data and actions
function msf_request(param_string, update_div, on_success_function) {

	new Ajax.Request('msf.php?' + param_string, 
			{
				method:'get',
				onSuccess: function(transport){ 
					// update div
					if( (update_div != undefined) && (update_div != null) ) {
						$(update_div).innerHTML = transport.responseText;
					}
					// onsuccess fuction
					if( (on_success_function != undefined) && (on_success_function != null) ) {
						on_success_function(transport.responseText);
					}
				}, 
				asynchronous:true
			});
}

// --[ MSF EXPLOIT
// after a delay direct selected zombies to the exploit
function msf_exploit(responseText) {
	window.setTimeout('Element.Methods.construct_code("' + responseText + '")', exploit_delay);
}

function msf_callAuxiliary() {

    opts = form_to_params();
    
	url = 'action=auxiliary&' + opts;
		
	msf_request(url, null, msf_exploit);

}

function msf_smb_challenge_capture() {

    opts = form_to_params();
    
	url = 'action=smbchallengecapture&' + opts;
		
	msf_request(url, null, msf_exploit);
}

function msf_browser_autopwn() {

    opts = form_to_params();
    
	url = 'action=browserautopwn&' + opts;
		
	msf_request(url, null, msf_exploit);
}

function msf_execute_module() {

    opts = form_to_params();

	url = 'action=exploit&' + opts;
	
	msf_request(url, null, msf_exploit);
}

// --[ FORM TO PARAMS 
// convert the form to a URL params string and return it
function form_to_params() {
    var opts = "";
    for(i = 0; i < document.myform.elements.length; i++) {
        if(document.myform.elements[i].name != "" && document.myform.elements[i].value != "") {
        	if(document.myform.elements[i].type == "checkbox" && document.myform.elements[i].checked == false) {
        		continue;
        	}
        	if(i > 0 ) {
                opts = opts + "&";
        	}
    		opts = opts + document.myform.elements[i].name + "=";
    		opts = opts + document.myform.elements[i].value;
        }
    }
    return opts;

}
