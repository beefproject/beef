#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
  module Core
    module Rest
      class AutorunEngine < BeEF::Core::Router::Router
        config = BeEF::Core::Configuration.instance

        before do
          error 401 unless params[:token] == config.get('beef.api_token')
          halt 401 unless BeEF::Core::Rest.permitted_source?(request.ip)
          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        #
        # Get all rules
        #
        get '/rules' do
          rules = BeEF::Core::Models::Rule.all
          {
            'success' => true,
            'count' => rules.length,
            'rules' => rules.to_json
          }.to_json
        rescue StandardError => e
          print_error("Internal error while retrieving Autorun rules: #{e.message}")
          halt 500
        end

        # Returns a specific rule by ID
        get '/rule/:rule_id' do
          rule_id = params[:rule_id]

          rule = BeEF::Core::Models::Rule.find(rule_id)
          raise InvalidParameterError, 'id' if rule.nil?

          halt 404 if rule.empty?

          rule.to_json
        rescue InvalidParameterError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          print_error "Internal error while retrieving Autorun rule with id #{rule_id} (#{e.message})"
          halt 500
        end

        #
        # Add a new ruleset. Return the rule_id if request was successful.
        # @return [Integer] rule ID
        #
        post '/rule/add' do
          request.body.rewind
          data = JSON.parse request.body.read
          rloader = BeEF::Core::AutorunEngine::RuleLoader.instance
          rloader.load_rule_json(data).to_json
        rescue StandardError => e
          print_error "Internal error while adding Autorun rule: #{e.message}"
          { 'success' => false, 'error' => e.message }.to_json
        end

        #
        # Delete a ruleset
        #
        delete '/rule/:rule_id' do
          rule_id = params[:rule_id]
          rule = BeEF::Core::Models::Rule.find(rule_id)
          raise InvalidParameterError, 'id' if rule.nil?
          rule.destroy

          { 'success' => true }.to_json
        rescue InvalidParameterError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          print_error "Internal error while deleting Autorun rule: #{e.message}"
          { 'success' => false, 'error' => e.message }.to_json
        end

        #
        # Run a specified rule on all online hooked browsers (if the zombie matches the rule).
        # Offline hooked browsers are ignored
        #
        get '/run/:rule_id' do
          rule_id = params[:rule_id]

          online_hooks = BeEF::Core::Models::HookedBrowser.where('lastseen >= ?', (Time.new.to_i - 15))

          if online_hooks.nil?
            return { 'success' => false, 'error' => 'There are currently no hooked browsers online.' }.to_json
          end

          are = BeEF::Core::AutorunEngine::Engine.instance
          online_hooks.each do |hb|
            are.run_matching_rules_on_zombie(rule_id, hb.id)
          end

          { 'success' => true }.to_json
        rescue StandardError => e
          msg = "Could not trigger rules: #{e.message}"
          print_error "[ARE] #{msg}"
          { 'success' => false, 'error' => msg }.to_json
        end

        #
        # Run a specified rule on the specified hooked browser.
        #
        get '/run/:rule_id/:hb_id' do
          rule_id = params[:rule_id]
          hb_id = params[:hb_id]

          raise InvalidParameterError, 'rule_id' if rule_id.nil?
          raise InvalidParameterError, 'hb_id' if hb_id.nil?

          are = BeEF::Core::AutorunEngine::Engine.instance
          are.run_matching_rules_on_zombie(rule_id, hb_id)

          { 'success' => true }.to_json
        rescue InvalidParameterError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          msg = "Could not trigger rule: #{e.message}"
          print_error "[ARE] #{msg}"
          { 'success' => false, 'error' => msg }.to_json
        end
      end
    end
  end
end
