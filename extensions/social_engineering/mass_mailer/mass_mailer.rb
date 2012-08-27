#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
module BeEF
  module Extension
    module SocialEngineering
      class MassMailer
        require 'net/smtp'
        require 'base64'
        include Singleton

        def initialize
          @config = BeEF::Core::Configuration.instance
          @user_agent = @config.get('beef.extension.social_engineering.mass_mailer.user_agent')
          @host = @config.get('beef.extension.social_engineering.mass_mailer.host')
          @port = @config.get('beef.extension.social_engineering.mass_mailer.port')
          @helo = @config.get('beef.extension.social_engineering.mass_mailer.helo')
          @from = @config.get('beef.extension.social_engineering.mass_mailer.from')
          @password = @config.get('beef.extension.social_engineering.mass_mailer.password')

          @subject = "Hi from BeEF"
        end

        # tos_hash is an Hash like:
        # 'antisnatchor@gmail.com' => 'Michele'
        # 'ciccio@pasticcio.com' => 'Ciccio'
        def send_email(tos_hash)
          # create new SSL context and disable CA chain validation
          if @config.get('beef.extension.social_engineering.mass_mailer.use_tls')
            @ctx = OpenSSL::SSL::SSLContext.new
            @ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE # In case the SMTP server uses a self-signed cert, we proceed anyway
            @ctx.ssl_version = "TLSv1"
          end

          # create a new SMTP object, enable TLS with the previous instantiated context, and connects to the server
          smtp = Net::SMTP.new(@host, @port)
          smtp.enable_starttls(@ctx) unless @config.get('beef.extension.social_engineering.mass_mailer.use_tls') == false
          smtp.start(@helo, @from, @password, :login) do |smtp|
            tos_hash.each do |mail, name|
            message = compose_email(mail, name, @subject)
            smtp.send_message(message, @from, mail)
            end
          end
        end

        #todo sending to hostmonster the email is probably flagged as spam:
        # todo: error -> 550 550 Administrative prohibition (state 17

        def compose_email(to, name, subject)
           msg_id = random_string(50)
           boundary = "------------#{random_string(24)}"
           rel_boundary = "------------#{random_string(24)}"
           plain_text = "Hi #{name},\nPlease be sure to check this link:\n"

           @file_path = '/Users/morru/WORKS/BeEF/beef-44Con-code/extensions/social_engineering/mass_mailer/templates/default/'
           file = 'beef_logo.png'

           header = email_headers(@from, @user_agent, to, name, subject, msg_id, boundary)
           plain_body = email_plain_body(plain_text,boundary)
           rel_header = email_related(rel_boundary)
           html_body = email_html_body(rel_boundary, file, plain_text)
           image = email_add_image(file,rel_boundary)
           close = email_close(boundary)

           message = header + plain_body + rel_header + html_body + image + close
           print_debug "Raw Email content:\n #{message}"
           message
        end

        def email_headers(from, user_agent, to, name, subject, msg_id, boundary)
          headers = <<EOF
From: Michele Orru #{from}
User-Agent: #{user_agent}
To: #{name} #{to}
Message-ID: <msg_id@#{@host}>
Subject: #{subject}
MIME-Version: 1.0
Content-Type: multipart/alternative;
 boundary=#{boundary}

This is a multi-part message in MIME format.
--#{boundary}
EOF
          headers
        end

        def email_plain_body(plain_text, boundary)
          plain_body = <<EOF
Content-Type: text/plain; charset="utf8"
Content-Transfer-Encoding:8bit

#{plain_text}

--#{boundary}
EOF
          plain_body
        end

        def email_related(rel_boundary)
          related = <<EOF
Content-Type: multipart/related;
 boundary="#{rel_boundary}"


--#{rel_boundary}
EOF
          related
        end

        def email_html_body(rel_boundary, file, plain_body)
           html_body = <<EOF
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html><head>
<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1"></head><body
 bgcolor="#FFFFFF" text="#000000">
#{plain_body}<br>
  <br>
  <img src="cid:#{file}" name="#{file}" alt="#{file}"><br>
  <br>
Thanks
</body>
</html>
--#{rel_boundary}
EOF
           html_body
        end

        def email_add_image(file, rel_boundary)
          file_encoded = [File.read(@file_path + file)].pack("m") # base64
          image = <<EOF
Content-Type: image/png;
 name="#{file}"
Content-Transfer-Encoding: base64
Content-ID: <#{file}>
Content-Disposition: inline;
 filename="#{file}"

#{file_encoded}
--#{rel_boundary}
EOF
          image
        end

        def email_close(boundary)
          close = <<EOF
--#{boundary}--
EOF
          close
        end

        def random_string(length)
           output = (0..length).map{ rand(36).to_s(36).upcase }.join
           output
        end
      end
    end
  end
end

