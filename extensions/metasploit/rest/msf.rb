#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Metasploit

      # This class handles the routing of RESTful API requests for Metasploit integration
      class MsfRest < BeEF::Core::Router::Router

        # Filters out bad requests before performing any routing
        before do
          @msf ||= BeEF::Extension::Metasploit::RpcClient.instance
          config = BeEF::Core::Configuration.instance

          # Require a valid API token from a valid IP address
          halt 401 unless params[:token] == config.get('beef.api_token')
          halt 403 unless BeEF::Core::Rest.permitted_source?(request.ip)

          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        # Returns version of Metasploit
        get '/version' do
          begin
            version = @msf.call('core.version')
            result = {}
            result[:version] = version
            result.to_json
          rescue StandardError => e
            print_error "Internal error while retrieving Metasploit version (#{e.message})"
            halt 500
          end
        end

        # Returns all the jobs
        get '/jobs' do
          begin
            jobs = @msf.call('job.list')
            count = jobs.size

            result = {}
            result[:count] = count
            result[:jobs] = jobs
            result.to_json
          rescue StandardError => e
            print_error "Internal error while retrieving Metasploit job list (#{e.message})"
            halt 500
          end
        end

        # Returns information about a specific job given its id
        get '/job/:id/info' do
          begin
            id = params[:id]
            raise InvalidParamError, 'id' if id !~ /\A\d+\Z/
            job = @msf.call('job.info', id)
            halt 404 if job.nil?
            job.to_json
          rescue InvalidParamError => e
            print_error e.message
            halt 400
          rescue StandardError => e
            print_error "Internal error while retrieving Metasploit job with ID #{id} (#{e.message})"
            halt 500
          end
        end

        # Stops a job given its id
        get '/job/:id/stop' do
          result = {}
          begin
            id = params[:id]
            raise InvalidParamError, 'id' if id !~ /\A\d+\Z/

            removed = @msf.call('job.stop', id)
            if !removed.nil?
              result['success'] = removed
              print_info "[Metasploit] Stopped job [id: #{id}]"
            end
          rescue InvalidParamError => e
            print_error e.message
            halt 400
          rescue StandardError => e
            print_error "Internal error while stopping job with ID #{id} (#{e.message})"
            halt 500
          end
          result.to_json
        end

        # Starts a new msf payload handler
        post '/handler' do
          begin
            body = JSON.parse(request.body.read)
            handler = @msf.call('module.execute', 'exploit', 'exploit/multi/handler', body)
            result = {}
            # example response: {"job_id"=>0, "uuid"=>"oye0kmpr"}
            if handler.nil? || handler['job_id'].nil?
              print_error "[Metasploit] Could not start payload handler"
              result['success'] = false
            else
              print_info "[Metasploit] Started job [id: #{handler['job_id']}]"
              print_debug "#{@msf.call('job.info', handler['job_id'])}"
              result['success'] = true
              result['id'] = handler['job_id']
            end
            result.to_json
          rescue InvalidJsonError => e
            print_error e.message
            halt 400
          rescue StandardError => e
            print_error "Internal error while creating exploit handler (#{e.message})"
            halt 500
          end
        end

        # Raised when invalid JSON input is passed to an /api/msf handler.
        class InvalidJsonError < StandardError

          DEFAULT_MESSAGE = 'Invalid JSON input passed to /api/msf handler'

          def initialize(message = nil)
            super(message || DEFAULT_MESSAGE)
          end

        end

        # Raised when an invalid named parameter is passed to an /api/msf handler.
        class InvalidParamError < StandardError

          DEFAULT_MESSAGE = 'Invalid parameter passed to /api/msf handler'

          def initialize(message = nil)
            str = "Invalid \"%s\" parameter passed to /api/msf handler"
            message = sprintf str, message unless message.nil?
            super(message)
          end

        end

      end

    end
  end
end
