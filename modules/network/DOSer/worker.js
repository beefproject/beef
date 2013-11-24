var url = "";
var delay = 0;
var method = "";
var post_data = "";
var counter = 0;

onmessage = function (oEvent) {
 url = oEvent.data['url'];
 delay = oEvent.data['delay'];
 method = oEvent.data['method'];
 post_data = oEvent.data['post_data'];
 doRequest();
};

function noCache(u){
 var result = "";
 if(u.indexOf("?") > 0){
  result = "&" + Date.now() + Math.random();
 }else{
  result = "?" + Date.now() + Math.random();
 }
 return result;
}

function doRequest(){
 setInterval(function(){

  var xhr = new XMLHttpRequest();
  xhr.open(method, url + noCache(url));
  xhr.setRequestHeader('Accept','*/*');
  xhr.setRequestHeader("Accept-Language", "en");
  if(method == "POST"){
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.send(post_data);
  }else{
    xhr.send(null);
  }
  counter++;

 },delay);

 setInterval(function(){
 postMessage("Requests sent: " + counter);
 },10000);
}