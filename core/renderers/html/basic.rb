module BeEF
module Renderers
module HTML
module Basic

    #renders basic string
    def self.string(d)
        return '<p>'+d.to_s+'</p>'
    end
   
    #renders list of strings from an array
    def self.array(d)
        if d.kind_of?(Array)
            html = '<ul>'
            d.each{|v|
                html += "<li>#{v.to_s}</li>"
            }
            return html+'</ul>'
        end 
        print_debug "BeEF::Renderers::HTML::Basic.array encountered a non-array data type"
        return self.string(d)
    end
   
    #renders list of strings from a hash with key values
    def self.hash(d)
        if d.kind_of?(Hash)
            html = '<ul>'
            d.each{|k,v|
                html += "<li><b>#{k.to_s}</b>: #{v.to_s}</li>"
            }
            return html+'</ul>'
        end
        print_debug "BeEF::Renderers::HTML::Basic.hash encountered a non-hash data type"
        return self.string(d)
    end

end
end
end
end
