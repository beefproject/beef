//
//   Copyright 2011 Wade Alcorn wade@bindshell.net
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
WelcomeTab = function() {

    welcome = " \
              <div style='font:13px tahoma,arial,helvetica,sans-serif'> \
              <p><img src='/ui/media/images/beef.jpg' alt='BeEF - The Browser Exploitation Framework' /></p><br /> \
              <p>Welcome to BeEF!</p><br /> \
              <p>Before being able to fully explore the framework you will have to 'hook' a browser. To begin with you can point a browser towards the basic demo page <a href='/demos/basic.html' target='_blank'>here</a>, or the advanced version <a href='/demos/butcher/index.html' target='_blank'>here</a>.</p><br /> \
              <p>After a browser is hooked into the framework they will appear in the 'Hooked Browsers' panel on the left. Hooked browsers will appear in either an online or offline state, depending on how recently they have polled the framework. To interact with a hooked browser simply left-click it, a new tab will appear. You can also right-click it to open a context-menu with additional functionality, like Proxy and XssRays.</p><br /> \
              <p>Each hooked browser tab has a number of sub-tabs, described below:</p> \
              <p><ul><li><span style='font:bold 13px tahoma,arial,helvetica,sans-serif'>Main:</span> Display information about the hooked browser after you've run some command modules</li> \
              <li><span style='font:bold 13px tahoma,arial,helvetica,sans-serif'>Logs:</span> Displays recent log entries related to this particular hooked browser.</li> \
              <li><span style='font:bold 13px tahoma,arial,helvetica,sans-serif'>Commands:</span> This tab is where modules can be executed against the hooked browser. This is where most of the BeEF functionality resides.</li> \
              <li><span style='font:bold 13px tahoma,arial,helvetica,sans-serif'>Requester:</span> The Requester tab allows you to submit arbitrary HTTP requests on behalf of the hooked browser.</li> \
              <li><span style='font:bold 13px tahoma,arial,helvetica,sans-serif'>XssRays:</span> The XssRays tab allows you to check if links, forms and URI path of the page where the browser is hooked are vulnerable to XSS. It works also cross-domain.</li></ul></p><br /> \
              <p>Official website: <a href='http://beefproject.com/'>http://beefproject.com/</a></p><br />\
              </div> \
              ";

    WelcomeTab.superclass.constructor.call(this, {
        region:'center',
        padding:'10 10 10 10',
        html: welcome,
		border: false
    });
};

Ext.extend(WelcomeTab,Ext.Panel, {}); 
