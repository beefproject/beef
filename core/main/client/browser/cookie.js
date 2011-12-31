//
//   Copyright 2012 Wade Alcorn wade@bindshell.net
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
/*!
 * @literal object: beef.browser.cookie
 * 
 * Provides fuctions for working with cookies. 
 * Several functions adopted from http://techpatterns.com/downloads/javascript_cookies.php
 * Original author unknown.
 * 
 */
beef.browser.cookie = {
	
		setCookie: function (name, value, expires, path, domain, secure) 
		{
	
			var today = new Date();
			today.setTime( today.getTime() );
	
			if ( expires )
			{
				expires = expires * 1000 * 60 * 60 * 24;
			}
			var expires_date = new Date( today.getTime() + (expires) );
	
			document.cookie = name + "=" +escape( value ) +
				( ( expires ) ? ";expires=" + expires_date.toGMTString() : "" ) +
				( ( path ) ? ";path=" + path : "" ) +
				( ( domain ) ? ";domain=" + domain : "" ) +
				( ( secure ) ? ";secure" : "" );
		},

		getCookie: function(name) 
		{
			var a_all_cookies = document.cookie.split( ';' );
			var a_temp_cookie = '';
			var cookie_name = '';
			var cookie_value = '';
			var b_cookie_found = false;
			
			for ( i = 0; i < a_all_cookies.length; i++ )
			{
				a_temp_cookie = a_all_cookies[i].split( '=' );
				cookie_name = a_temp_cookie[0].replace(/^\s+|\s+$/g, '');
				if ( cookie_name == name )
				{
					b_cookie_found = true;
					if ( a_temp_cookie.length > 1 )
					{
						cookie_value = unescape( a_temp_cookie[1].replace(/^\s+|\s+$/g, '') );
					}
					return cookie_value;
					break;
				}
				a_temp_cookie = null;
				cookie_name = '';
			}
			if ( !b_cookie_found )
			{
				return null;
			}
		},

		deleteCookie: function (name, path, domain) 
		{
			if ( this.getCookie(name) ) document.cookie = name + "=" +
			( ( path ) ? ";path=" + path : "") +
			( ( domain ) ? ";domain=" + domain : "" ) +
			";expires=Thu, 01-Jan-1970 00:00:01 GMT";
		},
		
		hasSessionCookies: function (name)
		{
			var name = name || "cookie";
			if (name == "") name = "cookie";
			this.setCookie( name, 'none', '', '/', '', '' );

			cookiesEnabled = (this.getCookie(name) == null)? false:true;
			this.deleteCookie(name, '/', '');
			return cookiesEnabled;
			
		},

		hasPersistentCookies: function (name)
		{
			var name = name || "cookie";
			if (name == "") name = "cookie";
			this.setCookie( name, 'none', 1, '/', '', '' );

			cookiesEnabled = (this.getCookie(name) == null)? false:true;
			this.deleteCookie(name, '/', '');
			return cookiesEnabled;
			
		}	
					
};

beef.regCmp('beef.browser.cookie');