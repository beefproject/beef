#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Metasploit
      class RpcClient < ::Msf::RPC::Client
        include Singleton

        def initialize
          @config = BeEF::Core::Configuration.instance.get('beef.extension.metasploit')

          unless @config.key?('host') || @config.key?('uri') || @config.key?('port') ||
                 @config.key?('user') || @config.key?('pass')
            print_error 'There is not enough information to initalize Metasploit connectivity at this time'
            print_error 'Please check your options in config.yaml to verify that all information is present'
            BeEF::Core::Configuration.instance.set('beef.extension.metasploit.enabled', false)
            BeEF::Core::Configuration.instance.set('beef.extension.metasploit.loaded', false)
            return
          end

          @lock = false
          @lastauth = nil
          @unit_test = false
          @msf_path = nil

          opts = {
            host: @config['host'] || '127.0.0.1',
            port: @config['port'] || 55_552,
            uri: @config['uri'] || '/api/',
            ssl: @config['ssl'],
            ssl_version: @config['ssl_version'],
            context: {}
          }

          print_warning '[Metasploit] Warning: Connections to Metasploit RPC over SSLv3 are insecure. Use TLSv1 instead.' if opts[:ssl_version].match?(/SSLv3/i)

          if @config['auto_msfrpcd']
            @config['msf_path'].each do |path|
              @msf_path = "#{path['path']}/msfrpcd" if File.exist? "#{path['path']}/msfrpcd"
            end

            if @msf_path.nil?
              print_error '[Metasploit] Please add a custom path for msfrpcd to the config file.'
              return
            end

            print_info "[Metasploit] Found msfrpcd: #{@msf_path}"

            return unless launch_msfrpcd(opts)
          end

          super(opts)
        end

        #
        # @note auto start msfrpcd
        #
        def launch_msfrpcd(opts)
          if opts[:ssl]
            argssl = '-S'
            proto = 'http'
          else
            argssl = ''
            proto = 'https'
          end

          msf_url = "#{proto}://#{opts[:host]}:#{opts[:port]}#{opts[:uri]}"

          child = IO.popen([
                             @msf_path,
                             '-f',
                             argssl,
                             '-P', @config['pass'],
                             '-U', @config['user'],
                             '-u', opts[:uri],
                             '-a', opts[:host],
                             '-p', opts[:port].to_s
                           ], 'r+')

          print_info "[Metasploit] Attempt to start msfrpcd, this may take a while. PID: #{child.pid}"

          # Give daemon time to launch
          # poll and giveup after timeout
          retries = @config['auto_msfrpcd_timeout']
          uri = URI(msf_url)
          http = Net::HTTP.new(uri.host, uri.port)

          if opts[:ssl]
            http.use_ssl = true
            http.ssl_version = opts[:ssl_version]
          end

          http.verify_mode = OpenSSL::SSL::VERIFY_NONE unless @config['ssl_verify']

          headers = { 'Content-Type' => 'binary/message-pack' }
          path = uri.path.empty? ? '/' : uri.path

          begin
            sleep 1
            code = http.head(path, headers).code.to_i
            print_debug "[Metasploit] Success - HTTP response: #{code}"
          rescue StandardError
            retry if (retries -= 1).positive?
          end

          true
        end

        def get_lock
          sleep 0.2 while @lock
          @lock = true
        end

        def release_lock
          @lock = false
        end

        def call(meth, *args)
          super(meth, *args)
        rescue StandardError => e
          print_error "[Metasploit] RPC call to '#{meth}' failed: #{e}"
          print_error e.backtrace
          nil
        end

        def unit_test_init
          @unit_test = true
        end

        # login to metasploit
        def login
          get_lock

          res = super(@config['user'], @config['pass'])

          unless res
            print_error '[Metasploit] Could not authenticate to Metasploit RPC sevrice.'
            return false
          end

          unless @lastauth
            print_info '[Metasploit] Successful connection with Metasploit.' unless @unit_test
            print_debug "[Metasploit] Received temporary token: #{token}"

            # Generate permanent token
            new_token = token_generate
            if new_token.nil?
              print_warning '[Metasploit] Could not retrieve permanent Metasploit token. Connection to Metasploit will time out in 5 minutes.'
            else
              self.token = new_token
              print_debug "[Metasploit] Received permanent token: #{token}"
            end
          end
          @lastauth = Time.now

          true
        ensure
          release_lock
        end

        # generate a permanent auth token
        def token_generate
          res = call('auth.token_generate')

          return unless res || res['token']

          res['token']
        end

        def browser_exploits
          get_lock
          res = call('module.exploits')

          return [] unless res || res['modules']

          res['modules'].select { |m| m.include?('/browser/') }.sort
        ensure
          release_lock
        end

        def get_exploit_info(name)
          get_lock
          res = call('module.info', 'exploit', name)
          res || {}
        rescue StandardError => e
          print_error "Call module.info for module #{name} failed: #{e.message}"
          {}
        ensure
          release_lock
        end

        def get_payloads(name)
          get_lock
          res = call('module.compatible_payloads', name)
          res || {}
        rescue StandardError => e
          print_error "Call module.compatible_payloads for module #{name} failed: #{e.message}"
          {}
        ensure
          release_lock
        end

        def get_options(name)
          get_lock
          res = call('module.options', 'exploit', name)
          res || {}
        rescue StandardError => e
          print_error "Call module.options for module #{name} failed: #{e.message}"
          {}
        ensure
          release_lock
        end

        def payloads
          get_lock
          res = call('module.payloads')
          return {} unless res || res['modules']

          res['modules']
        rescue StandardError => e
          print_error "Call module.payloads failed: #{e.message}"
          {}
        ensure
          release_lock
        end

        def payload_options(name)
          get_lock
          res = call('module.options', 'payload', name)
          return {} unless res

          res
        rescue StandardError => e
          print_error "Call module.options for payload #{name} failed: #{e.message}"
          {}
        ensure
          release_lock
        end

        def launch_exploit(exploit, opts)
          get_lock
          res = call('module.execute', 'exploit', exploit, opts)
          proto = opts['SSL'] ? 'https' : 'http'
          res['uri'] = "#{proto}://#{@config['callback_host']}:#{opts['SRVPORT']}/#{opts['URIPATH']}"
          res
        rescue StandardError => e
          print_error "Exploit failed for #{exploit}\n#{e.message}"
          false
        ensure
          release_lock
        end

        def launch_autopwn
          opts = {
            'LHOST' => @config['callback_host'],
            'URIPATH' => @apurl
          }
          get_lock
          call('module.execute', 'auxiliary', 'server/browser_autopwn', opts)
        rescue StandardError => e
          print_error "Failed to launch browser_autopwn: #{e.message}"
          false
        ensure
          release_lock
        end
      end
    end
  end
end
