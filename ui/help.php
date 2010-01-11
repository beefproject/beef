<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net
?>

<div class="entry">
	<p class="title">Test Page</p>
	The test page will hook and create an example zombie browser which will appear under the 
	'Zombies' heading in the left pane : <a href="../hook/example.php">Example Page</a> 

	<p class="title">Zombies Menu</p>
	From the Zombies menu, a single zombie can be selected. This will display a page containing
	details about that zombie. Some of the module results will be displayed on this page.

	<p class="title">Modules Menus</p>
	Modules can be selected from the various module menus. This will display a page containing
	details and options relevant to that module. Commands will be sent only to the zombies selected
	in the sidebar (left).<br>
	<br>
	Depending on the module design, the results can be displayed in a results pane on this page or within 
	the selected zombies' pages.

	<p class="title">Options Menu</p>
	This menu contains the 'disable autorun' and start/stop polling items.

	<p class="title">Sidebar Autorun Status</p>
	This section displays the status of BeEF autorun. Autoruns can be disabled from the 'Options Menu'.

	<p class="title">Sidebar Zombie Selection</p>
	All modules use the selected zombies in this section. The selected zombies (only) will receive the module
	commands. 

	<p class="title">Autorun</p>
	Each module may have an autorun option. Whether or not this exists is dependant upon the developer of the 
	module. A selected autorun will execute (after a slight delay) upon the zombie connecting to the server.<br>
	<br>
	Only one autorun can be selected at a time. To disable the autorun, either select the alternate one 
	desired to excute or the 'Disable Autorun' menu item in the 'Options' menu.

	<p class="title">Results</p>
	Results of modules can be found in a few places. It depends upon the implementation
	of the module. If the module contains a results pane, the results will be found there. If not, 
	the results are likely to be 
	zombie dependent so they will be located within the zombie page (accessable from the 'Zombies' menu). 
	The results may also be found in the raw log and the summary log.<br>
	
	<p class="title">Modules</p>
	The modules are loaded into the various module menus. The modules are 
	the parts of the application that provide code to be sent to the zombie browser. One of the main strengths 
	of BeEF is the ease with which modules can be written. They require minimal effort to incorporate into 
	the framework. Module development and API details can be found on the 
	<a href="http://www.bindshell.net/tools/beef/">http://www.bindshell.net/tools/beef/</a> web site.

	<p class="title">Bugs</p>
	Further help can be found in the FAQ (<a href="http://www.bindshell.net/tools/beef/">http://www.bindshell.net/tools/beef/</a>)
	or by emailing the author. 

	Please report any bugs to <a href="mailto:wade@bindshell.net">wade@bindshell.net</a>.

</div>

