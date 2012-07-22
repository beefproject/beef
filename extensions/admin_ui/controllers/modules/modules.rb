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
module AdminUI
module Controllers
  
#
#
#
class Modules < BeEF::Extension::AdminUI::HttpController
  
  BD = BeEF::Core::Models::BrowserDetails
  
  def initialize
    super({
      'paths' => {
        '/getRestfulApiToken.json'          => method(:get_restful_api_token),
        '/select/commandmodules/all.json'   => method(:select_all_command_modules),
        '/select/commandmodules/tree.json'  => method(:select_command_modules_tree),
        '/select/commandmodule.json'        => method(:select_command_module),
        '/select/command.json'              => method(:select_command),
        '/select/command_results.json'      => method(:select_command_results),
        '/select/zombie_summary.json'       => method(:select_zombie_summary),
        '/commandmodule/commands.json'      => method(:select_command_module_commands),
        '/commandmodule/new'                => method(:attach_command_module),
        '/commandmodule/dynamicnew'         => method(:attach_dynamic_command_module),
        '/commandmodule/reexecute'          => method(:reexecute_command_module)
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
         'token' => BeEF::Core::Configuration.instance.get("beef.api_token")
     }.to_json
  end
  
  # Returns a JSON array containing the summary for a selected zombie.
  def select_zombie_summary

    # get the zombie 
    zombie_session = @params['zombie_session'] || nil
    (print_error "Zombie session is nil";return) if zombie_session.nil?
    zombie = BeEF::Core::Models::HookedBrowser.first(:session => zombie_session)
    (print_error "Zombie is nil";return) if zombie.nil?

    # init the summary grid
    summary_grid_hash = {
      'success' => 'true', 
      'results' => []
    }

    # set and add the return values for the page title
    page_title = BD.get(zombie_session, 'PageTitle') 
    if not page_title.nil?
      encoded_page_title = CGI.escapeHTML(page_title)
      encoded_page_title_hash = { 'Page Title' => encoded_page_title }
      
      page_name_row = {
        'category' => 'Hooked Page',
        'data' => encoded_page_title_hash,
        'from' => 'Initialization'
      }
      
      summary_grid_hash['results'].push(page_name_row) # add the row
    end

    # set and add the return values for the page uri
    page_uri = BD.get(zombie_session, 'PageURI')
    if not page_uri.nil?
      encoded_page_uri = CGI.escapeHTML(page_uri)
      encoded_page_uri_hash = { 'Page URI' => encoded_page_uri }

      page_name_row = {
        'category' => 'Hooked Page',
        'data' => encoded_page_uri_hash,
        'from' => 'Initialization'
      }

      summary_grid_hash['results'].push(page_name_row) # add the row
    end

    # set and add the return values for the page referrer
    page_referrer = BD.get(zombie_session, 'PageReferrer')
    if not page_referrer.nil?
      encoded_page_referrer = CGI.escapeHTML(page_referrer)
      encoded_page_referrer_hash = { 'Page Referrer' => encoded_page_referrer }

      page_name_row = {
        'category' => 'Hooked Page',
        'data' => encoded_page_referrer_hash,
        'from' => 'Initialization'
      }

      summary_grid_hash['results'].push(page_name_row) # add the row
    end

    # set and add the return values for the host name
    host_name = BD.get(zombie_session, 'HostName') 
    if not host_name.nil?
      encoded_host_name = CGI.escapeHTML(host_name)
      encoded_host_name_hash = { 'Hostname/IP' => encoded_host_name }
    
      page_name_row = {
        'category' => 'Hooked Page',
        'data' => encoded_host_name_hash,
        'from' => 'Initialization'
      }
    
      summary_grid_hash['results'].push(page_name_row) # add the row
    end
    
    # set and add the return values for the date stamp
    date_stamp = BD.get(zombie_session, 'DateStamp')
    if not date_stamp.nil?
      encoded_date_stamp = CGI.escapeHTML(date_stamp)
      encoded_date_stamp_hash = { 'Date' => encoded_date_stamp }

      page_name_row = {
        'category' => 'Host',
        'data' => encoded_date_stamp_hash,
        'from' => 'Initialization'
      }

      summary_grid_hash['results'].push(page_name_row) # add the row
    end

    # set and add the return values for the os name
    os_name = BD.get(zombie_session, 'OsName')
    if not os_name.nil?
      encoded_os_name = CGI.escapeHTML(os_name)
      encoded_os_name_hash = { 'OS Name' => encoded_os_name }

      page_name_row = {
        'category' => 'Host',
        'data' => encoded_os_name_hash,
        'from' => 'Initialization'
      }

      summary_grid_hash['results'].push(page_name_row) # add the row
    end

    # set and add the return values for the hardware name
    hw_name = BD.get(zombie_session, 'Hardware')
    if not hw_name.nil?
      encoded_hw_name = CGI.escapeHTML(hw_name)
      encoded_hw_name_hash = { 'Hardware' => encoded_hw_name }

      page_name_row = {
        'category' => 'Host',
        'data' => encoded_hw_name_hash,
        'from' => 'Initialization'
      }

      summary_grid_hash['results'].push(page_name_row) # add the row
    end
 
    # set and add the return values for the browser name
    browser_name = BD.get(zombie_session, 'BrowserName') 
    if not browser_name.nil?
      friendly_browser_name = BeEF::Core::Constants::Browsers.friendly_name(browser_name)
      browser_name_hash = { 'Browser Name' => friendly_browser_name }

      browser_name_row = {
        'category' => 'Browser',
        'data' => browser_name_hash,
        'from' => 'Initialization'
      }
    
      summary_grid_hash['results'].push(browser_name_row) # add the row
    end
    
    # set and add the return values for the browser version
    browser_version = BD.get(zombie_session, 'BrowserVersion') 
    if not browser_version.nil?
      encoded_browser_version = CGI.escapeHTML(browser_version)
      browser_version_hash = { 'Browser Version' => encoded_browser_version }

      browser_version_row = {
        'category' => 'Browser',
         'data' => browser_version_hash,
        'from' => 'Initialization'
      }
    
      summary_grid_hash['results'].push(browser_version_row) # add the row
    end
    
    # set and add the return values for the browser ua string
    browser_uastring = BD.get(zombie_session, 'BrowserReportedName')
    if not browser_uastring.nil?
      browser_uastring_hash = { 'Browser UA String' => browser_uastring }

      browser_uastring_row = {
        'category' => 'Browser',
         'data' => browser_uastring_hash,
        'from' => 'Initialization'
      }
    
      summary_grid_hash['results'].push(browser_uastring_row) # add the row
    end
    
    # set and add the list of cookies
    cookies = BD.get(zombie_session, 'Cookies')
    if not cookies.nil? and not cookies.empty?
      encoded_cookies = CGI.escapeHTML(cookies)
      encoded_cookies_hash = { 'Cookies' => encoded_cookies }
      
      page_name_row = {
        'category' => 'Hooked Page',
        'data' => encoded_cookies_hash,
        'from' => 'Initialization'
      }
      
      summary_grid_hash['results'].push(page_name_row) # add the row
    end
    
    # set and add the list of plugins installed in the browser
    browser_plugins = BD.get(zombie_session, 'BrowserPlugins')
    if not browser_plugins.nil? and not browser_plugins.empty?
      encoded_browser_plugins = CGI.escapeHTML(browser_plugins)
      encoded_browser_plugins_hash = { 'Browser Plugins' => encoded_browser_plugins }
      
      page_name_row = {
        'category' => 'Browser',
        'data' => encoded_browser_plugins_hash,
        'from' => 'Initialization'
      }
      
      summary_grid_hash['results'].push(page_name_row) # add the row
    end
    
    # set and add the System Platform
    system_platform = BD.get(zombie_session, 'SystemPlatform')
    if not system_platform.nil?
      encoded_system_platform = CGI.escapeHTML(system_platform)
      encoded_system_platform_hash = { 'System Platform' => encoded_system_platform }

      page_name_row = {
        'category' => 'Host',
        'data' => encoded_system_platform_hash,
        'from' => 'Initialization'
      }

      summary_grid_hash['results'].push(page_name_row) # add the row
    end

    # set and add the zombie screen size and color depth
    screen_size = BD.get(zombie_session, 'ScreenSize')
    if not screen_size.nil?
      
      screen_size_hash = JSON.parse(screen_size.gsub(/\"\=\>/, '":')) # tidy up the string for JSON
      width = screen_size_hash['width']
      (print_error "width is wrong type";return) if not width.is_a?(Fixnum)
      height = screen_size_hash['height']
      (print_error "height is wrong type";return) if not height.is_a?(Fixnum)
      colordepth = screen_size_hash['colordepth']
      (print_error "colordepth is wrong type";return) if not colordepth.is_a?(Fixnum)
      
      # construct the string to be displayed in the details tab
      encoded_screen_size = CGI.escapeHTML("Width: "+width.to_s + ", Height: " + height.to_s + ", Colour Depth: " + colordepth.to_s)
      encoded_screen_size_hash = { 'Screen Size' => encoded_screen_size }
      
      page_name_row = {
        'category' => 'Host',
        'data' => encoded_screen_size_hash,
        'from' => 'Initialization'
      }

      summary_grid_hash['results'].push(page_name_row) # add the row
    end

    # set and add the zombie browser window size
    window_size = BD.get(zombie_session, 'WindowSize')
    if not window_size.nil?

      window_size_hash = JSON.parse(window_size.gsub(/\"\=\>/, '":')) # tidy up the string for JSON
      width = window_size_hash['width']
      (print_error "width is wrong type";return) if not width.is_a?(Fixnum)
      height = window_size_hash['height']
      (print_error "height is wrong type";return) if not height.is_a?(Fixnum)

      # construct the string to be displayed in the details tab
      encoded_window_size = CGI.escapeHTML("Width: "+width.to_s + ", Height: " + height.to_s)
      encoded_window_size_hash = { 'Window Size' => encoded_window_size }

      page_name_row = {
        'category' => 'Browser',
        'data' => encoded_window_size_hash,
        'from' => 'Initialization'
      }

      summary_grid_hash['results'].push(page_name_row) # add the row
    end

    # set and add the yes|no value for JavaEnabled
    java_enabled = BD.get(zombie_session, 'JavaEnabled')
    if not java_enabled.nil?
      encoded_java_enabled = CGI.escapeHTML(java_enabled)
      encoded_java_enabled_hash = { 'Java Enabled' => encoded_java_enabled }

      page_name_row = {
        'category' => 'Browser',
        'data' => encoded_java_enabled_hash,
        'from' => 'Initialization'
      }

      summary_grid_hash['results'].push(page_name_row) # add the row
    end

    # set and add the yes|no value for VBScriptEnabled
    vbscript_enabled = BD.get(zombie_session, 'VBScriptEnabled')
    if not vbscript_enabled.nil?
      encoded_vbscript_enabled = CGI.escapeHTML(vbscript_enabled)
      encoded_vbscript_enabled_hash = { 'VBScript Enabled' => encoded_vbscript_enabled }

      page_name_row = {
        'category' => 'Browser',
        'data' => encoded_vbscript_enabled_hash,
        'from' => 'Initialization'
      }

      summary_grid_hash['results'].push(page_name_row) # add the row
    end

    # set and add the yes|no value for HasFlash
    has_flash = BD.get(zombie_session, 'HasFlash')
    if not has_flash.nil?
      encoded_has_flash = CGI.escapeHTML(has_flash)
      encoded_has_flash_hash = { 'Has Flash' => encoded_has_flash }

      page_name_row = {
        'category' => 'Browser',
        'data' => encoded_has_flash_hash,
        'from' => 'Initialization'
      }

      summary_grid_hash['results'].push(page_name_row) # add the row
    end

    # set and add the yes|no value for hasPhonegap
    has_phonegap = BD.get(zombie_session, 'hasPhonegap')
    if not has_phonegap.nil?
      encoded_has_phonegap = CGI.escapeHTML(has_phonegap)
      encoded_has_phonegap_hash = { 'Has Phonegap' => encoded_has_phonegap }

      page_name_row = {
        'category' => 'Browser',
        'data' => encoded_has_phonegap_hash,
        'from' => 'Initialization'
      }

      summary_grid_hash['results'].push(page_name_row) # add the row
    end

    # set and add the yes|no value for HasGoogleGears
    has_googlegears = BD.get(zombie_session, 'HasGoogleGears')
    if not has_googlegears.nil?
      encoded_has_googlegears = CGI.escapeHTML(has_googlegears)
      encoded_has_googlegears_hash = { 'Has GoogleGears' => encoded_has_googlegears }

      page_name_row = {
        'category' => 'Browser',
        'data' => encoded_has_googlegears_hash,
        'from' => 'Initialization'
      }

      summary_grid_hash['results'].push(page_name_row) # add the row
    end

    # set and add the yes|no value for HasWebSocket
    has_web_socket = BD.get(zombie_session, 'HasWebSocket')
    if not has_web_socket.nil?
      encoded_has_web_socket = CGI.escapeHTML(has_web_socket)
      encoded_has_web_socket_hash = { 'Has WebSockets' => encoded_has_web_socket }

      page_name_row = {
        'category' => 'Browser',
        'data' => encoded_has_web_socket_hash,
        'from' => 'Initialization'
      }

      summary_grid_hash['results'].push(page_name_row) # add the row
    end

    # set and add the yes|no value for HasActiveX
    has_activex = BD.get(zombie_session, 'HasActiveX')
    if not has_activex.nil?
      encoded_has_activex = CGI.escapeHTML(has_activex)
      encoded_has_activex_hash = { 'Has ActiveX' => encoded_has_activex }

      page_name_row = {
        'category' => 'Browser',
        'data' => encoded_has_activex_hash,
        'from' => 'Initialization'
      }

      summary_grid_hash['results'].push(page_name_row) # add the row
    end

    # set and add the return values for hasSessionCookies
    has_session_cookies = BD.get(zombie_session, 'hasSessionCookies')
    if not has_session_cookies.nil?
      encoded_has_session_cookies = CGI.escapeHTML(has_session_cookies)
      encoded_has_session_cookies_hash = { 'Session Cookies' => encoded_has_session_cookies }

      page_name_row = {
        'category' => 'Browser',
        'data' => encoded_has_session_cookies_hash,
        'from' => 'Initialization'
      }

      summary_grid_hash['results'].push(page_name_row) # add the row
    end

    # set and add the return values for hasPersistentCookies
    has_persistent_cookies = BD.get(zombie_session, 'hasPersistentCookies')
    if not has_persistent_cookies.nil?
      encoded_has_persistent_cookies = CGI.escapeHTML(has_persistent_cookies)
      encoded_has_persistent_cookies_hash = { 'Persistent Cookies' => encoded_has_persistent_cookies }

      page_name_row = {
        'category' => 'Browser',
        'data' => encoded_has_persistent_cookies_hash,
        'from' => 'Initialization'
      }

      summary_grid_hash['results'].push(page_name_row) # add the row
    end
 
    @body = summary_grid_hash.to_json  
  end
      
  # Returns the list of all command_modules in a JSON format
  def select_all_command_modules
    @body = command_modules2json(BeEF::Modules.get_enabled.keys)
  end

  # Set the correct icon for the command module
  def set_command_module_icon(status)
      path = BeEF::Extension::AdminUI::Constants::Icons::MODULE_TARGET_IMG_PATH # add icon path
      case status
      when BeEF::Core::Constants::CommandModule::VERIFIED_NOT_WORKING
        path += BeEF::Extension::AdminUI::Constants::Icons::VERIFIED_NOT_WORKING_IMG
      when BeEF::Core::Constants::CommandModule::VERIFIED_USER_NOTIFY
        path += BeEF::Extension::AdminUI::Constants::Icons::VERIFIED_USER_NOTIFY_IMG
      when BeEF::Core::Constants::CommandModule::VERIFIED_WORKING
        path += BeEF::Extension::AdminUI::Constants::Icons::VERIFIED_WORKING_IMG
      when BeEF::Core::Constants::CommandModule::VERIFIED_UNKNOWN
        path += BeEF::Extension::AdminUI::Constants::Icons::VERIFIED_UNKNOWN_IMG
      else
        path += BeEF::Extension::AdminUI::Constants::Icons::VERIFIED_UNKNOWN_IMG
      end
      #return path
      path
  end

   # Set the correct working status for the command module
  def set_command_module_status(mod)
      hook_session_id = @params['zombie_session'] || nil
      if hook_session_id == nil
          return BeEF::Core::Constants::CommandModule::VERIFIED_UNKNOWN
      end
      return BeEF::Module.support(mod, {'browser' => BD.get(hook_session_id, 'BrowserName'), 'ver' => BD.get(hook_session_id, 'BrowserVersion'), 'os' => [BD.get(hook_session_id, 'OsName')]})
  end

  # If we're adding a leaf to the command tree, and it's in a subfolder, we need to recurse
  # into the tree to find where it goes
  def update_command_module_tree_recurse(tree,category,leaf)
    working_category = category.shift

    tree.each {|t|
      if t['text'].eql? working_category and category.count > 0
        #We have deeper to go
        update_command_module_tree_recurse(t['children'],category,leaf)
      elsif t['text'].eql? working_category
        #Bingo
        t['children'].push(leaf)
        break
      end
    }

    #return tree

  end

  #Add the command to the tree
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
        #The category is an array, therefore it's a sub-folderised category
        cat_copy = cmd_category.dup #Don't work with the original array, because, then it breaks shit
        update_command_module_tree_recurse(tree,cat_copy,leaf_node)
      else
        #original logic here, simply add the command to the tree.
        tree.each {|x|
          if x['text'].eql? cmd_category
            x['children'].push( leaf_node )
              break
          end
        }
      end
  end

  #Recursive function to build the tree now with sub-folders
  def build_recursive_tree(parent,input)
   cinput = input.shift.chomp('/')
   if cinput.split('/').count == 1 #then we have a single folder now
     if parent.detect {|p| p['text'] == cinput}.nil?
       parent << {'text' => cinput, 'cls' => 'folder', 'children' => []}
     else
       if input.count > 0
         parent.each {|p|
           if p['text'] == cinput
             p['children'] = build_recursive_tree(p['children'],input)
           end
         }
       end
     end
   else
     #we have multiple folders
     newinput = cinput.split('/')
     newcinput = newinput.shift
     if parent.detect {|p| p['text'] == newcinput }.nil?
       fldr = {'text' => newcinput, 'cls' => 'folder', 'children' => []}
       parent << build_recursive_tree(fldr['children'],newinput)
     else
       parent.each {|p|
         if p['text'] == newcinput
           p['children'] = build_recursive_tree(p['children'],newinput)
         end
       }
     end
   end

    if input.count > 0
      return build_recursive_tree(parent,input)
    else
      return parent
    end
  end

  #Recursive function to sort all the parent's children
  def sort_recursive_tree(parent)
    # sort the children nodes by status and name
    parent.each {|x| 
      #print_info "Sorting: " + x['children'].to_s
      if x.is_a?(Hash) and x.has_key?('children')
        x['children'] = x['children'].sort_by {|a| 
          fldr = a['cls'] ? a['cls'] : 'zzzzz'
          "#{fldr}#{a['status']}#{a['text']}"
        }
        x['children'].each {|c|
          sort_recursive_tree([c]) if c.has_key?('cls') and c['cls'] == 'folder'
       }
     end
    }
  end

  #Recursive function to retitle folders with the number of children
  def retitle_recursive_tree(parent)
    # append the number of command modules so the branch name results in: "<category name> (num)"
    parent.each {|command_module_branch|
      if command_module_branch.is_a?(Hash) and command_module_branch.has_key?('children')
        num_of_command_modules = command_module_branch['children'].length
        command_module_branch['text'] = command_module_branch['text'] + " (" + num_of_command_modules.to_s() + ")"

        command_module_branch['children'].each {|c|
          retitle_recursive_tree([c]) if c.has_key?('cls') and c['cls'] == 'folder'
        }
      end
    }
  end

  # Returns the list of all command_modules for a TreePanel in the interface.
  def select_command_modules_tree
    blanktree = []
    tree = []

    #Due to the sub-folder nesting, we use some really badly hacked together recursion
    #Note to the bored - if someone (anyone please) wants to refactor, I'll buy you cookies. -x
    tree = build_recursive_tree(blanktree,BeEF::Modules.get_categories)

    BeEF::Modules.get_enabled.each{|k, mod|
      # get the hooked browser session id and set it in the command module
      hook_session_id = @params['zombie_session'] || nil
      (print_error "hook_session_id is nil";return) if hook_session_id.nil?

      # create url path and file for the command module icon
      command_module_status = set_command_module_status(k)
      command_module_icon_path = set_command_module_icon(command_module_status)

      update_command_module_tree(tree, mod['category'], command_module_icon_path, command_module_status, mod['name'],mod['db']['id'])
    }

    # if dynamic modules are found in the DB, then we don't have yaml config for them
    # and loading must proceed in a different way.
    dynamic_modules = BeEF::Core::Models::CommandModule.all(:path.like => "Dynamic/")

    if(dynamic_modules != nil)
         all_modules = BeEF::Core::Models::CommandModule.all(:order => [:id.asc])
         all_modules.each{|dyn_mod|
         next if !dyn_mod.path.split('/').first.match(/^Dynamic/)

         hook_session_id = @params['zombie_session'] || nil
         (print_error "hook_session_id is nil";return) if hook_session_id.nil?

          dyn_mod_name = dyn_mod.path.split('/').last
          dyn_mod_category = nil
          if(dyn_mod_name == "Msf")
             dyn_mod_category = "Metasploit"
          else
             # future dynamic modules...
          end

          print_debug ("Loading Dynamic command module: category [#{dyn_mod_category}] - name [#{dyn_mod.name.to_s}]")
          command_mod = BeEF::Modules::Commands.const_get(dyn_mod_name.capitalize).new
          command_mod.session_id = hook_session_id
          command_mod.update_info(dyn_mod.id)
          command_mod_name = command_mod.info['Name'].downcase

          # create url path and file for the command module icon
          #command_module_status = set_command_module_status(command_mod)
          command_module_status = BeEF::Core::Constants::CommandModule::VERIFIED_UNKNOWN
          command_module_icon_path = set_command_module_icon(command_mod)

         update_command_module_tree(tree, dyn_mod_category, command_module_icon_path, command_module_status, command_mod_name,dyn_mod.id)
       }
    end
      
    # sort the parent array nodes 
    tree.sort! {|a,b| a['text'] <=> b['text']}
    
    sort_recursive_tree(tree)

    retitle_recursive_tree(tree)
    

      
    # return a JSON array of hashes
    @body = tree.to_json
  end
  
  # Returns the inputs definition of an command_module.
  def select_command_module
    command_module_id = @params['command_module_id'] || nil
    (print_error "command_module_id is nil";return) if command_module_id.nil?
    command_module = BeEF::Core::Models::CommandModule.get(command_module_id)
    key = BeEF::Module.get_key_by_database_id(command_module_id)

    payload_name = @params['payload_name'] || nil
    if not payload_name.nil?
      @body = dynamic_payload2json(command_module_id, payload_name)
     else
       @body = command_modules2json([key])
    end
  end
  
  # Returns the list of commands for an command_module
  def select_command_module_commands
    commands = []
    i=0

    # get params
    zombie_session = @params['zombie_session'] || nil
    (print_error "Zombie session is nil";return) if zombie_session.nil?
    command_module_id = @params['command_module_id'] || nil
    (print_error "command_module id is nil";return) if command_module_id.nil?
    # validate nonce
    nonce = @params['nonce'] || nil
    (print_error "nonce is nil";return) if nonce.nil?
    (print_error "nonce incorrect";return) if @session.get_nonce != nonce
    
    # get the browser id
    zombie = Z.first(:session => zombie_session)
    (print_error "Zombie is nil";return) if zombie.nil?
    zombie_id = zombie.id
    (print_error "Zombie id is nil";return) if zombie_id.nil?
      
    C.all(:command_module_id => command_module_id, :hooked_browser_id => zombie_id).each do |command|
      commands.push({
        'id' => i, 
        'object_id' => command.id, 
        'creationdate' => Time.at(command.creationdate.to_i).strftime("%Y-%m-%d %H:%M").to_s, 
        'label' => command.label
        })
      i+=1
    end
      
    @body = {
      'success' => 'true', 
      'commands' => commands}.to_json
      
  end
  
  # Attaches an command_module to a zombie.
  def attach_command_module
    
    definition = {}

    # get params
    zombie_session = @params['zombie_session'] || nil
    (print_error "Zombie id is nil";return) if zombie_session.nil?
    command_module_id = @params['command_module_id'] || nil
    (print_error "command_module id is nil";return) if command_module_id.nil?
    # validate nonce
    nonce = @params['nonce'] || nil
    (print_error "nonce is nil";return) if nonce.nil?
    (print_error "nonce incorrect";return) if @session.get_nonce != nonce
    
    @params.keys.each {|param| 
      (print_error "invalid key param string";return) if not BeEF::Filters.has_valid_param_chars?(param)
      (print_error "first char is num";return) if BeEF::Filters.first_char_is_num?(param)
      definition[param[4..-1]] = params[param]
      oc = BeEF::Core::Models::OptionCache.first_or_create(:name => param[4..-1])
      oc.value = params[param]
	    oc.save
    }

    mod_key = BeEF::Module.get_key_by_database_id(command_module_id)
    # Hack to rework the old option system into the new option system
    def2 = []
    definition.each{|k,v|
        def2.push({'name' => k, 'value' => v})
    }
    # End hack
    exec_results = BeEF::Module.execute(mod_key, zombie_session, def2)
    @body = (exec_results != nil) ? '{success: true}' : '{success: false}'
  end
  
  # Re-execute an command_module to a zombie.
  def reexecute_command_module
    
    # get params
    command_id = @params['command_id'] || nil
    (print_error "Command id is nil";return) if command_id.nil?
    command = BeEF::Core::Models::Command.first(:id => command_id.to_i) || nil
    (print_error "Command is nil";return) if command.nil?
    # validate nonce
    nonce = @params['nonce'] || nil
    (print_error "nonce is nil";return) if nonce.nil?
    (print_error "nonce incorrect";return) if @session.get_nonce != nonce
    
    command.instructions_sent = false
    command.save
    
    @body = '{success : true}'
  end

  def attach_dynamic_command_module
    
    definition = {}

    # get params
    zombie_session = @params['zombie_session'] || nil
    (print_error "Zombie id is nil";return) if zombie_session.nil?
    command_module_id = @params['command_module_id'] || nil
    (print_error "command_module id is nil";return) if command_module_id.nil?
    # validate nonce
    nonce = @params['nonce'] || nil
    (print_error "nonce is nil";return) if nonce.nil?
    (print_error "nonce incorrect";return) if @session.get_nonce != nonce
    
    @params.keys.each {|param| 
      (print_error "invalid key param string";return) if not BeEF::Filters.has_valid_param_chars?(param)
      (print_error "first char is num";return) if BeEF::Filters.first_char_is_num?(param)
      definition[param[4..-1]] = params[param]
      oc = BeEF::Core::Models::OptionCache.first_or_create(:name => param[4..-1])
      oc.value = params[param]
	  oc.save
    }

    zombie = Z.first(:session => zombie_session)
    (print_error "Zombie is nil";return) if zombie.nil?
    zombie_id = zombie.id
    (print_error "Zombie id is nil";return) if zombie_id.nil?
    command_module = BeEF::Core::Models::CommandModule.get(command_module_id)

    if(command_module != nil && command_module.path.match(/^Dynamic/))
      dyn_mod_name = command_module.path.split('/').last
      e = BeEF::Modules::Commands.const_get(dyn_mod_name.capitalize).new
      e.update_info(command_module_id)
      e.update_data()
 	    ret = e.launch_exploit(definition)

      return {'success' => 'false'}.to_json if ret['result'] != 'success'

      basedef = {}
		  basedef['sploit_url'] = ret['uri']

      C.new(  :data => basedef.to_json,
        :hooked_browser_id => zombie_id,
        :command_module_id => command_module_id,
        :creationdate => Time.new.to_i
        ).save

      @body = '{success : true}'
    else
#       return {'success' => 'false'}.to_json
      {'success' => 'false'}.to_json
    end



  end
  
  # Returns the results of a command
  def select_command_results
    results = []
    
    # get params
    command_id = @params['command_id']|| nil
    (print_error "Command id is nil";return) if command_id.nil?
    command = BeEF::Core::Models::Command.first(:id => command_id.to_i) || nil
    (print_error "Command is nil";return) if command.nil?

    # get command_module
    command_module = BeEF::Core::Models::CommandModule.first(:id => command.command_module_id)
    (print_error "command_module is nil";return) if command_module.nil?
    
    resultsdb = BeEF::Core::Models::Result.all(:command_id => command_id)
    (print_error "Command id result is nil";return) if resultsdb.nil?
    
    resultsdb.each{ |result| results.push({'date' => result.date, 'data' => JSON.parse(result.data)}) }
    
    @body = {
      'success'             => 'true', 
      'command_module_name' => command_module.name,
      'command_module_id'   => command_module.id,
      'results'             => results}.to_json

  end
  
  # Returns the definition of a command.
  # In other words it returns the command that was used to command_module a zombie.
  def select_command
    
    # get params
    command_id = @params['command_id'] || nil
    (print_error "Command id is nil";return) if command_id.nil?
    command = BeEF::Core::Models::Command.first(:id => command_id.to_i) || nil
    (print_error "Command is nil";return) if command.nil?

    command_module = BeEF::Core::Models::CommandModule.get(command.command_module_id)
    (print_error "command_module is nil";return) if command_module.nil?

    if(command_module.path.split('/').first.match(/^Dynamic/))
      dyn_mod_name = command_module.path.split('/').last
      e = BeEF::Modules::Commands.const_get(dyn_mod_name.capitalize).new
    else
      command_module_name = command_module.name
      e = BeEF::Core::Command.const_get(command_module_name.capitalize).new(command_module_name)
    end
            
    @body = {
      'success' => 'true', 
      'command_module_name'  => command_module_name,
      'command_module_id'    => command_module.id,
      'data'                 => BeEF::Module.get_options(command_module_name),
      'definition'           => JSON.parse(e.to_json)
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
          'Name'=> config.get("beef.module.#{command_module}.name"),
          'Description'=> config.get("beef.module.#{command_module}.description"),
          'Category'=> config.get("beef.module.#{command_module}.category"),
          'Data'=> BeEF::Module.get_options(command_module)
        }
        command_modules_json[i] = h
        i += 1
    end
    
    if not command_modules_json.empty?
      return {'success' => 'true', 'command_modules' => command_modules_json}.to_json
    else
      return {'success' => 'false'}.to_json
    end
  end

  # return the input requred for the module in JSON format
  def dynamic_modules2json(id)
    command_modules_json = {}
    
    mod = BeEF::Core::Models::CommandModule.first(:id => id)

    # if the module id is not in the database return false
    return {'success' => 'false'}.to_json if(not mod)
    
    # the path will equal Dynamic/<type> and this will get just the type
		dynamic_type = mod.path.split("/").last
		
    e = BeEF::Modules::Commands.const_get(dynamic_type.capitalize).new
    e.update_info(mod.id)
    e.update_data()
    command_modules_json[1] = JSON.parse(e.to_json)
    if not command_modules_json.empty?
        return {'success' => 'true', 'dynamic' => 'true', 'command_modules' => command_modules_json}.to_json
    else
        return {'success' => 'false'}.to_json
    end
  end

  def dynamic_payload2json(id, payload_name)
    command_modules_json = {}

    command_module = BeEF::Core::Models::CommandModule.get(id)
    (print_error "Module does not exists";return 'success' => 'false') if command_module.nil?

    payload_options = BeEF::Module.get_payload_options(command_module.name,payload_name)
    # get payload options in JSON
    #e = BeEF::Modules::Commands.const_get(dynamic_type.capitalize).new
    payload_options_json = []
    payload_options_json[1] = payload_options
    #payload_options_json[1] = e.get_payload_options(payload_name)
    return {'success' => 'true', 'command_modules' => payload_options_json}.to_json

  end
  
end

end
end
end
end
