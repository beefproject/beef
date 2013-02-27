#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
  module Extension
    module SocialEngineering
      class SEngRest < BeEF::Core::Router::Router

        config = BeEF::Core::Configuration.instance

        before do
          error 401 unless params[:token] == config.get('beef.api_token')
          halt 401 if not BeEF::Core::Rest.permitted_source?(request.ip)
          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        #Example: curl -H "Content-Type: application/json; charset=UTF-8"
        #-d '{"url":"https://accounts.google.com/ServiceLogin?service=mail&passive=true&rm=false&continue=
        #https://mail.google.com/mail/&ss=1&scc=1&ltmpl=default&ltmplcache=2", "mount":"/url"}'
        #-X POST http://127.0.0.1:3000/api/seng/clone_page?token=851a937305f8773ee82f5259e792288cdcb01cd7
        post '/clone_page' do
          request.body.rewind
          begin
            body = JSON.parse request.body.read
            uri = body["url"]
            mount = body["mount"]
            use_existing = body["use_existing"]

            if uri != nil && mount != nil
              if (uri =~ URI::regexp).nil? #invalid URI
                print_error "Invalid URI"
                halt 401
              end

              if !mount[/^\//] # mount needs to start with /
                print_error "Invalid mount (need to be a relative path, and start with / )"
                halt 401
              end

              web_cloner = BeEF::Extension::SocialEngineering::WebCloner.instance
              success = web_cloner.clone_page(uri,mount,use_existing)
              if success
                result = {
                    "success" => true,
                    "mount" => mount
                }.to_json
              else
                result = {
                    "success" => false
                }.to_json
              end
            end

          rescue Exception => e
            print_error "Invalid JSON input passed to endpoint /api/seng/clone_page"
            error 400 # Bad Request
          end
        end

        # Example: curl -H "Content-Type: application/json; charset=UTF-8" -d 'json_body'
        #-X POST http://127.0.0.1:3000/api/seng/send_mails?token=68f76c383709414f647eb4ba8448370453dd68b7
        # Example json_body:
        #{
        #    "template": "default",
        #    "subject": "Hi from BeEF",
        #    "fromname": "BeEF",
        #    "fromaddr": "beef@beef.com",
        #    "link": "http://www.microsoft.com/security/online-privacy/phishing-symptoms.aspx",
        #    "linktext": "http://beefproject.com",
        #    "recipients": [{
        #            "user1@gmail.com": "Michele",
        #            "user2@antisnatchor.com": "Antisnatchor"
        #}]
        #}
        post '/send_mails' do
          request.body.rewind
          begin
            body = JSON.parse request.body.read

            template = body["template"]
            subject = body["subject"]
            fromname = body["fromname"]
            fromaddr = body["fromaddr"]
            link = body["link"]
            linktext = body["linktext"]

            if template.nil? || subject.nil? || fromaddr.nil? || fromname.nil? || link.nil? || linktext.nil?
              print_error "All parameters are mandatory."
              halt 401
            end

            if (link =~ URI::regexp).nil?#invalid URI
              print_error "Invalid link or linktext"
              halt 401
            end

            recipients = body["recipients"][0]

            recipients.each do |email,name|
              if !/\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/.match(email) || name.nil?
                print_error "Email [#{email}] or name [#{name}] are not valid/null."
                halt 401
              end
            end
          rescue Exception => e
            print_error "Invalid JSON input passed to endpoint /api/seng/send_emails"
            error 400
          end

          begin
            mass_mailer = BeEF::Extension::SocialEngineering::MassMailer.instance
            mass_mailer.send_email(template, fromname, fromaddr, subject, link, linktext, recipients)
          rescue Exception => e
            print_error "Invalid mailer configuration"
            error 400
          end
        end

      end
    end
  end
end