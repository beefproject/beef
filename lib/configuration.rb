module BeEF
  
  #
  #
  #
  class Configuration < ParseConfig

    include Singleton

    def initialize(configuration_file="#{$root_dir}/config.ini")
      super(configuration_file)
    end
    
    def get(key)
      get_value(key)
    end

  end

end