#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Text_to_voice < BeEF::Core::Command
  def pre_send
    # Check for required binaries
    if IO.popen(%w[which espeak], 'r').read.to_s.eql?('')
      print_error('[Text to Voice] eSpeak is not in $PATH (brew install espeak on macOS, apt-get install espeak on Linux)')
      return
    end
    if IO.popen(%w[which lame], 'r').read.to_s.eql?('')
      print_error('[Text to Voice] Lame is not in $PATH (brew install lame on macOS, apt-get install lame on Linux)')
      return
    end

    # Load espeak gem (only if binaries are available)
    begin
      require 'espeak'
      include ESpeak
    rescue LoadError, StandardError => e
      print_error("[Text to Voice] Failed to load espeak gem: #{e.message}")
      return
    end

    # Validate module options
    message = nil
    language = nil
    @datastore.each do |input|
      message  = input['value'] if input['name'] == 'message'
      language = input['value'] if input['name'] == 'language'
    end
    
    # Validate language
    begin
      unless Voice.all.map(&:language).include?(language)
        print_error("[Text to Voice] Language '#{language}' is not supported")
        print_more("Supported languages: #{Voice.all.map(&:language).join(',')}")
        return
      end
    rescue StandardError => e
      print_error("[Text to Voice] Could not validate language: #{e.message}")
      return
    end

    # Convert text to voice, encode as mp3 and write to module directory
    begin
      msg = Speech.new(message.to_s, voice: language)
      mp3_path = "modules/social_engineering/text_to_voice/mp3/msg-#{@command_id}.mp3"
      msg.save(mp3_path)
    rescue StandardError => e
      print_error("[Text to Voice] Could not create mp3: #{e.message}")
      return
    end

    # Mount the mp3 to /objects/
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind(
      "/#{mp3_path}",
      "/objects/msg-#{@command_id}",
      'mp3'
    )
  end

  def self.options
    [
      { 'name' => 'message',
        'description' => 'Text to read',
        'type' => 'textarea',
        'ui_label' => 'Text',
        'value' => 'Hello; from beef',
        'width' => '400px' },
      { 'name' => 'language',
        'description' => 'Language',
        'type' => 'text',
        'ui_label' => 'Language',
        'value' => 'en' }
    ]
  end

  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind("/objects/msg-#{@command_id}.mp3")
  end
end
