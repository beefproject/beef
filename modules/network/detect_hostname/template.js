// code from http://code.google.com/p/attackapi/

var internalhostname = "";

function do_main(){
	
	try {
		var sock = new java.net.Socket();
		
		sock.bind(new java.net.InetSocketAddress('0.0.0.0', 0));
		sock.connect(new java.net.InetSocketAddress(document.domain, (!document.location.port)?80:document.location.port));
		
		internalhostname =  sock.getLocalAddress().getHostName();
	} catch (e) {
		internalhostname = 'failed';	
	}

}

do_main();
return_result(result_id, internalhostname);