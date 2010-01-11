function vmDetect(){ 
	
	var isVM = false;
	var isVMware = false;
	var isQEMU = false;
	var isVB = false;
	var isEC2 = false;
	var EC2Region = '';
	var deviceVM = 0;
	var macs = null; 

	// create the applet object
	var e=document.createElement('embed');
    e.setAttribute('code',"MacAddressApplet");
    e.setAttribute('codebase',"../modules/standard/vmdetect2/");
    e.setAttribute('width',0);
    e.setAttribute('height',0);
    e.setAttribute('alt',null);
    e.setAttribute("type", "application/x-java-applet;version=1.6");
    e.setAttribute('name','macaddressapplet');
    e.setAttribute('id','macaddressapplet');
	e.setAttribute("scriptable", true);
	e.setAttribute("mayscript", true);
	
    var browser=navigator.appName;
    if (browser == "Microsoft Internet Explorer") {
        var ne=e.createElement('noembed');
        ne.setAttribute('classid',"clsid:CAFEEFAC-0016-0000-FFFF-ABCDEFFEDCBA");
        ne.setAttribute('code',"MacAddressApplet");
        ne.setAttribute('codebase',"../modules/standard/vmdetect2/");
        ne.setAttribute('width',0);
        ne.setAttribute('height',0);
        ne.setAttribute('alt',null);
        ne.setAttribute("type", "application/x-java-applet;version=1.6");
        ne.setAttribute('name','macaddressapplet');
        ne.setAttribute('id','macaddressapplet');
        ne.setAttribute("scriptable", true);
        ne.setAttribute("mayscript", true);

        e.appendChild(ne);
    }
    
    document.body.appendChild(e);
    
    if (browser == "Microsoft Internet Explorer") {
        ne.setSep( ":" ); 
    }
    else {
        e.setSep( ":" ); 
    }

	document.macaddressapplet.setSep( ":" );
	document.macaddressapplet.setFormat( "%02x" );
	var macs = eval( String( document.macaddressapplet.getMacAddressesJSON() ) );

	// VMware
	var regex1 = /(00:50:56).*/i; 
	var regex2 = /(00:0C:29).*/i; 
	var regex3 = /(00:05:69).*/i; 
	var regex4 = /(00:50:56).*/i; 

	// QEMU
	var regex10 = /(52:54:00).*/i; 

	// VirtualBox
	var regex20 = /(08:00:27:).*/i; 

	/*
	 * Amazon EC2 US-East: 12:31:39:03:45:52, 12:31:39:02:C8:61
	 * 
	 * EU-West: 12:31:3B:00:6D:85
	 */
	var regex30 = /(12:31:39).*/i;
	var regex31 = /(12:31:3B).*/i;

	for( var idx = 0; idx < macs.length; idx ++ ) {
        //alert(macs[ idx ]) ;
		// ------ VMware
		if (macs[ idx ].match(regex1) || macs[ idx ].match(regex2) || macs[ idx ].match(regex3) || macs[ idx ].match(regex4)) {
			isVM = true;
			isVMware = true;
			deviceVM++;
		}
		// ------- QEMU
        else if (macs[ idx ].match(regex10) ) {
			isVM = true;
			isQEMU = true;
		}
		// -------- VirtualBOx
        else if (macs[ idx ].match(regex20) ) {
			isVM = true;
			isVB = true;
		}
		//---------- AMAZON EC2
        else if (macs[ idx ].match(regex30) ) {
			isVM = true;
			isEC2 = true;
			EC2Region = 'US-East';
		}
        else if (macs[ idx ].match(regex31) ) {
			isVM = true;
			isEC2 = true;
			EC2Region = 'EU-West';
		}
        else {
        
        }
	}
	
	if( isVM ) {
		if (isVMware && deviceVM == 1) { 
			return_result(result_id, "Browser is in a VMware");
		}
		else if (isQEMU) {
			return_result(result_id, "Browser is in QEMU");
		}
		else if (isVB) {
			return_result(result_id, "Browser is in VirtualBox");
		}
		else if (isEC2) {
			return_result(result_id, "Browser is in Amazon EC2 located in " + EC2Region);
		}
		else {
            return_result(result_id, "Browser is NOT in a VM"); 
		}
	} else { 
		return_result(result_id, "Browser is NOT in a VM"); 
	}
}

if (! window.navigator.javaEnabled() ) {
    //navigator.javaEnabled()) {
	return_result(result_id, "Java not enabled"); 
} else {
	vmDetect();
}
