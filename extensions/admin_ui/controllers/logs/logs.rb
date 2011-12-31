#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
module BeEF
module Extension
module AdminUI
module Controllers

class Logs < BeEF::Extension::AdminUI::HttpController
  
  def initialize
    super({
      'paths' => {
        '/all.json'     => method(:select_all_logs),
        '/zombie.json'  => method(:select_zombie_logs)
      }
    })
  end
  
  # Selects logs in the database and returns them in a JSON format.
  def select_all_logs

    log = BeEF::Core::Models::Log.all()
    (print_error "log is nil";return) if log.nil?
    
    # format log
    @body = logs2json(log)

  end
  
  # Selects the logs for a zombie
  def select_zombie_logs
    
    # get params
    session = @params['session'] || nil
    (print_error "session is nil";return) if session.nil?

    zombie = BeEF::Core::Models::HookedBrowser.first(:session => session)
    (print_error "zombie is nil";return) if zombie.nil?
    (print_error "zombie.id is nil";return)  if zombie.id.nil?
    zombie_id = zombie.id

    # get log
    log = BeEF::Core::Models::Log.all(:hooked_browser_id => zombie_id)
    (print_error "log is nil";return)  if log.nil?
    
    # format log
    @body = logs2json(log)
  end
  
  private
  
  # Returns a list of logs in JSON format.
  def logs2json(logs)
    logs_json = []
    count = logs.length
    output = '{success: false}'

    logs.each do |log|
      logs_json << {
        'id' => log.id.to_i,
        'date' => log.date.to_s,
        'event' => log.event.to_s,
        'type' => log.type.to_s
      }
    end
    
    # format output
    output = {'success' => 'true', 'count' => count, 'logs' => logs_json}.to_json if not logs_json.empty? 
        
    output
  end
  
end

end
end
end
end