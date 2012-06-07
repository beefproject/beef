package com.foxarc.util{  
    import flash.utils.ByteArray;  
    public class Base64 {  
        private static  const encodeChars:Array =   
        ['A','B','C','D','E','F','G','H',  
        'I','J','K','L','M','N','O','P',  
        'Q','R','S','T','U','V','W','X',  
        'Y','Z','a','b','c','d','e','f',  
        'g','h','i','j','k','l','m','n',  
        'o','p','q','r','s','t','u','v',  
        'w','x','y','z','0','1','2','3',  
        '4','5','6','7','8','9','+','/'];  
        private static  const decodeChars:Array =   
        [-1, -1, -1, -1, -1, -1, -1, -1,  
        -1, -1, -1, -1, -1, -1, -1, -1,  
        -1, -1, -1, -1, -1, -1, -1, -1,  
        -1, -1, -1, -1, -1, -1, -1, -1,  
        -1, -1, -1, -1, -1, -1, -1, -1,  
        -1, -1, -1, 62, -1, -1, -1, 63,  
        52, 53, 54, 55, 56, 57, 58, 59,  
        60, 61, -1, -1, -1, -1, -1, -1,  
        -1,  0,  1,  2,  3,  4,  5,  6,  
         7,  8,  9, 10, 11, 12, 13, 14,  
        15, 16, 17, 18, 19, 20, 21, 22,  
        23, 24, 25, -1, -1, -1, -1, -1,  
        -1, 26, 27, 28, 29, 30, 31, 32,  
        33, 34, 35, 36, 37, 38, 39, 40,  
        41, 42, 43, 44, 45, 46, 47, 48,  
        49, 50, 51, -1, -1, -1, -1, -1];  
        public static function encode(data:ByteArray):String {  
            var out:Array = [];  
            var i:int = 0;  
            var j:int = 0;  
            var r:int = data.length % 3;  
            var len:int = data.length - r;  
            var c:int;  
            while (i < len) {  
                c = data[i++] << 16 | data[i++] << 8 | data[i++];  
                out[j++] = encodeChars[c >> 18] + encodeChars[c >> 12 & 0x3f] + encodeChars[c >> 6 & 0x3f] + encodeChars[c & 0x3f];  
            }  
            if (r == 1) {  
                c = data[i++];  
                out[j++] = encodeChars[c >> 2] + encodeChars[(c & 0x03) << 4] + "==";  
            }  
            else if (r == 2) {  
                c = data[i++] << 8 | data[i++];  
                out[j++] = encodeChars[c >> 10] + encodeChars[c >> 4 & 0x3f] + encodeChars[(c & 0x0f) << 2] + "=";  
            }  
            return out.join('');  
        }  
        public static function decode(str:String):ByteArray {  
            var c1:int;  
            var c2:int;  
            var c3:int;  
            var c4:int;  
            var i:int;  
            var len:int;  
            var out:ByteArray;  
            len = str.length;  
            i = 0;  
            out = new ByteArray();  
            while (i < len) {  
                // c1  
                do {  
                    c1 = decodeChars[str.charCodeAt(i++) & 0xff];  
                } while (i < len && c1 == -1);  
                if (c1 == -1) {  
                    break;  
                }  
                // c2      
                do {  
                    c2 = decodeChars[str.charCodeAt(i++) & 0xff];  
                } while (i < len && c2 == -1);  
                if (c2 == -1) {  
                    break;  
                }  
                out.writeByte((c1 << 2) | ((c2 & 0x30) >> 4));  
                // c3  
                do {  
                    c3 = str.charCodeAt(i++) & 0xff;  
                    if (c3 == 61) {  
                        return out;  
                    }  
                    c3 = decodeChars[c3];  
                } while (i < len && c3 == -1);  
                if (c3 == -1) {  
                    break;  
                }  
                out.writeByte(((c2 & 0x0f) << 4) | ((c3 & 0x3c) >> 2));  
                // c4  
                do {  
                    c4 = str.charCodeAt(i++) & 0xff;  
                    if (c4 == 61) {  
                        return out;  
                    }  
                    c4 = decodeChars[c4];  
                } while (i < len && c4 == -1);  
                if (c4 == -1) {  
                    break;  
                }  
                out.writeByte(((c3 & 0x03) << 6) | c4);  
            }  
            return out;  
        }  
    }  
}