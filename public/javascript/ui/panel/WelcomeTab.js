WelcomeTab = function() {

    welcome = " \
              <div style='font:13px tahoma,arial,helvetica,sans-serif'> \
              <p><img src='/ui/public/images/icons/beef.gif' />&nbsp; <span style='font:bold 15px tahoma,arial,helvetica,sans-serif'>BeEF - The Browser Exploitation Framework</span></p><br /> \
              <p>Welcome to BeEF!</p><br /> \
              <p>Before being able to fully explore the framework you will have to 'hook' a browser. To begin with you can point a browser towards the basic demo page <a href='/demos/basic.html' target='_blank'>here</a>, or the advanced version <a href='/demos/butcher/index.html' target='_blank'>here</a>.</p><br /> \
              <p>After a browser is hooked into the framework they will appear in the 'Hooked Browsers' panel on the left. Hooked browsers will appear in either an online or offline state, depending on how recently they have polled the framework. To interact with a hooked browser simply click it, a new tab will appear.</p><br /> \
              <p>Each hooked browser tab has a number of sub-tabs, described below:</p> \
              <p><ul><li><span style='font:bold 13px tahoma,arial,helvetica,sans-serif'>Main:</span> Display information about the hooked browser after you've run some command modules</li> \
              <li><span style='font:bold 13px tahoma,arial,helvetica,sans-serif'>Logs:</span> Displays recent log entries related to this particular hooked browser.</li> \
              <li><span style='font:bold 13px tahoma,arial,helvetica,sans-serif'>Commands:</span> This tab is where modules can be executed against the hooked browser. This is where most of the BeEF functionality resides.</li> \
              <li><span style='font:bold 13px tahoma,arial,helvetica,sans-serif'>Requester:</span> The Requester tab is a special module that allows you to submit arbitrary HTTP requests on behalf of the hooked browser.</li></ul></p><br /> \
              <p>For more information visit: <a href='http://code.google.com/p/beef/'>http://code.google.com/p/beef/</a></p><br />\
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
