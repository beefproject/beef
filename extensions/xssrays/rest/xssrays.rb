#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Xssrays
      # This class handles the routing of RESTful API requests for XSSRays
      class XssraysRest < BeEF::Core::Router::Router
        # Filters out bad requests before performing any routing
        before do
          config = BeEF::Core::Configuration.instance

          # Require a valid API token from a valid IP address
          halt 401 unless params[:token] == config.get('beef.api_token')
          halt 403 unless BeEF::Core::Rest.permitted_source?(request.ip)

          CLEAN_TIMEOUT = config.get('beef.extension.xssrays.clean_timeout') || 3_000
          CROSS_DOMAIN = config.get('beef.extension.xssrays.cross_domain') || true

          HB = BeEF::Core::Models::HookedBrowser
          XS = BeEF::Core::Models::Xssraysscan
          XD = BeEF::Core::Models::Xssraysdetail

          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        # Returns the entire list of rays for all zombies
        get '/rays' do
          rays = XD.all.distinct.order(:id)
          count = rays.length

          result = {}
          result[:count] = count
          result[:rays] = []
          rays.each do |ray|
            result[:rays] << ray2hash(ray)
          end
          result.to_json
        rescue StandardError => e
          print_error "Internal error while retrieving rays (#{e.message})"
          halt 500
        end

        # Returns all rays given a specific hooked browser id
        get '/rays/:id' do
          id = params[:id]

          rays = XD.where(hooked_browser_id: id).distinct.order(:id)
          count = rays.length

          result = {}
          result[:count] = count
          result[:rays] = []
          rays.each do |ray|
            result[:rays] << ray2hash(ray)
          end
          result.to_json
        rescue InvalidParamError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          print_error "Internal error while retrieving rays list for hooked browser with id #{id} (#{e.message})"
          halt 500
        end

        # Returns the entire list of scans for all zombies
        get '/scans' do
          scans = XS.distinct.order(:id)
          count = scans.length

          result = {}
          result[:count] = count
          result[:scans] = []
          scans.each do |scan|
            result[:scans] << scan2hash(scan)
          end
          result.to_json
        rescue StandardError => e
          print_error "Internal error while retrieving scans (#{e.message})"
          halt 500
        end

        # Returns all scans given a specific hooked browser id
        get '/scans/:id' do
          id = params[:id]

          scans = XS.where(hooked_browser_id: id).distinct.order(:id)
          count = scans.length

          result = {}
          result[:count] = count
          result[:scans] = []
          scans.each do |_scans|
            result[:scans] << scan2hash(scan)
          end
          result.to_json
        rescue InvalidParamError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          print_error "Internal error while retrieving scans list for hooked browser with id #{id} (#{e.message})"
          halt 500
        end

        # Starts a new scan on the specified zombie ID
        post '/scan/:id' do
          id = params[:id]

          hooked_browser = HB.where(session: id).distinct.order(:id).first

          if hooked_browser.nil?
            print_error '[XSSRAYS] Invalid hooked browser ID'
            return
          end

          # set Cross-domain settings
          cross_domain = params[:cross_domain].to_s
          cross_domain = if cross_domain == ''
                           CROSS_DOMAIN
                         else
                           cross_domain != 'false'
                         end

          # set clean timeout settings
          clean_timeout = params[:clean_timeout].to_s
          clean_timeout = CLEAN_TIMEOUT if clean_timeout == '' || !Filters.alphanums_only?(clean_timeout)

          xssrays_scan = XS.new(
            hooked_browser_id: hooked_browser.id,
            scan_start: Time.now,
            domain: hooked_browser.domain,
            # check also cross-domain URIs found by the crawler
            cross_domain: cross_domain,
            # how long to wait before removing the iFrames from the DOM (5000ms default)
            clean_timeout: clean_timeout
          )
          xssrays_scan.save

          print_info(
            "[XSSRays] Starting XSSRays [ip:#{hooked_browser.ip}], " \
            "hooked domain [#{hooked_browser.domain}], " \
            "cross-domain: #{cross_domain}, " \
            "clean timeout: #{clean_timeout}"
          )

          result = scan2hash(xssrays_scan)
          print_debug "[XSSRays] New scan: #{result}"

          # result.to_json
        rescue InvalidParamError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          print_error "Internal error while creating XSSRays scan on zombie with id #{id} (#{e.message})"
          halt 500
        end

        private

        # Convert a ray object to JSON
        def ray2hash(ray)
          {
            id: ray.id,
            hooked_browser_id: ray.hooked_browser_id,
            vector_name: ray.vector_name,
            vector_method: ray.vector_method,
            vector_poc: ray.vector_poc
          }
        end

        # Convert a scan object to JSON
        def scan2hash(scan)
          {
            id: scan.id,
            hooked_browser_id: scan.hooked_browser_id,
            scan_start: scan.scan_start,
            scan_finish: scan.scan_finish,
            domain: scan.domain,
            cross_domain: scan.cross_domain,
            clean_timeout: scan.clean_timeout,
            is_started: scan.is_started,
            is_finished: scan.is_finished
          }
        end

        # Raised when invalid JSON input is passed to an /api/xssrays handler.
        class InvalidJsonError < StandardError
          DEFAULT_MESSAGE = 'Invalid JSON input passed to /api/xssrays handler'.freeze

          def initialize(message = nil)
            super(message || DEFAULT_MESSAGE)
          end
        end

        # Raised when an invalid named parameter is passed to an /api/xssrays handler.
        class InvalidParamError < StandardError
          DEFAULT_MESSAGE = 'Invalid parameter passed to /api/xssrays handler'.freeze

          def initialize(message = nil)
            str = 'Invalid "%s" parameter passed to /api/xssrays handler'
            message = format str, message unless message.nil?
            super(message)
          end
        end
      end
    end
  end
end
