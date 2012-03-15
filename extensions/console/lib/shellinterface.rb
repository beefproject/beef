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

class ShellInterface
  
  BD = BeEF::Extension::Initialization::Models::BrowserDetails
  
  def initialize(config)
    self.config = config
    self.cmd = {}
  end
  
  def settarget(id)
    begin
      self.targetsession = BeEF::Core::Models::HookedBrowser.first(:id => id).session
      self.targetip = BeEF::Core::Models::HookedBrowser.first(:id => id).ip
      self.targetid = id
    rescue
      return nil
    end
  end
  
  def setofflinetarget(id)
    begin
      self.targetsession = BeEF::Core::Models::HookedBrowser.first(:id => id).session
      self.targetip = "(OFFLINE) " + BeEF::Core::Models::HookedBrowser.first(:id => id).ip
      self.targetid = id
    rescue
      return nil
    end
  end
  
  def cleartarget
    self.targetsession = nil
    self.targetip = nil
    self.targetid = nil
    self.cmd = {}
  end

  # This is a *modified* replica of select_command_modules_tree from extensions/admin_ui/controllers/modules/modules.rb
  def getcommands
    
    return if self.targetid.nil?
    
    tree = []
    BeEF::Modules.get_categories.each { |c|
        tree.push({
            'text' => c,
            'cls' => 'folder',
            'children' => []
        })
    }

    BeEF::Modules.get_enabled.each{|k, mod|
      update_command_module_tree(tree, mod['category'], get_command_module_status(k), mod['name'],mod['db']['id'])
    }

    # if dynamic modules are found in the DB, then we don't have yaml config for them
    # and loading must proceed in a different way.
    dynamic_modules = BeEF::Core::Models::CommandModule.all(:path.like => "Dynamic/")

    if(dynamic_modules != nil)
      all_modules = BeEF::Core::Models::CommandModule.all(:order => [:id.asc])
      all_modules.each{|dyn_mod|
        next if !dyn_mod.path.split('/').first.match(/^Dynamic/)

        dyn_mod_name = dyn_mod.path.split('/').last
        dyn_mod_category = nil
        if(dyn_mod_name == "Msf")
          dyn_mod_category = "Metasploit"
        else
          # future dynamic modules...
        end

        #print_debug ("Loading Dynamic command module: category [#{dyn_mod_category}] - name [#{dyn_mod.name.to_s}]")
        command_mod = BeEF::Modules::Commands.const_get(dyn_mod_name.capitalize).new
        command_mod.session_id = hook_session_id
        command_mod.update_info(dyn_mod.id)
        command_mod_name = command_mod.info['Name'].downcase

        update_command_module_tree(tree, dyn_mod_category, "Verified Unknown", command_mod_name,dyn_mod.id)
       }
    end
    
    # sort the parent array nodes 
    tree.sort! {|a,b| a['text'] <=> b['text']}
  
    # sort the children nodes by status
    tree.each {|x| x['children'] =
      x['children'].sort_by {|a| a['status']}
    }
    
    # append the number of command modules so the branch name results in: "<category name> (num)"
    #tree.each {|command_module_branch|
    #  num_of_command_modules = command_module_branch['children'].length
    #  command_module_branch['text'] = command_module_branch['text'] + " (" + num_of_command_modules.to_s() + ")"
    #}
    
    # return a JSON array of hashes
    tree
  end
  
  def setcommand(id)
    key = BeEF::Module.get_key_by_database_id(id.to_i)
    
    self.cmd['id'] = id
    self.cmd['Name'] = self.config.get("beef.module.#{key}.name")
    self.cmd['Description'] = self.config.get("beef.module.#{key}.description")
    self.cmd['Category'] = self.config.get("beef.module.#{key}.category")
    self.cmd['Data'] = BeEF::Module.get_options(key)
  end
  
  def clearcommand
    self.cmd = {}
  end
  
  def setparam(param,value)
    self.cmd['Data'].each do |data|
      if data['name'] == param
        data['value'] = value
        return
      end
    end
  end
  
  def getcommandresponses(cmdid = self.cmd['id'])
    
    commands = []
    i = 0
    
    BeEF::Core::Models::Command.all(:command_module_id => cmdid, :hooked_browser_id => self.targetid).each do |command|
      commands.push({
        'id' => i,
        'object_id' => command.id,
        'creationdate' => Time.at(command.creationdate.to_i).strftime("%Y-%m-%d %H:%M").to_s,
        'label' => command.label
      })
      i+=1
    end
    
    commands
  end
  
  def getindividualresponse(cmdid)
    results = []
    begin
      BeEF::Core::Models::Result.all(:command_id => cmdid).each { |result|
        results.push({'date' => result.date, 'data' => JSON.parse(result.data)})
      }
    rescue
      return nil
    end
    results
  end
  
  def executecommand
    definition = {}
    options = {}
    options.store("zombie_session", self.targetsession.to_s)
    options.store("command_module_id", self.cmd['id'])
    
    if not self.cmd['Data'].nil?
      self.cmd['Data'].each do |key|
        options.store("txt_"+key['name'].to_s,key['value'])
      end
    end
    
    options.keys.each {|param| 
      definition[param[4..-1]] = options[param]
      oc = BeEF::Core::Models::OptionCache.first_or_create(:name => param[4..-1])
      oc.value = options[param]
	    oc.save
    }
    
    mod_key = BeEF::Module.get_key_by_database_id(self.cmd['id'])
    # Hack to rework the old option system into the new option system
    def2 = []
    definition.each{|k,v|
        def2.push({'name' => k, 'value' => v})
    }
    # End hack
    if BeEF::Module.execute(mod_key, self.targetsession.to_s, def2) != nil
      return true
    else
      return false
    end
    
    #Old method
    #begin
    #  BeEF::Core::Models::Command.new(  :data => definition.to_json,
    #          :hooked_browser_id => self.targetid,
    #          :command_module_id => self.cmd['id'],
    #          :creationdate => Time.new.to_i
    #        ).save
    #rescue
    #  return false
    #end
    
    #return true
  end
  
  def update_command_module_tree(tree, cmd_category, cmd_status, cmd_name, cmd_id)

      # construct leaf node for the command module tree
      leaf_node = {
          'text' => cmd_name,
          'leaf' => true,
          'status' => cmd_status,
          'id' => cmd_id
      }

      # add the node to the branch in the command module tree
      tree.each {|x|
        if x['text'].eql? cmd_category
          x['children'].push( leaf_node )
            break
        end
      }
  end
  
  def get_command_module_status(mod)
      hook_session_id = self.targetsession
      if hook_session_id == nil
          return "Verified Unknown"
      end
      case BeEF::Module.support(mod, {
        'browser' => BD.get(hook_session_id, 'BrowserName'),
        'ver' => BD.get(hook_session_id, 'BrowserVersion'),
        'os' => [BD.get(hook_session_id, 'OsName')]})
      
        when BeEF::Core::Constants::CommandModule::VERIFIED_NOT_WORKING
          return "Verfied Not Working"
        when BeEF::Core::Constants::CommandModule::VERIFIED_USER_NOTIFY
          return "Verified User Notify"
        when BeEF::Core::Constants::CommandModule::VERIFIED_WORKING
          return "Verified Working"
        when BeEF::Core::Constants::CommandModule::VERIFIED_UNKNOWN
          return "Verified Unknown"
        else
          return "Verified Unknown"
      end
  end
  
  #Yoinked from the UI panel - we really need to centralise all this stuff and encapsulate it away??
  def select_zombie_summary
    
    return if self.targetsession.nil?

    # init the summary grid
    summary_grid_hash = {
      'success' => 'true', 
      'results' => []
    }

    # set and add the return values for the page title
    page_title = BD.get(self.targetsession, 'PageTitle') 
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
    page_uri = BD.get(self.targetsession, 'PageURI')
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
    page_referrer = BD.get(self.targetsession, 'PageReferrer')
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
    host_name = BD.get(self.targetsession, 'HostName') 
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
    
    # set and add the return values for the os name
    os_name = BD.get(self.targetsession, 'OsName')
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
    
    # set and add the return values for the browser name
    browser_name = BD.get(self.targetsession, 'BrowserName') 
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
    browser_version = BD.get(self.targetsession, 'BrowserVersion') 
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
    browser_uastring = BD.get(self.targetsession, 'BrowserReportedName')
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
    cookies = BD.get(self.targetsession, 'Cookies')
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
    browser_plugins = BD.get(self.targetsession, 'BrowserPlugins')
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
    system_platform = BD.get(self.targetsession, 'SystemPlatform')
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
    screen_params = BD.get(self.targetsession, 'ScreenParams')
    if not screen_params.nil?
      
      screen_params_hash = JSON.parse(screen_params.gsub(/\"\=\>/, '":')) # tidy up the string for JSON
      width = screen_params_hash['width']
      height = screen_params_hash['height']
      colordepth = screen_params_hash['colordepth']

      # construct the string to be displayed in the details tab
      encoded_screen_params = CGI.escapeHTML("Width: "+width.to_s + ", Height: " + height.to_s + ", Colour Depth: " + colordepth.to_s)
      encoded_screen_params_hash = { 'Screen Params' => encoded_screen_params }
      
      page_name_row = {
        'category' => 'Host',
        'data' => encoded_screen_params_hash,
        'from' => 'Initialization'
      }

      summary_grid_hash['results'].push(page_name_row) # add the row
    end

    # set and add the zombie browser window size
    window_size = BD.get(self.targetsession, 'WindowSize')
    if not window_size.nil?

      window_size_hash = JSON.parse(window_size.gsub(/\"\=\>/, '":')) # tidy up the string for JSON
      width = window_size_hash['width']
      height = window_size_hash['height']

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
    java_enabled = BD.get(self.targetsession, 'JavaEnabled')
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
    vbscript_enabled = BD.get(self.targetsession, 'VBScriptEnabled')
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
    has_flash = BD.get(self.targetsession, 'HasFlash')
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

    # set and add the yes|no value for HasGoogleGears
    has_googlegears = BD.get(self.targetsession, 'HasGoogleGears')
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
    has_web_socket = BD.get(self.targetsession, 'HasWebSocket')
    if not has_web_socket.nil?
      encoded_has_web_socket = CGI.escapeHTML(has_web_socket)
      encoded_has_web_socket_hash = { 'Has GoogleGears' => encoded_has_web_socket }

      page_name_row = {
        'category' => 'Browser',
        'data' => encoded_has_web_socket_hash,
        'from' => 'Initialization'
      }

      summary_grid_hash['results'].push(page_name_row) # add the row
    end

    # set and add the yes|no value for HasActiveX
    has_activex = BD.get(self.targetsession, 'HasActiveX')
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
    has_session_cookies = BD.get(self.targetsession, 'hasSessionCookies')
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
    has_persistent_cookies = BD.get(self.targetsession, 'hasPersistentCookies')
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
 
    summary_grid_hash
  end
  
  attr_reader :targetsession
  attr_reader :targetid
  attr_reader :targetip
  attr_reader :cmd
  
  protected
  
  attr_writer :targetsession
  attr_writer :targetid
  attr_writer :targetip
  attr_writer :cmd
  attr_accessor :config

end

end end end
