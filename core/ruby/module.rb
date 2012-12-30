#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Module

  # Returns the classes in the current ObjectSpace where this module has been mixed in according to Module#included_modules.
  # @return [Array] An array of classes
  def included_in_classes
    classes = []
    ObjectSpace.each_object(Class) { |k| classes << k if k.included_modules.include?(self) }

    classes.reverse.inject([]) do |unique_classes, klass|
      unique_classes << klass unless unique_classes.collect { |k| k.to_s }.include?(klass.to_s)
      unique_classes
    end
  end

  # Returns the modules in the current ObjectSpace where this module has been mixed in according to Module#included_modules.
  # @return [Array] An array of modules
  def included_in_modules
    modules = []
    ObjectSpace.each_object(Module) { |k| modules << k if k.included_modules.include?(self) }

    modules.reverse.inject([]) do |unique_modules, klass|
      unique_modules << klass unless unique_modules.collect { |k| k.to_s }.include?(klass.to_s)
      unique_modules
    end
  end
end
