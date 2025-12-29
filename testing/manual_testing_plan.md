# BeEF Manual Testing Plan (Local VM Edition)

This document provides a simplified approach for manually testing BeEF modules entirely within the same Linux Ubuntu VM where BeEF is running.

## 1. Environment Setup (Local VM)

### 1.1 BeEF Server
1.  **Dependencies**: Already installed via `./install`.
2.  **Configuration**: Credentials have been updated in `config.yaml`.
3.  **Launch**: Run `./beef` from the repository root.
4.  **Access**: Open the local browser (e.g., Firefox) and navigate to the BeEF UI: `http://127.0.0.1:3000/ui/panel`.

### 1.2 Hooked Browsers (Local)
For local testing on the same machine:
1.  Open a new tab or window in your browser (Firefox, Chromium, etc.).
2.  Navigate to the hook demo page: `http://127.0.0.1:3000/demos/butcher/index.html`.
3.  The browser will appear in the BeEF "Online Browsers" list as `127.0.0.1`.

## 2. Testing Strategy: Firefox First

1.  **Primary Browser (Firefox)**: Use Firefox for **all** modules listed in Section 3.1.
    *   This list includes every module compatible with Firefox or "ALL" browsers.
2.  **Secondary Browser (Chrome/Safari/Edge)**: Use a secondary browser *only* for modules in Section 3.2.
    *   These are modules that explicitly identify as working in Chrome/Safari/Edge but *not* Firefox.
3.  **Skip Legacy**: Modules not listed in Section 3 are incompatible with modern browsers (e.g., IE-only, old Java/Flash exploits) and should be skipped.

### 2.1 Execution Procedure
1.  **Select Hooked Browser**: Click on your **Firefox** hook (or secondary browser for List 3.2).
2.  **Find Module**: Search for the module name in the BeEF "Commands" tab.
3.  **Read Instructions**: Follow the guidance in the **Instructions** column below.
4.  **Execute**: Click "Execute" and verify the "Command History".
5.  **Cleanup**: Perform any cleanup actions (e.g., clear cookies, close tabs) listed in the **Cleanup Needed** column.

## 3. Module Inventory and Instructions

### 3.1 Primary Test List (Firefox)

Test these modules using **Firefox**. Instructions are derived from module descriptions.

| Module Name | Instructions / Description | Cleanup Needed |
| :--- | :--- | :--- |
| **Alert User** | Show user an alert | None. |
| **Apache Cookie Disclosure** | This module exploits CVE-2012-0053 in order to read the victim's cookies, even if issued with the HttpOnly attribute. The exploit only works if the target server is running Apache HTTP Server 2.2.0 through 2.2.21. | Clear browser cookies. |
| **Apache Felix Remote Shell (Reverse Shell)** | This module attempts to get a reverse shell on an Apache Felix Remote Shell server using the 'exec' command. The org.eclipse.osgi and org.eclipse.equinox.console bundles must be installed and active. | None. |
| **Beep** | Make the phone beep. This module requires the PhoneGap API. | None. |
| **Bindshell (POSIX)** | Using Inter-protocol Exploitation/Communication (IPEC) the hooked browser will send commands to a listening POSIX shell bound on the target specified in the 'Target Address' input field.   The target address can be on the hooked browser's subnet which is potentially not directly accessible from the Internet. | None. |
| **Bindshell (Windows)** | Using Inter-Protocol Exploitation/Communication (IPEC) the hooked browser will send commands to a listening Windows shell bound on the target specified in the 'Target Address' input field.  The target address can be on the hooked browser's subnet which is potentially not directly accessible from the Internet.  The results of the commands are not returned to BeEF.  Note: ampersands are required to separate commands. | None. |
| **BlockUI Modal Dialog** | This module uses jQuery  BlockUI  to block the window and display a message. | None. |
| **Browser AutoPwn** | This module will redirect a user to the autopwn port on a Metasploit listener and then rely on Metasploit to handle the resulting shells.  If the Metasploit extension is loaded, this module will pre-populate the URL to the pre-launched listener.  Otherwise, enter the URL you would like the user to be redirected to. | None. |
| **Check Connection** | Find out the network connection type e.g. Wifi, 3G. This module requires the PhoneGap API. | None. |
| **Clickjacking** | Allows you to perform basic multi-click clickjacking. The iframe follows the mouse, so anywhere the user clicks on the page will be over x-pos,y-pos. The optional JS configuration values specify local Javascript to exectute when a user clicks, allowing the page can give visual feedback. The attack stops when y-pos is set to a non-numeric values (e.g. a dash).   For a demo, visit /demos/clickjacking/clickjack_attack.html with the default settings (based on browser they may have to be adjusted). | None. |
| **Clippy** | Brings up a clippy image and asks the user to do stuff. Users who accept are prompted to download an executable.  You can mount an exe in BeEF as per extensions/social_engineering/droppers/readme.txt. | None. |
| **ColdFusion Directory Traversal Exploit** | ColdFusion 9.0, 8.0.1, 9.0 and 9.0.1 are vulnerable to directory traversal that leads to arbitrary file retrieval from the ColdFusion server (CVE-2010-2861) | None. |
| **Confirm Close Tab** | Shows a confirm dialog to the user when they try to close a tab. If they click yes, re-display the confirmation dialog. This doesn't work on Opera < v12. In Chrome you can't keep opening confirm dialogs. | Close tab/window. Check for residual pop-unders. |
| **Create Foreground iFrame** | Rewrites all links on the webpage to spawn a 100% by 100% iFrame with a source relative to the selected link. | Close tab/window. Check for residual pop-unders. |
| **Create Invisible Iframe** | Creates an invisible iframe. | None. |
| **Create Pop Under** | This module creates a new discreet pop under window with the BeEF hook included.  Another browser node will be added to the hooked browser tree.  Modern browsers block popups by default and warn the user the popup was blocked (unless the origin is permitted to spawn popups).  However, this check is bypassed for some user-initiated events such as clicking the page. Use the 'clickjack' option below to add an event handler which spawns the popup when the user clicks anywhere on the page. Running the module multiple times will spawn multiple popups for a single click event.  Note: mobile devices may open the new popup window on top or redirect the current window, rather than open in the background. | Close tab/window. Check for residual pop-unders. |
| **Cross-Origin Scanner (CORS)** | Scan an IP range for web servers which allow cross-origin requests using CORS. The HTTP response is returned to BeEF.  Note: set the IP address range to 'common' to scan a list of common LAN addresses. | None. |
| **Cross-Origin Scanner (Flash)** | This module scans an IP range to locate web servers with a permissive Flash cross-origin policy. The HTTP response is returned to BeEF.  Note: set the IP address range to 'common' to scan a list of common LAN addresses.  This module uses ContentHijacking.swf from  CrossSiteContentHijacking  by Soroush Dalili (@irsdl). | None. |
| **Cross-Site Faxing (XSF)** | Using Inter-protocol Exploitation/Communication (IPEC) the hooked browser will send a message to ActiveFax RAW server socket (3000 by default) on the target specified in the 'Target Address' input field.  This module can send a FAX to a (premium) faxnumber via the ActiveFax Server.  The target address can be on the hooked browser's subnet which is potentially not directly accessible from the Internet. | None. |
| **Cross-Site Printing (XSP)** | Using Inter-protocol Exploitation/Communication (IPEC) the hooked browser will send a message to a listening print port (9100 by default) on the target specified in the 'Target Address' input field.  The target address can be on the hooked browser's subnet which is potentially not directly accessible from the Internet. | None. |
| **DNS Enumeration** | Discover DNS hostnames within the victim's network using dictionary and timing attacks. | None. |
| **DNS Tunnel** | This module sends data one way over DNS, client to server only. BeEF's DNS server is used to reconstruct chunks of data being extruded via DNS.   Make sure that:  - the DNS extension is enabled,  - the DNS server is listening on port 53, - the hooked browser is resolving the domain you specified via BeEF's DNS server.  By default all DNS requests used to extrude data return NXDomain responses. | None. |
| **DNS Tunnel** | This module sends data one way over DNS.  A domain and message are taken as input. The message is XOR'd, url encoded, the '%' are replaced with '.' and the message is split into segments of 230 bytes. The segments are sent in sequence along with the sequence number and XOR key.  Note: A remote domain with a DNS server configured to accept wildcard subdomains is required to receive the data. BeEF does not support this feature so you're on your own when it comes to decoding the information. | None. |
| **DNS Tunnel: Server-to-Client** | This module retrieves data sent by the server over DNS covert channel (DNS tunnel).   A payload name and message are taken as input. The message is sent as a bitstream, decoded, and then can be accessed via Window object property specified in payload name parameter.  Note: To use this feature you should enable S2C DNS Tunnel extension. | None. |
| **DOSer** | Do infinite GET or POST requests to a target, spawning a WebWorker in order to don't slow down the hooked page. If the browser doesn't support WebWorkers, the module will not run. | None. |
| **Detect Airdroid** | This module attempts to detect Airdroid application for Android running on localhost (default port: 8888) | None. |
| **Detect Antivirus** | This module detects the javascript code automatically included by some AVs (currently supports detection for Kaspersky, Avira, Avast (ASW), BitDefender, Norton, Dr. Web) | None. |
| **Detect Burp** | This module checks if the browser is using Burp. The Burp web interface must be enabled (default). The proxy IP address is returned to BeEF. | None. |
| **Detect CUPS** | This module attempts to detect Common UNIX Printing System (CUPS) on localhost on the default port 631. | None. |
| **Detect Coupon Printer** | This module attempts to detect Coupon Printer on localhost on the default WebSocket port 4004. | None. |
| **Detect Ethereum ENS** | This module will detect if the zombie is currently using Ethereum ENS resolvers. Note that the detection may fail when attempting to load a HTTP resource from a hooked HTTPS page. | None. |
| **Detect Extensions** | This module detects extensions installed in Google Chrome and Mozilla Firefox. | Remove installed extension if any. |
| **Detect FireBug** | This module checks if the Mozilla Firefox Firebug extension is being use to inspect the current window. | None. |
| **Detect Foxit Reader** | This module will check if the browser has Foxit Reader Plugin. | None. |
| **Detect Google Desktop** | This module attempts to detect Google Desktop running on the default port 4664. | None. |
| **Detect LastPass** | This module checks if the LastPass extension is installed and active. | None. |
| **Detect MIME Types** | This module retrieves the browser's supported MIME types. | None. |
| **Detect OpenNIC DNS** | This module will detect if the zombie is currently using OpenNIC DNS resolvers.  Note that the detection may fail when attempting to load a HTTP resource from a hooked HTTPS page. | None. |
| **Detect PhoneGap** | Detects if the PhoneGap API is present. | None. |
| **Detect Popup Blocker** | Detect if popup blocker is enabled. | None. |
| **Detect QuickTime** | This module will check if the browser has Quicktime support. | None. |
| **Detect RealPlayer** | This module will check if the browser has RealPlayer support. | None. |
| **Detect Silverlight** | This module will check if the browser has Silverlight support. | None. |
| **Detect Social Networks** | This module will detect if the Hooked Browser is currently authenticated to GMail, Facebook and Twitter. | None. |
| **Detect Toolbars** | Detects which browser toolbars are installed. | None. |
| **Detect Tor** | This module will detect if the zombie is currently using Tor (https://www.torproject.org/). | None. |
| **Detect Unity Web Player** | Detects Unity Web Player. | None. |
| **Detect VLC** | This module will check if the browser has VLC plugin. | None. |
| **Detect Windows Media Player** | This module will check if the browser has the Windows Media Player plugin installed. | None. |
| **ETag Tunnel: Server-to-Client** | This module sends data from server to client using ETag HTTP header.  A payload name and message are taken as input. The structure of ETag header isn't modified. The message is sent as a bitstream, decoded, and then can be accessed via Window object property specified in payload name parameter.   Note: To use this feature you should enable ETag extension. | None. |
| **EXTRAnet Collaboration Tool (extra-ct) Command Execution** | This module exploits a command execution vulnerability in the 'admserver' component of the EXTRAnet Collaboration Tool (default port 10100) to execute operating system commands.  The target address can be on the hooked browser's subnet which is potentially not directly accessible from the Internet.  The results of the commands are not returned to BeEF.  Note: Spaces in the command are not supported. | None. |
| **Fake Flash Update** | Prompts the user to install an update to  Adobe Flash Player  from the specified URL. | None. |
| **Fake Notification Bar (Chrome)** | Displays a fake notification bar at the top of the screen, similar to those presented in Chrome. If the user clicks the notification they will be prompted to download the file specified below.  You can mount an exe in BeEF as per extensions/social_engineering/droppers/readme.txt. | None. |
| **Fake Notification Bar (Firefox)** | Displays a fake notification bar at the top of the screen, similar to those presented in Firefox. If the user clicks the notification they will be prompted to download a file from the the specified URL. | None. |
| **Fake Notification Bar (IE)** | Displays a fake notification bar at the top of the screen, similar to those presented in IE. If the user clicks the notification they will be prompted to download the file specified below.  You can mount an exe in BeEF as per extensions/social_engineering/droppers/readme.txt. | None. |
| **Fake Notification Bar** | Displays a fake notification bar at the top of the screen, similar to those presented in IE. | None. |
| **Farsite X25 gateway remote code execution** | This module exploits CVE-2014-7175 to write a payload to the router and CVE-2014-7173 to execute it. Once you have shell you can use the setuid /http/bin/execCmd to execute commands as root. | None. |
| **Fetch Port Scanner** | Uses fetch to test the response in order to determine if a port is open or not | None. |
| **Fingerprint Browser (PoC)** | This module attempts to fingerprint the browser type and version using URI protocol handlers unique to Safari, Internet Explorer and Mozilla Firefox. | None. |
| **Fingerprint Browser** | This module attempts to fingerprint the browser and browser capabilities using  FingerprintJS2 . | None. |
| **Fingerprint Local Network** | Discover devices and applications in the victim's Local Area Network.  This module uses a signature based approach - based on default logo images/favicons for known network device/applications - to fingerprint each IP address within the LAN.  Partially based on  Yokosou  and  jslanscanner .  Note: set the IP address range to 'common' to scan a list of common LAN addresses. | None. |
| **Fingerprint Routers** | This module attempts to discover network routers on the local network of the hooked browser. It scans for web servers on IP addresses commonly used by routers. It uses a signature based approach - based on default image paths for known network devices - to determine if the web server is a router web interface.  Ported to BeEF from  JsLanScanner .  Note: The user may see authentication popups in the event any of the target IP addresses are using HTTP authentication. | None. |
| **Firephp 0.7.1 RCE** | Exploit FirePHP <= 0.7.1 to execute arbitrary JavaScript within the trusted 'chrome://' zone.  This module forces the browser to load '/firephp' on the BeEF server.  The payload is executed silently once the user moves the mouse over the array returned for 'http://[BeEF]/firephp' in Firebug.   Note:  Use msfpayload to generate JavaScript payloads. The default payload binds a shell on port 4444. See 'modules/exploits/firephp/payload.js' | None. |
| **Geolocation** | Geo locate your victim. This module requires the PhoneGap API. | None. |
| **Get Battery Status** | Get informations of the victim current battery status | None. |
| **Get Geolocation (API)** | This module will retrieve the physical location of the hooked browser using the geolocation API. | None. |
| **Get Geolocation (Third-Party)** | This module retrieves the physical location of the hooked browser using third-party hosted geolocation APIs. | None. |
| **Get HTTP Servers (Favicon)** | Attempts to discover HTTP servers on the specified IP range by checking for a favicon.  Note: You can specify multiple remote IP addresses (separated by commas) or a range of IP addresses for a class C network (10.1.1.1-10.1.1.254). Set the IP address to 'common' to scan a list of common LAN addresses. | None. |
| **Get Internal IP (Java)** | Retrieve the local network interface IP address of the victim machine using an unsigned Java applet.  The browser must have Java enabled and configured to allow execution of unsigned Java applets.  Note that modern Java (as of Java 7u51) will outright refuse to execute unsigned Java applets, and will also reject self-signed Java applets unless they're added to the exception list. | None. |
| **Get Internal IP WebRTC** | Retrieve the internal (behind NAT) IP address of the victim machine using WebRTC Peer-to-Peer connection framework. Code from  http://net.ipcalf.com/ | None. |
| **Get Network Connection Type** | Retrieve the network connection type (wifi, 3G, etc). Note: Android only. | None. |
| **Get Protocol Handlers** | This module attempts to identify protocol handlers present on the hooked browser. Only Internet Explorer and Firefox are supported.  Firefox users are prompted to launch the application for which the protocol handler is responsible.  Firefox users are warned when there is no application assigned to a protocol handler.    The possible return values are: unknown, exists, does not exist. | None. |
| **Get Proxy Servers (WPAD)** | This module retrieves proxy server addresses for the zombie browser's local network using Web Proxy Auto-Discovery Protocol (WPAD).  Note: The zombie browser must resolve  wpad  to an IP address successfully for this module to work. | None. |
| **Get System Info (Java)** | This module will retrieve basic information about the host system using an unsigned Java Applet.   The details will include:     - Operating system details   - Java VM details   - NIC names and IP   - Number of processors   - Amount of memory   - Screen display modes | None. |
| **Get Visited Domains** | This module will retrieve rapid history extraction through non-destructive cache timing. Based on work done by Michal Zalewski at http://lcamtuf.coredump.cx/cachetime/  You can specify additional resources to fetch during visited domains analysis. To do so, paste to the below text field full URLs leading to CSS, image, JS or other *static* resources hosted on desired page (mind to avoid CDN resources, as they vary). Separate domain names with url by using semicolon (;), specify next domains by separating them with comma (,). | None. |
| **Get Visited URLs (Avant Browser)** | This module attempts to retrieve a user's browser history by invoking the 'AFRunCommand()' privileged function.  Note: Avant Browser in Firefox engine mode only. | None. |
| **Get Visited URLs (Old Browsers)** | This module will detect whether or not the hooked browser has visited the specified URL(s) | None. |
| **Get Wireless Keys** | This module will retrieve the wireless profiles from the target system (Windows Vista and Windows 7 only).  You will need to copy the results to 'exported_wlan_profiles.xml' and then reimport back into your Windows Vista/7 computers by running the command: netsh wlan add profile filename="exported_wlan_profiles.xml".  After that, just launch and connect to the wireless network without any password prompt.  For more information, refer to http://pauldotcom.com/2012/03/retrieving-wireless-keys-from.html | None. |
| **Get ntop Network Hosts** | This module retrieves network information from ntop (unauthenticated).  Tested on:  ntop v.5.0.1 on Ubuntu 14.04.1 Server (x86_64)  ntop v.5.0 on Fedora 19.1 (x86_64)  ntop v.4.1.0 on Solaris 11.1 (x86)   This module does not work for ntop-ng. | None. |
| **GlassFish WAR Upload XSRF** | This module attempts to deploy a malicious war file on an Oracle GlassFish Server 3.1.1 (build 12).  It makes advantage of a CSRF bug in the REST interface. For more information refer to  http://blog.malerisch.net/2012/04/oracle-glassfish-server-rest-csrf.html . | None. |
| **Globalization Status** | Examine device local settings. This module requires the PhoneGap API. | None. |
| **Google Phishing** | This plugin uses an image tag to XSRF the logout button of Gmail. Continuously the user is logged out of Gmail (eg. if he is logged in in another tab). Additionally it will show the Google favicon and a Gmail phishing page (although the URL is NOT the Gmail URL). | None. |
| **GroovyShell Server Command Execution** | This module uses the GroovyShell Server interface (default port 6789) to execute operating system commands.  The target address can be on the hooked browser's subnet which is potentially not directly accessible from the Internet.  The results of the commands are not returned to BeEF.  Note: Spaces in the command are not supported. | None. |
| **HP uCMDB 9.0x add user CSRF** | This module attempts to add additional users to the HP uCMDB (universal configuration management database). For more information please refer to  http://bmantra.blogspot.com/2012/10/hp-ucmdb-jmx-console-csrf.html | None. |
| **Hijack Opener Window** | This module abuses window.location.opener to hijack the opening window, replacing it with a BeEF hook and 100% * 100% iframe containing the referring web page. Note that the iframe will be blank if the origin makes use of a restrictive X-Frame-Origin directive.  This attack will only work if the opener did not make use of the  noopener  and  noreferrer  directives. Refer to  Target=_blank - the most underestimated vulnerability ever  for more information. | Close tab/window. Check for residual pop-unders. |
| **Hook Default Browser** | This module will use a PDF to attempt to hook the default browser (assuming it isn't currently hooked).   Normally, this will be IE but it will also work when Chrome is set to the default. When executed, the hooked browser will load a PDF and use that to start the default browser. If successful another browser will appear in the browser tree. | None. |
| **IMAP** | Using Inter-protocol Communication (IPEC) zombie browser will send commands to an IMAP4 server. The target address can be on the zombie's subnet which is potentially not directly accessible from the Internet. Have in mind that browser Port Banning is denying connections to default IMAP port 143. | None. |
| **IRC NAT Pinning** | Attempts to open closed ports on statefull firewalls and attempts to create pinholes on NAT-devices.  The firewall/NAT-device must support IRC connection tracking. BeEF will automatically bind a socket on port 6667 (IRC). Then you can connect to the victims public IP on that port.  For more information, please refer to:  http://samy.pl/natpin/  . | None. |
| **IRC** | Using Inter-protocol Exploitation/Communication (IPEC) the hooked browser will connect to an IRC server, join a channel and send messages to it.  NOTE: Some IRC servers (like freenode) have implemented protections against connections from a web browser. This module is unlikely to work in those instances. | None. |
| **Identify LAN Subnets** | Discover active hosts in the internal network(s) of the hooked browser. This module works by attempting to connect to commonly used LAN IP addresses and timing the response. | None. |
| **Jboss 6.0.0M1 JMX Deploy Exploit** | Deploy a JSP reverse or bind shell (Metasploit one) using the JMX exposed deploymentFileRepository MBean of JBoss. The first request made is a HEAD one to bypass auth and deploy the malicious JSP, the second request is a GET one that triggers the reverse connection to the specified MSF listener. Remember to run the MSF multi/handler listener with java/jsp_shell_reverse_tcp as payload, in case you are using the reverse payload. | None. |
| **Jenkins Code Exec CSRF** | This module attempts to get a reverse shell from Jenkins web interface Groovy Script console. Works if the user is authenticated with console privileges or authentication is disabled. | None. |
| **Kemp LoadBalancer Command Execution** | This module exploits a remote code execution vulnerability in Kemp LoadBalancer 7.1-16. More information can be found here:  http://blog.malerisch.net/2015/04/playing-with-kemp-load-master.html | None. |
| **Keychain** | Read/CreateUpdate/Delete Keychain Elements. This module requires the PhoneGap API. | None. |
| **Lcamtuf Download** | This module will attempt to execute a lcamtuf download.  The file will be served with an alternative  Content-Disposition: attachment  header.  For more information please refer to  http://lcamtuf.blogspot.co.uk/2012/05/yes-you-can-have-fun-with-downloads.html  . | Delete downloaded files. |
| **List Contacts** | Examine device contacts. This module requires the PhoneGap API. | None. |
| **List Files** | Examine device file system. This module requires the PhoneGap API. | None. |
| **List Plugins** | Attempts to guess installed plugins. This module requires the PhoneGap API. | None. |
| **Make Skype Call (Skype)** | This module will force the browser to attempt a skype call. It will exploit the insecure handling of URL schemes  The protocol handler used will be: skype. | None. |
| **Man-In-The-Browser** | This module will use a Man-In-The-Browser attack to ensure that the BeEF hook will stay until the user leaves the domain (manually changing it in the URL bar) | Close tab/window. Check for residual pop-unders. |
| **No Sleep** | This module uses  NoSleep.js  to prevent display sleep and enable wake lock in any Android or iOS web browser. | None. |
| **Persist resume** | Persist over applications sleep/wake events. This module requires the PhoneGap API. | None. |
| **Persistence (PhoneGap)** | Insert the BeEF hook into PhoneGap's index.html (iPhone only). This module requires the PhoneGap API. | None. |
| **Ping Sweep (FF)** | Discover active hosts in the internal network of the hooked browser. It works by calling a Java method from JavaScript and does not require user interaction.  For browsers other than Firefox, use the 'Ping Sweep (Java)' module. | None. |
| **Ping Sweep (JS XHR)** | Discover active hosts in the internal network of the hooked browser using JavaScript XHR.  Note: set the IP address range to 'common' to scan a list of common LAN addresses. | None. |
| **Play Sound** | Play a sound on the hooked browser. | None. |
| **Port Scanner (Multiple Methods)** | Scan ports in a given hostname, using WebSockets, CORS and img tags. It uses the three methods to avoid blocked ports or Same Origin Policy.  Note: The user may see authentication popups in the event any of the target ports are web servers using HTTP authentication. | None. |
| **Pretty Theft** | Asks the user for their username and password using a floating div. | None. |
| **Prompt User** | Ask device user a question. This module requires the PhoneGap API. | None. |
| **QEMU Monitor 'migrate' Command Execution** | This module attempts to get a reverse shell from  QEMU monitor service  (TCP or Telnet) using the 'migrate' command.  Works only if SSL/TLS and authentication are disabled. See:  https://www.qemu.org/docs/master/system/security.html . | None. |
| **QNX QCONN Command Execution** | This module exploits a vulnerability in the qconn component of QNX Neutrino which can be abused to allow unauthenticated users to execute arbitrary commands under the context of the 'root' user.  The results of the commands are not returned to BeEF. | None. |
| **RFI Scanner** | This module scans the specified web server for ~2,500 remote file include vulnerabilities using the  fuzzdb   RFI list . Many of these vulns require the target to have register_globals enabled in the PHP config.  The scan will take about 10 minutes with the default settings. Successful exploitation results in a reverse shell. Be sure to start your shell handler on the local port specified below. | None. |
| **Raw JavaScript** | This module will send the code entered in the 'JavaScript Code' section to the selected hooked browsers where it will be executed. Code is run inside an anonymous function and the return value is passed to the framework. Multiline scripts are allowed, no special encoding is required. | None. |
| **Read Gmail** | If we are able to run in the context of mail.google.com (either by SOP bypass or other issue) then lets go read some email, grabs unread message ids from gmails atom feed, then grabs content of each message | None. |
| **Redis** | Using Inter-Protocol Exploitation/Communication (IPEC) the hooked browser will send commands to a listening Redis daemon on the target specified in the 'Target Address' input field.  The target address can be on the hooked browser's subnet which is potentially not directly accessible from the Internet.  The results of the Redis commands are not returned to BeEF.  Note: Use '\n' to separate Redis commands and '\\n' for new lines. | None. |
| **Remove Hook Element** | This module removes the BeEF hook script element from the hooked page, but the underlying BeEF DOM object remains. | None. |
| **Replace Videos (Fake Plugin)** | Replaces an object selected with jQuery (all embed tags by default) with an image advising the user to install a missing plugin. If the user clicks the image they will be prompted to download a file from the specified URL. | None. |
| **Resource Exhaustion DoS** | This module attempts to exhaust system resources rendering the browser unusable. | None. |
| **Return Ascii Chars** | This module will return the set of ascii chars. | None. |
| **Return Image** | This module will test returning a PNG image as a base64 encoded string. The image should be rendered in the BeEF web interface. | None. |
| **Shell Shock (CVE-2014-6271)** | Attempt to use vulnerability CVE-2014-627 to execute arbitrary code. The default command attempts to get a reverse shell. Note: Set the LHOST and LPORT. | None. |
| **Shell Shock Scanner (Reverse Shell)** | This module attempts to get a reverse shell on the specified web server, blindly, by requesting ~400 potentially vulnerable CGI scripts. Each CGI is requested with a shellshock payload in the 'Accept' HTTP header. The list of CGI scripts was taken from  Shocker .  The scan will take about 2 minutes with the default settings. Successful exploitation results in a reverse shell. Be sure to start your shell handler on the local port specified below. | None. |
| **Simple Hijacker** | Hijack clicks on links to display what you want. | None. |
| **Skype iPhone XSS Steal Contacts** | This module will steal iPhone contacts using a Skype XSS vuln. | None. |
| **Spoof Address Bar (data URL)** | This module redirects the browser to a legitimate looking URL with a ''data'' scheme, such as ''data:text/html,http://victim.com'', with a BeEF hook and a user-specified URL in a 100% x 100% iframe. | None. |
| **Spyder Eye** | This module takes a picture of the victim's browser window. | None. |
| **Start Recording Audio** | Start recording audio. This module requires the PhoneGap API. | None. |
| **Stop Recording Audio** | Stop recording audio. This module requires the PhoneGap API. | None. |
| **TabNabbing** | This module redirects to the specified URL after the tab has been inactive for a specified amount of time. | None. |
| **Test CORS Request** | Test the beef.net.cors.request function by retrieving a URL. | None. |
| **Test HTTP Redirect** | Test the HTTP 'redirect' handler. | None. |
| **Test JS variable passing** | Test for JS variable passing from another BeEF's script via Window object | None. |
| **Test Network Request** | Test the beef.net.request function by retrieving a URL. | None. |
| **Test Returning Results** | This module will return a string of the specified length. | None. |
| **Test beef.debug()** | Test the 'beef.debug()' function. This function wraps 'console.log()' | None. |
| **Text to Voice** | Convert text to mp3 and play it on the hooked browser. Note: this module requires Lame and eSpeak to be installed. | None. |
| **Track Physical Movement** | This module will track the physical movement of the user's device. Ported from  user.activity  by @KrauseFx. | None. |
| **UnBlockUI** | This module removes all jQuery BlockUI dialogs. | None. |
| **Unhook** | This module removes the BeEF hook from the hooked page. | None. |
| **Upload File** | Upload files from device to a server of your choice. This module requires the PhoneGap API. | None. |
| **VTiger CRM Upload Exploit** | This module demonstrates chained exploitation. It will upload and execute a reverse shell. The vulnerability is exploited in the CRM  vtiger 5.0.4  The default PHP requires a listener, so don't forget to start one, for example: nc -l 8888. | None. |
| **WAN Emulator Command Execution** | Attempts to get a reverse root shell on a WAN Emulator server. Tested on version 2.3 however other versions are likely to be vulnerable. | None. |
| **Webcam (Flash)** | This module will show the Adobe Flash 'Allow Webcam' dialog to the user. The user has to click the allow button, otherwise this module will not return pictures. The title/text to convince the user can be customised. You can customise how many pictures you want to take and in which interval (default will take 20 pictures, 1 picture per second). The picture is sent as a base64 encoded JPG string. | None. |
| **Webcam Permission Check** | This module will check to see if the user has allowed the BeEF domain (or all domains) to access the Camera and Mic with Flash. This module is transparent and should not be detected by the user (ie. no popup requesting permission will appear) | None. |
| **WordPress Add User** | Adds a WordPress User. No email will be sent to the email address entered, and weak password are allowed. | None. |
| **WordPress Current User Info** | Get the current logged in user information (such as username, email etc) | None. |
| **WordPress Upload RCE Plugin** | This module attempts to upload and activate a malicious wordpress plugin, which will be hidden from the plugins list in the dashboard. Afterwards, the URI to trigger is: http://vulnerable-wordpress.site/wp-content/plugins/beefbind/beefbind.php,  and the command to execute can be send by a POST-parameter named 'cmd', with a 'BEEF' header containing the value of the auth_key option. However, there are more stealthy ways to send the POST request to execute the command, depending on the target. CORS headers have been added to allow bidirectional crossorigin communication. | None. |
| **Wordpress Add Administrator** | This module stealthily adds a Wordpress administrator account | Close tab/window. Check for residual pop-unders. |
| **Wordpress Post-Auth RCE** | This module attempts to upload and activate a malicious wordpress plugin.  Afterwards, the URI to trigger it is: http://vulnerable-wordpress.site/wordpress/wp-content/plugins/beefbind/beefbind.php.  The command to execute can be send by a POST-parameter named 'cmd'.  CORS headers have been added to allow bidirectional crossorigin communication. | None. |
| **Zenoss 3.x Add User CSRF** | Attempts to add a user to a Zenoss Core 3.x server. | None. |
| **Zenoss 3.x Command Execution** | Attempts to get a reverse shell on a Zenoss 3.x server. Valid credentials are required. | None. |
| **iFrame Event Key Logger** | Creates a 100% by 100% iFrame overlay with event logging. The content of the overlay is set in the 'iFrame Src' option. | None. |
| **ruby-nntpd Command Execution** | This module uses the 'eval' verb in ruby-nntpd 0.01dev (default port 1119) to execute operating system commands.  The target address can be on the hooked browser's subnet which is potentially not directly accessible from the Internet.  The results of the commands are not returned to BeEF. | None. |

### 3.2 Secondary Test List (Other Modern Browsers)

Test these modules **only if they cannot be tested in Firefox**. Use Chrome, Safari, or Edge.

| Module Name | Instructions / Description | Cleanup Needed |
| :--- | :--- | :--- |
| **DNS Rebinding** | dnsrebind | None. |
| **Detect Evernote Web Clipper** | This module checks if the Evernote Web Clipper extension is installed and active. | None. |
| **Execute On Tab** | Open a new tab and execute the Javascript code on it. The Chrome Extension needs to have the 'tabs' permission, as well as access to the domain. | None. |
| **Fake Evernote Web Clipper Login** | Displays a fake Evernote Web Clipper login dialog. | None. |
| **Fake LastPass** | Displays a fake LastPass user dialog. | None. |
| **Get All Cookies** | Steal cookies, even HttpOnly cookies, providing the hooked extension has cookies access. If a URL is not specified then  all  cookies are returned (this can be a lot!) | Clear browser cookies. |
| **Grab Google Contacts** | Attempt to grab the contacts of the currently logged in Google account, exploiting the export to CSV feature. | None. |
| **Hook Microsoft Edge** | This module will use the 'microsoft-edge:' protocol handler to attempt to hook Microsoft Edge (assuming it isn't currently hooked).  Note: the user will be prompted to open Microsoft Edge. | None. |
| **Inject BeEF** | Attempt to inject the BeEF hook on all the available tabs. | None. |
| **JSONP Service Worker** | This module will exploit an unfiltered callback parameter in a JSONP endpoint (of the same domain compromized) to ensure that BeEF will hook every time the user revisits the domain | Close tab/window. Check for residual pop-unders. |
| **Local File Theft** | JavaScript may have filesystem access if we are running from a local resource and using the file:// scheme. This module checks common locations and cheekily snaches anything it finds. Shamelessly plagurised from http://kos.io/xsspwn. To test this module save the BeEF hook page locally and open in Safari from the your localfile system. | None. |
| **Make Telephone Call** | This module will force the browser to attempt a telephone call in iOS. It will exploit the insecure handling of URL schemes in iOS.  The protocol handler used will be: tel | None. |
| **Ping Sweep (Java)** | Discover active hosts in the internal network of the hooked browser. Same logic of the Ping Sweep module, but using an unsigned Java applet to work in browsers other than Firefox.  For Firefox, use the normal PingSweep module. | None. |
| **Screenshot** | Screenshots current tab the user is in, screenshot returned as base64d data for a dataurl | None. |
| **Send Gvoice SMS** | Send a text message (SMS) through the Google Voice account of the victim, if she's logged in to Google. | None. |
| **Webcam HTML5** | This module will leverage HTML5s WebRTC to capture webcam images. Only tested in Chrome, and it will display a dialog to ask if the user wants to enable their webcam.  If no image shown choose smaller image size | None. |
| **iFrame Sniffer** | This module attempts to do framesniffing (aka Leaky Frame).  It will append leakyframe.js (written by Paul Stone) to the DOM and check for specified anchors to be present on a URL. For more information, refer to  https://www.contextis.com/en/blog/framesniffing-against-sharepoint-and-linkedin | None. |

## 4. Expected Results and Pass/Fail Criteria

| Result Type | Pass Criteria | Fail Criteria |
| :--- | :--- | :--- |
| **Execution** | Marked as "Executed" with a returned value. | "Error" status or no response after a reasonable timeout. |
| **Data Quality** | Correct and readable information returned. | Empty results or garbled text. |
| **UI Impact** | Visual modules (e.g., fake prompts) render correctly. | Visual artifacts are broken or non-functional. |

## 5. Simplified Test Log Template

```markdown
| Module Name | Hooked Browser | Result | Notes |
| :--- | :--- | :--- | :--- |
| browser_fingerprinting | Firefox (Ubuntu) | PASS | Correctly identified FF 115 |
| port_scanner | Chrome (Ubuntu) | PASS | Found open port 80 on gateway |
```
