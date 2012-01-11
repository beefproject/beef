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
    module Console
      #
      # This module parses the command line argument when running beef.
      #
      module CommandLine

        @options = Hash.new
        @options[:verbose] = false
        @options[:resetdb] = false

        @already_parsed = false

        #
        # Parses the command line arguments of the console.
        # It also populates the 'options' hash.
        #
        def self.parse
          return @options if @already_parsed

          begin
          optparse = OptionParser.new do |opts|
            opts.on('-x', '--reset', 'Reset the database') do
              @options[:resetdb] = true
            end

            opts.on('-v', '--verbose', 'Display debug information') do
              @options[:verbose] = true
            end
          end

          optparse.parse!
          @already_parsed = true
          @options
          rescue OptionParser::InvalidOption => e
            puts "Invalid command line option provided. Please run beef --help"
            exit 1
          end
        end

      end

    end
  end
end