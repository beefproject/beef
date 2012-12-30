#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Object

  # Returns true if the object is a Boolean
  # @return [Boolean] Whether the object is boolean
  def boolean?
    self.is_a?(TrueClass) || self.is_a?(FalseClass)
  end

  # Returns true if the object is a String
  # @return [Boolean] Whether the object is a string
  def string?
    self.is_a?(String)
  end

  # Returns true if the object is an Integer
  # @return [Boolean] Whether the object is an integer
  def integer?
    self.is_a?(Integer)
  end

  # Returns true if the object is a hash
  # @return [Boolean] Whether the object is a hash
  def hash?
    self.is_a?(Hash)
  end

  # Returns true if the object is a class
  # @return [Boolean] Whether the object is a class
  def class?
    self.is_a?(Class)
  end

end
