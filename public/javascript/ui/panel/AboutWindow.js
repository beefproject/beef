AboutWindow = function() {
	
	about = " \
		<p> \
			BeEF, the Browser Exploitation Framework is a professional security \
			tool provided for lawful research and testing purposes. It allows \
			the experienced penetration tester or system administrator additional \
			attack vectors when assessing the posture of a target. The user of \
			BeEF will control which browser will launch which module and at \
			which target.\
		<p><br> \
			BeEF hooks one or more web browsers as beachheads for the launching \
			of directed modules in real-time. Each browser is likely to be \
			within a different security context. This provides additional vectors \
			that can be exploited by security professionals. \
		<p><br> \
			<b>Authors:</b><br> \
			- Wade Alcorn (Founder, Architect)<br> \
			- Benjamin Mosse (Main developer) \
		</p> \
		";
	
	var button = Ext.get('open-about-menu');
	var about_open = false;
	
	button.on('click', function(){
		if(!about_open) {
			var content = new Ext.Panel({
				region: 'center',
				padding: '3 3 3 3',
				html: about
			});

			var win = new Ext.Window({
				title: 'About BeEF',
				closable:true,
				width:600,
				height:250,
				plain:true,
				layout: 'border',
				shadow: true,
				items: [content]
			});

			win.on('close', function() {
				about_open = false;
			});

			win.show(this);
			about_open = true;
		}
	})
};