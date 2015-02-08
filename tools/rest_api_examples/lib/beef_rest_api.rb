class BeefRestAPI

# initialize
def initialize proto = 'http', host = '127.0.0.1', port = '3000', user = 'beef', pass = 'beef'
  @user = user
  @pass = pass
  @url = "#{proto}://#{host}:#{port}/api/"
  @token = nil
end

################################################################################
### BeEF core API
################################################################################

# authenticate and get API token
def auth
  print_verbose "Retrieving authentication token"
  begin
  response = RestClient.post "#{@url}admin/login",
    { 'username' => "#{@user}",
      'password' => "#{@pass}" }.to_json,
    :content_type => :json,
    :accept => :json
  result = JSON.parse(response.body)
  @token = result['token']
  print_good "Retrieved RESTful API token: #{@token}"
  rescue => e
    print_error "Could not retrieve RESTful API token: #{e.message}"
  end
end

# get BeEF version
def version
  begin
    response = RestClient.get "#{@url}server/version", {:params => {:token => @token}}
    result = JSON.parse(response.body)
    print_good "Retrieved BeEF version: #{result['version']}"
    result['version']
  rescue => e
    print_error "Could not retrieve BeEF version: #{e.message}"
  end
end

# get online hooked browsers
def online_browsers
  begin
    print_verbose "Retrieving online browsers"
    response = RestClient.get "#{@url}hooks", {:params => {:token => @token}}
    result = JSON.parse(response.body)
    browsers = result["hooked-browsers"]["online"]
    print_good "Retrieved online browser list [#{browsers.size} online]"
    browsers
  rescue => e
    print_error "Could not retrieve browser details: #{e.message}"
  end
end

# get hooked browser details by session
def browser_details session
  begin
    print_verbose "Retrieving details for hooked browser [session: #{session}]"
    response = RestClient.get "#{@url}hooks/#{session}", {:params => {:token => @token}}
    details = JSON.parse(response.body)
    print_good "Retrieved browser details for #{details['IP']}"
    details
  rescue => e
    print_error "Could not retrieve browser details: #{e.message}"
  end
end

# get BeEF logs
def logs
  begin
    print_verbose "Retrieving logs"
    response = RestClient.get "#{@url}logs", {:params => {:token => @token}}
    logs = JSON.parse(response.body)
    print_good "Retrieved #{logs['logs_count']} log entries"
    logs
  rescue => e
    print_error "Could not retrieve logs: #{e.message}"
  end
end

# get hooked browser logs by session
def browser_logs session
  begin
    print_verbose "Retrieving browser logs [session: #{session}]"
    response = RestClient.get "#{@url}logs/#{session}", {:params => {:token => @token}}
    logs = JSON.parse(response.body)
    print_good "Retrieved #{logs['logs'].size} browser logs"
    logs
  rescue => e
    print_error "Could not retrieve browser logs: #{e.message}"
  end
end

################################################################################
### command module API
################################################################################

# get command module categories
def categories
  begin
    print_verbose "Retrieving module categories"
    response = RestClient.get "#{@url}categories", {:params => {:token => @token}}
    categories = JSON.parse(response.body)
    print_good "Retrieved #{categories.size} module categories"
    categories
  rescue => e
    print_error "Could not retrieve logs: #{e.message}"
  end
end

# get command modules
def modules
  begin
    print_verbose "Retrieving modules"
    response = RestClient.get "#{@url}modules", {:params => {:token => @token}}
    @modules = JSON.parse(response.body)
    print_good "Retrieved #{@modules.size} available command modules"
    @modules
  rescue => e
    print_error "Could not retrieve modules: #{e.message}"
  end
end

# get module id by module short name
def get_module_id mod_name
  print_verbose "Retrieving id for module [name: #{mod_name}]"
  @modules.each do |mod|
    # normal modules
    if mod_name.capitalize == mod[1]["class"]
      return mod[1]["id"]
      break
      # metasploit modules
    elsif mod[1]["class"] == "Msf_module" && mod_name.capitalize == mod[1]["name"]
      return mod[1]["id"]
      break
    end
  end
  nil
end

# get command module details
def module_details id
  begin
    print_verbose "Retrieving details for command module [id: #{id}]"
    response = RestClient.get "#{@url}modules/#{id}", {:params => {:token => @token}}
    details = JSON.parse(response.body)
    print_good "Retrieved details for module [#{details['name']}]"
    details
  rescue => e
    print_error "Could not retrieve modules: #{e.message}"
  end
end

# execute module
def execute_module session, mod_id, options
  print_verbose "Executing module [id: #{mod_id}, #{options}]"
  begin
    response = RestClient.post "#{@url}modules/#{session}/#{mod_id}?token=#{@token}", options.to_json,
      :content_type => :json,
      :accept => :json
    result = JSON.parse(response.body)
    if result['success'] ==  'true'
      print_good "Executed module [id: #{mod_id}]"
    else
      print_error "Could not execute module [id: #{mod_id}]"
    end
    result
  rescue => e
    print_error "Could not start payload handler: #{e.message}"
  end
end


################################################################################
### Metasploit API
################################################################################

# get metasploit version
def msf_version
  begin
    response = RestClient.get "#{@url}msf/version", {:params => {:token => @token}}
    result = JSON.parse(response.body)
    version = result['version']['version']
    print_good "Retrieved Metasploit version: #{version}"
    version
  rescue => e
    print_error "Could not retrieve Metasploit version: #{e.message}"
  end
end

# get metasploit jobs
def msf_jobs
  begin
    response = RestClient.get "#{@url}msf/jobs", {:params => {:token => @token}}
    result = JSON.parse(response.body)
    jobs = result['jobs']
    print_good "Retrieved job list [#{jobs.size} jobs]"
    jobs
  rescue => e
    print_error "Could not retrieve Metasploit job list: #{e.message}"
  end
end

# get metasploit job info
def msf_job_info id
  begin
    response = RestClient.get "#{@url}msf/job/#{id}/info", {:params => {:token => @token}}
    details = JSON.parse(response.body)
    print_good "Retrieved job information [id: #{id}]"
    details
  rescue => e
    print_error "Could not retrieve job info: #{e.message}"
  end
end

# start metasploit payload handler
def msf_handler options
  print_verbose "Starting Metasploit payload handler [#{options}]"
  begin
    response = RestClient.post "#{@url}msf/handler?token=#{@token}", options.to_json,
      :content_type => :json,
      :accept => :json
    result = JSON.parse(response.body)
    job_id = result['id']
    if job_id.nil?
      print_error "Could not start payload handler: Job id is nil"
    else
      print_good "Started payload handler [id: #{job_id}]"
    end
    job_id
  rescue => e
    print_error "Could not start payload handler: #{e.message}"
  end
end

# stop metasploit job
def msf_job_stop id
  print_verbose "Stopping Metasploit job [id: #{id}]"
  begin
    response = RestClient.get "#{@url}msf/job/#{id}/stop", {:params => {:token => @token}}
    result = JSON.parse(response.body)
    if result['success'].nil?
      print_error "Could not stop Metasploit job [id: #{id}]: No such job ?"
    else
      print_good "Stopped job [id: #{id}]"
    end
    result
  rescue => e
    print_error "Could not stop Metasploit job [id: #{id}]: #{e.message}"
  end
end


################################################################################
### Network API
################################################################################

# get all network hosts
def network_hosts_all
  begin
    print_verbose "Retrieving all network hosts"
    response = RestClient.get "#{@url}network/hosts", {:params => {:token => @token}}
    details = JSON.parse(response.body)
    print_good "Retrieved #{details['count']} network hosts"
    details
  rescue => e
    print_error "Could not retrieve network hosts: #{e.message}"
  end
end

# get all network services
def network_services_all
  begin
    print_verbose "Retrieving all network services"
    response = RestClient.get "#{@url}network/services", {:params => {:token => @token}}
    details = JSON.parse(response.body)
    print_good "Retrieved #{details['count']} network services"
    details
  rescue => e
    print_error "Could not retrieve network services: #{e.message}"
  end
end

# get network hosts by session
def network_hosts session
  begin
    print_verbose "Retrieving network hosts for hooked browser [session: #{session}]"
    response = RestClient.get "#{@url}network/hosts/#{session}", {:params => {:token => @token}}
    details = JSON.parse(response.body)
    print_good "Retrieved #{details['count']} network hosts"
    details
  rescue => e
    print_error "Could not retrieve network hosts: #{e.message}"
  end
end

# get network services by session
def network_services session
  begin
    print_verbose "Retrieving network services for hooked browser [session: #{session}]"
    response = RestClient.get "#{@url}network/services/#{session}", {:params => {:token => @token}}
    details = JSON.parse(response.body)
    print_good "Retrieved #{details['count']} network services"
    details
  rescue => e
    print_error "Could not retrieve network services: #{e.message}"
  end
end

################################################################################
### DNS API
################################################################################

# get ruleset
def dns_ruleset
  begin
    print_verbose "Retrieving DNS ruleset"
    response = RestClient.get "#{@url}dns/ruleset", {:params => {:token => @token}}
    details = JSON.parse(response.body)
    print_good "Retrieved #{details['count']} rules"
    details
  rescue => e
    print_error "Could not retrieve DNS ruleset: #{e.message}"
  end
end

################################################################################
### WebRTC
################################################################################

# get webrtc status for hooked browser by session
def webrtc_status id
  begin
    print_verbose "Retrieving status for hooked browser [id: #{id}]"
    response = RestClient.get "#{@url}webrtc/status/#{id}", {:params => {:token => @token}}
    details = JSON.parse(response.body)
    print_good "Retrieved status for hooked browser [id: #{id}]"
    details
  rescue => e
    print_error "Could not retrieve status: #{e.message}"
  end
end

end
