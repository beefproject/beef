# The following file contains patches for WEBrick.
module WEBrick
  
  class Cookie
    attr_accessor :httponly
        
    def to_s
      ret = ""
      ret << @name << "=" << @value
      ret << "; " << "Version=" << @version.to_s if @version > 0
      ret << "; " << "Domain="  << @domain  if @domain
      ret << "; " << "Expires=" << @expires if @expires
      ret << "; " << "Max-Age=" << @max_age.to_s if @max_age
      ret << "; " << "Comment=" << @comment if @comment
      ret << "; " << "Path="    << @path if @path
      ret << "; " << "Secure"   if @secure
      ret << "; " << "HttpOnly"   if @httponly
      ret
    end
    
  end
  
end