class Module
  # Returns the classes in the current ObjectSpace where this module has been
  # mixed in according to Module#included_modules.
  #
  #   module M
  #   end
  #   
  #   module N
  #     include M
  #   end
  #   
  #   class C
  #     include M
  #   end
  #   
  #   class D < C
  #   end
  #
  #   p M.included_in_classes # => [C, D]
  #
  def included_in_classes
    classes = []
    ObjectSpace.each_object(Class) { |k| classes << k if k.included_modules.include?(self) }

    classes.reverse.inject([]) do |unique_classes, klass| 
      unique_classes << klass unless unique_classes.collect { |k| k.to_s }.include?(klass.to_s)
      unique_classes
    end
  end
  
  # Returns the modules in the current ObjectSpace where this module has been
  # mixed in according to Module#included_modules.
  #
  #   module M
  #   end
  #
  #   module N
  #     include M
  #   end
  #
  #   p M.included_in_modules # => [N]
  #
  def included_in_modules
    modules = []
    ObjectSpace.each_object(Module) { |k| modules << k if k.included_modules.include?(self) }
    
    modules.reverse.inject([]) do |unique_modules, klass| 
      unique_modules << klass unless unique_modules.collect { |k| k.to_s }.include?(klass.to_s)
      unique_modules
    end
  end
  
  #
  #   module M
  #   end
  #
  #   module N
  #     extend M
  #   end
  #
  #  p N.extended_modules # => [M]
  #
  def extended_modules
    (class << self; self end).included_modules
  end
  
  #
  #   module M
  #   end
  #
  #   module N
  #     extend M
  #   end
  #
  #  p M.extended_in_modules # => [N]
  #
  def extended_in_modules
    modules = []
    ObjectSpace.each_object(Module) { |k| modules << k if k.extended_modules.include?(self) }
    
    modules.reverse.inject([]) do |unique_modules, klass| 
      unique_modules << klass unless unique_modules.collect { |k| k.to_s }.include?(klass.to_s)
      unique_modules
    end
  end
end