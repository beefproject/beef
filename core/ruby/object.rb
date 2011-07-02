#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
class Object
  
  #
  # Returns true if the object is a Boolean
  #
  #  Example:
  #
  #     a = true
  #     b = false
  #     c = 1234 # Integer
  #
  #     a.boolean? # => true
  #     b.boolean? # => false
  #     c.boolean? # => false
  #
  def boolean?
    self.is_a?(TrueClass) || self.is_a?(FalseClass) 
  end
  
  #
  # Returns true if the object is a String
  #
  #  Example:
  #
  #     1.string?       # => false
  #     'abc'.string?   # => true
  #
  def string?
    self.is_a?(String)
  end
  
  #
  # Returns true if the object is an Integer
  #
  #  Example:
  #
  #     1.integer?      # => true
  #     'abc'.integer?  # => false
  #
  def integer?
    self.is_a?(Integer)
  end
  
  #
  # Returns true if the object is a hash
  #
  #  Example:
  #
  #     {}.hash?  # => true
  #     1.hash?   # => false
  #
  def hash?
    self.is_a?(Hash)
  end
  
  #
  # Returns true if the object is a class
  #
  #  Example:
  #
  #     class A
  #     end
  #
  #     obj = A.new
  #     obj.class? # => true
  #
  def class?
    self.is_a?(Class)
  end
  
end