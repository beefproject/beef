#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module AdminUI
      module Controllers
        class Modules < BeEF::Extension::AdminUI::HttpController
          BD = BeEF::Core::Models::BrowserDetails

          def initialize
            super({
              'paths' => {
                '/getRestfulApiToken.json' => method(:get_restful_api_token),
                '/select/commandmodules/all.json' => method(:select_all_command_modules),
                '/select/commandmodules/tree.json' => method(:select_command_modules_tree),
                '/select/commandmodule.json' => method(:select_command_module),
                '/select/command.json' => method(:select_command),
                '/select/command_results.json' => method(:select_command_results),
                '/commandmodule/commands.json' => method(:select_command_module_commands),
                '/commandmodule/new' => method(:attach_command_module),
                '/commandmodule/dynamicnew' => method(:attach_dynamic_command_module),
                '/commandmodule/reexecute' => method(:reexecute_command_module)
              }
            })

            @session = BeEF::Extension::AdminUI::Session.instance
          end

          # @note Returns the RESTful api key. Authenticated call, so callable only
          # from the admin UI after successful authentication (cookie).
          # -> http://127.0.0.1:3000/ui/modules/getRestfulApiToken.json
          # response
          # <- {"token":"800679edbb59976935d7673924caaa9e99f55c32"}
          def get_restful_api_token
            @body = {
              'token' => BeEF::Core::Configuration.instance.get('beef.api_token')
            }.to_json
          end

          # Returns the list of all command_modules in a JSON format
          def select_all_command_modules
            @body = command_modules2json(BeEF::Modules.get_enabled.keys)
          end

          # Set the correct icon for the command module
          def set_command_module_icon(status)
            path = BeEF::Extension::AdminUI::Constants::Icons::MODULE_TARGET_IMG_PATH # add icon path
            path += case status
                    when BeEF::Core::Constants::CommandModule::VERIFIED_NOT_WORKING
                      BeEF::Extension::AdminUI::Constants::Icons::VERIFIED_NOT_WORKING_IMG
                    when BeEF::Core::Constants::CommandModule::VERIFIED_USER_NOTIFY
                      BeEF::Extension::AdminUI::Constants::Icons::VERIFIED_USER_NOTIFY_IMG
                    when BeEF::Core::Constants::CommandModule::VERIFIED_WORKING
                      BeEF::Extension::AdminUI::Constants::Icons::VERIFIED_WORKING_IMG
                    when BeEF::Core::Constants::CommandModule::VERIFIED_UNKNOWN
                      BeEF::Extension::AdminUI::Constants::Icons::VERIFIED_UNKNOWN_IMG
                    else
                      BeEF::Extension::AdminUI::Constants::Icons::VERIFIED_UNKNOWN_IMG
                    end
            # return path
            path
          end

          # Set the correct working status for the command module
          def set_command_module_status(mod)
            hook_session_id = @params['zombie_session'] || nil
            return BeEF::Core::Constants::CommandModule::VERIFIED_UNKNOWN if hook_session_id.nil?

            BeEF::Module.support(mod, {
                                   'browser' => BD.get(hook_session_id, 'browser.name'),
                                   'ver' => BD.get(hook_session_id, 'browser.version'),
                                   'os' => [BD.get(hook_session_id, 'host.os.name')]
                                 })
          end

          # If we're adding a leaf to the command tree, and it's in a subfolder, we need to recurse
          # into the tree to find where it goes
          def update_command_module_tree_recurse(tree, category, leaf)
            working_category = category.shift

            tree.each do |t|
              if t['text'].eql? working_category && category.count > 0
                # We have deeper to go
                update_command_module_tree_recurse(t['children'], category, leaf)
              elsif t['text'].eql? working_category
                # Bingo
                t['children'].push(leaf)
                break
              end
            end

            # return tree
          end

          # Add the command to the tree
          def update_command_module_tree(tree, cmd_category, cmd_icon_path, cmd_status, cmd_name, cmd_id)
            # construct leaf node for the command module tree
            leaf_node = {
              'text' => cmd_name,
              'leaf' => true,
              'icon' => cmd_icon_path,
              'status' => cmd_status,
              'id' => cmd_id
            }

            # add the node to the branch in the command module tree
            if cmd_category.is_a?(Array)
              # The category is an array, therefore it's a sub-folderised category
              cat_copy = cmd_category.dup # Don't work with the original array, because, then it breaks shit
              update_command_module_tree_recurse(tree, cat_copy, leaf_node)
            else
              # original logic here, simply add the command to the tree.
              tree.each do |x|
                if x['text'].eql? cmd_category
                  x['children'].push(leaf_node)
                  break
                end
              end
            end
          end

          # Recursive function to build the tree now with sub-folders
          def build_recursive_tree(parent, input)
            cinput = input.shift.chomp('/')
            if cinput.split('/').count == 1 # then we have a single folder now
              if parent.detect { |p| p['text'] == cinput }.nil?
                parent << { 'text' => cinput, 'cls' => 'folder', 'children' => [] }
              elsif input.count > 0
                parent.each do |p|
                  p['children'] = build_recursive_tree(p['children'], input) if p['text'] == cinput
                end
              end
            else
              # we have multiple folders
              newinput = cinput.split('/')
              newcinput = newinput.shift
              parent << { 'text' => newcinput, 'cls' => 'folder', 'children' => [] } if parent.detect { |p| p['text'] == newcinput }.nil?
              parent.each do |p|
                p['children'] = build_recursive_tree(p['children'], newinput) if p['text'] == newcinput
              end
            end

            if input.count > 0
              build_recursive_tree(parent, input)
            else
              parent
            end
          end

          # Recursive function to sort all the parent's children
          def sort_recursive_tree(parent)
            # sort the children nodes by status and name
            parent.each do |x|
              # print_info "Sorting: " + x['children'].to_s
              next unless x.is_a?(Hash) && x.has_key?('children')

              x['children'] = x['children'].sort_by do |a|
                fldr = a['cls'] || 'zzzzz'
                "#{fldr}#{a['status']}#{a['text']}"
              end
              x['children'].each do |c|
                sort_recursive_tree([c]) if c.has_key?('cls') && c['cls'] == 'folder'
              end
            end
          end

          # Recursive function to retitle folders with the number of children
          def retitle_recursive_tree(parent)
            # append the number of command modules so the branch name results in: "<category name> (num)"
            parent.each do |command_module_branch|
              next unless command_module_branch.is_a?(Hash) && command_module_branch.has_key?('children')

              num_of_subs = 0
              command_module_branch['children'].each do |c|
                # add in the submodules and subtract 1 for the folder node
                num_of_subs += c['children'].length - 1 if c.has_key?('children')
                retitle_recursive_tree([c]) if c.has_key?('cls') && c['cls'] == 'folder'
              end
              num_of_command_modules = command_module_branch['children'].length + num_of_subs
              command_module_branch['text'] = command_module_branch['text'] + ' (' + num_of_command_modules.to_s + ')'
            end
          end

          # Returns the list of all command_modules for a TreePanel in the interface.
          def select_command_modules_tree
            blanktree = []
            tree = []

            # Due to the sub-folder nesting, we use some really badly hacked together recursion
            # Note to the bored - if someone (anyone please) wants to refactor, I'll buy you cookies. -x
            tree = build_recursive_tree(blanktree, BeEF::Modules.get_categories)

            BeEF::Modules.get_enabled.each do |k, mod|
              # get the hooked browser session id and set it in the command module
              hook_session_id = @params['zombie_session'] || nil
              if hook_session_id.nil?
                print_error 'hook_session_id is nil'
                return
              end

              # create url path and file for the command module icon
              command_module_status = set_command_module_status(k)
              command_module_icon_path = set_command_module_icon(command_module_status)

              update_command_module_tree(tree, mod['category'], command_module_icon_path, command_module_status, mod['name'], mod['db']['id'])
            end

            # if dynamic modules are found in the DB, then we don't have yaml config for them
            # and loading must proceed in a different way.
            dynamic_modules = BeEF::Core::Models::CommandModule.where('path LIKE ?', 'Dynamic/')

            unless dynamic_modules.nil?
              all_modules = BeEF::Core::Models::CommandModule.all.order(:id)
              all_modules.each do |dyn_mod|
                next unless dyn_mod.path.split('/')[1].match(/^metasploit/)

                command_mod_name = dyn_mod['name']
                dyn_mod_category = 'Metasploit'
                command_module_status = set_command_module_status(command_mod_name)
                command_module_icon_path = set_command_module_icon(command_module_status)

                update_command_module_tree(tree, dyn_mod_category, command_module_icon_path, command_module_status, command_mod_name, dyn_mod.id)
              end
            end

            # sort the parent array nodes
            tree.sort! { |a, b| a['text'] <=> b['text'] }

            sort_recursive_tree(tree)

            retitle_recursive_tree(tree)

            # return a JSON array of hashes
            @body = tree.to_json
          end

          # Returns the inputs definition of an command_module.
          def select_command_module
            command_module_id = @params['command_module_id'] || nil
            if command_module_id.nil?
              print_error 'command_module_id is nil'
              return
            end
            command_module = BeEF::Core::Models::CommandModule.find(command_module_id)
            key = BeEF::Module.get_key_by_database_id(command_module_id)

            payload_name = @params['payload_name'] || nil
            @body = if payload_name.nil?
                      command_modules2json([key])
                    else
                      dynamic_payload2json(command_module_id, payload_name)
                    end
          end

          # Returns the list of commands for an command_module
          def select_command_module_commands
            commands = []
            i = 0

            # get params
            zombie_session = @params['zombie_session'] || nil
            if zombie_session.nil?
              print_error 'Zombie session is nil'
              return
            end
            command_module_id = @params['command_module_id'] || nil
            if command_module_id.nil?
              print_error 'command_module id is nil'
              return
            end
            # validate nonce
            nonce = @params['nonce'] || nil
            if nonce.nil?
              print_error 'nonce is nil'
              return
            end
            if @session.get_nonce != nonce
              print_error 'nonce incorrect'
              return
            end

            # get the browser id
            zombie = Z.where(session: zombie_session).first
            if zombie.nil?
              print_error 'Zombie is nil'
              return
            end

            zombie_id = zombie.id
            if zombie_id.nil?
              print_error 'Zombie id is nil'
              return
            end

            C.where(command_module_id: command_module_id, hooked_browser_id: zombie_id).each do |command|
              commands.push({
                'id' => i,
                'object_id' => command.id,
                'creationdate' => Time.at(command.creationdate.to_i).strftime('%Y-%m-%d %H:%M').to_s,
                'label' => command.label
              })
              i += 1
            end

            @body = {
              'success' => 'true',
              'commands' => commands
            }.to_json
          end

          # Attaches an command_module to a zombie.
          def attach_command_module
            definition = {}

            # get params
            zombie_session = @params['zombie_session'] || nil
            if zombie_session.nil?
              print_error 'Zombie id is nil'
              return
            end

            command_module_id = @params['command_module_id'] || nil
            if command_module_id.nil?
              print_error 'command_module id is nil'
              return
            end

            # validate nonce
            nonce = @params['nonce'] || nil
            if nonce.nil?
              print_error 'nonce is nil'
              return
            end
            if @session.get_nonce != nonce
              print_error 'nonce incorrect'
              return
            end

            @params.keys.each do |param|
              unless BeEF::Filters.has_valid_param_chars?(param)
                print_error 'invalid key param string'
                return
              end
              if BeEF::Filters.first_char_is_num?(param)
                print_error 'first char is num'
                return
              end
              definition[param[4..-1]] = params[param]
              oc = BeEF::Core::Models::OptionCache.first_or_create(name: param[4..-1])
              oc.value = params[param]
              oc.save
            end

            mod_key = BeEF::Module.get_key_by_database_id(command_module_id)
            # Hack to rework the old option system into the new option system
            def2 = []
            definition.each do |k, v|
              def2.push({ 'name' => k, 'value' => v })
            end
            # End hack
            exec_results = BeEF::Module.execute(mod_key, zombie_session, def2)
            @body = exec_results.nil? ? '{success: false}' : '{success: true}'
          end

          # Re-execute an command_module to a zombie.
          def reexecute_command_module
            # get params
            command_id = @params['command_id'] || nil
            if command_id.nil?
              print_error 'Command id is nil'
              return
            end

            command = BeEF::Core::Models::Command.find(command_id.to_i) || nil
            if command.nil?
              print_error 'Command is nil'
              return
            end
            # validate nonce
            nonce = @params['nonce'] || nil
            if nonce.nil?
              print_error 'nonce is nil'
              return
            end
            if @session.get_nonce != nonce
              print_error 'nonce incorrect'
              return
            end

            command.instructions_sent = false
            command.save

            @body = '{success : true}'
          end

          def attach_dynamic_command_module
            definition = {}

            # get params
            zombie_session = @params['zombie_session'] || nil
            if zombie_session.nil?
              print_error 'Zombie id is nil'
              return
            end

            command_module_id = @params['command_module_id'] || nil
            if command_module_id.nil?
              print_error 'command_module id is nil'
              return
            end

            # validate nonce
            nonce = @params['nonce'] || nil
            if nonce.nil?
              print_error 'nonce is nil'
              return
            end

            if @session.get_nonce != nonce
              print_error 'nonce incorrect'
              return
            end

            @params.keys.each do |param|
              unless BeEF::Filters.has_valid_param_chars?(param)
                print_error 'invalid key param string'
                return
              end

              if BeEF::Filters.first_char_is_num?(param)
                print_error "first char is num: #{param}"
                return
              end

              definition[param[4..-1]] = params[param]
              oc = BeEF::Core::Models::OptionCache.first_or_create(name: param[4..-1])
              oc.value = params[param]
              oc.save
            end

            zombie = Z.where(session: zombie_session).first
            if zombie.nil?
              print_error 'Zombie is nil'
              return
            end

            zombie_id = zombie.id
            if zombie_id.nil?
              print_error 'Zombie id is nil'
              return
            end

            command_module = BeEF::Core::Models::CommandModule.find(command_module_id)

            return { 'success' => 'false' }.to_json if command_module.nil?

            unless command_module.path.match(/^Dynamic/)
              print_info "Command module path is not dynamic: #{command_module.path}"
              return { 'success' => 'false' }.to_json
            end

            dyn_mod_name = command_module.path.split('/').last
            e = BeEF::Modules::Commands.const_get(dyn_mod_name.capitalize).new
            e.update_info(command_module_id)
            e.update_data
            ret = e.launch_exploit(definition)

            if ret['result'] != 'success'
              print_info 'mount failed'
              return { 'success' => 'false' }.to_json
            end

            basedef = {}
            basedef['sploit_url'] = ret['uri']

            C.new(
              data: basedef.to_json,
              hooked_browser_id: zombie_id,
              command_module_id: command_module_id,
              creationdate: Time.new.to_i
            ).save

            @body = { 'success' => true }.to_json
          end

          # Returns the results of a command
          def select_command_results
            results = []

            # get params
            command_id = @params['command_id'] || nil
            if command_id.nil?
              print_error 'Command id is nil'
              return
            end

            command = BeEF::Core::Models::Command.find(command_id.to_i) || nil
            if command.nil?
              print_error 'Command is nil'
              return
            end

            # get command_module
            command_module = BeEF::Core::Models::CommandModule.find(command.command_module_id)
            if command_module.nil?
              print_error 'command_module is nil'
              return
            end

            resultsdb = BeEF::Core::Models::Result.where(command_id: command_id)
            if resultsdb.nil?
              print_error 'Command id result is nil'
              return
            end

            resultsdb.each { |result| results.push({ 'date' => result.date, 'data' => JSON.parse(result.data) }) }

            @body = {
              'success' => 'true',
              'command_module_name' => command_module.name,
              'command_module_id' => command_module.id,
              'results' => results
            }.to_json
          end

          # Returns the definition of a command.
          # In other words it returns the command that was used to command_module a zombie.
          def select_command
            # get params
            command_id = @params['command_id'] || nil
            if command_id.nil?
              print_error 'Command id is nil'
              return
            end

            command = BeEF::Core::Models::Command.find(command_id.to_i) || nil
            if command.nil?
              print_error 'Command is nil'
              return
            end

            command_module = BeEF::Core::Models::CommandModule.find(command.command_module_id)
            if command_module.nil?
              print_error 'command_module is nil'
              return
            end

            if command_module.path.split('/').first.match(/^Dynamic/)
              dyn_mod_name = command_module.path.split('/').last
              e = BeEF::Modules::Commands.const_get(dyn_mod_name.capitalize).new
            else
              command_module_name = command_module.name
              e = BeEF::Core::Command.const_get(command_module_name.capitalize).new(command_module_name)
            end

            @body = {
              'success' => 'true',
              'command_module_name' => command_module_name,
              'command_module_id' => command_module.id,
              'data' => BeEF::Module.get_options(command_module_name),
              'definition' => JSON.parse(e.to_json)
            }.to_json
          end

          private

          # Takes a list of command_modules and returns them as a JSON array
          def command_modules2json(command_modules)
            command_modules_json = {}
            i = 1
            config = BeEF::Core::Configuration.instance
            command_modules.each do |command_module|
              h = {
                'Name' => config.get("beef.module.#{command_module}.name"),
                'Description' => config.get("beef.module.#{command_module}.description"),
                'Category' => config.get("beef.module.#{command_module}.category"),
                'Data' => BeEF::Module.get_options(command_module)
              }
              command_modules_json[i] = h
              i += 1
            end

            return { 'success' => 'false' }.to_json if command_modules_json.empty?

            { 'success' => 'true', 'command_modules' => command_modules_json }.to_json
          end

          # return the input requred for the module in JSON format
          def dynamic_modules2json(id)
            command_modules_json = {}

            mod = BeEF::Core::Models::CommandModule.find(id)

            # if the module id is not in the database return false
            return { 'success' => 'false' }.to_json unless mod

            # the path will equal Dynamic/<type> and this will get just the type
            dynamic_type = mod.path.split('/').last

            e = BeEF::Modules::Commands.const_get(dynamic_type.capitalize).new
            e.update_info(mod.id)
            e.update_data
            command_modules_json[1] = JSON.parse(e.to_json)
            if command_modules_json.empty?
              { 'success' => 'false' }.to_json
            else
              { 'success' => 'true', 'dynamic' => 'true', 'command_modules' => command_modules_json }.to_json
            end
          end

          def dynamic_payload2json(id, payload_name)
            command_module = BeEF::Core::Models::CommandModule.find(id)
            if command_module.nil?
              print_error 'Module does not exists'
              return { 'success' => 'false' }.to_json
            end

            payload_options = BeEF::Module.get_payload_options(command_module.name, payload_name)
            # get payload options in JSON
            # e = BeEF::Modules::Commands.const_get(dynamic_type.capitalize).new
            payload_options_json = []
            payload_options_json[1] = payload_options
            # payload_options_json[1] = e.get_payload_options(payload_name)
            { 'success' => 'true', 'command_modules' => payload_options_json }.to_json
          end
        end
      end
    end
  end
end
