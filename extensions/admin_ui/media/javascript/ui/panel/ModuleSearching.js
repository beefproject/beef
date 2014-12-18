/*
 * Keyword search for command module panel. 
 * Words in query are searched as separated queries. You can search for exact matching using double qoutes arround query
 */

function search_module(module_tree, query_string) {
  if ( query_string.search(/\w/) == -1 )
    return tree_array;

	// copy module tree w/o ExtJS service properties
	var tree_array = new Array();
  for ( var i = 0; i < module_tree.length; i++ ) 
    tree_array.push(module_tree[i].attributes);

	var json_object = jQuery.extend(true, [], tree_array);

	// split query string into separate words and exact phrases
  query_string = query_string.replace(/"\s*"/g, " ").replace(/\s+/g, " ").match(/"[^"]+"|\S+/g);
  query_string.forEach(prepare_query_string);
  
	var result = json_object.filter(form_new_modules_tree);
  result.forEach(recount_modules_and_expand_directories);
 
	return result;
  
	// remove quotes from phrases for exact match
  function prepare_query_string(string, index, array){
    array[index] = string.toLowerCase().replace(/"/g, "");
  }
  
	// True if this.toString() contains str
  function check_module_name(str) {
    return Boolean(this.toString().toLowerCase().replace(/\s\([0-9]+\)/g,"").indexOf(str) + 1);
  }
  
  // func for JSON filter
	// Build a new tree from modules which are appropriate for any part of query
  function form_new_modules_tree(element) {
    if ( query_string.some(check_module_name, element.text) )
      return true;
    if ( element.children ) {  
      element.children = element.children.filter(form_new_modules_tree);
      return Boolean(element.children.length);
    }
    return false;
  }
  
  function recount_modules_and_expand_directories(element) {
    if ( element.children ) {
      element.expanded = true;
      var modules_in_directory = element.children.length;
			// visit all
      for ( var i = 0; i < element.children.length; i++ )
        if ( element.children )
          modules_in_directory += recount_modules_and_expand_directories(element.children[i]);
			// expand them
      element.children.forEach(recount_modules_and_expand_directories);
			// and set new number of modules in directory
      element.text = element.text.replace(/([-_ 0-9a-zA-Z]+)\(([0-9]+)\)/, "$1(" + modules_in_directory + ")")
      return modules_in_directory - 1;
    }
    return 0;
  }
}
