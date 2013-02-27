#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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
          @config_prefix = "beef.extension.social_engineering.mass_mailer"
          @templates_dir = "#{File.expand_path('../../../../extensions/social_engineering/mass_mailer/templates', __FILE__)}/"

          @user_agent = @config.get("#{@config_prefix}.user_agent")
          @host = @config.get("#{@config_prefix}.host")
          @port = @config.get("#{@config_prefix}.port")
          @helo = @config.get("#{@config_prefix}.helo")
          @auth = @config.get("#{@config_prefix}.auth")
          @password = @config.get("#{@config_prefix}.password")
        end

        # tos_hash is an Hash like:
        # 'antisnatchor@gmail.com' => 'Michele'
        # 'ciccio@pasticcio.com' => 'Ciccio'
        def send_email(template, fromname, fromaddr, subject, link, linktext, tos_hash)
          # create new SSL context and disable CA chain validation
          if @config.get("#{@config_prefix}.use_tls")
            @ctx = OpenSSL::SSL::SSLContext.new
            @ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE # In case the SMTP server uses a self-signed cert, we proceed anyway
            @ctx.ssl_version = "TLSv1"
          end

          n = tos_hash.size
          x = 1
          print_info "Sending #{n} mail(s) from [#{fromaddr}] - name [#{fromname}] using template [#{template}]:"
          print_info "subject: #{subject}"
          print_info "link: #{link}"
          print_info "linktext: #{linktext}"

          # create a new SMTP object, enable TLS with the previous instantiated context, and connects to the server
          smtp = Net::SMTP.new(@host, @port)
          smtp.enable_starttls(@ctx) unless @config.get("#{@config_prefix}.use_tls") == false

          if @config.get("#{@config_prefix}.use_auth")
            smtp.start(@helo, @auth, @password, :login) do |smtp|
              tos_hash.each do |to, name|
                message = compose_email(fromname, fromaddr, to, name, subject, link, linktext, template)
                smtp.send_message(message, fromaddr, to)
                print_info "Mail #{x}/#{n} to [#{to}] sent."
                x += 1
              end
            end
          else
            smtp.start(@helo, @auth) do |smtp|
              tos_hash.each do |to, name|
                message = compose_email(fromname, fromaddr, to, name, subject, link, linktext, template)
                smtp.send_message(message, fromaddr, to)
                print_info "Mail #{x}/#{n} to [#{to}] sent."
                x += 1
              end
            end
          end
        end

        def compose_email(fromname, fromaddr, to, name, subject, link, linktext, template)
          begin
            msg_id = random_string(50)
            boundary = "------------#{random_string(24)}"
            rel_boundary = "------------#{random_string(24)}"


            header = email_headers(fromaddr, fromname, @user_agent, to, subject, msg_id, boundary)
            plain_body = email_plain_body(parse_template(name, link, linktext, "#{@templates_dir}#{template}/mail.plain", template), boundary)
            rel_header = email_related(rel_boundary)
            html_body = email_html_body(parse_template(name, link, linktext, "#{@templates_dir}#{template}/mail.html", template),rel_boundary)

            images = ""
            @config.get("#{@config_prefix}.templates.#{template}.images").each do |image|
              images += email_add_image(image, "#{@templates_dir}#{template}/#{image}",rel_boundary)
            end

            attachments = ""
            if @config.get("#{@config_prefix}.templates.#{template}.attachments") != nil
              @config.get("#{@config_prefix}.templates.#{template}.attachments").each do |attachment|
                 attachments += email_add_attachment(attachment, "#{@templates_dir}#{template}/#{attachment}",rel_boundary)
              end
            end

            close = email_close(boundary)
          rescue Exception => e
            print_error "Error constructing email."
            raise
          end

          message = header + plain_body + rel_header + html_body + images + attachments + close
          print_debug "Raw Email content:\n #{message}"
          message
        end

        def email_headers(from, fromname, user_agent, to, subject, msg_id, boundary)
          headers = <<EOF
From: "#{fromname}" <#{from}>
Reply-To: "#{fromname}" <#{from}>
Return-Path: "#{fromname}" <#{from}>
X-Mailer: #{user_agent}
To: #{to}
Message-ID: <#{msg_id}@#{@host}>
X-Spam-Status: No, score=0.001 required=5
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

        def email_html_body(html_body, rel_boundary)
           html_body = <<EOF
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

#{html_body}
--#{rel_boundary}
EOF
           html_body
        end

        def email_add_image(name, path, rel_boundary)
          file_encoded = [File.read(path)].pack("m") # base64 encoded
          image = <<EOF
Content-Type: #{get_mime(path)};
 name="#{name}"
Content-Transfer-Encoding: base64
Content-ID: <#{name}>
Content-Disposition: inline;
 filename="#{name}"

#{file_encoded}
--#{rel_boundary}
EOF
          image
        end

        def email_add_attachment(name, path, rel_boundary)
          file_encoded = [File.read(path)].pack("m") # base64 encoded
          image = <<EOF
Content-Type: #{get_mime(path)};
 name="#{name}"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="#{name}"

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

        # Replaces placeholder values from the plain/html email templates
        def parse_template(name, link, linktext, template_path, template)
          result = ""
          img_config = "#{@config_prefix}.templates.#{template}.images_cids"
          img_count = 0
          File.open(template_path, 'r').each do |line|
             # change the Recipient name
             if line.include?("__name__")
               result += line.gsub("__name__",name)
             # change the link/linktext
             elsif line.include?("__link__")
               if line.include?("__linktext__")
                 result += line.gsub("__link__",link).gsub("__linktext__",linktext)
               else
                 result += line.gsub("__link__",link)
               end
             # change images cid/name/alt
             elsif line.include?("src=\"cid:__")
               img_count += 1
               if line.include?("name=\"img__") || line.include?("alt=\"__img")
                 result += line.gsub("__cid#{img_count}__",
                                     @config.get("#{img_config}.cid#{img_count}")).gsub("__img#{img_count}__",
                                     @config.get("#{img_config}.cid#{img_count}"))
               else
                 result += line.gsub("__cid#{img_count}__",@config.get("#{img_config}.cid#{img_count}"))
               end
             else
               result += line
             end
          end
          result
        end

        def get_mime(file_path)
          result = ""
          IO.popen(["file", "--mime","-b", "#{file_path}"], 'r+') do |io|
            result = io.readlines.first.split(";").first
          end
          result
        end

        def random_string(length)
           output = (0..length).map{ rand(36).to_s(36).upcase }.join
        end
      end
    end
  end
end

