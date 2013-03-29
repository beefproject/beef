#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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
        'type' => log.type.to_s,
        'hooked_browser_id' => log.hooked_browser_id.to_i
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