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

## 2. Testing Strategy: Grouped Execution

1.  **Phase 1: Common Infrastructure (Firefox)**: Start here. These modules work on the standard Linux/Firefox setup provided by the VM and don't require external devices or specific insecure software.
2.  **Phase 2: Specific Requirements (Firefox)**: Test these if you have the specific requirements (e.g., Android device, Flash plugin, specific vulnerable server running).
3.  **Phase 3: Other Browsers**: Use Chrome/Edge/Safari for modules that explicitly don't work in Firefox.

## 3. Module Inventory and Instructions

### 3.1 Phase 1: Common Infrastructure (Standard Firefox)

Test these modules using **Firefox** on your local Linux VM. They leverage standard browser features or the BeEF infrastructure itself.

| Status | Module Name | Instructions / Description | Cleanup Needed | Comments |
| :---: | :--- | :--- | :--- | :--- |
| [x] | **Alert Dialog** | 1. Configure: `Title`, `Message`, `Button name`<br>2. Click Execute.<br><br>_Show user an alert_ | None. | |
| [x] | **BlockUI Modal Dialog** | 1. Configure: `Message`, `Timeout (s)`<br>2. Click Execute.<br><br>_This module uses jQuery  BlockUI  to block the window and display a message._ | None. | |
| [x] | **Clickjacking** | 1. Configure: `iFrame Src`, `Security restricted (IE)`, `Sandbox`...<br>2. Click Execute.<br><br>_Allows you to perform basic multi-click clickjacking._ | None. | |
| [x] | **Confirm Close Tab** | 1. Configure: `Confirm text`, `Create a pop-under window on user\`<br>2. Click Execute.<br><br>_Shows a confirm dialog to the user when they try to close a tab._ | Close tab/window. Check for residual pop-unders. | a window pops up, but the text not as per command |
| [NEXT ] | **Create Foreground iFrame** | 1. Click Execute.<br><br>_Rewrites all links on the webpage to spawn a 100% by 100% iFrame with a source relative to the selected link._ | Close tab/window. Check for residual pop-unders. | |
| [ ] | **Create Invisible Iframe** | 1. Configure: `URL`<br>2. Click Execute.<br><br>_Creates an invisible iframe._ | None. | |
| [ ] | **Create Pop Under** | 1. Configure: `Clickjack`<br>2. Click Execute.<br><br>_This module creates a new discreet pop under window with the BeEF hook included._ | Close tab/window. Check for residual pop-unders. | |
| [ ] | **Cross-Origin Scanner (CORS)** | 1. Configure: `Scan IP range (C class)`, `Ports`, `Workers`...<br>2. Click Execute.<br><br>_Scan an IP range for web servers which allow cross-origin requests using CORS._ | None. | |
| [ ] | **DNS Enumeration** | 1. Configure: `DNS (comma separated)`, `Timeout (ms)`<br>2. Click Execute.<br><br>_Discover DNS hostnames within the victim's network using dictionary and timing attacks._ | None. | |
| [ ] | **DNS Tunnel** | 1. Configure: `Domain`, `Data to send`<br>2. Click Execute.<br><br>_This module sends data one way over DNS, client to server only._ | None. | |
| [ ] | **DNS Tunnel** | 1. Configure: `Domain`, `Message`, `Wait between requests (ms)`<br>2. Click Execute.<br><br>_This module sends data one way over DNS. Message split into chunks._ | None. | |
| [ ] | **DNS Tunnel: Server-to-Client** | 1. Configure: `Payload Name`, `Zone`, `Message`<br>2. Click Execute.<br><br>_This module retrieves data sent by the server over DNS covert channel._ | None. | |
| [ ] | **DOSer** | 1. Configure: `URL`, `Delay between requests (ms)`, `HTTP Method`...<br>2. Click Execute.<br><br>_Do infinite GET or POST requests to a target._ | None. | |
| [ ] | **Detect Antivirus** | 1. Click Execute.<br><br>_This module detects the javascript code automatically included by some AVs._ | None. | |
| [ ] | **Detect Burp** | 1. Click Execute.<br><br>_This module checks if the browser is using Burp._ | None. | |
| [ ] | **Detect Extensions** | 1. Click Execute.<br><br>_This module detects extensions installed in Google Chrome and Mozilla Firefox._ | Remove installed extension if any. | |
| [ ] | **Detect FireBug** | 1. Click Execute.<br><br>_This module checks if the Mozilla Firefox Firebug extension is being use._ | None. | |
| [ ] | **Detect LastPass** | 1. Click Execute.<br><br>_This module checks if the LastPass extension is installed and active._ | None. | |
| [ ] | **Detect MIME Types** | 1. Click Execute.<br><br>_This module retrieves the browser's supported MIME types._ | None. | |
| [ ] | **Detect Popup Blocker** | 1. Click Execute.<br><br>_Detect if popup blocker is enabled._ | None. | |
| [ ] | **Detect Toolbars** | 1. Click Execute.<br><br>_Detects which browser toolbars are installed._ | None. | |
| [ ] | **Detect Tor** | 1. Configure: `What Tor resource to request`, `Detection timeout`<br>2. Click Execute.<br><br>_This module will detect if the zombie is currently using Tor._ | None. | |
| [ ] | **ETag Tunnel: Server-to-Client** | 1. Configure: `Payload Name`, `Message`<br>2. Click Execute.<br><br>_This module sends data from server to client using ETag HTTP header._ | None. | |
| [ ] | **Fetch Port Scanner** | 1. Configure: `Scan IP or Hostname`, `Specific port(s) to scan`<br>2. Click Execute.<br><br>_Uses fetch to test the response in order to determine if a port is open or not._ | None. | |
| [ ] | **Fingerprint Browser (PoC)** | 1. Click Execute.<br><br>_This module attempts to fingerprint the browser type and version._ | None. | |
| [ ] | **Fingerprint Browser** | 1. Click Execute.<br><br>_This module attempts to fingerprint the browser and browser capabilities using  FingerprintJS2._ | None. | |
| [ ] | **Fingerprint Local Network** | 1. Configure: `Scan IP range (C class)`, `Ports to test`, `Workers`...<br>2. Click Execute.<br><br>_Discover devices and applications in the victim's Local Area Network._ | None. | |
| [ ] | **Fingerprint Routers** | 1. Click Execute.<br><br>_This module attempts to discover network routers on the local network._ | None. | |
| [ ] | **Get Geolocation (API)** | 1. Click Execute.<br><br>_This module will retrieve the physical location using the HTML5 geolocation API._ | None. | |
| [ ] | **Get HTTP Servers (Favicon)** | 1. Configure: `Remote IP(s)`, `Ports`, `Workers`...<br>2. Click Execute.<br><br>_Attempts to discover HTTP servers on the specified IP range by checking for a favicon._ | None. | |
| [ ] | **Get Internal IP WebRTC** | 1. Click Execute.<br><br>_Retrieve the internal (behind NAT) IP address of the victim machine using WebRTC._ | None. | |
| [ ] | **Get Protocol Handlers** | 1. Configure: `Link Protocol(s)`, `Link Address`<br>2. Click Execute.<br><br>_This module attempts to identify protocol handlers present on the hooked browser._ | None. | |
| [ ] | **Get Proxy Servers (WPAD)** | 1. Click Execute.<br><br>_This module retrieves proxy server addresses for the zombie browser's local network using WPAD._ | None. | |
| [ ] | **Get Visited Domains** | 1. Configure: `Specify custom page to check`<br>2. Click Execute.<br><br>_This module will retrieve rapid history extraction through non-destructive cache timing._ | None. | |
| [ ] | **Hijack Opener Window** | 1. Click Execute.<br><br>_This module abuses window.location.opener to hijack the opening window._ | Close tab/window. Check for residual pop-unders. | |
| [ ] | **Hook Default Browser** | 1. Configure: `URL`<br>2. Click Execute.<br><br>_This module will use a PDF to attempt to hook the default browser._ | None. | |
| [ ] | **Identify LAN Subnets** | 1. Configure: `Timeout for each request (ms)`<br>2. Click Execute.<br><br>_Discover active hosts in the internal network(s) of the hooked browser._ | None. | |
| [ ] | **Lcamtuf Download** | 1. Configure: `Real File Path`, `Malicious File Path`, `Run Once`<br>2. Click Execute.<br><br>_This module will attempt to execute a lcamtuf download._ | Delete downloaded files. | |
| [ ] | **Link Rewrite** | 1. Click Execute.<br><br>_This module will rewrite all the href attributes of all matched links._ | None. | |
| [ ] | **Man-In-The-Browser** | 1. Click Execute.<br><br>_This module will use a Man-In-The-Browser attack to ensure that the BeEF hook will stay._ | Close tab/window. Check for residual pop-unders. | |
| [ ] | **No Sleep** | 1. Click Execute.<br><br>_This module uses  NoSleep.js  to prevent display sleep and enable wake lock in any Android or iOS web browser._ | None. | |
| [ ] | **Ping Sweep (FF)** | 1. Configure: `Scan IP range (C class or IP)`, `Timeout (ms)`, `Delay between requests (ms)`<br>2. Click Execute.<br><br>_Discover active hosts in the internal network of the hooked browser._ | None. | |
| [ ] | **Ping Sweep (JS XHR)** | 1. Configure: `Scan IP range (C class)`, `Workers`<br>2. Click Execute.<br><br>_Discover active hosts in the internal network of the hooked browser using JavaScript XHR._ | None. | |
| [ ] | **Play Sound** | 1. Configure: `Sound File Path`<br>2. Click Execute.<br><br>_Play a sound on the hooked browser._ | None. | |
| [ ] | **Port Scanner (Multiple Methods)** | 1. Configure: `Scan IP or Hostname`, `Specific port(s) to scan`, `Closed port timeout (ms)`...<br>2. Click Execute.<br><br>_Scan ports in a given hostname, using WebSockets, CORS and img tags._ | None. | |
| [ ] | **Pretty Theft** | 1. Configure: `Dialog Type`, `Backing`, `Custom Logo (Generic only)`<br>2. Click Execute.<br><br>_Asks the user for their username and password using a floating div._ | None. | |
| [ ] | **Raw JavaScript** | 1. Configure: `Javascript Code`<br>2. Click Execute.<br><br>_Execute arbitrary JavaScript._ | None. | |
| [ ] | **Redirect Browser (Rickroll)** | 1. Click Execute.<br><br>_Overwrite the body of the page the victim is on with a full screen Rickroll._ | None. | |
| [ ] | **Redirect Browser (Standard)** | 1. Configure: `Redirect URL`<br>2. Click Execute.<br><br>_Redirect the hooked browser to the address specified._ | None. | |
| [ ] | **Redirect Browser (iFrame)** | 1. Configure: `Redirect URL`, `Title`, `Favicon`...<br>2. Click Execute.<br><br>_Creates a 100% x 100% overlaying iframe._ | None. | |
| [ ] | **Replace Videos (Fake Plugin)** | 1. Configure: `Payload URL`, `jQuery Selector`<br>2. Click Execute.<br><br>_Replaces an object selected with jQuery with an image advising the user to install a missing plugin._ | None. | |
| [ ] | **Resource Exhaustion DoS** | 1. Click Execute.<br><br>_This module attempts to exhaust system resources rendering the browser unusable._ | None. | |
| [ ] | **Return Ascii Chars** | 1. Click Execute.<br><br>_This module will return the set of ascii chars._ | None. | |
| [ ] | **Return Image** | 1. Click Execute.<br><br>_This module will test returning a PNG image as a base64 encoded string._ | None. | |
| [ ] | **Simple Hijacker** | 1. Configure: `Targetted domains`, `Template to use`<br>2. Click Execute.<br><br>_Hijack clicks on links to display what you want._ | None. | |
| [ ] | **Spoof Address Bar (data URL)** | 1. Configure: `Spoofed URL`, `Real URL`<br>2. Click Execute.<br><br>_This module redirects the browser to a legitimate looking URL with a data scheme._ | None. | |
| [ ] | **Spyder Eye** | 1. Configure: `Repeat`, `Delay`<br>2. Click Execute.<br><br>_This module takes a picture of the victim's browser window._ | None. | |
| [ ] | **TabNabbing** | 1. Configure: `URL`, `Wait (minutes)`<br>2. Click Execute.<br><br>_This module redirects to the specified URL after the tab has been inactive._ | None. | |
| [ ] | **Test CORS Request** | 1. Configure: `Method`, `URL`, `Data`<br>2. Click Execute.<br><br>_Test the beef.net.cors.request function._ | None. | |
| [ ] | **Test HTTP Redirect** | 1. Click Execute.<br><br>_Test the HTTP 'redirect' handler._ | None. | |
| [ ] | **Test JS variable passing** | 1. Configure: `Payload Name`<br>2. Click Execute.<br><br>_Test for JS variable passing._ | None. | |
| [ ] | **Test Network Request** | 1. Configure: `Scheme`, `Method`, `Domain`...<br>2. Click Execute.<br><br>_Test the beef.net.request function by retrieving a URL._ | None. | |
| [ ] | **Test Returning Results** | 1. Configure: `Times to repeat`, `String to repeat`<br>2. Click Execute.<br><br>_This module will return a string of the specified length._ | None. | |
| [ ] | **Test beef.debug()** | 1. Configure: `Debug Message`<br>2. Click Execute.<br><br>_Test the 'beef.debug()' function._ | None. | |
| [ ] | **Text to Voice** | 1. Configure: `Text`, `Language`<br>2. Click Execute.<br><br>_Convert text to mp3 and play it on the hooked browser._ | None. | |
| [ ] | **UnBlockUI** | 1. Click Execute.<br><br>_This module removes all jQuery BlockUI dialogs._ | None. | |
| [ ] | **Unhook** | 1. Click Execute.<br><br>_This module removes the BeEF hook from the hooked page._ | None. | |
| [ ] | **iFrame Event Key Logger** | 1. Configure: `iFrame Src`, `Send Back Interval (ms)`<br>2. Click Execute.<br><br>_Creates a 100% by 100% iFrame overlay with event logging._ | None. | |


### 3.2 Phase 2: Specific Requirements (Firefox)

These modules require specific devices, plugins, vulnerable software, or valid credentials to work.

#### 3.2.1 Mobile & PhoneGap
Requires an Android/iOS device or PhoneGap environment.

| Status | Module Name | Instructions / Description | Cleanup Needed | Comments |
| :---: | :--- | :--- | :--- | :--- |
| [ ] | **Alert User** | 1. Click Execute.<br><br>_Show user an alert. This module requires the PhoneGap API._ | None. | |
| [ ] | **Beep** | 1. Click Execute.<br><br>_Make the phone beep. This module requires the PhoneGap API._ | None. | |
| [ ] | **Check Connection** | 1. Click Execute.<br><br>_Find out the network connection type e.g. Wifi, 3G. This module requires the PhoneGap API._ | None. | |
| [ ] | **Detect PhoneGap** | 1. Click Execute.<br><br>_Detects if the PhoneGap API is present._ | None. | |
| [ ] | **Geolocation** | 1. Click Execute.<br><br>_Geo locate your victim. This module requires the PhoneGap API._ | None. | |
| [ ] | **Get Network Connection Type** | 1. Click Execute.<br><br>_Retrieve the network connection type (wifi, 3G, etc). Note: Android only._ | None. | |
| [ ] | **Globalization Status** | 1. Click Execute.<br><br>_Examine device local settings. This module requires the PhoneGap API._ | None. | |
| [ ] | **Keychain** | 1. Configure: `Service name`, `Key`, `Value`...<br>2. Click Execute.<br><br>_Read/CreateUpdate/Delete Keychain Elements. This module requires the PhoneGap API._ | None. | |
| [ ] | **List Contacts** | 1. Click Execute.<br><br>_Examine device contacts. This module requires the PhoneGap API._ | None. | |
| [ ] | **List Files** | 1. Configure: `Directory`<br>2. Click Execute.<br><br>_Examine device file system. This module requires the PhoneGap API._ | None. | |
| [ ] | **List Plugins** | 1. Click Execute.<br><br>_Attempts to guess installed plugins. This module requires the PhoneGap API._ | None. | |
| [ ] | **Persist resume** | 1. Click Execute.<br><br>_Persist over applications sleep/wake events. This module requires the PhoneGap API._ | None. | |
| [ ] | **Persistence (PhoneGap)** | 1. Configure: `Hook URL`<br>2. Click Execute.<br><br>_Insert the BeEF hook into PhoneGap's index.html (iPhone only). This module requires the PhoneGap API._ | None. | |
| [ ] | **Prompt User** | 1. Configure: `Title`, `Question`, `Yes`...<br>2. Click Execute.<br><br>_Ask device user a question. This module requires the PhoneGap API._ | None. | |
| [ ] | **Start Recording Audio** | 1. Configure: `File Name`<br>2. Click Execute.<br><br>_Start recording audio. This module requires the PhoneGap API._ | None. | |
| [ ] | **Stop Recording Audio** | 1. Click Execute.<br><br>_Stop recording audio. This module requires the PhoneGap API._ | None. | |
| [ ] | **Track Physical Movement** | 1. Click Execute.<br><br>_This module will track the physical movement of the user's device._ | None. | |
| [ ] | **Upload File** | 1. Configure: `Destination`, `File Path`<br>2. Click Execute.<br><br>_Upload files from device to a server of your choice. This module requires the PhoneGap API._ | None. | |

#### 3.2.2 Legacy Plugins (Flash, Java, Silverlight, etc.)
Requires the specific plugin to be installed and enabled in the browser.

| Status | Module Name | Instructions / Description | Cleanup Needed | Comments |
| :---: | :--- | :--- | :--- | :--- |
| [ ] | **Cross-Origin Scanner (Flash)** | 1. Configure: `Scan IP range (C class)`, `Ports`, `Workers`...<br>2. Click Execute.<br><br>_Scans an IP range... This module uses ContentHijacking.swf._ | None. | |
| [ ] | **Detect Foxit Reader** | 1. Click Execute.<br><br>_This module will check if the browser has Foxit Reader Plugin._ | None. | |
| [ ] | **Detect QuickTime** | 1. Click Execute.<br><br>_This module will check if the browser has Quicktime support._ | None. | |
| [ ] | **Detect RealPlayer** | 1. Click Execute.<br><br>_This module will check if the browser has RealPlayer support._ | None. | |
| [ ] | **Detect Silverlight** | 1. Click Execute.<br><br>_This module will check if the browser has Silverlight support._ | None. | |
| [ ] | **Detect Unity Web Player** | 1. Click Execute.<br><br>_Detects Unity Web Player._ | None. | |
| [ ] | **Detect VLC** | 1. Click Execute.<br><br>_This module will check if the browser has VLC plugin._ | None. | |
| [ ] | **Detect Windows Media Player** | 1. Click Execute.<br><br>_This module will check if the browser has the Windows Media Player plugin installed._ | None. | |
| [ ] | **Get Internal IP (Java)** | 1. Configure: `Number`<br>2. Click Execute.<br><br>_Retrieve the local network interface IP address of the victim machine using an unsigned Java applet._ | None. | |
| [ ] | **Get System Info (Java)** | 1. Click Execute.<br><br>_This module will retrieve basic information about the host system using an unsigned Java Applet._ | None. | |
| [ ] | **Webcam (Flash)** | 1. Configure: `Social Engineering Title`...<br>2. Click Execute.<br><br>_Shows the Adobe Flash 'Allow Webcam' dialog._ | None. | |
| [ ] | **Webcam Permission Check** | 1. Click Execute.<br><br>_Checks if user has allowed BeEF domain to access Camera/Mic with Flash._ | None. | |

#### 3.2.3 Specific Target Software / Services
Requires a specific vulnerable software or service to be running and accessible (e.g., Apache, JBoss, Printers).

| Status | Module Name | Instructions / Description | Cleanup Needed | Comments |
| :---: | :--- | :--- | :--- | :--- |
| [ ] | **Apache Cookie Disclosure** | 1. Click Execute.<br><br>_Exploits CVE-2012-0053. Requires Apache HTTP Server 2.2.0 through 2.2.21._ | Clear browser cookies. | |
| [ ] | **Apache Felix Remote Shell** | 1. Configure: `Target Host`, `Target Port`...<br>2. Click Execute.<br><br>_Attempts to get a reverse shell on an Apache Felix Remote Shell server._ | None. | |
| [ ] | **Bindshell (POSIX)** | 1. Configure: `Target Address`, `Target Port`, `Timeout (s)`...<br>2. Click Execute.<br><br>_Sends commands to a listening POSIX shell._ | None. | |
| [ ] | **Bindshell (Windows)** | 1. Configure: `Target Address`, `Target Port`, `Timeout (s)`...<br>2. Click Execute.<br><br>_Sends commands to a listening Windows shell._ | None. | |
| [ ] | **ColdFusion Directory Traversal** | 1. Configure: `Retrieve file`, `CF server OS`...<br>2. Click Execute.<br><br>_Exploits directory traversal in ColdFusion 8/9._ | None. | |
| [ ] | **Cross-Site Faxing (XSF)** | 1. Configure: `Target Address`, `Target Port`...<br>2. Click Execute.<br><br>_Sends commands to ActiveFax RAW server socket._ | None. | |
| [ ] | **Cross-Site Printing (XSP)** | 1. Configure: `Target Address`, `Target Port`...<br>2. Click Execute.<br><br>_Sends a message to a listening print port (9100)._ | None. | |
| [ ] | **Detect Airdroid** | 1. Configure: `IP or Hostname`, `Port`<br>2. Click Execute.<br><br>_Attempts to detect Airdroid application for Android running on localhost._ | None. | |
| [ ] | **Detect CUPS** | 1. Configure: `IP or Hostname`, `Port`<br>2. Click Execute.<br><br>_Attempts to detect Common UNIX Printing System (CUPS) on localhost._ | None. | |
| [ ] | **Detect Coupon Printer** | 1. Click Execute.<br><br>_Attempts to detect Coupon Printer on localhost._ | None. | |
| [ ] | **Detect Ethereum ENS** | 1. Configure: `Image resource`...<br>2. Click Execute.<br><br>_Detects if using Ethereum ENS resolvers._ | None. | |
| [ ] | **Detect Google Desktop** | 1. Click Execute.<br><br>_Attempts to detect Google Desktop running on the default port 4664._ | None. | |
| [ ] | **Detect OpenNIC DNS** | 1. Configure: `Image resource`...<br>2. Click Execute.<br><br>_Detects if using OpenNIC DNS resolvers._ | None. | |
| [ ] | **EXTRAnet Collaboration Tool** | 1. Configure: `Remote Host`, `Remote Port`...<br>2. Click Execute.<br><br>_Exploits command execution in 'admserver' component._ | None. | |
| [ ] | **Farsite X25 gateway** | 1. Configure: `HTTP(s)`, `Remote Host`...<br>2. Click Execute.<br><br>_Exploits CVE-2014-7175/7173 to execute code._ | None. | |
| [ ] | **Firephp 0.7.1 RCE** | 1. Click Execute.<br><br>_Exploit FirePHP <= 0.7.1._ | None. | |
| [ ] | **Get Wireless Keys** | 1. Click Execute.<br><br>_Retrieve wireless profiles (Windows Vista and Windows 7 only)._ | None. | |
| [ ] | **Get ntop Network Hosts** | 1. Configure: `Remote Host`, `Remote Port`<br>2. Click Execute.<br><br>_Retrieves information from ntop (unauthenticated)._ | None. | |
| [ ] | **GlassFish WAR Upload** | 1. Configure: `Host`, `Filename`...<br>2. Click Execute.<br><br>_Attempts to deploy a malicious war file on GlassFish Server 3.1.1._ | None. | |
| [ ] | **GroovyShell Server** | 1. Configure: `Remote Host`, `Remote Port`...<br>2. Click Execute.<br><br>_Uses GroovyShell Server interface to execute commands._ | None. | |
| [ ] | **HP uCMDB 9.0x add user** | 1. Configure: `Protocol`, `Host`, `Port`...<br>2. Click Execute.<br><br>_Attempts to add users to HP uCMDB._ | None. | |
| [ ] | **IBM iNotes (Extract List)** | 1. Click Execute.<br><br>_Extracts iNotes contact list._ | None. | |
| [ ] | **IBM iNotes (Flooder)** | 1. Configure: `To`, `Subject`, `Body`, `Count`...<br>2. Click Execute.<br><br>_Floods an email address from the victim's account._ | None. | |
| [ ] | **IBM iNotes (Read)** | 1. Click Execute.<br><br>_Read a note from the victim's IBM iNotes._ | None. | |
| [ ] | **IBM iNotes (Send)** | 1. Configure: `To`, `Subject`, `Body`<br>2. Click Execute.<br><br>_Sends an email from the victim's account._ | None. | |
| [ ] | **IBM iNotes (Send w/ Attachment)** | 1. Configure: `To`, `Subject`, `Body`, `File`...<br>2. Click Execute.<br><br>_Sends an email with attachment from the victim's account._ | None. | |
| [ ] | **IMAP** | 1. Configure: `IMAP Server`, `Port`, `Commands`<br>2. Click Execute.<br><br>_Sends commands to an IMAP4 server._ | None. | |
| [ ] | **IRC** | 1. Configure: `IRC Server`, `Port`, `Username`...<br>2. Click Execute.<br><br>_Connects to an IRC server and sends messages._ | None. | |
| [ ] | **IRC NAT Pinning** | 1. Configure: `Connect to`, `Private IP`, `Private Port`<br>2. Click Execute.<br><br>_Attempts to open closed ports on statefull firewalls compatible with IRC tracking._ | None. | |
| [ ] | **Jboss 6.0.0M1 JMX Deploy** | 1. Configure: `Remote Target Host`...<br>2. Click Execute.<br><br>_Deploy a JSP reverse or bind shell using JMX._ | None. | |
| [ ] | **Jenkins Code Exec CSRF** | 1. Configure: `Remote Host`, `Target URI`...<br>2. Click Execute.<br><br>_Attempts to get a reverse shell from Jenkins Groovy Script console._ | None. | |
| [ ] | **Kemp LoadBalancer RCE** | 1. Configure: `URL`, `Remote Port`...<br>2. Click Execute.<br><br>_Exploits RCE in Kemp LoadBalancer 7.1-16._ | None. | |
| [ ] | **QEMU Monitor 'migrate'** | 1. Configure: `Remote Host`, `Remote Port`...<br>2. Click Execute.<br><br>_Attempts to get a reverse shell from QEMU monitor service._ | None. | |
| [ ] | **QNX QCONN Command Exec** | 1. Configure: `Remote Host`, `Remote Port`...<br>2. Click Execute.<br><br>_Exploits vulnerability in qconn component of QNX Neutrino._ | None. | |
| [ ] | **RFI Scanner** | 1. Configure: `Target Protocol`, `Target Host`...<br>2. Click Execute.<br><br>_Scans web server for RFI vulnerabilities._ | None. | |
| [ ] | **Redis** | 1. Configure: `Target Address`, `Target Port`...<br>2. Click Execute.<br><br>_Sends commands to a listening Redis daemon._ | None. | |
| [ ] | **Shell Shock (CVE-2014-6271)** | 1. Configure: `Target`, `HTTP Method`...<br>2. Click Execute.<br><br>_Attemp to use vulnerability CVE-2014-627 to execute arbitrary code._ | None. | |
| [ ] | **Shell Shock Scanner** | 1. Configure: `HTTP Method`, `Target Protocol`...<br>2. Click Execute.<br><br>_Attempts to get a reverse shell by requesting ~400 potentially vulnerable CGI scripts._ | None. | |
| [ ] | **VTiger CRM Upload Exploit** | 1. Configure: `Target Web Server`...<br>2. Click Execute.<br><br>_Uploads and executes a reverse shell on VTiger CRM 5.0.4._ | None. | |
| [ ] | **WAN Emulator Command Exec** | 1. Configure: `Target Host`, `Target Port`...<br>2. Click Execute.<br><br>_Attempts to get a reverse root shell on a WAN Emulator server._ | None. | |
| [ ] | **WordPress Add User** | 1. Configure: `Username`, `Pwd`, `Email`...<br>2. Click Execute.<br><br>_Adds a WordPress User._ | None. | |
| [ ] | **WordPress Add Administrator** | 1. Configure: `Username:`, `Pwd:`...<br>2. Click Execute.<br><br>_Stealthily adds a Wordpress administrator account._ | Close tab/window. Check for residual pop-unders. | |
| [ ] | **WordPress Current User** | 1. Click Execute.<br><br>_Get the current logged in user information._ | None. | |
| [ ] | **WordPress Upload RCE (Plugin)** | 1. Configure: `Auth Key`<br>2. Click Execute.<br><br>_Attempts to upload and activate a malicious wordpress plugin._ | None. | |
| [ ] | **Wordpress Post-Auth RCE** | 1. Configure: `Target Web Server`<br>2. Click Execute.<br><br>_Attempts to upload and activate a malicious wordpress plugin._ | None. | |
| [ ] | **Zenoss 3.x Add User** | 1. Configure: `Zenoss web root`...<br>2. Click Execute.<br><br>_Attempts to add a user to a Zenoss Core 3.x server._ | None. | |
| [ ] | **Zenoss 3.x Command Exec** | 1. Configure: `Target Host`, `Target Port`...<br>2. Click Execute.<br><br>_Attempts to get a reverse shell on a Zenoss 3.x server._ | None. | |
| [ ] | **ruby-nntpd Command Exec** | 1. Configure: `Remote Host`, `Remote Port`...<br>2. Click Execute.<br><br>_Uses 'eval' verb in ruby-nntpd 0.01dev to execute commands._ | None. | |

#### 3.2.4 Social Engineering / Account Phishing
Requires the user to be logged into valid accounts (Gmail, Facebook, etc.) or susceptible to specific social engineering tricks.

| Status | Module Name | Instructions / Description | Cleanup Needed | Comments |
| :---: | :--- | :--- | :--- | :--- |
| [ ] | **Clippy** | 1. Configure: `Clippy image directory`...<br>2. Click Execute.<br><br>_Brings up a clippy image and asks the user to do stuff._ | None. | |
| [ ] | **Detect Social Networks** | 1. Configure: `Detection Timeout`<br>2. Click Execute.<br><br>_Detects if authenticated to GMail, Facebook and Twitter._ | None. | |
| [ ] | **Fake Flash Update** | 1. Configure: `Image`, `Payload URI`<br>2. Click Execute.<br><br>_Prompts the user to install an update to Adobe Flash Player._ | None. | |
| [ ] | **Fake Notification Bar** | 1. Configure: `Notification text`<br>2. Click Execute.<br><br>_Displays a fake notification bar._ | None. | |
| [ ] | **Fake Notification Bar (Chrome)**| 1. Configure: `URL`, `Notification text`<br>2. Click Execute.<br><br>_Displays a fake Chrome notification bar._ | None. | |
| [ ] | **Fake Notification Bar (Firefox)**| 1. Configure: `Plugin URL`, `Notification text`<br>2. Click Execute.<br><br>_Displays a fake Firefox notification bar._ | None. | |
| [ ] | **Fake Notification Bar (IE)** | 1. Configure: `URL`, `Notification text`<br>2. Click Execute.<br><br>_Displays a fake IE notification bar._ | None. | |
| [ ] | **Google Phishing** | 1. Configure: `XSS hook URI`, `Gmail logout interval`...<br>2. Click Execute.<br><br>_XSRF logout of Gmail, show phishing page._ | None. | |
| [ ] | **Read Gmail** | 1. Click Execute.<br><br>_Grabs unread message ids from gmail atom feed._ | None. | |
| [ ] | **Send Gvoice SMS** | 1. Configure: `To`, `Message`<br>2. Click Execute.<br><br>_Send a text message (SMS) through Google Voice._ | None. | |
| [ ] | **Skype iPhone XSS** | 1. Click Execute.<br><br>_Steals iPhone contacts using a Skype XSS vuln._ | None. | |

### 3.3 Phase 3: Other Browsers & Specialized Extensions

Test these modules **only if they cannot be tested in Firefox**. Use Chrome, Safari, or Edge.

| Status | Module Name | Instructions / Description | Cleanup Needed | Comments |
| :---: | :--- | :--- | :--- | :--- |
| [ ] | **DNS Rebinding** | 1. Click Execute.<br><br>_dnsrebind_ | None. | |
| [ ] | **Detect Evernote Web Clipper** | 1. Click Execute.<br><br>_This module checks if the Evernote Web Clipper extension is installed and active._ | None. | |
| [ ] | **Execute On Tab** | 1. Configure: `URL`, `Javascript`<br>2. Click Execute.<br><br>_Open a new tab and execute the Javascript code on it. Chrome Extension specific._ | None. | |
| [ ] | **Fake Evernote Web Clipper Login** | 1. Click Execute.<br><br>_Displays a fake Evernote Web Clipper login dialog._ | None. | |
| [ ] | **Fake LastPass** | 1. Click Execute.<br><br>_Displays a fake LastPass user dialog. (Often Chrome specific)_ | None. | |
| [ ] | **Get All Cookies** | 1. Configure: `Domain (e.g. http://facebook.com)`<br>2. Click Execute.<br><br>_Steal cookies, even HttpOnly cookies, providing the hooked extension has cookies access._ | Clear browser cookies. | |
| [ ] | **Get Visited URLs (Avant Browser)** | 1. Configure: `Command ID`<br>2. Click Execute.<br><br>_Attempts to retrieve history requiring 'AFRunCommand()'. Avant Browser only._ | None. | |
| [ ] | **Get Visited URLs (Old Browsers)** | 1. Configure: `URL(s)`<br>2. Click Execute.<br><br>_Detects visited URLs in older browsers._ | None. | |
| [ ] | **Grab Google Contacts** | 1. Click Execute.<br><br>_Attempt to grab the contacts... exploiting export to CSV._ | None. | |
| [ ] | **Hook Microsoft Edge** | 1. Configure: `URL`<br>2. Click Execute.<br><br>_Uses 'microsoft-edge:' protocol handler to hook Edge._ | None. | |
| [ ] | **Inject BeEF** | 1. Click Execute.<br><br>_Attempt to inject the BeEF hook on all the available tabs._ | None. | |
| [ ] | **JSONP Service Worker** | 1. Configure: `Path of the current domain`...<br>2. Click Execute.<br><br>_Exploits unfiltered callback in JSONP endpoint._ | Close tab/window. Check for residual pop-unders. | |
| [ ] | **Local File Theft** | 1. Configure: `Target file`<br>2. Click Execute.<br><br>_JavaScript may have filesystem access if using file:// scheme (Safari/Local)._ | None. | |
| [ ] | **Make Skype Call** | 1. Configure: `Number`<br>2. Click Execute.<br><br>_Forces browser to Skype call. Protocol handler `skype:`._ | None. | |
| [ ] | **Make Telephone Call** | 1. Configure: `Number`<br>2. Click Execute.<br><br>_Forces browser to telephone call (iOS). Protocol handler `tel:`._ | None. | |
| [ ] | **Ping Sweep (Java)** | 1. Configure: `Scan IP range (C class or IP)`, `Timeout (ms)`<br>2. Click Execute.<br><br>_Discover active hosts... using unsigned Java applet. (Alt for FF)_ | None. | |
| [ ] | **Screenshot** | 1. Click Execute.<br><br>_Screenshots current tab (Chrome/HTML5)._ | None. | |
| [ ] | **Webcam HTML5** | 1. Configure: `Screenshot size`<br>2. Click Execute.<br><br>_Leverage HTML5 WebRTC to capture webcam images. Only tested in Chrome._ | None. | |
| [ ] | **iFrame Sniffer** | 1. Configure: `input URL`, `anchors to check`<br>2. Click Execute.<br><br>_Attempts to do framesniffing (aka Leaky Frame)._ | None. | |
