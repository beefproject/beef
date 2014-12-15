function search_module(module_tree, searching_string) {
  var json_object_clone = new Array();
  for ( var i = 0; i < module_tree.length; i++ ) 
    json_object_clone.push(module_tree[i].attributes);
  if ( searching_string.search(/\w/) == -1 )
    return json_object_clone;
  var json_object = jQuery.extend(true, [], json_object_clone);
  searching_string = searching_string.replace(/"\s*"/g, " ").replace(/\s+/g, " ").match(/"[^"]+"|\S+/g);
  searching_string.forEach(prepare_searching_string);
  var result = json_object.filter(form_new_modules_tree);
  result.forEach(recount_modules_and_expand_directories);
  return result;
  
  function prepare_searching_string(string, index, array){
    array[index] = string.toLowerCase().replace(/"/g, "");
  }
  
  function check_name_of_module(str) {
    return Boolean(this.toString().toLowerCase().replace(/\s\([0-9]+\)/g,"").indexOf(str) + 1);
  }
  
  function form_new_modules_tree(element) {
    if ( searching_string.some(check_name_of_module, element.text) )
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
      var count_of_modules = element.children.length;
      for ( var i = 0; i < element.children.length; i++ )
        if ( element.children )
          count_of_modules += recount_modules_and_expand_directories(element.children[i]);
      element.children.forEach(recount_modules_and_expand_directories);
      element.text = element.text.replace(/([-_ 0-9a-zA-Z]+)\(([0-9]+)\)/, "$1(" + count_of_modules + ")")
      return count_of_modules - 1;
    }
    return 0;
  }
}
