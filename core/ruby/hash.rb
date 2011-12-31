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
class Hash

    # Recursively deep merge two hashes together
    # @param [Hash] hash Hash to be merged
    # @return [Hash] Combined hash
    # @note Duplicate keys are overwritten by the value defined in the hash calling deep_merge (not the parameter hash)
    # @note http://snippets.dzone.com/posts/show/4706
    def deep_merge(hash)
        target = dup
        hash.keys.each do |key|
          if hash[key].is_a? Hash and self[key].is_a? Hash
            target[key] = target[key].deep_merge(hash[key])
            next
          end
          target[key] = hash[key]
        end
        target
    end
end
