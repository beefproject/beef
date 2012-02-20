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
