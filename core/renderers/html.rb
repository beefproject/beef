module BeEF
module Renderers
module HTML

    #fires the HTML render function, attempting to match the appropriate data type
    def self.render(cat, type, data)
        kclass = self.const_get(cat.capitalize)
        if kclass 
            if kclass.respond_to?(type.downcase)
                return kclass.send type.downcase.to_sym, data
            else
                return kclass.send :string, data 
            end
        end
        return data.to_s
    end

end
end
end
