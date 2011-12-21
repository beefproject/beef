// 
// make the phone beep
//
beef.execute(function() {
    navigator.notification.beep(1);
    beef.net.send("<%= @command_url %>", <%= @command_id %>, 'Beeped');
});
