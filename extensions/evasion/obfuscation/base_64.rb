#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Evasion
      class Base_64
        include Singleton

        def need_bootstrap
          true
        end

        def get_bootstrap
          # the decode function is obfuscated, and it's called "dec" (see below in "execute", where it is used)
          decode_function = 'var _0x33db=["\x61\x74\x6F\x62","\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4A\x4B\x4C\x4D\x4E\x4F\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5A\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6A\x6B\x6C\x6D\x6E\x6F\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7A\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x2B\x2F\x3D","","\x63\x68\x61\x72\x41\x74","\x69\x6E\x64\x65\x78\x4F\x66","\x66\x72\x6F\x6D\x43\x68\x61\x72\x43\x6F\x64\x65","\x6C\x65\x6E\x67\x74\x68","\x6A\x6F\x69\x6E"];function dec(_0x487fx2){if(window[_0x33db[0]]){return atob(_0x487fx2);} ;var _0x487fx3=_0x33db[1];var _0x487fx4,_0x487fx5,_0x487fx6,_0x487fx7,_0x487fx8,_0x487fx9,_0x487fxa,_0x487fxb,_0x487fxc=0,_0x487fxd=0,dec=_0x33db[2],_0x487fxe=[];if(!_0x487fx2){return _0x487fx2;} ;_0x487fx2+=_0x33db[2];do{_0x487fx7=_0x487fx3[_0x33db[4]](_0x487fx2[_0x33db[3]](_0x487fxc++));_0x487fx8=_0x487fx3[_0x33db[4]](_0x487fx2[_0x33db[3]](_0x487fxc++));_0x487fx9=_0x487fx3[_0x33db[4]](_0x487fx2[_0x33db[3]](_0x487fxc++));_0x487fxa=_0x487fx3[_0x33db[4]](_0x487fx2[_0x33db[3]](_0x487fxc++));_0x487fxb=_0x487fx7<<18|_0x487fx8<<12|_0x487fx9<<6|_0x487fxa;_0x487fx4=_0x487fxb>>16&0xff;_0x487fx5=_0x487fxb>>8&0xff;_0x487fx6=_0x487fxb&0xff;if(_0x487fx9==64){_0x487fxe[_0x487fxd++]=String[_0x33db[5]](_0x487fx4);} else {if(_0x487fxa==64){_0x487fxe[_0x487fxd++]=String[_0x33db[5]](_0x487fx4,_0x487fx5);} else {_0x487fxe[_0x487fxd++]=String[_0x33db[5]](_0x487fx4,_0x487fx5,_0x487fx6);} ;} ;} while(_0x487fxc<_0x487fx2[_0x33db[6]]);;dec=_0x487fxe[_0x33db[7]](_0x33db[2]);return dec;};'
        end

        def execute(input, config)
          encoded = Base64.strict_encode64(input)
          # basically, use atob if supported otherwise a normal base64 JS implementation (ie.: IE :-)
          var_name = BeEF::Extension::Evasion::Helper::random_string(3)
          input = "var #{var_name}=\"#{encoded}\";[].constructor.constructor(dec(#{var_name}))();"
          print_debug "[OBFUSCATION - BASE64] Javascript has been base64'ed'"
          input
        end
      end
    end
  end
end

