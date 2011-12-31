#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
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
