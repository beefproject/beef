#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Console

class ShellInterface

  BD = BeEF::Core::Models::BrowserDetails

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

  # @note Get commands. This is a *modified* replica of select_command_modules_tree from extensions/admin_ui/controllers/modules/modules.rb
  def getcommands

    return if self.targetid.nil?

    tree = []
    BeEF::Modules.get_categories.each { |c|
        if c[-1,1] != "/"
          c.concat("/")
        end
        tree.push({
            'text' => c,
            'cls' => 'folder',
            'children' => []
        })
    }

    BeEF::Modules.get_enabled.each{|k, mod|

      flatcategory = ""
      if mod['category'].kind_of?(Array)
        # Therefore this module has nested categories (sub-folders), munge them together into a string with '/' characters, like a folder.
        mod['category'].each {|cat|
          flatcategory << cat + "/"
        }
      else
        flatcategory = mod['category']
        if flatcategory[-1,1] != "/"
          flatcategory.concat("/")
        end
      end

      update_command_module_tree(tree, flatcategory, get_command_module_status(k), mod['name'],mod['db']['id'])
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
          return "Verified Not Working"
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

  # @note Returns a JSON array containing the summary for a selected zombie.
  # Yoinked from the UI panel -
  # we really need to centralise all this stuff and encapsulate it away.
  def select_zombie_summary

    return if self.targetsession.nil?

    # init the summary grid
    summary_grid_hash = {
      'success' => 'true',
      'results' => []
    }

    # zombie properties
    # in the form of: category, UI label, value
    zombie_properties = [

        # Browser
        ['Browser', 'Browser Name',       'BrowserName'],
        ['Browser', 'Browser Version',    'BrowserVersion'],
        ['Browser', 'Browser UA String',  'BrowserReportedName'],
        ['Browser', 'Browser Platform',   'BrowserPlatform'],
        ['Browser', 'Browser Plugins',    'BrowserPlugins'],
        ['Browser', 'Window Size',        'WindowSize'],

        # Browser Components
        ['Browser Components', 'Flash',              'HasFlash'],
        ['Browser Components', 'Java',               'JavaEnabled'],
        ['Browser Components', 'VBScript',           'VBScriptEnabled'],
        ['Browser Components', 'PhoneGap',           'HasPhonegap'],
        ['Browser Components', 'Google Gears',       'HasGoogleGears'],
        ['Browser Components', 'Silverlight',        'HasSilverlight'],
        ['Browser Components', 'Web Sockets',        'HasWebSocket'],
        ['Browser Components', 'QuickTime',          'HasQuickTime'],
        ['Browser Components', 'RealPlayer',         'HasRealPlayer'],
        ['Browser Components', 'Windows Media Player','HasWMP'], 
        ['Browser Components', 'VLC',                'HasVLC'],
        ['Browser Components', 'Foxit',              'HasFoxit'],
        ['Browser Components', 'WebRTC',             'HasWebRTC'],
        ['Browser Components', 'ActiveX',            'HasActiveX'],
        ['Browser Components', 'Session Cookies',    'hasSessionCookies'],
        ['Browser Components', 'Persistent Cookies', 'hasPersistentCookies'],

        # Hooked Page
        ['Hooked Page', 'Page Title',    'PageTitle'],
        ['Hooked Page', 'Page URI',      'PageURI'],
        ['Hooked Page', 'Page Referrer', 'PageReferrer'],
        ['Hooked Page', 'Hook Host',     'HostName'],
        ['Hooked Page', 'Cookies',       'Cookies'],

        # Host
        ['Host', 'Date',             'DateStamp'],
        ['Host', 'Operating System', 'OsName'],
        ['Host', 'Hardware',         'Hardware'],
        ['Host', 'CPU',              'CPU'],
        ['Host', 'Screen Size',      'ScreenSize'],
        ['Host', 'Touch Screen',     'TouchEnabled']
    ]

    # set and add the return values for each browser property
    # in the form of: category, UI label, value
    zombie_properties.each do |p|

      case p[2]
        when "BrowserName"
          data   = BeEF::Core::Constants::Browsers.friendly_name(BD.get(self.targetsession.to_s, p[2])).to_s

        when "ScreenSize"
          screen_size_hash = JSON.parse(BD.get(self.targetsession.to_s, p[2]).gsub(/\"\=\>/, '":')) # tidy up the string for JSON
          width  = screen_size_hash['width']
          height = screen_size_hash['height']
          cdepth = screen_size_hash['colordepth']
          data   = "Width: #{width}, Height: #{height}, Colour Depth: #{cdepth}"

        when "WindowSize"
          window_size_hash = JSON.parse(BD.get(self.targetsession.to_s, p[2]).gsub(/\"\=\>/, '":')) # tidy up the string for JSON
          width  = window_size_hash['width']
          height = window_size_hash['height']
          data   = "Width: #{width}, Height: #{height}"
        else
          data   = BD.get(self.targetsession, p[2])
      end

      # add property to summary hash
      if not data.nil?
        summary_grid_hash['results'].push({
          'category' => p[0],
          'data'     => { p[1] => CGI.escapeHTML("#{data}") },
          'from'     => 'Initialization'
        })
      end

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
