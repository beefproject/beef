module BeEF
module API
  #
  # Use this API call if you want to add new methods and variables to the default
  # BeEF::Core::Command module.
  #
  # Here's an example:
  #
  #   module A
  #     extend BeEF::API::Command
  #   
  #     def hello
  #       p 'hi there'
  #     end
  #   end
  #
  #   b = BeEF::Core::Command.new
  #   b.hello # => 'hi there'
  #
  #   c = BeEF::Core::Command::Detect_details.new
  #   c.hello # => 'hi there'
  #
  #
  # For a real life example, have a look at BeEF::Extension::AdminUI::API::Command
  #
  module Command
  end
  
end
end
