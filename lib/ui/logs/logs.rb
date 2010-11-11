module BeEF
module UI

class Logs < BeEF::HttpController
  
  def initialize
    super({
      'paths' => {
        'select_all_logs' => '/all.json',
        'select_zombie_logs' => '/zombie.json'
      }
    })
  end
  
  # Selects logs in the database and returns them in a JSON format.
  def select_all_logs

    # get params
    start = @params['start'].to_i || 0
    limit = @params['limit'].to_i || 25
    raise WEBrick::HTTPStatus::BadRequest, "start less than 0" if start < 0
    raise WEBrick::HTTPStatus::BadRequest, "limit less than 1" if limit < 1
    raise WEBrick::HTTPStatus::BadRequest, "limit less than or equal to start" if limit <= start

    # get log
    log = BeEF::Models::Log.all(:offset => start, :limit => limit, :order => [:date.desc])
    raise WEBrick::HTTPStatus::BadRequest, "log is nil" if log.nil?
    
    # format log
    @body = logs2json(log)

  end
  
  # Selects the logs for a zombie
  def select_zombie_logs
    
    # get params
    session = @params['session'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "session is nil" if session.nil?
    start = @params['start'].to_i || 0
    limit = @params['limit'].to_i || 25
    raise WEBrick::HTTPStatus::BadRequest, "start less than 0" if start < 0
    raise WEBrick::HTTPStatus::BadRequest, "limit less than 1" if limit < 1
    raise WEBrick::HTTPStatus::BadRequest, "limit less than or equal to start" if limit <= start

    zombie = BeEF::Models::Zombie.first(:session => session)
    raise WEBrick::HTTPStatus::BadRequest, "zombie is nil" if zombie.nil?
    raise WEBrick::HTTPStatus::BadRequest, "zombie.id is nil" if zombie.id.nil?
    zombie_id = zombie.id

    # get log
    log = BeEF::Models::Log.all(:offset => start, :limit => limit, :zombie_id => zombie_id, :order => [:date.desc])
    raise WEBrick::HTTPStatus::BadRequest, "log is nil" if log.nil?
    
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
