#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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
