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
  module Core
    module Handlers
      module Modules

        module Command

          # Adds the command module instructions to a hooked browser's http response.
          # @param [Object] command Command object
          # @param [Object] hooked_browser Hooked Browser object
          def add_command_instructions(command, hooked_browser)

            (print_error "hooked_browser is nil"; return) if hooked_browser.nil?
            (print_error "hooked_browser.session is nil"; return) if hooked_browser.session.nil?
            (print_error "hooked_browser is nil"; return) if command.nil?
            (print_error "hooked_browser.command_module_id is nil"; return) if command.command_module_id.nil?

            # @note get the command module
            command_module = BeEF::Core::Models::CommandModule.first(:id => command.command_module_id)
            (print_error "command_module is nil"; return) if command_module.nil?
            (print_error "command_module.path is nil"; return) if command_module.path.nil?

            if (command_module.path.match(/^Dynamic/))
              command_module = BeEF::Modules::Commands.const_get(command_module.path.split('/').last.capitalize).new
            else
              key = BeEF::Module.get_key_by_database_id(command.command_module_id)
              command_module = BeEF::Core::Command.const_get(BeEF::Core::Configuration.instance.get("beef.module.#{key}.class")).new(key)
            end

            command_module.command_id = command.id
            command_module.session_id = hooked_browser.session
            command_module.build_datastore(command.data)
            command_module.pre_send

            build_missing_beefjs_components(command_module.beefjs_components) if not command_module.beefjs_components.empty?
            let= BeEF::Core::Websocket::Websocket.instance

            #todo antisnatchor: remove this gsub crap adding some hook packing.
            if  let.getsocket(hooked_browser.session)
              funtosend=command_module.output.gsub('//
              //   Copyright 2012 Wade Alcorn wade@bindshell.net
              //
              //   Licensed under the Apache License, Version 2.0 (the "License");
              //   you may not use this file except in compliance with the License.
              //   You may obtain a copy of the License at
              //
              //       http://www.apache.org/licenses/LICENSE-2.0
              //
              //   Unless required by applicable law or agreed to in writing, software
              //   distributed under the License is distributed on an "AS IS" BASIS,
              //   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
              //   See the License for the specific language governing permissions and
              //   limitations under the License.
              //', "")
              let.sent(funtosend, hooked_browser.session)
            else
              @body << command_module.output + "\n\n"
            end
            # @note prints the event to the console
            if BeEF::Settings.console?
              name = command_module.friendlyname || kclass
              print_info "Hooked browser #{hooked_browser.ip} has been sent instructions from command module '#{name}'"
            end

            # @note flag that the command has been sent to the hooked browser
            command.instructions_sent = true
            command.save
          end

        end

      end
    end
  end
end
