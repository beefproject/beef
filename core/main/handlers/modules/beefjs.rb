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
module Core
module Handlers
module Modules
  
  #
  # Purpose: avoid rewriting several times the same code.
  #
  module BeEFJS
    
    #
    # Builds the default beefjs library (all default components of the library).
    #
    # @param: {Object} the hook session id
    # @param: {Boolean} if the framework is already loaded in the hooked browser
    #
    def build_beefjs!(req_host)

      # set up values required to construct beefjs
      beefjs = '' #  init the beefjs string (to be sent as the beefjs file)
      beefjs_path = "#{$root_dir}/core/main/client/" # location of sub files      
      js_sub_files = %w(lib/jquery-1.6.2.min.js lib/evercookie.js lib/json2.js beef.js browser.js browser/cookie.js session.js os.js dom.js logger.js net.js updater.js encode/base64.js encode/json.js net/local.js init.js)

      # construct the beefjs string from file(s)
      js_sub_files.each {|js_sub_file_name|
        js_sub_file_abs_path = beefjs_path + js_sub_file_name # construct absolute path
        beefjs << (File.read(js_sub_file_abs_path) + "\n\n") # concat each js sub file
      }
      
      # create the config for the hooked browser session
      config = BeEF::Core::Configuration.instance
      hook_session_name = config.get('beef.http.hook_session_name')
      hook_session_config = BeEF::Core::Server.instance.to_h

      # if http_host="0.0.0.0" in config ini, use the host requested by client
      if hook_session_config['beef_host'].eql? "0.0.0.0" 
        hook_session_config['beef_host'] = req_host 
        hook_session_config['beef_url'].sub!(/0\.0\.0\.0/, req_host)  
      end
      
      # populate place holders in the beefjs string and set the response body
      eruby = Erubis::FastEruby.new(beefjs)
      @body << eruby.evaluate(hook_session_config)
  
    end
    
    #
    # Finds the path to js components
    #
    def find_beefjs_component_path(component)
      component_path = component
      component_path.gsub!(/beef./, '')
      component_path.gsub!(/\./, '/')
      component_path.replace "#{$root_dir}/core/main/client/#{component_path}.js"
      
      return false if not File.exists? component_path
      
      component_path
    end
    
    #
    # Builds missing beefjs components.
    #
    # Ex: build_missing_beefjs_components(['beef.net.local', 'beef.net.requester'])
    #
    def build_missing_beefjs_components(beefjs_components)
      # verifies that @beef_js_cmps is not nil to avoid bugs
      @beef_js_cmps = '' if @beef_js_cmps.nil?
      
      if beefjs_components.is_a? String
        beefjs_components_path = find_beefjs_component_path(beefjs_components)
        raise "Invalid component: could not build the beefjs file" if not beefjs_components_path
        beefjs_components = {beefjs_components => beefjs_components_path} 
      end

      beefjs_components.keys.each {|k|
        next if @beef_js_cmps.include? beefjs_components[k]
        
        # path to the component
        component_path = beefjs_components[k]
        
        # we output the component to the hooked browser
        @body << File.read(component_path)+"\n\n"
        
        # finally we add the component to the list of components already generated so it does not
        # get generated numerous times.
        if @beef_js_cmps.eql? ''
          @beef_js_cmps = component_path
        else
          @beef_js_cmps += ",#{component_path}"
        end
      }
    end

  end
  
end
end
end
end
