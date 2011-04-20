module BeEF
module Extension
module Console
  #
  # This module parses the command line argument when running beef.
  #
  module CommandLine
    
    @options = Hash.new
    @options[:verbose] = false
    @options[:resetdb] = false
    
    @already_parsed = false
    
    #
    # Parses the command line arguments of the console.
    # It also populates the 'options' hash.
    #
    def self.parse
      return @options if @already_parsed
      
      optparse = OptionParser.new do |opts|
        opts.on('-x', '--reset', 'Reset the database') do
          @options[:resetdb] = true
        end
        
        opts.on('-v', '--verbose', 'Display debug information') do
          @options[:verbose] = true
        end
      end
      
      optparse.parse!
      @already_parsed = true
      @options
    end
    
  end
  
end
end
end