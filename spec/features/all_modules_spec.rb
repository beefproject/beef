#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'rspec'
require 'rest-client'
require 'spec/support/constants.rb'
require 'spec/support/ui_support.rb'

RSpec.describe 'Load All Modules Integration', run_on_long_tests: true  do
    before(:each) do
        @pid, @beef_session, @hooked_browser = start_beef_and_hook_browser
    end

    after(:each) do
        stop_beef_and_unhook_browser(@pid, @beef_session, @hooked_browser)
    end
    
    it "Load all modules" do
        
        Dir.glob("modules/**/config.yaml").each do |file|
            module_yaml_data = YAML.load_file(file)
            
            module_yaml_data['beef']['module'].each do |module_key, module_value|
                next if rand(50) != 0 # for testing purposes only
                
                next if not module_value['enable'] # skip disabled modules
                
                module_name = module_value['name']
                module_category = module_value['category'] # can be an array or a string
                module_description_sub = module_value['description'][0, 15]  # descriptions including html cause errors
                
                expect(module_category).not_to be_nil
                expect(module_name).not_to be_nil
                
                expect(@beef_session).to have_content(module_category, wait: PAGE_LOAD_TIMEOUT) if module_category.is_a?(String)
                
                expect(module_name).to be_a(String)
                expect(module_description_sub).not_to be_nil
                expect(module_description_sub).to be_a(String)
                
                # print the category and module name
                if module_category.is_a?(Array) 
                    category_tree_text =  module_category.join(' > ')
                else
                    category_tree_text = module_category
                end
                print_info "Category: #{category_tree_text}, Module: #{module_name}"
                
                # click on the module then expect the description and execute button to be visible
                click_on_module(@beef_session, module_category, module_name)
                
                # expect the module description and the execute button to be visible
                expect(@beef_session).to have_content(module_description_sub, wait: PAGE_LOAD_TIMEOUT)
                expect(@beef_session).to have_content('Execute', wait: PAGE_LOAD_TIMEOUT)

                # tidy up and collapse the category tree
                collapse_category_tree(@beef_session, module_category)
            end
        end
    end
end