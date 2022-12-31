#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Module
  # Returns the classes in the current ObjectSpace where this module has been mixed in according to Module#included_modules.
  # @return [Array] An array of classes
  def included_in_classes
    classes = []
    ObjectSpace.each_object(Class) { |k| classes << k if k.included_modules.include?(self) }

    classes.reverse.each_with_object([]) do |klass, unique_classes|
      unique_classes << klass unless unique_classes.collect { |k| k.to_s }.include?(klass.to_s)
    end
  end

  # Returns the modules in the current ObjectSpace where this module has been mixed in according to Module#included_modules.
  # @return [Array] An array of modules
  def included_in_modules
    modules = []
    ObjectSpace.each_object(Module) { |k| modules << k if k.included_modules.include?(self) }

    modules.reverse.each_with_object([]) do |klass, unique_modules|
      unique_modules << klass unless unique_modules.collect { |k| k.to_s }.include?(klass.to_s)
    end
  end
end
