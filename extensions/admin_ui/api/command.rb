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
module Extension
module AdminUI
module API
  
  module CommandExtension
    
    extend BeEF::API::Command
    
    include BeEF::Core::Constants::Browsers
    include BeEF::Core::Constants::CommandModule
    
    #
    # verify whether this command module has been checked against the target browser
    # this function is used when determining the code of the node icon
    #
    def verify_target

      return VERIFIED_UNKNOWN if not @target # no target specified in the module

      # loop through each definition and check it
      @target.each {|definition| 
        return definition['verified_status'] if test_target(definition)
      }

      return VERIFIED_UNKNOWN

    end
    
    #
    # test if the target definition matches the hooked browser
    # this function is used when determining the code of the node icon
    #
    def test_target_attribute(hb_attr_name, hb_attr_ver, target_attr_name, target_attr_max_ver, target_attr_min_ver)

      # check if wild cards are set
      return true if not target_attr_name
      return true if target_attr_name.nil?
      return true if target_attr_name.eql? ALL

      # can't answer based on hb_attr_name
      return false if not hb_attr_name
      return false if hb_attr_name.nil?
      return false if hb_attr_name.eql? UNKNOWN
      
      # check if the attribute is targeted
      return false if not target_attr_name.eql? hb_attr_name
      
      # assume that the max version and min version were purposefully excluded 
      return true if target_attr_max_ver.nil? && target_attr_min_ver.nil?
      
      # check if the framework can detect hb version
      return false if hb_attr_ver.eql? 'UNKNOWN'
      
      # check the version number is within range
      return false if hb_attr_ver.to_f > target_attr_max_ver.to_f
      return false if hb_attr_ver.to_f < target_attr_min_ver.to_f
      
      # all the checks passed
      true
    end
    
    #
    # test if the target definition matches the hooked browser
    # this function is used when determining the code of the node icon
    #
    def test_target(target_definition)
      
      # if the definition is nill we don't know
      return false if target_definition.nil?
      
      # check if the browser is a target
      hb_browser_name = get_browser_detail('BrowserName')
      hb_browser_version = get_browser_detail('BrowserVersion')
      target_browser_name = target_definition['browser_name']
      target_browser_max_ver = target_definition['browser_max_ver']
      target_browser_min_ver = target_definition['browser_min_ver']
      browser_match = test_target_attribute(hb_browser_name, hb_browser_version, target_browser_name, target_browser_max_ver, target_browser_min_ver)

      # check if the operating system is a target
      hb_os_name = get_browser_detail('OsName')
      target_os_name = target_definition['os_name']
      os_match =  test_target_attribute(hb_os_name, nil, target_os_name, nil, nil)
      return browser_match && os_match

    end
    
    #
    # Get the browser detail from the database.
    #
    def get_browser_detail(key)
      bd = BeEF::Extension::Initialization::Models::BrowserDetails
      raise WEBrick::HTTPStatus::BadRequest, "@session_id is invalid" if not BeEF::Filters.is_valid_hook_session_id?(@session_id)
      bd.get(@session_id, key)
    end
  end
  
end
end
end
end