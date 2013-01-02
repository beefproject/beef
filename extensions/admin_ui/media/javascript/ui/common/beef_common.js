//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*!
 * BeEF Web UI commons
 */

if(typeof beefwui === 'undefined' && typeof window.beefwui === 'undefined') {

    var BeefWUI = {

        rest_token: "",

        /**
         * Retrieve the token needed to call the RESTful API.
         * This is obviously a post-auth call.
         */
        get_rest_token: function() {
            if(this.rest_token.length == 0){
                var url = "/ui/modules/getRestfulApiToken.json";
                jQuery.ajax({
                    contentType: 'application/json',
                    dataType: 'json',
                    type: 'GET',
                    url: url,
                    async: false,
                    processData: false,
                    success: function(data){
                        beefwui.rest_token = data.token;
                    },
                    error: function(){
                        beefwui.rest_token = "";
                    }
                });
            }
            return this.rest_token;
        }
    };

    window.beefwui = BeefWUI;
}
