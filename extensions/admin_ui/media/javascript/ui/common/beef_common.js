//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*!
 * BeEF Web UI commons
 */

if(typeof beefwui === 'undefined' && typeof window.beefwui === 'undefined') {

    var BeefWUI = {

        rest_token: "",
        hooked_browsers: {},

        /**
         * Retrieve the token needed to call the RESTful API.
         * This is obviously a post-auth call.
         */
        get_rest_token: function() {
            if(this.rest_token.length == 0){
                var url = "<%= @base_path %>/modules/getRestfulApiToken.json";
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
        },

        /**
	     * Get hooked browser ID from session
         */
        get_hb_id: function(sess){
	    	var id = "";
	    	$jwterm.ajax({
	    		type: 'GET',
	    		url: "/api/hooks/?token=" + this.get_rest_token(),
	    		async: false,
	    		processData: false,
	    		success: function(data){                            
                    for (var k in data['hooked-browsers']['online']) {
                        if (data['hooked-browsers']['online'][k].session === sess) {
                            id = data['hooked-browsers']['online'][k].id;
                        }
                    }

                    if (id === "") {
                      for (var k in data['hooked-browsers']['offline']) {
                          if (data['hooked-browsers']['offline'][k].session === sess) {
                              id = data['hooked-browsers']['offline'][k].id;
                          }
                      }
                    }
	    		},
	    		error: function(){                                  
	    			commands_statusbar.update_fail("Error getting hb id");
	    		}
	    	});                                                     
            return id;
	    },

      /**
       * Get hooked browser info from ID
       */
      get_info_from_id: function(id) {
	    	var info = {};
	    	$jwterm.ajax({
	    		type: 'GET',
	    		url: "/api/hooks/?token=" + this.get_rest_token(),
	    		async: false,
	    		processData: false,
	    		success: function(data){                            
                    for (var k in data['hooked-browsers']['online']) {
                        if (data['hooked-browsers']['online'][k].id === id) {
                            info = data['hooked-browsers']['online'][k];
                        }
                    }

                    if ($jwterm.isEmptyObject(info)) {
                      for (var k in data['hooked-browsers']['offline']) {
                          if (data['hooked-browsers']['offline'][k].id === id) {
                              info = data['hooked-browsers']['offline'][k];
                          }
                      }
                    }
	    		},
	    		error: function(){                                  
	    			commands_statusbar.update_fail("Error getting hb ip");
	    		}
	    	});                                                     
            console.log(info);
            return info;

      },

      /**
       * Get hooked browser info from ID
       */
      get_fullinfo_from_id: function(id) {
	    	var info = {};
	    	$jwterm.ajax({
	    		type: 'POST',
	    		url: "<%= @base_path %>/panel/hooked-browser-tree-update.json",
	    		async: false,
	    		processData: false,
	    		success: function(data){                            
                    for (var k in data['hooked-browsers']['online']) {
                        if (data['hooked-browsers']['online'][k].id === id) {
                            info = data['hooked-browsers']['online'][k];
                        }
                    }

                    if ($jwterm.isEmptyObject(info)) {
                      for (var k in data['hooked-browsers']['offline']) {
                          if (data['hooked-browsers']['offline'][k].id === id) {
                              info = data['hooked-browsers']['offline'][k];
                          }
                      }
                    }
	    		},
	    		error: function(){                                  
	    			commands_statusbar.update_fail("Error getting hb ip");
	    		}
	    	});                                                     
            console.log(info);
            return info;

      }
    };

    window.beefwui = BeefWUI;
}
