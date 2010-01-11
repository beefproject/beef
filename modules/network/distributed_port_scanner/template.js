var AttackAPI = {
	version: '0.1',
	author: 'Petko Petkov (architect)',
	homepage: 'http://www.gnucitizen.org'};

AttackAPI.PortScanner = {};
AttackAPI.PortScanner.scanPort = function (callback, target, port, timeout) {
	var timeout = (timeout == null)?100:timeout;
	var img = new Image();
	
	img.onerror = function () {
		if (!img) return;
		img = undefined;
		callback(target, port, 'open');
	};
	
	img.onload = img.onerror;
	img.src = 'http://' + target + ':' + port;
	
	setTimeout(function () {
		if (!img) return;
		img = undefined;
		callback(target, port, 'closed');
	}, timeout);
};
AttackAPI.PortScanner.scanTarget = function (callback, target, ports_str, timeout)
	{
	var ports = ports_str.split(",");

	for (index = 0; index < ports.length; index++) {
		AttackAPI.PortScanner.scanPort(callback, target, ports[index], timeout);
	}
};

function do_main(){ 
	var result = "";

	var callback = function (target, port, status) {
		result = target + ":" + port + " " + status;
		return_result(result_id, result);
	};

	AttackAPI.PortScanner.scanTarget(callback, "TARGET", "PORTS", TIMEOUT);
}

do_main()