beef.net.cors = {

  handler: "cors",

    /**
     * Response Object - used in the beef.net.request callback
     */
    response:function () {
        this.status  = null;      // 500, 404, 200, 302, etc
        this.headers = null;      // full response headers
        this.body    = null;      // full response body
    },

    /**
     * Make a cross-domain request using CORS
     *
     * @param method {String} HTTP verb ('GET', 'POST', 'DELETE', etc.)
     * @param url {String} url
     * @param data {String} request body
     * @param callback {Function} function to callback on completion
     */
    request: function(method, url, data, callback) {

    var xhr;
    var response = new this.response;

    if (XMLHttpRequest) {
        xhr = new XMLHttpRequest();

        if ('withCredentials' in xhr) {
            xhr.open(method, url, true);
            xhr.onerror = function() {
            };
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    response.headers = this.getAllResponseHeaders()
                    response.body    = this.responseText;
                    response.status  = this.status;
                    if (!!callback) {
                        if (!!response) {
                            callback(response);
                        } else { 
                            callback('ERROR: No Response. CORS requests may be denied for this resource.')
                        }
                    }
                }
            };
            xhr.send(data);
        }
    } else if (typeof XDomainRequest != "undefined") {
        xhr = new XDomainRequest();
        xhr.open(method, url);
        xhr.onerror = function() {
        };
        xhr.onload = function() {
            response.headers = this.getAllResponseHeaders()
            response.body    = this.responseText;
            response.status  = this.status;
            if (!!callback) {
                if (!!response) {
                    callback(response);
                } else {
                    callback('ERROR: No Response. CORS requests may be denied for this resource.')
                }
            }
        };
        xhr.send(data);
    } else {
        if (!!callback) callback('ERROR: Not Supported. CORS is not supported by the browser. The request was not sent.');
    }

    }

};

beef.regCmp('beef.net.cors');

