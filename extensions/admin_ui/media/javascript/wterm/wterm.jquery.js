/*
 * Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
 * Browser Exploitation Framework (BeEF) - http://beefproject.com
 * See the file 'doc/COPYING' for copying permission
 */

/**
 * @Author :        venkatakrishnan ganesh
 * @file   :        wterm.jquery.js
 * @url    :        http://wterminal.appspot.com
 * @desc   :
 *
 * Allows Emulation of Terminal on the browser.
 * Completely Extendible. 
 * Command History.
 * Commandline Editing. 
 *
 * Modified by antisnatchor (also to prevent XSS, see line 270)
 * */

( function( $ ) {

   
  var VERSION = '0.0.4';

  /**
  *
  * @function : get_defaults
  * @returns  : Object
  * @desc     : Returns Global Defaults
  *
  * */
  var get_defaults = function() {

    return {

      // PS1 : The Primary Prompt
      PS1                : 'BeEF-bind-$',

      // TERMINAL_CLASS  
      // Will be applied to the primary terminal container
      TERMINAL_CLASS     : 'wterm_terminal',

      // PROMPT_CLASS 
      // Will Applied to prompt container
      PROMPT_CLASS       : 'wterm_prompt',

      // THEME_CLASS_PREFIX
      // All Theme Classes will be prefixed by this string
      THEME_CLASS_PREFIX : 'wterm_theme',

      // DEFAULT_THEME
      // The theme that is applied by default
      DEFAULT_THEME      : '_green_on_black',

      // HIGHLIGHT_CLASS
      // The Class that is applied to highlighted text
      HIGHLIGHT_CLASS    : 'wterm_highlight',

      // KEYWORD_CLASS
      // The Class that is applied to keywords
      KEYWORD_CLASS      : 'wterm_keyword',

      // CONTENT_CLASS 
      // The Class that is applied to content section 
      KEYWORD_CLASS      : 'wterm_content',

      // WIDTH | HIGHT
      // Explicitly set width and height of the terminal
      // container. This may also be done in TERMINAL_CLASS
      WIDTH              : '90%',
      HEIGHT             : '90%', 

      // WELCOME_MESSAGE
      // Message to be shown when the terminal is first 
      // published
      WELCOME_MESSAGE    : 'Welcome to Wterm version-' + VERSION ,

      // NOT_FOUND
      // Message to be published if the command is not found
      // Note: "CMD" will be replaced with the actual command
      NOT_FOUND          : '<div> CMD: Command Not Found </div>',

      // AUTOCOMPLETE
      // Is Autocomplete feature Enabled
      // Please see the manual on how AUTOCOMPLETE is implemented
      AUTOCOMPLETE      : true,

      // HISTORY
      // Is Command History Enabled
      HISTORY           : true,

      // HISTORY
      // No of entries to be stored in HISTORY
      HISTORY_ENTRIES  : 100,


      // AJAX_METHOD
      // The HTTP Method that must be used for Ajax Requests
      AJAX_METHOD      : 'GET',


      // AJAX_PARAMETER
      // The GET/POST parameter that should be used to make requests
      AJAX_PARAM      : 'tokens',

      // ERROR_PREFIX
      // Prefix For Error Messages
      ERROR_PREFIX    : 'An Error Occured: '

    };
  };

 
  /**
  * @property : dispatch
  * @accessor : $.register_command ( See Below )
  * @private
  * @desc     : 
  *
  * dispatch table stores command name and action
  * to be taken when user enters a command. See
  * Manual for more details on how to implement 
  * your own commands
  *
  **/
  var dispatch = { 
  };


  /**
  *
  * @method : wterm
  * @public
  * @desc   : Sets up the terminal on the JQ object that 
  * represents a ( or a group ) of HTML NODE (s)
  *
  **/
  $.fn.wterm = function( options ) {


    // Merge defaults with options
    var settings = get_defaults();
    $.extend( true, settings, options );

    // JQ Plugin surprised??
    return this.each( function() {

      
      var element  = $( this );
      var history  = [ ];
      var hcurrent = null;
      
      // Set up some markup in the element
      // required for terminal emulation
      element.addClass( settings.TERMINAL_CLASS ).addClass( settings.THEME_CLASS_PREFIX + settings.DEFAULT_THEME );
      if( settings.WIDTH && settings.HEIGHT ) element.css( { width: settings.WIDTH, height: settings.HEIGHT } )
      element.html( '' ).append( '<div>' + settings.WELCOME_MESSAGE + '</div>' );

      element.append( '<div class="' + settings.CONTENT_CLASS + '"></div>' );
      element.append( '<div><span class="' + settings.PROMPT_CLASS + '">' + settings.PS1 + '&nbsp;</span>' +
                      '<form> <input type="text" ></form></div>' ); 


      // Representing prompt, form, input and content section 
      // in the terminal
      var _prompt    = element.find( 'div:last span:last' );
      var input_form = element.find( 'div:last form' );
      var input      = element.find( 'div:last form input' );
      var content    = element.find( '.' + settings.CONTENT_CLASS );

      // Custom Dispatcher
      var cdispatch  = null;

      // Temprary storage for autocomplete configuration
      var ac_save    = null;

      // Temporary store for current prompt
      var cprompt    = null;
      
      // Curson always needs to be on the prompt
      input.focus();
      element.click( function() { input.focus(); } );


      /**
      * @method   : hide
      * @private  :
      * @desc     : Hides the prompt
      **/
      var hide = function() {
        _prompt.hide();
      };

      /**
      * @method   : show 
      * @private  :
      * @desc     : Shows the prompt
      **/
      var show = function() {
        _prompt.show();
        input.focus();
      };
   
      /**
      * @method   : update_content
      * @private  :
      * @desc     : Updates the content section
      * @args     : current_prompt, command, data
      **/
      var update_content = function( p, cmd, data ) {
        content.append( '<div><span>' + p + ' ' + cmd + '</span><div>' + ( ( data ) ? data : '' ) + '</div></div>' );
      }; 

      /**
      * @method   : clear_content
      * @private  :
      * @desc     : Updates the content section
      * @args     : current_prompt, command, data
      **/
      var clear_content = function() {
        content.html( '' );
      };

      // Add the command to the dispatch
      dispatch.clear = clear_content;



      /**
      * @method   : set_prompt 
      * @private  :
      * @desc     : Set the current prompt
      * @args     : string 
      **/
      set_prompt = function( p ) {
        if( p && p.length ) element.find( '.' + settings.PROMPT_CLASS).html( p + '&nbsp;' );
      };

 

      /**
      *
      * @method   : Anonymous
      * @private  :
      * @event_handler
      *
      **/
      input_form.submit( function( e ) {
        e.preventDefault();
        e.stopPropagation();

        var value = input.attr( 'value' );

        if( settings.HISTORY ) {
          if( history.length > settings.HISTORY_ENTRIES ) history.shift();
          history.push( value );
        }
        
        // Reset The Input
        input.attr( 'value', '' );
        var tokens = value.split( /\s+/ );
        var key    = tokens[0];
        
        hide(); 

        var get_current_prompt = function() {
          return ( cprompt ) ? cprompt : settings.PS1;
        }

        var _dispatch = function( key, tokens ) {

          if( typeof key === 'function' ) {
              data = key( tokens );
              /*
               * antisnatchor: preventing XSS
               */
              if( data ) { update_content( get_current_prompt(), $jEncoder.encoder.encodeForJavascript(value), data)}
          } else if( typeof key === 'string' ) {
            var to_send = { };
            to_send[ settings.AJAX_PARAM ] = tokens.join( ' ' );

            var on_complete = function( data, text_status ) {
              update_content( get_current_prompt(), value, data )
            };
           
            $[ settings.AJAX_METHOD.toLowerCase() ](  key, to_send, on_complete );
          }
        };

        if( key == '' ) {
          update_content( get_current_prompt() , '' )
        } else if( cdispatch && key == 'exit' ) {
           
           // Recover old configuration and Dispatch exit hook
           settings.AUTOCOMPLETE = ( ac_save ) ? ac_save : false ;

           // Todo: test what happens when exit hook is not defined
           if( cdispatch.EXIT_HOOK ) {
             _dispatch( cdispatch.EXIT_HOOK, tokens );
           } else {
             _dispatch( function() { return '<b></b>' }, tokens );
           }
       
          // Clear temporary values
          cdispatch = null;  
          cprompt   = null;

          // Reset the prompt
          set_prompt( settings.PS1 );

        } else if( cdispatch ) {

          // Dispatch to the custom dispatcher
          _dispatch( cdispatch.DISPATCH, tokens ); 

        } else if( dispatch[ key ] ) {
          if( typeof dispatch[ key ] === 'object' ) {
            cdispatch = dispatch[ key ];
            cprompt   = cdispatch.PS1 || key;
            set_prompt( cprompt );

            ac_save = settings.AUTOCOMPLETE;
            settings.AUTOCOMPLETE = false;

            // Todo:See what happens if start hook is not defined
            if( cdispatch.START_HOOK ) {
              _dispatch( cdispatch.START_HOOK, tokens );
            } else {
              // A stupid Hack
              _dispatch( function() { return '<b></b>' }, tokens );
            }
          } else {
            _dispatch( dispatch[ key ], tokens );
          } 
        } else {
          update_content( settings.PS1, value, settings.NOT_FOUND.replace( 'CMD', tokens[0] ));
        }

        show();


      } );


      /**
      *
      * @method   : Anonymous
      * @private  :
      * @event_handler
      *
      **/
      input.keydown( function( e ) {
        var keycode = e.keyCode;
        switch( keycode ) {

          case 9:

            e.preventDefault();

            if( settings.AUTOCOMPLETE ) {
              var commands      = [ ];   
              var current_value = input.attr( 'value' );
              // Command Completion
              if( current_value.match( /^[^\s]{0,}$/ ) ) {
                for( i in dispatch ) {
                  if( current_value == '' ) {
                    commands.push( i );
                  } else if( i.indexOf( current_value ) == 0 ) {
                    commands.push( i );
                  }
                }
               
                if( commands.length > 1 ) { 
                  update_content( settings.PS1, current_value, commands.join( '<br>' ) );
                } else if( commands.length == 1 ) {
                  input.attr( 'value', commands.pop() + ' ' );  
                }
              }
            }

          break;

          // History Up
          case 38:
            e.preventDefault();
            if( settings.HISTORY ) {
              hcurrent  = ( hcurrent === null )? history.length - 1 : ( hcurrent == 0 ) ? history.length - 1 : hcurrent - 1;
              input.attr( 'value', history[ hcurrent ] );
            }
          break;

          // History Down
          case 40:
            e.preventDefault();
            if( settings.HISTORY ) {
              if( hcurrent === null || hcurrent == (history.length - 1 ) ) break;
              hcurrent++;
              input.attr( 'value', history[ hcurrent ] );
            }
          break;

          default:
          break;
        }
      });
    });

  };


  $.register_command = function( command, dispatch_method ) {
    try {
      if( typeof dispatch_method === 'function' || typeof dispatch_method === 'string' || typeof dispatch_method === 'object' ) {
        dispatch[ command ] = dispatch_method;
      } else {
        throw 'Dispatch needs to be a method';
      }
    } catch ( e ) {
      // Error Handling here
    }
  };

})( jQuery );
