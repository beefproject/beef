#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Helpers for unit specs of command modules (modules/*/module.rb).
# Use with stubbed config; no REST/API or real server.
#

module ModuleSpecHelper
  #
  # Build a command instance for testing post_execute (or other instance methods).
  # Uses allocate so we avoid Command#initialize reading from config.
  # Set @datastore before calling post_execute; results are stored in @results via save().
  #
  # @param klass [Class] The command module class (e.g. Test_beef_debug)
  # @param datastore [Hash] Data to set on @datastore (simulates callback data)
  # @return [Object] Instance with @datastore set; call post_execute then read instance_variable_get(:@results)
  #
  def build_command_instance(klass, datastore = {})
    instance = klass.allocate
    instance.instance_variable_set(:@datastore, datastore)
    instance
  end

  #
  # Call post_execute on a command instance and return the saved results.
  # Use after build_command_instance(klass, datastore).
  #
  # @param instance [Object] Command instance from build_command_instance
  # @return [Hash, nil] The value passed to save() (stored in @results)
  #
  def run_post_execute(instance)
    instance.post_execute
    instance.instance_variable_get(:@results)
  end

  #
  # Call pre_send on a command instance (e.g. before sending the command to the hooked browser).
  # Use after build_command_instance(klass, datastore). Stub AssetHandler, Configuration, etc. before calling.
  #
  # @param instance [Object] Command instance from build_command_instance
  #
  def run_pre_send(instance)
    instance.pre_send
  end
end

RSpec.configure do |config|
  config.include ModuleSpecHelper

  # Stub Kernel.sleep for all module specs so modules that call sleep (e.g. Irc_nat_pinning's post_execute sleep 30) don't slow the suite.
  config.before(:each) do |example|
    if example.metadata[:file_path]&.include?('spec/beef/modules')
      allow(Kernel).to receive(:sleep)
    end
  end
end
