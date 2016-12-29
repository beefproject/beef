#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Text_to_voice < BeEF::Core::Command
  require "espeak"
  include ESpeak

  def pre_send

    # Ensure lame and espeak are installed
    if IO.popen(['which', 'lame'], 'r').read.to_s.eql?('')
      print_error("[Text to Voice] Lame is not in $PATH (apt-get install lame)")
      return
    end
    if IO.popen(['which', 'espeak'], 'r').read.to_s.eql?('')
      print_error("[Text to Voice] eSpeak is not in $PATH (apt-get install espeak)")
      return
    end

    # Validate module options
    message = nil
    language = nil
    @datastore.each do |input|
      message  = input['value'] if input['name'] == 'message'
      language = input['value'] if input['name'] == 'language'
    end
    unless Voice.all.map { |v| v.language }.include?(language)
      print_error("[Text to Voice] Language '#{language}' is not supported")
      print_more("Supported languages: #{Voice.all.map { |v| v.language }.join(',')}")
      return
    end

    # Convert text to voice, encode as mp3 and write to module directory
    begin
      msg = Speech.new(message.to_s, voice: language)
      mp3_path = "modules/social_engineering/text_to_voice/mp3/msg-#{@command_id}.mp3"
      msg.save(mp3_path)
    rescue => e
      print_error("[Text to Voice] Could not create mp3: #{e.message}")
      return
    end

    # Mount the mp3 to /objects/
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind(
      "/#{mp3_path}",
      "/objects/msg-#{@command_id}",
      'mp3')
  end
 
  def self.options
    return [
      { 'name'        => 'message',
        'description' => 'Text to read',
        'type'        => 'textarea',
        'ui_label'    => 'Text',
        'value'       => 'Hello; from beef',
        'width'       => '400px' },
      { 'name'        => 'language',
        'description' => 'Language',
        'type'        => 'text',
        'ui_label'    => 'Language',
        'value'       => 'en' }]
  end

  def post_execute     
    content = {}
    content['result'] = @datastore['result']          
    save content   
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind("/objects/msg-#{@command_id}.mp3")
  end
  
end
