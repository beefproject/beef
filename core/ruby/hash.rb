# http://snippets.dzone.com/posts/show/3401
class Hash
    def recursive_merge(h)
        self.merge!(h) {|key, _old, _new| if _old.class == Hash then _old.recursive_merge(_new) else _new end  } 
    end
end
