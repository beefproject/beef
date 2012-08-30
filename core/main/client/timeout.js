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
/*
 Sometimes there are timing issues and looks like beef_init
 is not called at all (always in cross-domain situations,
 for example calling the hook with jquery getScript,
 or sometimes with event handler injections).

 To fix this, we call again beef_init after 1 second.
 Cheers to John Wilander that discussed this bug with me at OWASP AppSec Research Greece
 antisnatchor
 */
setTimeout(beef_init, 1000);