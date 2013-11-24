#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Webcam_permission_check < BeEF::Core::Command
  def pre_send
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/browser/webcam_permission_check/cameraCheck.swf', '/cameraCheck', 'swf')
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/browser/webcam_permission_check/swfobject.js', '/swfobject', 'js')
  end
  
  def post_execute 

  	BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/cameraCheck.swf')
	BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/swfobject.js')
  end

end
