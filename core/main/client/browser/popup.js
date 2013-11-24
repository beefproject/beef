//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*!
 * @literal object: beef.browser.popup
 * 
 * Provides fuctions for working with cookies. 
 * Several functions adopted from http://davidwalsh.name/popup-block-javascript
 * Original author unknown.
 * 
 */
beef.browser.popup = {
	
		blocker_enabled: function ()
		{
			screenParams = beef.browser.getScreenSize();
			var popUp = window.open('/', 'windowName0', 'width=1, height=1, left='+screenParams.width+', top='+screenParams.height+', scrollbars, resizable');
			if (popUp == null || typeof(popUp)=='undefined') {   
			  	return true;
			} else {   
				popUp.close();
				return false;
			}
		}
};

beef.regCmp('beef.browser.popup');
