#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
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
module API
  #
  # Use this API call if you want to add new methods and variables to the default
  # BeEF::Core::Command module.
  #
  # Here's an example:
  #
  #   module A
  #     extend BeEF::API::Command
  #   
  #     def hello
  #       p 'hi there'
  #     end
  #   end
  #
  #   b = BeEF::Core::Command.new
  #   b.hello # => 'hi there'
  #
  #   c = BeEF::Core::Command::Detect_details.new
  #   c.hello # => 'hi there'
  #
  #
  # For a real life example, have a look at BeEF::Extension::AdminUI::API::Command
  #
  module Command
  end
  
end
end
