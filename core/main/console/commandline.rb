#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'optparse'

module BeEF
  module Core
    module Console
      #
      # This module parses the command line argument when running beef.
      #
      module CommandLine
        @options = {
          verbose: false,
          resetdb: false,
          ascii_art: false,
          ext_config: '',
          port: '',
          ws_port: '',
          interactive: false,
          update_disabled: false,
          update_auto: false,
        }

        @already_parsed = false

        #
        # Parses the command line arguments of the console.
        # It also populates the 'options' hash.
        #
        def self.parse
          return if @already_parsed

          optparse = OptionParser.new do |opts|
            opts.on('-x', '--reset', 'Reset the database') do
              @options[:resetdb] = true
            end

            opts.on('-v', '--verbose', 'Display debug information') do
              @options[:verbose] = true
            end

            opts.on('-a', '--ascii-art', 'Prints BeEF ascii art') do
              @options[:ascii_art] = true
            end

            opts.on('-c', '--config FILE', "Specify configuration file to load (instead of ./config.yaml)") do |f|
              @options[:ext_config] = f
            end

            opts.on('-p', '--port PORT', 'Change the default BeEF listening port') do |p|
              @options[:port] = p
            end

            opts.on('-w', '--wsport WS_PORT', 'Change the default BeEF WebSocket listening port') do |ws_port|
              @options[:ws_port] = ws_port
            end

            opts.on('--update-disable', 'Skips update') do
              @options[:update_disabled] = true
            end

            opts.on('--update-auto', 'Automatic update with no prompt') do
              @options[:update_auto] = true
            end

            opts.on("-h", "--help", "Prints this help") do
              puts opts
              exit 0
            end
          end

          # NOTE:
          # OptionParser consumes ARGV, all options are removed from it after parsing.
          # If we wanted to pass Options to Sinatra, we would need to parse on a copy here.
          # We don't do that since we explicitly don't want to allow users messing with these options, though.
          optparse.parse!
          @already_parsed = true
        rescue OptionParser::InvalidOption
          puts 'Provided option not recognized by beef. If you provided a Sinatra option, note that beef explicitly disallows them.'
          exit 1
        end

        #
        # Return the parsed options.
        # Ensures that cmd line arguments are parsed.
        #
        def self.get_options
          self.class.parse unless @already_parsed
          return @options 
        end

      end
    end
  end
end
