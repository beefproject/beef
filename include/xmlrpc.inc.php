<?php
// by Edd Dumbill (C) 1999-2002
// <edd@usefulinc.com>
// $Id: xmlrpc.inc,v 1.174 2009/03/16 19:36:38 ggiunta Exp $

// Copyright (c) 1999,2000,2002 Edd Dumbill.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//
//    * Redistributions in binary form must reproduce the above
//      copyright notice, this list of conditions and the following
//      disclaimer in the documentation and/or other materials provided
//      with the distribution.
//
//    * Neither the name of the "XML-RPC for PHP" nor the names of its
//      contributors may be used to endorse or promote products derived
//      from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
// OF THE POSSIBILITY OF SUCH DAMAGE.

	if(!function_exists('xml_parser_create'))
	{
		// For PHP 4 onward, XML functionality is always compiled-in on windows:
		// no more need to dl-open it. It might have been compiled out on *nix...
		if(strtoupper(substr(PHP_OS, 0, 3) != 'WIN'))
		{
			dl('xml.so');
		}
	}

	// Try to be backward compat with php < 4.2 (are we not being nice ?)
	$phpversion = phpversion();
	if($phpversion[0] == '4' && $phpversion[2] < 2)
	{
		// give an opportunity to user to specify where to include other files from
		if(!defined('PHP_XMLRPC_COMPAT_DIR'))
		{
			define('PHP_XMLRPC_COMPAT_DIR',dirname(__FILE__).'/compat/');
		}
		if($phpversion[2] == '0')
		{
			if($phpversion[4] < 6)
			{
				include(PHP_XMLRPC_COMPAT_DIR.'is_callable.php');
			}
			include(PHP_XMLRPC_COMPAT_DIR.'is_scalar.php');
			include(PHP_XMLRPC_COMPAT_DIR.'array_key_exists.php');
			include(PHP_XMLRPC_COMPAT_DIR.'version_compare.php');
		}
		include(PHP_XMLRPC_COMPAT_DIR.'var_export.php');
		include(PHP_XMLRPC_COMPAT_DIR.'is_a.php');
	}

	// G. Giunta 2005/01/29: declare global these variables,
	// so that xmlrpc.inc will work even if included from within a function
	// Milosch: 2005/08/07 - explicitly request these via $GLOBALS where used.
	$GLOBALS['xmlrpcI4']='i4';
	$GLOBALS['xmlrpcInt']='int';
	$GLOBALS['xmlrpcBoolean']='boolean';
	$GLOBALS['xmlrpcDouble']='double';
	$GLOBALS['xmlrpcString']='string';
	$GLOBALS['xmlrpcDateTime']='dateTime.iso8601';
	$GLOBALS['xmlrpcBase64']='base64';
	$GLOBALS['xmlrpcArray']='array';
	$GLOBALS['xmlrpcStruct']='struct';
	$GLOBALS['xmlrpcValue']='undefined';

	$GLOBALS['xmlrpcTypes']=array(
		$GLOBALS['xmlrpcI4']       => 1,
		$GLOBALS['xmlrpcInt']      => 1,
		$GLOBALS['xmlrpcBoolean']  => 1,
		$GLOBALS['xmlrpcString']   => 1,
		$GLOBALS['xmlrpcDouble']   => 1,
		$GLOBALS['xmlrpcDateTime'] => 1,
		$GLOBALS['xmlrpcBase64']   => 1,
		$GLOBALS['xmlrpcArray']    => 2,
		$GLOBALS['xmlrpcStruct']   => 3
	);

	$GLOBALS['xmlrpc_valid_parents'] = array(
		'VALUE' => array('MEMBER', 'DATA', 'PARAM', 'FAULT'),
		'BOOLEAN' => array('VALUE'),
		'I4' => array('VALUE'),
		'INT' => array('VALUE'),
		'STRING' => array('VALUE'),
		'DOUBLE' => array('VALUE'),
		'DATETIME.ISO8601' => array('VALUE'),
		'BASE64' => array('VALUE'),
		'MEMBER' => array('STRUCT'),
		'NAME' => array('MEMBER'),
		'DATA' => array('ARRAY'),
		'ARRAY' => array('VALUE'),
		'STRUCT' => array('VALUE'),
		'PARAM' => array('PARAMS'),
		'METHODNAME' => array('METHODCALL'),
		'PARAMS' => array('METHODCALL', 'METHODRESPONSE'),
		'FAULT' => array('METHODRESPONSE'),
		'NIL' => array('VALUE') // only used when extension activated
	);

	// define extra types for supporting NULL (useful for json or <NIL/>)
	$GLOBALS['xmlrpcNull']='null';
	$GLOBALS['xmlrpcTypes']['null']=1;

	// Not in use anymore since 2.0. Shall we remove it?
	/// @deprecated
	$GLOBALS['xmlEntities']=array(
		'amp'  => '&',
		'quot' => '"',
		'lt'   => '<',
		'gt'   => '>',
		'apos' => "'"
	);

	// tables used for transcoding different charsets into us-ascii xml

	$GLOBALS['xml_iso88591_Entities']=array();
	$GLOBALS['xml_iso88591_Entities']['in'] = array();
	$GLOBALS['xml_iso88591_Entities']['out'] = array();
	for ($i = 0; $i < 32; $i++)
	{
		$GLOBALS['xml_iso88591_Entities']['in'][] = chr($i);
		$GLOBALS['xml_iso88591_Entities']['out'][] = '&#'.$i.';';
	}
	for ($i = 160; $i < 256; $i++)
	{
		$GLOBALS['xml_iso88591_Entities']['in'][] = chr($i);
		$GLOBALS['xml_iso88591_Entities']['out'][] = '&#'.$i.';';
	}

	/// @todo add to iso table the characters from cp_1252 range, i.e. 128 to 159?
	/// These will NOT be present in true ISO-8859-1, but will save the unwary
	/// windows user from sending junk (though no luck when reciving them...)
  /*
	$GLOBALS['xml_cp1252_Entities']=array();
	for ($i = 128; $i < 160; $i++)
	{
		$GLOBALS['xml_cp1252_Entities']['in'][] = chr($i);
	}
	$GLOBALS['xml_cp1252_Entities']['out'] = array(
		'&#x20AC;', '?',        '&#x201A;', '&#x0192;',
		'&#x201E;', '&#x2026;', '&#x2020;', '&#x2021;',
		'&#x02C6;', '&#x2030;', '&#x0160;', '&#x2039;',
		'&#x0152;', '?',        '&#x017D;', '?',
		'?',        '&#x2018;', '&#x2019;', '&#x201C;',
		'&#x201D;', '&#x2022;', '&#x2013;', '&#x2014;',
		'&#x02DC;', '&#x2122;', '&#x0161;', '&#x203A;',
		'&#x0153;', '?',        '&#x017E;', '&#x0178;'
	);
  */

	$GLOBALS['xmlrpcerr'] = array(
	'unknown_method'=>1,
	'invalid_return'=>2,
	'incorrect_params'=>3,
	'introspect_unknown'=>4,
	'http_error'=>5,
	'no_data'=>6,
	'no_ssl'=>7,
	'curl_fail'=>8,
	'invalid_request'=>15,
	'no_curl'=>16,
	'server_error'=>17,
	'multicall_error'=>18,
	'multicall_notstruct'=>9,
	'multicall_nomethod'=>10,
	'multicall_notstring'=>11,
	'multicall_recursion'=>12,
	'multicall_noparams'=>13,
	'multicall_notarray'=>14,

	'cannot_decompress'=>103,
	'decompress_fail'=>104,
	'dechunk_fail'=>105,
	'server_cannot_decompress'=>106,
	'server_decompress_fail'=>107
	);

	$GLOBALS['xmlrpcstr'] = array(
	'unknown_method'=>'Unknown method',
	'invalid_return'=>'Invalid return payload: enable debugging to examine incoming payload',
	'incorrect_params'=>'Incorrect parameters passed to method',
	'introspect_unknown'=>"Can't introspect: method unknown",
	'http_error'=>"Didn't receive 200 OK from remote server.",
	'no_data'=>'No data received from server.',
	'no_ssl'=>'No SSL support compiled in.',
	'curl_fail'=>'CURL error',
	'invalid_request'=>'Invalid request payload',
	'no_curl'=>'No CURL support compiled in.',
	'server_error'=>'Internal server error',
	'multicall_error'=>'Received from server invalid multicall response',
	'multicall_notstruct'=>'system.multicall expected struct',
	'multicall_nomethod'=>'missing methodName',
	'multicall_notstring'=>'methodName is not a string',
	'multicall_recursion'=>'recursive system.multicall forbidden',
	'multicall_noparams'=>'missing params',
	'multicall_notarray'=>'params is not an array',

	'cannot_decompress'=>'Received from server compressed HTTP and cannot decompress',
	'decompress_fail'=>'Received from server invalid compressed HTTP',
	'dechunk_fail'=>'Received from server invalid chunked HTTP',
	'server_cannot_decompress'=>'Received from client compressed HTTP request and cannot decompress',
	'server_decompress_fail'=>'Received from client invalid compressed HTTP request'
	);

	// The charset encoding used by the server for received messages and
	// by the client for received responses when received charset cannot be determined
	// or is not supported
	$GLOBALS['xmlrpc_defencoding']='UTF-8';

	// The encoding used internally by PHP.
	// String values received as xml will be converted to this, and php strings will be converted to xml
	// as if having been coded with this
	$GLOBALS['xmlrpc_internalencoding']='ISO-8859-1';

	$GLOBALS['xmlrpcName']='XML-RPC for PHP';
	$GLOBALS['xmlrpcVersion']='2.2.2';

	// let user errors start at 800
	$GLOBALS['xmlrpcerruser']=800;
	// let XML parse errors start at 100
	$GLOBALS['xmlrpcerrxml']=100;

	// formulate backslashes for escaping regexp
	// Not in use anymore since 2.0. Shall we remove it?
	/// @deprecated
	$GLOBALS['xmlrpc_backslash']=chr(92).chr(92);

	// set to TRUE to enable correct decoding of <NIL/> values
	$GLOBALS['xmlrpc_null_extension']=false;

	// used to store state during parsing
	// quick explanation of components:
	//   ac - used to accumulate values
	//   isf - used to indicate a parsing fault (2) or xmlrpcresp fault (1)
	//   isf_reason - used for storing xmlrpcresp fault string
	//   lv - used to indicate "looking for a value": implements
	//        the logic to allow values with no types to be strings
	//   params - used to store parameters in method calls
	//   method - used to store method name
	//   stack - array with genealogy of xml elements names:
	//           used to validate nesting of xmlrpc elements
	$GLOBALS['_xh']=null;

	/**
	* Convert a string to the correct XML representation in a target charset
	* To help correct communication of non-ascii chars inside strings, regardless
	* of the charset used when sending requests, parsing them, sending responses
	* and parsing responses, an option is to convert all non-ascii chars present in the message
	* into their equivalent 'charset entity'. Charset entities enumerated this way
	* are independent of the charset encoding used to transmit them, and all XML
	* parsers are bound to understand them.
	* Note that in the std case we are not sending a charset encoding mime type
	* along with http headers, so we are bound by RFC 3023 to emit strict us-ascii.
	*
	* @todo do a bit of basic benchmarking (strtr vs. str_replace)
	* @todo	make usage of iconv() or recode_string() or mb_string() where available
	*/
	function xmlrpc_encode_entitites($data, $src_encoding='', $dest_encoding='')
	{
		if ($src_encoding == '')
		{
			// lame, but we know no better...
			$src_encoding = $GLOBALS['xmlrpc_internalencoding'];
		}

		switch(strtoupper($src_encoding.'_'.$dest_encoding))
		{
			case 'ISO-8859-1_':
			case 'ISO-8859-1_US-ASCII':
				$escaped_data = str_replace(array('&', '"', "'", '<', '>'), array('&amp;', '&quot;', '&apos;', '&lt;', '&gt;'), $data);
				$escaped_data = str_replace($GLOBALS['xml_iso88591_Entities']['in'], $GLOBALS['xml_iso88591_Entities']['out'], $escaped_data);
				break;
			case 'ISO-8859-1_UTF-8':
				$escaped_data = str_replace(array('&', '"', "'", '<', '>'), array('&amp;', '&quot;', '&apos;', '&lt;', '&gt;'), $data);
				$escaped_data = utf8_encode($escaped_data);
				break;
			case 'ISO-8859-1_ISO-8859-1':
			case 'US-ASCII_US-ASCII':
			case 'US-ASCII_UTF-8':
			case 'US-ASCII_':
			case 'US-ASCII_ISO-8859-1':
			case 'UTF-8_UTF-8':
			//case 'CP1252_CP1252':
				$escaped_data = str_replace(array('&', '"', "'", '<', '>'), array('&amp;', '&quot;', '&apos;', '&lt;', '&gt;'), $data);
				break;
			case 'UTF-8_':
			case 'UTF-8_US-ASCII':
			case 'UTF-8_ISO-8859-1':
	// NB: this will choke on invalid UTF-8, going most likely beyond EOF
	$escaped_data = '';
	// be kind to users creating string xmlrpcvals out of different php types
	$data = (string) $data;
	$ns = strlen ($data);
	for ($nn = 0; $nn < $ns; $nn++)
	{
		$ch = $data[$nn];
		$ii = ord($ch);
		//1 7 0bbbbbbb (127)
		if ($ii < 128)
		{
			/// @todo shall we replace this with a (supposedly) faster str_replace?
			switch($ii){
				case 34:
					$escaped_data .= '&quot;';
					break;
				case 38:
					$escaped_data .= '&amp;';
					break;
				case 39:
					$escaped_data .= '&apos;';
					break;
				case 60:
					$escaped_data .= '&lt;';
					break;
				case 62:
					$escaped_data .= '&gt;';
					break;
				default:
					$escaped_data .= $ch;
			} // switch
		}
		//2 11 110bbbbb 10bbbbbb (2047)
		else if ($ii>>5 == 6)
		{
			$b1 = ($ii & 31);
			$ii = ord($data[$nn+1]);
			$b2 = ($ii & 63);
			$ii = ($b1 * 64) + $b2;
			$ent = sprintf ('&#%d;', $ii);
			$escaped_data .= $ent;
			$nn += 1;
		}
		//3 16 1110bbbb 10bbbbbb 10bbbbbb
		else if ($ii>>4 == 14)
		{
			$b1 = ($ii & 15);
			$ii = ord($data[$nn+1]);
			$b2 = ($ii & 63);
			$ii = ord($data[$nn+2]);
			$b3 = ($ii & 63);
			$ii = ((($b1 * 64) + $b2) * 64) + $b3;
			$ent = sprintf ('&#%d;', $ii);
			$escaped_data .= $ent;
			$nn += 2;
		}
		//4 21 11110bbb 10bbbbbb 10bbbbbb 10bbbbbb
		else if ($ii>>3 == 30)
		{
			$b1 = ($ii & 7);
			$ii = ord($data[$nn+1]);
			$b2 = ($ii & 63);
			$ii = ord($data[$nn+2]);
			$b3 = ($ii & 63);
			$ii = ord($data[$nn+3]);
			$b4 = ($ii & 63);
			$ii = ((((($b1 * 64) + $b2) * 64) + $b3) * 64) + $b4;
			$ent = sprintf ('&#%d;', $ii);
			$escaped_data .= $ent;
			$nn += 3;
		}
	}
				break;
/*
			case 'CP1252_':
			case 'CP1252_US-ASCII':
				$escaped_data = str_replace(array('&', '"', "'", '<', '>'), array('&amp;', '&quot;', '&apos;', '&lt;', '&gt;'), $data);
				$escaped_data = str_replace($GLOBALS['xml_iso88591_Entities']['in'], $GLOBALS['xml_iso88591_Entities']['out'], $escaped_data);
				$escaped_data = str_replace($GLOBALS['xml_cp1252_Entities']['in'], $GLOBALS['xml_cp1252_Entities']['out'], $escaped_data);
				break;
			case 'CP1252_UTF-8':
				$escaped_data = str_replace(array('&', '"', "'", '<', '>'), array('&amp;', '&quot;', '&apos;', '&lt;', '&gt;'), $data);
				/// @todo we could use real UTF8 chars here instead of xml entities... (note that utf_8 encode all allone will NOT convert them)
				$escaped_data = str_replace($GLOBALS['xml_cp1252_Entities']['in'], $GLOBALS['xml_cp1252_Entities']['out'], $escaped_data);
				$escaped_data = utf8_encode($escaped_data);
				break;
			case 'CP1252_ISO-8859-1':
				$escaped_data = str_replace(array('&', '"', "'", '<', '>'), array('&amp;', '&quot;', '&apos;', '&lt;', '&gt;'), $data);
				// we might as well replave all funky chars with a '?' here, but we are kind and leave it to the receiving application layer to decide what to do with these weird entities...
				$escaped_data = str_replace($GLOBALS['xml_cp1252_Entities']['in'], $GLOBALS['xml_cp1252_Entities']['out'], $escaped_data);
				break;
*/
			default:
				$escaped_data = '';
				error_log("Converting from $src_encoding to $dest_encoding: not supported...");
		}
		return $escaped_data;
	}

	/// xml parser handler function for opening element tags
	function xmlrpc_se($parser, $name, $attrs, $accept_single_vals=false)
	{
		// if invalid xmlrpc already detected, skip all processing
		if ($GLOBALS['_xh']['isf'] < 2)
		{
			// check for correct element nesting
			// top level element can only be of 2 types
			/// @todo optimization creep: save this check into a bool variable, instead of using count() every time:
			///       there is only a single top level element in xml anyway
			if (count($GLOBALS['_xh']['stack']) == 0)
			{
				if ($name != 'METHODRESPONSE' && $name != 'METHODCALL' && (
					$name != 'VALUE' && !$accept_single_vals))
				{
					$GLOBALS['_xh']['isf'] = 2;
					$GLOBALS['_xh']['isf_reason'] = 'missing top level xmlrpc element';
					return;
				}
				else
				{
					$GLOBALS['_xh']['rt'] = strtolower($name);
				}
			}
			else
			{
				// not top level element: see if parent is OK
				$parent = end($GLOBALS['_xh']['stack']);
				if (!array_key_exists($name, $GLOBALS['xmlrpc_valid_parents']) || !in_array($parent, $GLOBALS['xmlrpc_valid_parents'][$name]))
				{
					$GLOBALS['_xh']['isf'] = 2;
					$GLOBALS['_xh']['isf_reason'] = "xmlrpc element $name cannot be child of $parent";
					return;
				}
			}

			switch($name)
			{
				// optimize for speed switch cases: most common cases first
				case 'VALUE':
					/// @todo we could check for 2 VALUE elements inside a MEMBER or PARAM element
					$GLOBALS['_xh']['vt']='value'; // indicator: no value found yet
					$GLOBALS['_xh']['ac']='';
					$GLOBALS['_xh']['lv']=1;
					$GLOBALS['_xh']['php_class']=null;
					break;
				case 'I4':
				case 'INT':
				case 'STRING':
				case 'BOOLEAN':
				case 'DOUBLE':
				case 'DATETIME.ISO8601':
				case 'BASE64':
					if ($GLOBALS['_xh']['vt']!='value')
					{
						//two data elements inside a value: an error occurred!
						$GLOBALS['_xh']['isf'] = 2;
						$GLOBALS['_xh']['isf_reason'] = "$name element following a {$GLOBALS['_xh']['vt']} element inside a single value";
						return;
					}
					$GLOBALS['_xh']['ac']=''; // reset the accumulator
					break;
				case 'STRUCT':
				case 'ARRAY':
					if ($GLOBALS['_xh']['vt']!='value')
					{
						//two data elements inside a value: an error occurred!
						$GLOBALS['_xh']['isf'] = 2;
						$GLOBALS['_xh']['isf_reason'] = "$name element following a {$GLOBALS['_xh']['vt']} element inside a single value";
						return;
					}
					// create an empty array to hold child values, and push it onto appropriate stack
					$cur_val = array();
					$cur_val['values'] = array();
					$cur_val['type'] = $name;
					// check for out-of-band information to rebuild php objs
					// and in case it is found, save it
					if (@isset($attrs['PHP_CLASS']))
					{
						$cur_val['php_class'] = $attrs['PHP_CLASS'];
					}
					$GLOBALS['_xh']['valuestack'][] = $cur_val;
					$GLOBALS['_xh']['vt']='data'; // be prepared for a data element next
					break;
				case 'DATA':
					if ($GLOBALS['_xh']['vt']!='data')
					{
						//two data elements inside a value: an error occurred!
						$GLOBALS['_xh']['isf'] = 2;
						$GLOBALS['_xh']['isf_reason'] = "found two data elements inside an array element";
						return;
					}
				case 'METHODCALL':
				case 'METHODRESPONSE':
				case 'PARAMS':
					// valid elements that add little to processing
					break;
				case 'METHODNAME':
				case 'NAME':
					/// @todo we could check for 2 NAME elements inside a MEMBER element
					$GLOBALS['_xh']['ac']='';
					break;
				case 'FAULT':
					$GLOBALS['_xh']['isf']=1;
					break;
				case 'MEMBER':
					$GLOBALS['_xh']['valuestack'][count($GLOBALS['_xh']['valuestack'])-1]['name']=''; // set member name to null, in case we do not find in the xml later on
					//$GLOBALS['_xh']['ac']='';
					// Drop trough intentionally
				case 'PARAM':
					// clear value type, so we can check later if no value has been passed for this param/member
					$GLOBALS['_xh']['vt']=null;
					break;
				case 'NIL':
					if ($GLOBALS['xmlrpc_null_extension'])
					{
						if ($GLOBALS['_xh']['vt']!='value')
						{
							//two data elements inside a value: an error occurred!
							$GLOBALS['_xh']['isf'] = 2;
							$GLOBALS['_xh']['isf_reason'] = "$name element following a {$GLOBALS['_xh']['vt']} element inside a single value";
							return;
						}
						$GLOBALS['_xh']['ac']=''; // reset the accumulator
						break;
					}
					// we do not support the <NIL/> extension, so
					// drop through intentionally
				default:
					/// INVALID ELEMENT: RAISE ISF so that it is later recognized!!!
					$GLOBALS['_xh']['isf'] = 2;
					$GLOBALS['_xh']['isf_reason'] = "found not-xmlrpc xml element $name";
					break;
			}

			// Save current element name to stack, to validate nesting
			$GLOBALS['_xh']['stack'][] = $name;

			/// @todo optimization creep: move this inside the big switch() above
			if($name!='VALUE')
			{
				$GLOBALS['_xh']['lv']=0;
			}
		}
	}

	/// Used in decoding xml chunks that might represent single xmlrpc values
	function xmlrpc_se_any($parser, $name, $attrs)
	{
		xmlrpc_se($parser, $name, $attrs, true);
	}

	/// xml parser handler function for close element tags
	function xmlrpc_ee($parser, $name, $rebuild_xmlrpcvals = true)
	{
		if ($GLOBALS['_xh']['isf'] < 2)
		{
			// push this element name from stack
			// NB: if XML validates, correct opening/closing is guaranteed and
			// we do not have to check for $name == $curr_elem.
			// we also checked for proper nesting at start of elements...
			$curr_elem = array_pop($GLOBALS['_xh']['stack']);

			switch($name)
			{
				case 'VALUE':
					// This if() detects if no scalar was inside <VALUE></VALUE>
					if ($GLOBALS['_xh']['vt']=='value')
					{
						$GLOBALS['_xh']['value']=$GLOBALS['_xh']['ac'];
						$GLOBALS['_xh']['vt']=$GLOBALS['xmlrpcString'];
					}

					if ($rebuild_xmlrpcvals)
					{
						// build the xmlrpc val out of the data received, and substitute it
						$temp =& new xmlrpcval($GLOBALS['_xh']['value'], $GLOBALS['_xh']['vt']);
						// in case we got info about underlying php class, save it
						// in the object we're rebuilding
						if (isset($GLOBALS['_xh']['php_class']))
							$temp->_php_class = $GLOBALS['_xh']['php_class'];
						// check if we are inside an array or struct:
						// if value just built is inside an array, let's move it into array on the stack
						$vscount = count($GLOBALS['_xh']['valuestack']);
						if ($vscount && $GLOBALS['_xh']['valuestack'][$vscount-1]['type']=='ARRAY')
						{
							$GLOBALS['_xh']['valuestack'][$vscount-1]['values'][] = $temp;
						}
						else
						{
							$GLOBALS['_xh']['value'] = $temp;
						}
					}
					else
					{
						/// @todo this needs to treat correctly php-serialized objects,
						/// since std deserializing is done by php_xmlrpc_decode,
						/// which we will not be calling...
						if (isset($GLOBALS['_xh']['php_class']))
						{
						}

						// check if we are inside an array or struct:
						// if value just built is inside an array, let's move it into array on the stack
						$vscount = count($GLOBALS['_xh']['valuestack']);
						if ($vscount && $GLOBALS['_xh']['valuestack'][$vscount-1]['type']=='ARRAY')
						{
							$GLOBALS['_xh']['valuestack'][$vscount-1]['values'][] = $GLOBALS['_xh']['value'];
						}
					}
					break;
				case 'BOOLEAN':
				case 'I4':
				case 'INT':
				case 'STRING':
				case 'DOUBLE':
				case 'DATETIME.ISO8601':
				case 'BASE64':
					$GLOBALS['_xh']['vt']=strtolower($name);
					/// @todo: optimization creep - remove the if/elseif cycle below
					/// since the case() in which we are already did that
					if ($name=='STRING')
					{
						$GLOBALS['_xh']['value']=$GLOBALS['_xh']['ac'];
					}
					elseif ($name=='DATETIME.ISO8601')
					{
						if (!preg_match('/^[0-9]{8}T[0-9]{2}:[0-9]{2}:[0-9]{2}$/', $GLOBALS['_xh']['ac']))
						{
							error_log('XML-RPC: invalid value received in DATETIME: '.$GLOBALS['_xh']['ac']);
						}
						$GLOBALS['_xh']['vt']=$GLOBALS['xmlrpcDateTime'];
						$GLOBALS['_xh']['value']=$GLOBALS['_xh']['ac'];
					}
					elseif ($name=='BASE64')
					{
						/// @todo check for failure of base64 decoding / catch warnings
						$GLOBALS['_xh']['value']=base64_decode($GLOBALS['_xh']['ac']);
					}
					elseif ($name=='BOOLEAN')
					{
						// special case here: we translate boolean 1 or 0 into PHP
						// constants true or false.
						// Strings 'true' and 'false' are accepted, even though the
						// spec never mentions them (see eg. Blogger api docs)
						// NB: this simple checks helps a lot sanitizing input, ie no
						// security problems around here
						if ($GLOBALS['_xh']['ac']=='1' || strcasecmp($GLOBALS['_xh']['ac'], 'true') == 0)
						{
							$GLOBALS['_xh']['value']=true;
						}
						else
						{
							// log if receiveing something strange, even though we set the value to false anyway
							if ($GLOBALS['_xh']['ac']!='0' && strcasecmp($GLOBALS['_xh']['ac'], 'false') != 0)
								error_log('XML-RPC: invalid value received in BOOLEAN: '.$GLOBALS['_xh']['ac']);
							$GLOBALS['_xh']['value']=false;
						}
					}
					elseif ($name=='DOUBLE')
					{
						// we have a DOUBLE
						// we must check that only 0123456789-.<space> are characters here
						// NOTE: regexp could be much stricter than this...
						if (!preg_match('/^[+-eE0123456789 \t.]+$/', $GLOBALS['_xh']['ac']))
						{
							/// @todo: find a better way of throwing an error than this!
							error_log('XML-RPC: non numeric value received in DOUBLE: '.$GLOBALS['_xh']['ac']);
							$GLOBALS['_xh']['value']='ERROR_NON_NUMERIC_FOUND';
						}
						else
						{
							// it's ok, add it on
							$GLOBALS['_xh']['value']=(double)$GLOBALS['_xh']['ac'];
						}
					}
					else
					{
						// we have an I4/INT
						// we must check that only 0123456789-<space> are characters here
						if (!preg_match('/^[+-]?[0123456789 \t]+$/', $GLOBALS['_xh']['ac']))
						{
							/// @todo find a better way of throwing an error than this!
							error_log('XML-RPC: non numeric value received in INT: '.$GLOBALS['_xh']['ac']);
							$GLOBALS['_xh']['value']='ERROR_NON_NUMERIC_FOUND';
						}
						else
						{
							// it's ok, add it on
							$GLOBALS['_xh']['value']=(int)$GLOBALS['_xh']['ac'];
						}
					}
					//$GLOBALS['_xh']['ac']=''; // is this necessary?
					$GLOBALS['_xh']['lv']=3; // indicate we've found a value
					break;
				case 'NAME':
					$GLOBALS['_xh']['valuestack'][count($GLOBALS['_xh']['valuestack'])-1]['name'] = $GLOBALS['_xh']['ac'];
					break;
				case 'MEMBER':
					//$GLOBALS['_xh']['ac']=''; // is this necessary?
					// add to array in the stack the last element built,
					// unless no VALUE was found
					if ($GLOBALS['_xh']['vt'])
					{
						$vscount = count($GLOBALS['_xh']['valuestack']);
						$GLOBALS['_xh']['valuestack'][$vscount-1]['values'][$GLOBALS['_xh']['valuestack'][$vscount-1]['name']] = $GLOBALS['_xh']['value'];
					} else
						error_log('XML-RPC: missing VALUE inside STRUCT in received xml');
					break;
				case 'DATA':
					//$GLOBALS['_xh']['ac']=''; // is this necessary?
					$GLOBALS['_xh']['vt']=null; // reset this to check for 2 data elements in a row - even if they're empty
					break;
				case 'STRUCT':
				case 'ARRAY':
					// fetch out of stack array of values, and promote it to current value
					$curr_val = array_pop($GLOBALS['_xh']['valuestack']);
					$GLOBALS['_xh']['value'] = $curr_val['values'];
					$GLOBALS['_xh']['vt']=strtolower($name);
					if (isset($curr_val['php_class']))
					{
						$GLOBALS['_xh']['php_class'] = $curr_val['php_class'];
					}
					break;
				case 'PARAM':
					// add to array of params the current value,
					// unless no VALUE was found
					if ($GLOBALS['_xh']['vt'])
					{
						$GLOBALS['_xh']['params'][]=$GLOBALS['_xh']['value'];
						$GLOBALS['_xh']['pt'][]=$GLOBALS['_xh']['vt'];
					}
					else
						error_log('XML-RPC: missing VALUE inside PARAM in received xml');
					break;
				case 'METHODNAME':
					$GLOBALS['_xh']['method']=preg_replace('/^[\n\r\t ]+/', '', $GLOBALS['_xh']['ac']);
					break;
				case 'NIL':
					if ($GLOBALS['xmlrpc_null_extension'])
					{
						$GLOBALS['_xh']['vt']='null';
						$GLOBALS['_xh']['value']=null;
						$GLOBALS['_xh']['lv']=3;
						break;
					}
					// drop through intentionally if nil extension not enabled
				case 'PARAMS':
				case 'FAULT':
				case 'METHODCALL':
				case 'METHORESPONSE':
					break;
				default:
					// End of INVALID ELEMENT!
					// shall we add an assert here for unreachable code???
					break;
			}
		}
	}

	/// Used in decoding xmlrpc requests/responses without rebuilding xmlrpc values
	function xmlrpc_ee_fast($parser, $name)
	{
		xmlrpc_ee($parser, $name, false);
	}

	/// xml parser handler function for character data
	function xmlrpc_cd($parser, $data)
	{
		// skip processing if xml fault already detected
		if ($GLOBALS['_xh']['isf'] < 2)
		{
			// "lookforvalue==3" means that we've found an entire value
			// and should discard any further character data
			if($GLOBALS['_xh']['lv']!=3)
			{
				// G. Giunta 2006-08-23: useless change of 'lv' from 1 to 2
				//if($GLOBALS['_xh']['lv']==1)
				//{
					// if we've found text and we're just in a <value> then
					// say we've found a value
					//$GLOBALS['_xh']['lv']=2;
				//}
				// we always initialize the accumulator before starting parsing, anyway...
				//if(!@isset($GLOBALS['_xh']['ac']))
				//{
				//	$GLOBALS['_xh']['ac'] = '';
				//}
				$GLOBALS['_xh']['ac'].=$data;
			}
		}
	}

	/// xml parser handler function for 'other stuff', ie. not char data or
	/// element start/end tag. In fact it only gets called on unknown entities...
	function xmlrpc_dh($parser, $data)
	{
		// skip processing if xml fault already detected
		if ($GLOBALS['_xh']['isf'] < 2)
		{
			if(substr($data, 0, 1) == '&' && substr($data, -1, 1) == ';')
			{
				// G. Giunta 2006-08-25: useless change of 'lv' from 1 to 2
				//if($GLOBALS['_xh']['lv']==1)
				//{
				//	$GLOBALS['_xh']['lv']=2;
				//}
				$GLOBALS['_xh']['ac'].=$data;
			}
		}
		return true;
	}

	class xmlrpc_client
	{
		var $path;
		var $server;
		var $port=0;
		var $method='http';
		var $errno;
		var $errstr;
		var $debug=0;
		var $username='';
		var $password='';
		var $authtype=1;
		var $cert='';
		var $certpass='';
		var $cacert='';
		var $cacertdir='';
		var $key='';
		var $keypass='';
		var $verifypeer=true;
		var $verifyhost=1;
		var $no_multicall=false;
		var $proxy='';
		var $proxyport=0;
		var $proxy_user='';
		var $proxy_pass='';
		var $proxy_authtype=1;
		var $cookies=array();
		/**
		* List of http compression methods accepted by the client for responses.
		* NB: PHP supports deflate, gzip compressions out of the box if compiled w. zlib
		*
		* NNB: you can set it to any non-empty array for HTTP11 and HTTPS, since
		* in those cases it will be up to CURL to decide the compression methods
		* it supports. You might check for the presence of 'zlib' in the output of
		* curl_version() to determine wheter compression is supported or not
		*/
		var $accepted_compression = array();
		/**
		* Name of compression scheme to be used for sending requests.
		* Either null, gzip or deflate
		*/
		var $request_compression = '';
		/**
		* CURL handle: used for keep-alive connections (PHP 4.3.8 up, see:
		* http://curl.haxx.se/docs/faq.html#7.3)
		*/
		var $xmlrpc_curl_handle = null;
		/// Wheter to use persistent connections for http 1.1 and https
		var $keepalive = false;
		/// Charset encodings that can be decoded without problems by the client
		var $accepted_charset_encodings = array();
		/// Charset encoding to be used in serializing request. NULL = use ASCII
		var $request_charset_encoding = '';
		/**
		* Decides the content of xmlrpcresp objects returned by calls to send()
		* valid strings are 'xmlrpcvals', 'phpvals' or 'xml'
		*/
		var $return_type = 'xmlrpcvals';

		/**
		* @param string $path either the complete server URL or the PATH part of the xmlrc server URL, e.g. /xmlrpc/server.php
		* @param string $server the server name / ip address
		* @param integer $port the port the server is listening on, defaults to 80 or 443 depending on protocol used
		* @param string $method the http protocol variant: defaults to 'http', 'https' and 'http11' can be used if CURL is installed
		*/
		function xmlrpc_client($path, $server='', $port='', $method='')
		{
			// allow user to specify all params in $path
			if($server == '' and $port == '' and $method == '')
			{
				$parts = parse_url($path);
				$server = $parts['host'];
				$path = isset($parts['path']) ? $parts['path'] : '';
				if(isset($parts['query']))
				{
					$path .= '?'.$parts['query'];
				}
				if(isset($parts['fragment']))
				{
					$path .= '#'.$parts['fragment'];
				}
				if(isset($parts['port']))
				{
					$port = $parts['port'];
				}
				if(isset($parts['scheme']))
				{
					$method = $parts['scheme'];
				}
				if(isset($parts['user']))
				{
					$this->username = $parts['user'];
				}
				if(isset($parts['pass']))
				{
					$this->password = $parts['pass'];
				}
			}
			if($path == '' || $path[0] != '/')
			{
				$this->path='/'.$path;
			}
			else
			{
				$this->path=$path;
			}
			$this->server=$server;
			if($port != '')
			{
				$this->port=$port;
			}
			if($method != '')
			{
				$this->method=$method;
			}

			// if ZLIB is enabled, let the client by default accept compressed responses
			if(function_exists('gzinflate') || (
				function_exists('curl_init') && (($info = curl_version()) &&
				((is_string($info) && strpos($info, 'zlib') !== null) || isset($info['libz_version'])))
			))
			{
				$this->accepted_compression = array('gzip', 'deflate');
			}

			// keepalives: enabled by default ONLY for PHP >= 4.3.8
			// (see http://curl.haxx.se/docs/faq.html#7.3)
			if(version_compare(phpversion(), '4.3.8') >= 0)
			{
				$this->keepalive = true;
			}

			// by default the xml parser can support these 3 charset encodings
			$this->accepted_charset_encodings = array('UTF-8', 'ISO-8859-1', 'US-ASCII');
		}

		/**
		* Enables/disables the echoing to screen of the xmlrpc responses received
		* @param integer $debug values 0, 1 and 2 are supported (2 = echo sent msg too, before received response)
		* @access public
		*/
		function setDebug($in)
		{
			$this->debug=$in;
		}

		/**
		* Add some http BASIC AUTH credentials, used by the client to authenticate
		* @param string $u username
		* @param string $p password
		* @param integer $t auth type. See curl_setopt man page for supported auth types. Defaults to CURLAUTH_BASIC (basic auth)
		* @access public
		*/
		function setCredentials($u, $p, $t=1)
		{
			$this->username=$u;
			$this->password=$p;
			$this->authtype=$t;
		}

		/**
		* Add a client-side https certificate
		* @param string $cert
		* @param string $certpass
		* @access public
		*/
		function setCertificate($cert, $certpass)
		{
			$this->cert = $cert;
			$this->certpass = $certpass;
		}

		/**
		* Add a CA certificate to verify server with (see man page about
		* CURLOPT_CAINFO for more details
		* @param string $cacert certificate file name (or dir holding certificates)
		* @param bool $is_dir set to true to indicate cacert is a dir. defaults to false
		* @access public
		*/
		function setCaCertificate($cacert, $is_dir=false)
		{
			if ($is_dir)
			{
				$this->cacertdir = $cacert;
			}
			else
			{
				$this->cacert = $cacert;
			}
		}

		/**
		* Set attributes for SSL communication: private SSL key
		* NB: does not work in older php/curl installs
		* Thanks to Daniel Convissor
		* @param string $key The name of a file containing a private SSL key
		* @param string $keypass The secret password needed to use the private SSL key
		* @access public
		*/
		function setKey($key, $keypass)
		{
			$this->key = $key;
			$this->keypass = $keypass;
		}

		/**
		* Set attributes for SSL communication: verify server certificate
		* @param bool $i enable/disable verification of peer certificate
		* @access public
		*/
		function setSSLVerifyPeer($i)
		{
			$this->verifypeer = $i;
		}

		/**
		* Set attributes for SSL communication: verify match of server cert w. hostname
		* @param int $i
		* @access public
		*/
		function setSSLVerifyHost($i)
		{
			$this->verifyhost = $i;
		}

		/**
		* Set proxy info
		* @param string $proxyhost
		* @param string $proxyport Defaults to 8080 for HTTP and 443 for HTTPS
		* @param string $proxyusername Leave blank if proxy has public access
		* @param string $proxypassword Leave blank if proxy has public access
		* @param int $proxyauthtype set to constant CURLAUTH_NTLM to use NTLM auth with proxy
		* @access public
		*/
		function setProxy($proxyhost, $proxyport, $proxyusername = '', $proxypassword = '', $proxyauthtype = 1)
		{
			$this->proxy = $proxyhost;
			$this->proxyport = $proxyport;
			$this->proxy_user = $proxyusername;
			$this->proxy_pass = $proxypassword;
			$this->proxy_authtype = $proxyauthtype;
		}

		/**
		* Enables/disables reception of compressed xmlrpc responses.
		* Note that enabling reception of compressed responses merely adds some standard
		* http headers to xmlrpc requests. It is up to the xmlrpc server to return
		* compressed responses when receiving such requests.
		* @param string $compmethod either 'gzip', 'deflate', 'any' or ''
		* @access public
		*/
		function setAcceptedCompression($compmethod)
		{
			if ($compmethod == 'any')
				$this->accepted_compression = array('gzip', 'deflate');
			else
				$this->accepted_compression = array($compmethod);
		}

		/**
		* Enables/disables http compression of xmlrpc request.
		* Take care when sending compressed requests: servers might not support them
		* (and automatic fallback to uncompressed requests is not yet implemented)
		* @param string $compmethod either 'gzip', 'deflate' or ''
		* @access public
		*/
		function setRequestCompression($compmethod)
		{
			$this->request_compression = $compmethod;
		}

		/**
		* Adds a cookie to list of cookies that will be sent to server.
		* NB: setting any param but name and value will turn the cookie into a 'version 1' cookie:
		* do not do it unless you know what you are doing
		* @param string $name
		* @param string $value
		* @param string $path
		* @param string $domain
		* @param int $port
		* @access public
		*
		* @todo check correctness of urlencoding cookie value (copied from php way of doing it...)
		*/
		function setCookie($name, $value='', $path='', $domain='', $port=null)
		{
			$this->cookies[$name]['value'] = urlencode($value);
			if ($path || $domain || $port)
			{
				$this->cookies[$name]['path'] = $path;
				$this->cookies[$name]['domain'] = $domain;
				$this->cookies[$name]['port'] = $port;
				$this->cookies[$name]['version'] = 1;
			}
			else
			{
				$this->cookies[$name]['version'] = 0;
			}
		}

		/**
		* Send an xmlrpc request
		* @param mixed $msg The message object, or an array of messages for using multicall, or the complete xml representation of a request
		* @param integer $timeout Connection timeout, in seconds, If unspecified, a platform specific timeout will apply
		* @param string $method if left unspecified, the http protocol chosen during creation of the object will be used
		* @return xmlrpcresp
		* @access public
		*/
		function& send($msg, $timeout=0, $method='')
		{
			// if user deos not specify http protocol, use native method of this client
			// (i.e. method set during call to constructor)
			if($method == '')
			{
				$method = $this->method;
			}

			if(is_array($msg))
			{
				// $msg is an array of xmlrpcmsg's
				$r = $this->multicall($msg, $timeout, $method);
				return $r;
			}
			elseif(is_string($msg))
			{
				$n =& new xmlrpcmsg('');
				$n->payload = $msg;
				$msg = $n;
			}

			// where msg is an xmlrpcmsg
			$msg->debug=$this->debug;

			if($method == 'https')
			{
				$r =& $this->sendPayloadHTTPS(
					$msg,
					$this->server,
					$this->port,
					$timeout,
					$this->username,
					$this->password,
					$this->authtype,
					$this->cert,
					$this->certpass,
					$this->cacert,
					$this->cacertdir,
					$this->proxy,
					$this->proxyport,
					$this->proxy_user,
					$this->proxy_pass,
					$this->proxy_authtype,
					$this->keepalive,
					$this->key,
					$this->keypass
				);
			}
			elseif($method == 'http11')
			{
				$r =& $this->sendPayloadCURL(
					$msg,
					$this->server,
					$this->port,
					$timeout,
					$this->username,
					$this->password,
					$this->authtype,
					null,
					null,
					null,
					null,
					$this->proxy,
					$this->proxyport,
					$this->proxy_user,
					$this->proxy_pass,
					$this->proxy_authtype,
					'http',
					$this->keepalive
				);
			}
			else
			{
				$r =& $this->sendPayloadHTTP10(
					$msg,
					$this->server,
					$this->port,
					$timeout,
					$this->username,
					$this->password,
					$this->authtype,
					$this->proxy,
					$this->proxyport,
					$this->proxy_user,
					$this->proxy_pass,
					$this->proxy_authtype
				);
			}

			return $r;
		}

		/**
		* @access private
		*/
		function &sendPayloadHTTP10($msg, $server, $port, $timeout=0,
			$username='', $password='', $authtype=1, $proxyhost='',
			$proxyport=0, $proxyusername='', $proxypassword='', $proxyauthtype=1)
		{
			if($port==0)
			{
				$port=80;
			}

			// Only create the payload if it was not created previously
			if(empty($msg->payload))
			{
				$msg->createPayload($this->request_charset_encoding);
			}

			$payload = $msg->payload;
			// Deflate request body and set appropriate request headers
			if(function_exists('gzdeflate') && ($this->request_compression == 'gzip' || $this->request_compression == 'deflate'))
			{
				if($this->request_compression == 'gzip')
				{
					$a = @gzencode($payload);
					if($a)
					{
						$payload = $a;
						$encoding_hdr = "Content-Encoding: gzip\r\n";
					}
				}
				else
				{
					$a = @gzcompress($payload);
					if($a)
					{
						$payload = $a;
						$encoding_hdr = "Content-Encoding: deflate\r\n";
					}
				}
			}
			else
			{
				$encoding_hdr = '';
			}

			// thanks to Grant Rauscher <grant7@firstworld.net> for this
			$credentials='';
			if($username!='')
			{
				$credentials='Authorization: Basic ' . base64_encode($username . ':' . $password) . "\r\n";
				if ($authtype != 1)
				{
					error_log('XML-RPC: xmlrpc_client::send: warning. Only Basic auth is supported with HTTP 1.0');
				}
			}

			$accepted_encoding = '';
			if(is_array($this->accepted_compression) && count($this->accepted_compression))
			{
				$accepted_encoding = 'Accept-Encoding: ' . implode(', ', $this->accepted_compression) . "\r\n";
			}

			$proxy_credentials = '';
			if($proxyhost)
			{
				if($proxyport == 0)
				{
					$proxyport = 8080;
				}
				$connectserver = $proxyhost;
				$connectport = $proxyport;
				$uri = 'http://'.$server.':'.$port.$this->path;
				if($proxyusername != '')
				{
					if ($proxyauthtype != 1)
					{
						error_log('XML-RPC: xmlrpc_client::send: warning. Only Basic auth to proxy is supported with HTTP 1.0');
					}
					$proxy_credentials = 'Proxy-Authorization: Basic ' . base64_encode($proxyusername.':'.$proxypassword) . "\r\n";
				}
			}
			else
			{
				$connectserver = $server;
				$connectport = $port;
				$uri = $this->path;
			}

			// Cookie generation, as per rfc2965 (version 1 cookies) or
			// netscape's rules (version 0 cookies)
			$cookieheader='';
			if (count($this->cookies))
			{
				$version = '';
				foreach ($this->cookies as $name => $cookie)
				{
					if ($cookie['version'])
					{
						$version = ' $Version="' . $cookie['version'] . '";';
						$cookieheader .= ' ' . $name . '="' . $cookie['value'] . '";';
						if ($cookie['path'])
							$cookieheader .= ' $Path="' . $cookie['path'] . '";';
						if ($cookie['domain'])
							$cookieheader .= ' $Domain="' . $cookie['domain'] . '";';
						if ($cookie['port'])
							$cookieheader .= ' $Port="' . $cookie['port'] . '";';
					}
					else
					{
						$cookieheader .= ' ' . $name . '=' . $cookie['value'] . ";";
					}
				}
				$cookieheader = 'Cookie:' . $version . substr($cookieheader, 0, -1) . "\r\n";
			}

			$op= 'POST ' . $uri. " HTTP/1.0\r\n" .
				'User-Agent: ' . $GLOBALS['xmlrpcName'] . ' ' . $GLOBALS['xmlrpcVersion'] . "\r\n" .
				'Host: '. $server . ':' . $port . "\r\n" .
				$credentials .
				$proxy_credentials .
				$accepted_encoding .
				$encoding_hdr .
				'Accept-Charset: ' . implode(',', $this->accepted_charset_encodings) . "\r\n" .
				$cookieheader .
				'Content-Type: ' . $msg->content_type . "\r\nContent-Length: " .
				strlen($payload) . "\r\n\r\n" .
				$payload;

			if($this->debug > 1)
			{
				print "<PRE>\n---SENDING---\n" . htmlentities($op) . "\n---END---\n</PRE>";
				// let the client see this now in case http times out...
				flush();
			}

			if($timeout>0)
			{
				$fp=@fsockopen($connectserver, $connectport, $this->errno, $this->errstr, $timeout);
			}
			else
			{
				$fp=@fsockopen($connectserver, $connectport, $this->errno, $this->errstr);
			}
			if($fp)
			{
				if($timeout>0 && function_exists('stream_set_timeout'))
				{
					stream_set_timeout($fp, $timeout);
				}
			}
			else
			{
				$this->errstr='Connect error: '.$this->errstr;
				$r=&new xmlrpcresp(0, $GLOBALS['xmlrpcerr']['http_error'], $this->errstr . ' (' . $this->errno . ')');
				return $r;
			}

			if(!fputs($fp, $op, strlen($op)))
			{
    			fclose($fp);
				$this->errstr='Write error';
				$r=&new xmlrpcresp(0, $GLOBALS['xmlrpcerr']['http_error'], $this->errstr);
				return $r;
			}
			else
			{
				// reset errno and errstr on succesful socket connection
				$this->errstr = '';
			}
			// G. Giunta 2005/10/24: close socket before parsing.
			// should yeld slightly better execution times, and make easier recursive calls (e.g. to follow http redirects)
			$ipd='';
			do
			{
				// shall we check for $data === FALSE?
				// as per the manual, it signals an error
				$ipd.=fread($fp, 32768);
			} while(!feof($fp));
			fclose($fp);
			$r =& $msg->parseResponse($ipd, false, $this->return_type);
			return $r;

		}

		/**
		* @access private
		*/
		function &sendPayloadHTTPS($msg, $server, $port, $timeout=0, $username='',
			$password='', $authtype=1, $cert='',$certpass='', $cacert='', $cacertdir='',
			$proxyhost='', $proxyport=0, $proxyusername='', $proxypassword='', $proxyauthtype=1,
			$keepalive=false, $key='', $keypass='')
		{
			$r =& $this->sendPayloadCURL($msg, $server, $port, $timeout, $username,
				$password, $authtype, $cert, $certpass, $cacert, $cacertdir, $proxyhost, $proxyport,
				$proxyusername, $proxypassword, $proxyauthtype, 'https', $keepalive, $key, $keypass);
			return $r;
		}

		/**
		* Contributed by Justin Miller <justin@voxel.net>
		* Requires curl to be built into PHP
		* NB: CURL versions before 7.11.10 cannot use proxy to talk to https servers!
		* @access private
		*/
		function &sendPayloadCURL($msg, $server, $port, $timeout=0, $username='',
			$password='', $authtype=1, $cert='', $certpass='', $cacert='', $cacertdir='',
			$proxyhost='', $proxyport=0, $proxyusername='', $proxypassword='', $proxyauthtype=1, $method='https',
			$keepalive=false, $key='', $keypass='')
		{
			if(!function_exists('curl_init'))
			{
				$this->errstr='CURL unavailable on this install';
				$r=&new xmlrpcresp(0, $GLOBALS['xmlrpcerr']['no_curl'], $GLOBALS['xmlrpcstr']['no_curl']);
				return $r;
			}
			if($method == 'https')
			{
				if(($info = curl_version()) &&
					((is_string($info) && strpos($info, 'OpenSSL') === null) || (is_array($info) && !isset($info['ssl_version']))))
				{
					$this->errstr='SSL unavailable on this install';
					$r=&new xmlrpcresp(0, $GLOBALS['xmlrpcerr']['no_ssl'], $GLOBALS['xmlrpcstr']['no_ssl']);
					return $r;
				}
			}

			if($port == 0)
			{
				if($method == 'http')
				{
					$port = 80;
				}
				else
				{
					$port = 443;
				}
			}

			// Only create the payload if it was not created previously
			if(empty($msg->payload))
			{
				$msg->createPayload($this->request_charset_encoding);
			}

			// Deflate request body and set appropriate request headers
			$payload = $msg->payload;
			if(function_exists('gzdeflate') && ($this->request_compression == 'gzip' || $this->request_compression == 'deflate'))
			{
				if($this->request_compression == 'gzip')
				{
					$a = @gzencode($payload);
					if($a)
					{
						$payload = $a;
						$encoding_hdr = 'Content-Encoding: gzip';
					}
				}
				else
				{
					$a = @gzcompress($payload);
					if($a)
					{
						$payload = $a;
						$encoding_hdr = 'Content-Encoding: deflate';
					}
				}
			}
			else
			{
				$encoding_hdr = '';
			}

			if($this->debug > 1)
			{
				print "<PRE>\n---SENDING---\n" . htmlentities($payload) . "\n---END---\n</PRE>";
				// let the client see this now in case http times out...
				flush();
			}

			if(!$keepalive || !$this->xmlrpc_curl_handle)
			{
				$curl = curl_init($method . '://' . $server . ':' . $port . $this->path);
				if($keepalive)
				{
					$this->xmlrpc_curl_handle = $curl;
				}
			}
			else
			{
				$curl = $this->xmlrpc_curl_handle;
			}

			// results into variable
			curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);

			if($this->debug)
			{
				curl_setopt($curl, CURLOPT_VERBOSE, 1);
			}
			curl_setopt($curl, CURLOPT_USERAGENT, $GLOBALS['xmlrpcName'].' '.$GLOBALS['xmlrpcVersion']);
			// required for XMLRPC: post the data
			curl_setopt($curl, CURLOPT_POST, 1);
			// the data
			curl_setopt($curl, CURLOPT_POSTFIELDS, $payload);

			// return the header too
			curl_setopt($curl, CURLOPT_HEADER, 1);

			// will only work with PHP >= 5.0
			// NB: if we set an empty string, CURL will add http header indicating
			// ALL methods it is supporting. This is possibly a better option than
			// letting the user tell what curl can / cannot do...
			if(is_array($this->accepted_compression) && count($this->accepted_compression))
			{
				//curl_setopt($curl, CURLOPT_ENCODING, implode(',', $this->accepted_compression));
				// empty string means 'any supported by CURL' (shall we catch errors in case CURLOPT_SSLKEY undefined ?)
				if (count($this->accepted_compression) == 1)
				{
					curl_setopt($curl, CURLOPT_ENCODING, $this->accepted_compression[0]);
				}
				else
					curl_setopt($curl, CURLOPT_ENCODING, '');
			}
			// extra headers
			$headers = array('Content-Type: ' . $msg->content_type , 'Accept-Charset: ' . implode(',', $this->accepted_charset_encodings));
			// if no keepalive is wanted, let the server know it in advance
			if(!$keepalive)
			{
				$headers[] = 'Connection: close';
			}
			// request compression header
			if($encoding_hdr)
			{
				$headers[] = $encoding_hdr;
			}

			curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
			// timeout is borked
			if($timeout)
			{
				curl_setopt($curl, CURLOPT_TIMEOUT, $timeout == 1 ? 1 : $timeout - 1);
			}

			if($username && $password)
			{
				curl_setopt($curl, CURLOPT_USERPWD, $username.':'.$password);
				if (defined('CURLOPT_HTTPAUTH'))
				{
					curl_setopt($curl, CURLOPT_HTTPAUTH, $authtype);
				}
				else if ($authtype != 1)
				{
					error_log('XML-RPC: xmlrpc_client::send: warning. Only Basic auth is supported by the current PHP/curl install');
				}
			}

			if($method == 'https')
			{
				// set cert file
				if($cert)
				{
					curl_setopt($curl, CURLOPT_SSLCERT, $cert);
				}
				// set cert password
				if($certpass)
				{
					curl_setopt($curl, CURLOPT_SSLCERTPASSWD, $certpass);
				}
				// whether to verify remote host's cert
				curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, $this->verifypeer);
				// set ca certificates file/dir
				if($cacert)
				{
					curl_setopt($curl, CURLOPT_CAINFO, $cacert);
				}
				if($cacertdir)
				{
					curl_setopt($curl, CURLOPT_CAPATH, $cacertdir);
				}
				// set key file (shall we catch errors in case CURLOPT_SSLKEY undefined ?)
				if($key)
				{
					curl_setopt($curl, CURLOPT_SSLKEY, $key);
				}
				// set key password (shall we catch errors in case CURLOPT_SSLKEY undefined ?)
				if($keypass)
				{
					curl_setopt($curl, CURLOPT_SSLKEYPASSWD, $keypass);
				}
				// whether to verify cert's common name (CN); 0 for no, 1 to verify that it exists, and 2 to verify that it matches the hostname used
				curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, $this->verifyhost);
			}

			// proxy info
			if($proxyhost)
			{
				if($proxyport == 0)
				{
					$proxyport = 8080; // NB: even for HTTPS, local connection is on port 8080
				}
				curl_setopt($curl, CURLOPT_PROXY, $proxyhost.':'.$proxyport);
				//curl_setopt($curl, CURLOPT_PROXYPORT,$proxyport);
				if($proxyusername)
				{
					curl_setopt($curl, CURLOPT_PROXYUSERPWD, $proxyusername.':'.$proxypassword);
					if (defined('CURLOPT_PROXYAUTH'))
					{
						curl_setopt($curl, CURLOPT_PROXYAUTH, $proxyauthtype);
					}
					else if ($proxyauthtype != 1)
					{
						error_log('XML-RPC: xmlrpc_client::send: warning. Only Basic auth to proxy is supported by the current PHP/curl install');
					}
				}
			}

			// NB: should we build cookie http headers by hand rather than let CURL do it?
			// the following code does not honour 'expires', 'path' and 'domain' cookie attributes
			// set to client obj the the user...
			if (count($this->cookies))
			{
				$cookieheader = '';
				foreach ($this->cookies as $name => $cookie)
				{
					$cookieheader .= $name . '=' . $cookie['value'] . '; ';
				}
				curl_setopt($curl, CURLOPT_COOKIE, substr($cookieheader, 0, -2));
			}

			$result = curl_exec($curl);

			if ($this->debug > 1)
			{
				print "<PRE>\n---CURL INFO---\n";
				foreach(curl_getinfo($curl) as $name => $val)
					 print $name . ': ' . htmlentities($val). "\n";
				print "---END---\n</PRE>";
			}

			if(!$result) /// @todo we should use a better check here - what if we get back '' or '0'?
			{
				$this->errstr='no response';
				$resp=&new xmlrpcresp(0, $GLOBALS['xmlrpcerr']['curl_fail'], $GLOBALS['xmlrpcstr']['curl_fail']. ': '. curl_error($curl));
				curl_close($curl);
				if($keepalive)
				{
					$this->xmlrpc_curl_handle = null;
				}
			}
			else
			{
				if(!$keepalive)
				{
					curl_close($curl);
				}
				$resp =& $msg->parseResponse($result, true, $this->return_type);
			}
			return $resp;
		}

		/**
		* Send an array of request messages and return an array of responses.
		* Unless $this->no_multicall has been set to true, it will try first
		* to use one single xmlrpc call to server method system.multicall, and
		* revert to sending many successive calls in case of failure.
		* This failure is also stored in $this->no_multicall for subsequent calls.
		* Unfortunately, there is no server error code universally used to denote
		* the fact that multicall is unsupported, so there is no way to reliably
		* distinguish between that and a temporary failure.
		* If you are sure that server supports multicall and do not want to
		* fallback to using many single calls, set the fourth parameter to FALSE.
		*
		* NB: trying to shoehorn extra functionality into existing syntax has resulted
		* in pretty much convoluted code...
		*
		* @param array $msgs an array of xmlrpcmsg objects
		* @param integer $timeout connection timeout (in seconds)
		* @param string $method the http protocol variant to be used
		* @param boolean fallback When true, upon receiveing an error during multicall, multiple single calls will be attempted
		* @return array
		* @access public
		*/
		function multicall($msgs, $timeout=0, $method='', $fallback=true)
		{
			if ($method == '')
			{
				$method = $this->method;
			}
			if(!$this->no_multicall)
			{
				$results = $this->_try_multicall($msgs, $timeout, $method);
				if(is_array($results))
				{
					// System.multicall succeeded
					return $results;
				}
				else
				{
					// either system.multicall is unsupported by server,
					// or call failed for some other reason.
					if ($fallback)
					{
						// Don't try it next time...
						$this->no_multicall = true;
					}
					else
					{
						if (is_a($results, 'xmlrpcresp'))
						{
							$result = $results;
						}
						else
						{
							$result =& new xmlrpcresp(0, $GLOBALS['xmlrpcerr']['multicall_error'], $GLOBALS['xmlrpcstr']['multicall_error']);
						}
					}
				}
			}
			else
			{
				// override fallback, in case careless user tries to do two
				// opposite things at the same time
				$fallback = true;
			}

			$results = array();
			if ($fallback)
			{
				// system.multicall is (probably) unsupported by server:
				// emulate multicall via multiple requests
				foreach($msgs as $msg)
				{
					$results[] =& $this->send($msg, $timeout, $method);
				}
			}
			else
			{
				// user does NOT want to fallback on many single calls:
				// since we should always return an array of responses,
				// return an array with the same error repeated n times
				foreach($msgs as $msg)
				{
					$results[] = $result;
				}
			}
			return $results;
		}

		/**
		* Attempt to boxcar $msgs via system.multicall.
		* Returns either an array of xmlrpcreponses, an xmlrpc error response
		* or false (when received response does not respect valid multicall syntax)
		* @access private
		*/
		function _try_multicall($msgs, $timeout, $method)
		{
			// Construct multicall message
			$calls = array();
			foreach($msgs as $msg)
			{
				$call['methodName'] =& new xmlrpcval($msg->method(),'string');
				$numParams = $msg->getNumParams();
				$params = array();
				for($i = 0; $i < $numParams; $i++)
				{
					$params[$i] = $msg->getParam($i);
				}
				$call['params'] =& new xmlrpcval($params, 'array');
				$calls[] =& new xmlrpcval($call, 'struct');
			}
			$multicall =& new xmlrpcmsg('system.multicall');
			$multicall->addParam(new xmlrpcval($calls, 'array'));

			// Attempt RPC call
			$result =& $this->send($multicall, $timeout, $method);

			if($result->faultCode() != 0)
			{
				// call to system.multicall failed
				return $result;
			}

			// Unpack responses.
			$rets = $result->value();

			if ($this->return_type == 'xml')
			{
					return $rets;
			}
			else if ($this->return_type == 'phpvals')
			{
				///@todo test this code branch...
				$rets = $result->value();
				if(!is_array($rets))
				{
					return false;		// bad return type from system.multicall
				}
				$numRets = count($rets);
				if($numRets != count($msgs))
				{
					return false;		// wrong number of return values.
				}

				$response = array();
				for($i = 0; $i < $numRets; $i++)
				{
					$val = $rets[$i];
					if (!is_array($val)) {
						return false;
					}
					switch(count($val))
					{
						case 1:
							if(!isset($val[0]))
							{
								return false;		// Bad value
							}
							// Normal return value
							$response[$i] =& new xmlrpcresp($val[0], 0, '', 'phpvals');
							break;
						case 2:
							///	@todo remove usage of @: it is apparently quite slow
							$code = @$val['faultCode'];
							if(!is_int($code))
							{
								return false;
							}
							$str = @$val['faultString'];
							if(!is_string($str))
							{
								return false;
							}
							$response[$i] =& new xmlrpcresp(0, $code, $str);
							break;
						default:
							return false;
					}
				}
				return $response;
			}
			else // return type == 'xmlrpcvals'
			{
				$rets = $result->value();
				if($rets->kindOf() != 'array')
				{
					return false;		// bad return type from system.multicall
				}
				$numRets = $rets->arraysize();
				if($numRets != count($msgs))
				{
					return false;		// wrong number of return values.
				}

				$response = array();
				for($i = 0; $i < $numRets; $i++)
				{
					$val = $rets->arraymem($i);
					switch($val->kindOf())
					{
						case 'array':
							if($val->arraysize() != 1)
							{
								return false;		// Bad value
							}
							// Normal return value
							$response[$i] =& new xmlrpcresp($val->arraymem(0));
							break;
						case 'struct':
							$code = $val->structmem('faultCode');
							if($code->kindOf() != 'scalar' || $code->scalartyp() != 'int')
							{
								return false;
							}
							$str = $val->structmem('faultString');
							if($str->kindOf() != 'scalar' || $str->scalartyp() != 'string')
							{
								return false;
							}
							$response[$i] =& new xmlrpcresp(0, $code->scalarval(), $str->scalarval());
							break;
						default:
							return false;
					}
				}
				return $response;
			}
		}
	} // end class xmlrpc_client

	class xmlrpcresp
	{
		var $val = 0;
		var $valtyp;
		var $errno = 0;
		var $errstr = '';
		var $payload;
		var $hdrs = array();
		var $_cookies = array();
		var $content_type = 'text/xml';
		var $raw_data = '';

		/**
		* @param mixed $val either an xmlrpcval obj, a php value or the xml serialization of an xmlrpcval (a string)
		* @param integer $fcode set it to anything but 0 to create an error response
		* @param string $fstr the error string, in case of an error response
		* @param string $valtyp either 'xmlrpcvals', 'phpvals' or 'xml'
		*
		* @todo add check that $val / $fcode / $fstr is of correct type???
		* NB: as of now we do not do it, since it might be either an xmlrpcval or a plain
		* php val, or a complete xml chunk, depending on usage of xmlrpc_client::send() inside which creator is called...
		*/
		function xmlrpcresp($val, $fcode = 0, $fstr = '', $valtyp='')
		{
			if($fcode != 0)
			{
				// error response
				$this->errno = $fcode;
				$this->errstr = $fstr;
				//$this->errstr = htmlspecialchars($fstr); // XXX: encoding probably shouldn't be done here; fix later.
			}
			else
			{
				// successful response
				$this->val = $val;
				if ($valtyp == '')
				{
					// user did not declare type of response value: try to guess it
					if (is_object($this->val) && is_a($this->val, 'xmlrpcval'))
					{
						$this->valtyp = 'xmlrpcvals';
					}
					else if (is_string($this->val))
					{
						$this->valtyp = 'xml';

					}
					else
					{
						$this->valtyp = 'phpvals';
					}
				}
				else
				{
					// user declares type of resp value: believe him
					$this->valtyp = $valtyp;
				}
			}
		}

		/**
		* Returns the error code of the response.
		* @return integer the error code of this response (0 for not-error responses)
		* @access public
		*/
		function faultCode()
		{
			return $this->errno;
		}

		/**
		* Returns the error code of the response.
		* @return string the error string of this response ('' for not-error responses)
		* @access public
		*/
		function faultString()
		{
			return $this->errstr;
		}

		/**
		* Returns the value received by the server.
		* @return mixed the xmlrpcval object returned by the server. Might be an xml string or php value if the response has been created by specially configured xmlrpc_client objects
		* @access public
		*/
		function value()
		{
			return $this->val;
		}

		/**
		* Returns an array with the cookies received from the server.
		* Array has the form: $cookiename => array ('value' => $val, $attr1 => $val1, $attr2 = $val2, ...)
		* with attributes being e.g. 'expires', 'path', domain'.
		* NB: cookies sent as 'expired' by the server (i.e. with an expiry date in the past)
		* are still present in the array. It is up to the user-defined code to decide
		* how to use the received cookies, and wheter they have to be sent back with the next
		* request to the server (using xmlrpc_client::setCookie) or not
		* @return array array of cookies received from the server
		* @access public
		*/
		function cookies()
		{
			return $this->_cookies;
		}

		/**
		* Returns xml representation of the response. XML prologue not included
		* @param string $charset_encoding the charset to be used for serialization. if null, US-ASCII is assumed
		* @return string the xml representation of the response
		* @access public
		*/
		function serialize($charset_encoding='')
		{
			if ($charset_encoding != '')
				$this->content_type = 'text/xml; charset=' . $charset_encoding;
			else
				$this->content_type = 'text/xml';
			$result = "<methodResponse>\n";
			if($this->errno)
			{
				// G. Giunta 2005/2/13: let non-ASCII response messages be tolerated by clients
				// by xml-encoding non ascii chars
				$result .= "<fault>\n" .
"<value>\n<struct><member><name>faultCode</name>\n<value><int>" . $this->errno .
"</int></value>\n</member>\n<member>\n<name>faultString</name>\n<value><string>" .
xmlrpc_encode_entitites($this->errstr, $GLOBALS['xmlrpc_internalencoding'], $charset_encoding) . "</string></value>\n</member>\n" .
"</struct>\n</value>\n</fault>";
			}
			else
			{
				if(!is_object($this->val) || !is_a($this->val, 'xmlrpcval'))
				{
					if (is_string($this->val) && $this->valtyp == 'xml')
					{
						$result .= "<params>\n<param>\n" .
							$this->val .
							"</param>\n</params>";
					}
					else
					{
						/// @todo try to build something serializable?
						die('cannot serialize xmlrpcresp objects whose content is native php values');
					}
				}
				else
				{
					$result .= "<params>\n<param>\n" .
						$this->val->serialize($charset_encoding) .
						"</param>\n</params>";
				}
			}
			$result .= "\n</methodResponse>";
			$this->payload = $result;
			return $result;
		}
	}

	class xmlrpcmsg
	{
		var $payload;
		var $methodname;
		var $params=array();
		var $debug=0;
		var $content_type = 'text/xml';

		/**
		* @param string $meth the name of the method to invoke
		* @param array $pars array of parameters to be paased to the method (xmlrpcval objects)
		*/
		function xmlrpcmsg($meth, $pars=0)
		{
			$this->methodname=$meth;
			if(is_array($pars) && count($pars)>0)
			{
				for($i=0; $i<count($pars); $i++)
				{
					$this->addParam($pars[$i]);
				}
			}
		}

		/**
		* @access private
		*/
		function xml_header($charset_encoding='')
		{
			if ($charset_encoding != '')
			{
				return "<?xml version=\"1.0\" encoding=\"$charset_encoding\" ?" . ">\n<methodCall>\n";
			}
			else
			{
				return "<?xml version=\"1.0\"?" . ">\n<methodCall>\n";
			}
		}

		/**
		* @access private
		*/
		function xml_footer()
		{
			return '</methodCall>';
		}

		/**
		* @access private
		*/
		function kindOf()
		{
			return 'msg';
		}

		/**
		* @access private
		*/
		function createPayload($charset_encoding='')
		{
			if ($charset_encoding != '')
				$this->content_type = 'text/xml; charset=' . $charset_encoding;
			else
				$this->content_type = 'text/xml';
			$this->payload=$this->xml_header($charset_encoding);
			$this->payload.='<methodName>' . $this->methodname . "</methodName>\n";
			$this->payload.="<params>\n";
			for($i=0; $i<count($this->params); $i++)
			{
				$p=$this->params[$i];
				$this->payload.="<param>\n" . $p->serialize($charset_encoding) .
				"</param>\n";
			}
			$this->payload.="</params>\n";
			$this->payload.=$this->xml_footer();
		}

		/**
		* Gets/sets the xmlrpc method to be invoked
		* @param string $meth the method to be set (leave empty not to set it)
		* @return string the method that will be invoked
		* @access public
		*/
		function method($meth='')
		{
			if($meth!='')
			{
				$this->methodname=$meth;
			}
			return $this->methodname;
		}

		/**
		* Returns xml representation of the message. XML prologue included
		* @return string the xml representation of the message, xml prologue included
		* @access public
		*/
		function serialize($charset_encoding='')
		{
			$this->createPayload($charset_encoding);
			return $this->payload;
		}

		/**
		* Add a parameter to the list of parameters to be used upon method invocation
		* @param xmlrpcval $par
		* @return boolean false on failure
		* @access public
		*/
		function addParam($par)
		{
			// add check: do not add to self params which are not xmlrpcvals
			if(is_object($par) && is_a($par, 'xmlrpcval'))
			{
				$this->params[]=$par;
				return true;
			}
			else
			{
				return false;
			}
		}

		/**
		* Returns the nth parameter in the message. The index zero-based.
		* @param integer $i the index of the parameter to fetch (zero based)
		* @return xmlrpcval the i-th parameter
		* @access public
		*/
		function getParam($i) { return $this->params[$i]; }

		/**
		* Returns the number of parameters in the messge.
		* @return integer the number of parameters currently set
		* @access public
		*/
		function getNumParams() { return count($this->params); }

		/**
		* Given an open file handle, read all data available and parse it as axmlrpc response.
		* NB: the file handle is not closed by this function.
		* NNB: might have trouble in rare cases to work on network streams, as we
        *      check for a read of 0 bytes instead of feof($fp).
		*      But since checking for feof(null) returns false, we would risk an
		*      infinite loop in that case, because we cannot trust the caller
		*      to give us a valid pointer to an open file...
		* @access public
		* @return xmlrpcresp
		* @todo add 2nd & 3rd param to be passed to ParseResponse() ???
		*/
		function &parseResponseFile($fp)
		{
			$ipd='';
			while($data=fread($fp, 32768))
			{
				$ipd.=$data;
			}
			//fclose($fp);
			$r =& $this->parseResponse($ipd);
			return $r;
		}

		/**
		* Parses HTTP headers and separates them from data.
		* @access private
		*/
		function &parseResponseHeaders(&$data, $headers_processed=false)
		{
				// Support "web-proxy-tunelling" connections for https through proxies
				if(preg_match('/^HTTP\/1\.[0-1] 200 Connection established/', $data))
				{
					// Look for CR/LF or simple LF as line separator,
					// (even though it is not valid http)
					$pos = strpos($data,"\r\n\r\n");
					if($pos || is_int($pos))
					{
						$bd = $pos+4;
					}
					else
					{
						$pos = strpos($data,"\n\n");
						if($pos || is_int($pos))
						{
							$bd = $pos+2;
						}
						else
						{
							// No separation between response headers and body: fault?
							$bd = 0;
						}
					}
					if ($bd)
					{
						// this filters out all http headers from proxy.
						// maybe we could take them into account, too?
						$data = substr($data, $bd);
					}
					else
					{
						error_log('XML-RPC: xmlrpcmsg::parseResponse: HTTPS via proxy error, tunnel connection possibly failed');
						$r=&new xmlrpcresp(0, $GLOBALS['xmlrpcerr']['http_error'], $GLOBALS['xmlrpcstr']['http_error']. ' (HTTPS via proxy error, tunnel connection possibly failed)');
						return $r;
					}
				}

				// Strip HTTP 1.1 100 Continue header if present
				while(preg_match('/^HTTP\/1\.1 1[0-9]{2} /', $data))
				{
					$pos = strpos($data, 'HTTP', 12);
					// server sent a Continue header without any (valid) content following...
					// give the client a chance to know it
					if(!$pos && !is_int($pos)) // works fine in php 3, 4 and 5
					{
						break;
					}
					$data = substr($data, $pos);
				}
				if(!preg_match('/^HTTP\/[0-9.]+ 200 /', $data))
				{
					$errstr= substr($data, 0, strpos($data, "\n")-1);
					error_log('XML-RPC: xmlrpcmsg::parseResponse: HTTP error, got response: ' .$errstr);
					$r=&new xmlrpcresp(0, $GLOBALS['xmlrpcerr']['http_error'], $GLOBALS['xmlrpcstr']['http_error']. ' (' . $errstr . ')');
					return $r;
				}

				$GLOBALS['_xh']['headers'] = array();
				$GLOBALS['_xh']['cookies'] = array();

				// be tolerant to usage of \n instead of \r\n to separate headers and data
				// (even though it is not valid http)
				$pos = strpos($data,"\r\n\r\n");
				if($pos || is_int($pos))
				{
					$bd = $pos+4;
				}
				else
				{
					$pos = strpos($data,"\n\n");
					if($pos || is_int($pos))
					{
						$bd = $pos+2;
					}
					else
					{
						// No separation between response headers and body: fault?
						// we could take some action here instead of going on...
						$bd = 0;
					}
				}
				// be tolerant to line endings, and extra empty lines
				$ar = split("\r?\n", trim(substr($data, 0, $pos)));
				while(list(,$line) = @each($ar))
				{
					// take care of multi-line headers and cookies
					$arr = explode(':',$line,2);
					if(count($arr) > 1)
					{
						$header_name = strtolower(trim($arr[0]));
						/// @todo some other headers (the ones that allow a CSV list of values)
						/// do allow many values to be passed using multiple header lines.
						/// We should add content to $GLOBALS['_xh']['headers'][$header_name]
						/// instead of replacing it for those...
						if ($header_name == 'set-cookie' || $header_name == 'set-cookie2')
						{
							if ($header_name == 'set-cookie2')
							{
								// version 2 cookies:
								// there could be many cookies on one line, comma separated
								$cookies = explode(',', $arr[1]);
							}
							else
							{
								$cookies = array($arr[1]);
							}
							foreach ($cookies as $cookie)
							{
								// glue together all received cookies, using a comma to separate them
								// (same as php does with getallheaders())
								if (isset($GLOBALS['_xh']['headers'][$header_name]))
									$GLOBALS['_xh']['headers'][$header_name] .= ', ' . trim($cookie);
								else
									$GLOBALS['_xh']['headers'][$header_name] = trim($cookie);
								// parse cookie attributes, in case user wants to correctly honour them
								// feature creep: only allow rfc-compliant cookie attributes?
								// @todo support for server sending multiple time cookie with same name, but using different PATHs
								$cookie = explode(';', $cookie);
								foreach ($cookie as $pos => $val)
								{
									$val = explode('=', $val, 2);
									$tag = trim($val[0]);
									$val = trim(@$val[1]);
									/// @todo with version 1 cookies, we should strip leading and trailing " chars
									if ($pos == 0)
									{
										$cookiename = $tag;
										$GLOBALS['_xh']['cookies'][$tag] = array();
										$GLOBALS['_xh']['cookies'][$cookiename]['value'] = urldecode($val);
									}
									else
									{
										if ($tag != 'value')
										{
										  $GLOBALS['_xh']['cookies'][$cookiename][$tag] = $val;
										}
									}
								}
							}
						}
						else
						{
							$GLOBALS['_xh']['headers'][$header_name] = trim($arr[1]);
						}
					}
					elseif(isset($header_name))
					{
						///	@todo version1 cookies might span multiple lines, thus breaking the parsing above
						$GLOBALS['_xh']['headers'][$header_name] .= ' ' . trim($line);
					}
				}

				$data = substr($data, $bd);

				if($this->debug && count($GLOBALS['_xh']['headers']))
				{
					print '<PRE>';
					foreach($GLOBALS['_xh']['headers'] as $header => $value)
					{
						print htmlentities("HEADER: $header: $value\n");
					}
					foreach($GLOBALS['_xh']['cookies'] as $header => $value)
					{
						print htmlentities("COOKIE: $header={$value['value']}\n");
					}
					print "</PRE>\n";
				}

				// if CURL was used for the call, http headers have been processed,
				// and dechunking + reinflating have been carried out
				if(!$headers_processed)
				{
					// Decode chunked encoding sent by http 1.1 servers
					if(isset($GLOBALS['_xh']['headers']['transfer-encoding']) && $GLOBALS['_xh']['headers']['transfer-encoding'] == 'chunked')
					{
						if(!$data = decode_chunked($data))
						{
							error_log('XML-RPC: xmlrpcmsg::parseResponse: errors occurred when trying to rebuild the chunked data received from server');
							$r =& new xmlrpcresp(0, $GLOBALS['xmlrpcerr']['dechunk_fail'], $GLOBALS['xmlrpcstr']['dechunk_fail']);
							return $r;
						}
					}

					// Decode gzip-compressed stuff
					// code shamelessly inspired from nusoap library by Dietrich Ayala
					if(isset($GLOBALS['_xh']['headers']['content-encoding']))
					{
						$GLOBALS['_xh']['headers']['content-encoding'] = str_replace('x-', '', $GLOBALS['_xh']['headers']['content-encoding']);
						if($GLOBALS['_xh']['headers']['content-encoding'] == 'deflate' || $GLOBALS['_xh']['headers']['content-encoding'] == 'gzip')
						{
							// if decoding works, use it. else assume data wasn't gzencoded
							if(function_exists('gzinflate'))
							{
								if($GLOBALS['_xh']['headers']['content-encoding'] == 'deflate' && $degzdata = @gzuncompress($data))
								{
									$data = $degzdata;
									if($this->debug)
									print "<PRE>---INFLATED RESPONSE---[".strlen($data)." chars]---\n" . htmlentities($data) . "\n---END---</PRE>";
								}
								elseif($GLOBALS['_xh']['headers']['content-encoding'] == 'gzip' && $degzdata = @gzinflate(substr($data, 10)))
								{
									$data = $degzdata;
									if($this->debug)
									print "<PRE>---INFLATED RESPONSE---[".strlen($data)." chars]---\n" . htmlentities($data) . "\n---END---</PRE>";
								}
								else
								{
									error_log('XML-RPC: xmlrpcmsg::parseResponse: errors occurred when trying to decode the deflated data received from server');
									$r =& new xmlrpcresp(0, $GLOBALS['xmlrpcerr']['decompress_fail'], $GLOBALS['xmlrpcstr']['decompress_fail']);
									return $r;
								}
							}
							else
							{
								error_log('XML-RPC: xmlrpcmsg::parseResponse: the server sent deflated data. Your php install must have the Zlib extension compiled in to support this.');
								$r =& new xmlrpcresp(0, $GLOBALS['xmlrpcerr']['cannot_decompress'], $GLOBALS['xmlrpcstr']['cannot_decompress']);
								return $r;
							}
						}
					}
				} // end of 'if needed, de-chunk, re-inflate response'

				// real stupid hack to avoid PHP 4 complaining about returning NULL by ref
				$r = null;
				$r =& $r;
				return $r;
		}

		/**
		* Parse the xmlrpc response contained in the string $data and return an xmlrpcresp object.
		* @param string $data the xmlrpc response, eventually including http headers
		* @param bool $headers_processed when true prevents parsing HTTP headers for interpretation of content-encoding and consequent decoding
		* @param string $return_type decides return type, i.e. content of response->value(). Either 'xmlrpcvals', 'xml' or 'phpvals'
		* @return xmlrpcresp
		* @access public
		*/
		function &parseResponse($data='', $headers_processed=false, $return_type='xmlrpcvals')
		{
			if($this->debug)
			{
				//by maHo, replaced htmlspecialchars with htmlentities
				print "<PRE>---GOT---\n" . htmlentities($data) . "\n---END---\n</PRE>";
			}

			if($data == '')
			{
				error_log('XML-RPC: xmlrpcmsg::parseResponse: no response received from server.');
				$r =& new xmlrpcresp(0, $GLOBALS['xmlrpcerr']['no_data'], $GLOBALS['xmlrpcstr']['no_data']);
				return $r;
			}

			$GLOBALS['_xh']=array();

			$raw_data = $data;
			// parse the HTTP headers of the response, if present, and separate them from data
			if(substr($data, 0, 4) == 'HTTP')
			{
				$r =& $this->parseResponseHeaders($data, $headers_processed);
				if ($r)
				{
					// failed processing of HTTP response headers
					// save into response obj the full payload received, for debugging
					$r->raw_data = $data;
					return $r;
				}
			}
			else
			{
				$GLOBALS['_xh']['headers'] = array();
				$GLOBALS['_xh']['cookies'] = array();
			}

			if($this->debug)
			{
				$start = strpos($data, '<!-- SERVER DEBUG INFO (BASE64 ENCODED):');
				if ($start)
				{
					$start += strlen('<!-- SERVER DEBUG INFO (BASE64 ENCODED):');
					$end = strpos($data, '-->', $start);
					$comments = substr($data, $start, $end-$start);
					print "<PRE>---SERVER DEBUG INFO (DECODED) ---\n\t".htmlentities(str_replace("\n", "\n\t", base64_decode($comments)))."\n---END---\n</PRE>";
				}
			}

			// be tolerant of extra whitespace in response body
			$data = trim($data);

			/// @todo return an error msg if $data=='' ?

			// be tolerant of junk after methodResponse (e.g. javascript ads automatically inserted by free hosts)
			// idea from Luca Mariano <luca.mariano@email.it> originally in PEARified version of the lib
			$bd = false;
			// Poor man's version of strrpos for php 4...
			$pos = strpos($data, '</methodResponse>');
			while($pos || is_int($pos))
			{
				$bd = $pos+17;
				$pos = strpos($data, '</methodResponse>', $bd);
			}
			if($bd)
			{
				$data = substr($data, 0, $bd);
			}

			// if user wants back raw xml, give it to him
			if ($return_type == 'xml')
			{
				$r =& new xmlrpcresp($data, 0, '', 'xml');
				$r->hdrs = $GLOBALS['_xh']['headers'];
				$r->_cookies = $GLOBALS['_xh']['cookies'];
				$r->raw_data = $raw_data;
				return $r;
			}

			// try to 'guestimate' the character encoding of the received response
			$resp_encoding = guess_encoding(@$GLOBALS['_xh']['headers']['content-type'], $data);

			$GLOBALS['_xh']['ac']='';
			//$GLOBALS['_xh']['qt']=''; //unused...
			$GLOBALS['_xh']['stack'] = array();
			$GLOBALS['_xh']['valuestack'] = array();
			$GLOBALS['_xh']['isf']=0; // 0 = OK, 1 for xmlrpc fault responses, 2 = invalid xmlrpc
			$GLOBALS['_xh']['isf_reason']='';
			$GLOBALS['_xh']['rt']=''; // 'methodcall or 'methodresponse'

			// if response charset encoding is not known / supported, try to use
			// the default encoding and parse the xml anyway, but log a warning...
			if (!in_array($resp_encoding, array('UTF-8', 'ISO-8859-1', 'US-ASCII')))
			// the following code might be better for mb_string enabled installs, but
			// makes the lib about 200% slower...
			//if (!is_valid_charset($resp_encoding, array('UTF-8', 'ISO-8859-1', 'US-ASCII')))
			{
				error_log('XML-RPC: xmlrpcmsg::parseResponse: invalid charset encoding of received response: '.$resp_encoding);
				$resp_encoding = $GLOBALS['xmlrpc_defencoding'];
			}
			$parser = xml_parser_create($resp_encoding);
			xml_parser_set_option($parser, XML_OPTION_CASE_FOLDING, true);
			// G. Giunta 2005/02/13: PHP internally uses ISO-8859-1, so we have to tell
			// the xml parser to give us back data in the expected charset.
			// What if internal encoding is not in one of the 3 allowed?
			// we use the broadest one, ie. utf8
			// This allows to send data which is native in various charset,
			// by extending xmlrpc_encode_entitites() and setting xmlrpc_internalencoding
			if (!in_array($GLOBALS['xmlrpc_internalencoding'], array('UTF-8', 'ISO-8859-1', 'US-ASCII')))
			{
				xml_parser_set_option($parser, XML_OPTION_TARGET_ENCODING, 'UTF-8');
			}
			else
			{
				xml_parser_set_option($parser, XML_OPTION_TARGET_ENCODING, $GLOBALS['xmlrpc_internalencoding']);
			}

			if ($return_type == 'phpvals')
			{
				xml_set_element_handler($parser, 'xmlrpc_se', 'xmlrpc_ee_fast');
			}
			else
			{
				xml_set_element_handler($parser, 'xmlrpc_se', 'xmlrpc_ee');
			}

			xml_set_character_data_handler($parser, 'xmlrpc_cd');
			xml_set_default_handler($parser, 'xmlrpc_dh');

			// first error check: xml not well formed
			if(!xml_parse($parser, $data, count($data)))
			{
				// thanks to Peter Kocks <peter.kocks@baygate.com>
				if((xml_get_current_line_number($parser)) == 1)
				{
					$errstr = 'XML error at line 1, check URL';
				}
				else
				{
					$errstr = sprintf('XML error: %s at line %d, column %d',
						xml_error_string(xml_get_error_code($parser)),
						xml_get_current_line_number($parser), xml_get_current_column_number($parser));
				}
				error_log($errstr);
				$r=&new xmlrpcresp(0, $GLOBALS['xmlrpcerr']['invalid_return'], $GLOBALS['xmlrpcstr']['invalid_return'].' ('.$errstr.')');
				xml_parser_free($parser);
				if($this->debug)
				{
					print $errstr;
				}
				$r->hdrs = $GLOBALS['_xh']['headers'];
				$r->_cookies = $GLOBALS['_xh']['cookies'];
				$r->raw_data = $raw_data;
				return $r;
			}
			xml_parser_free($parser);
			// second error check: xml well formed but not xml-rpc compliant
			if ($GLOBALS['_xh']['isf'] > 1)
			{
				if ($this->debug)
				{
					/// @todo echo something for user?
				}

				$r =& new xmlrpcresp(0, $GLOBALS['xmlrpcerr']['invalid_return'],
				$GLOBALS['xmlrpcstr']['invalid_return'] . ' ' . $GLOBALS['_xh']['isf_reason']);
			}
			// third error check: parsing of the response has somehow gone boink.
			// NB: shall we omit this check, since we trust the parsing code?
			elseif ($return_type == 'xmlrpcvals' && !is_object($GLOBALS['_xh']['value']))
			{
				// something odd has happened
				// and it's time to generate a client side error
				// indicating something odd went on
				$r=&new xmlrpcresp(0, $GLOBALS['xmlrpcerr']['invalid_return'],
					$GLOBALS['xmlrpcstr']['invalid_return']);
			}
			else
			{
				if ($this->debug)
				{
					print "<PRE>---PARSED---\n";
					// somehow htmlentities chokes on var_export, and some full html string...
					//print htmlentitites(var_export($GLOBALS['_xh']['value'], true));
					print htmlspecialchars(var_export($GLOBALS['_xh']['value'], true));
					print "\n---END---</PRE>";
				}

				// note that using =& will raise an error if $GLOBALS['_xh']['st'] does not generate an object.
				$v =& $GLOBALS['_xh']['value'];

				if($GLOBALS['_xh']['isf'])
				{
					/// @todo we should test here if server sent an int and a string,
					/// and/or coerce them into such...
					if ($return_type == 'xmlrpcvals')
					{
						$errno_v = $v->structmem('faultCode');
						$errstr_v = $v->structmem('faultString');
						$errno = $errno_v->scalarval();
						$errstr = $errstr_v->scalarval();
					}
					else
					{
						$errno = $v['faultCode'];
						$errstr = $v['faultString'];
					}

					if($errno == 0)
					{
						// FAULT returned, errno needs to reflect that
						$errno = -1;
					}

					$r =& new xmlrpcresp(0, $errno, $errstr);
				}
				else
				{
					$r=&new xmlrpcresp($v, 0, '', $return_type);
				}
			}

			$r->hdrs = $GLOBALS['_xh']['headers'];
			$r->_cookies = $GLOBALS['_xh']['cookies'];
			$r->raw_data = $raw_data;
			return $r;
		}
	}

	class xmlrpcval
	{
		var $me=array();
		var $mytype=0;
		var $_php_class=null;

		/**
		* @param mixed $val
		* @param string $type any valid xmlrpc type name (lowercase). If null, 'string' is assumed
		*/
		function xmlrpcval($val=-1, $type='')
		{
			/// @todo: optimization creep - do not call addXX, do it all inline.
			/// downside: booleans will not be coerced anymore
			if($val!==-1 || $type!='')
			{
				// optimization creep: inlined all work done by constructor
				switch($type)
				{
					case '':
						$this->mytype=1;
						$this->me['string']=$val;
						break;
					case 'i4':
					case 'int':
					case 'double':
					case 'string':
					case 'boolean':
					case 'dateTime.iso8601':
					case 'base64':
					case 'null':
						$this->mytype=1;
						$this->me[$type]=$val;
						break;
					case 'array':
						$this->mytype=2;
						$this->me['array']=$val;
						break;
					case 'struct':
						$this->mytype=3;
						$this->me['struct']=$val;
						break;
					default:
						error_log("XML-RPC: xmlrpcval::xmlrpcval: not a known type ($type)");
				}
				/*if($type=='')
				{
					$type='string';
				}
				if($GLOBALS['xmlrpcTypes'][$type]==1)
				{
					$this->addScalar($val,$type);
				}
				elseif($GLOBALS['xmlrpcTypes'][$type]==2)
				{
					$this->addArray($val);
				}
				elseif($GLOBALS['xmlrpcTypes'][$type]==3)
				{
					$this->addStruct($val);
				}*/
			}
		}

		/**
		* Add a single php value to an (unitialized) xmlrpcval
		* @param mixed $val
		* @param string $type
		* @return int 1 or 0 on failure
		*/
		function addScalar($val, $type='string')
		{
			$typeof=@$GLOBALS['xmlrpcTypes'][$type];
			if($typeof!=1)
			{
				error_log("XML-RPC: xmlrpcval::addScalar: not a scalar type ($type)");
				return 0;
			}

			// coerce booleans into correct values
			// NB: we should iether do it for datetimes, integers and doubles, too,
			// or just plain remove this check, implemnted on booleans only...
			if($type==$GLOBALS['xmlrpcBoolean'])
			{
				if(strcasecmp($val,'true')==0 || $val==1 || ($val==true && strcasecmp($val,'false')))
				{
					$val=true;
				}
				else
				{
					$val=false;
				}
			}

			switch($this->mytype)
			{
				case 1:
					error_log('XML-RPC: xmlrpcval::addScalar: scalar xmlrpcval can have only one value');
					return 0;
				case 3:
					error_log('XML-RPC: xmlrpcval::addScalar: cannot add anonymous scalar to struct xmlrpcval');
					return 0;
				case 2:
					// we're adding a scalar value to an array here
					//$ar=$this->me['array'];
					//$ar[]=&new xmlrpcval($val, $type);
					//$this->me['array']=$ar;
					// Faster (?) avoid all the costly array-copy-by-val done here...
					$this->me['array'][]=&new xmlrpcval($val, $type);
					return 1;
				default:
					// a scalar, so set the value and remember we're scalar
					$this->me[$type]=$val;
					$this->mytype=$typeof;
					return 1;
			}
		}

		/**
		* Add an array of xmlrpcval objects to an xmlrpcval
		* @param array $vals
		* @return int 1 or 0 on failure
		* @access public
		*
		* @todo add some checking for $vals to be an array of xmlrpcvals?
		*/
		function addArray($vals)
		{
			if($this->mytype==0)
			{
				$this->mytype=$GLOBALS['xmlrpcTypes']['array'];
				$this->me['array']=$vals;
				return 1;
			}
			elseif($this->mytype==2)
			{
				// we're adding to an array here
				$this->me['array'] = array_merge($this->me['array'], $vals);
				return 1;
			}
			else
			{
				error_log('XML-RPC: xmlrpcval::addArray: already initialized as a [' . $this->kindOf() . ']');
				return 0;
			}
		}

		/**
		* Add an array of named xmlrpcval objects to an xmlrpcval
		* @param array $vals
		* @return int 1 or 0 on failure
		* @access public
		*
		* @todo add some checking for $vals to be an array?
		*/
		function addStruct($vals)
		{
			if($this->mytype==0)
			{
				$this->mytype=$GLOBALS['xmlrpcTypes']['struct'];
				$this->me['struct']=$vals;
				return 1;
			}
			elseif($this->mytype==3)
			{
				// we're adding to a struct here
				$this->me['struct'] = array_merge($this->me['struct'], $vals);
				return 1;
			}
			else
			{
				error_log('XML-RPC: xmlrpcval::addStruct: already initialized as a [' . $this->kindOf() . ']');
				return 0;
			}
		}

		// poor man's version of print_r ???
		// DEPRECATED!
		function dump($ar)
		{
			foreach($ar as $key => $val)
			{
				echo "$key => $val<br />";
				if($key == 'array')
				{
					while(list($key2, $val2) = each($val))
					{
						echo "-- $key2 => $val2<br />";
					}
				}
			}
		}

		/**
		* Returns a string containing "struct", "array" or "scalar" describing the base type of the value
		* @return string
		* @access public
		*/
		function kindOf()
		{
			switch($this->mytype)
			{
				case 3:
					return 'struct';
					break;
				case 2:
					return 'array';
					break;
				case 1:
					return 'scalar';
					break;
				default:
					return 'undef';
			}
		}

		/**
		* @access private
		*/
		function serializedata($typ, $val, $charset_encoding='')
		{
			$rs='';
			switch(@$GLOBALS['xmlrpcTypes'][$typ])
			{
				case 1:
					switch($typ)
					{
						case $GLOBALS['xmlrpcBase64']:
							$rs.="<${typ}>" . base64_encode($val) . "</${typ}>";
							break;
						case $GLOBALS['xmlrpcBoolean']:
							$rs.="<${typ}>" . ($val ? '1' : '0') . "</${typ}>";
							break;
						case $GLOBALS['xmlrpcString']:
							// G. Giunta 2005/2/13: do NOT use htmlentities, since
							// it will produce named html entities, which are invalid xml
							$rs.="<${typ}>" . xmlrpc_encode_entitites($val, $GLOBALS['xmlrpc_internalencoding'], $charset_encoding). "</${typ}>";
							break;
						case $GLOBALS['xmlrpcInt']:
						case $GLOBALS['xmlrpcI4']:
							$rs.="<${typ}>".(int)$val."</${typ}>";
							break;
						case $GLOBALS['xmlrpcDouble']:
    						// avoid using standard conversion of float to string because it is locale-dependent,
    						// and also because the xmlrpc spec forbids exponential notation
    						// sprintf('%F') would be most likely ok but it is only available since PHP 4.3.10 and PHP 5.0.3.
    						// The code below tries its best at keeping max precision while avoiding exp notation,
    						// but there is of course no limit in the number of decimal places to be used...
    						$rs.="<${typ}>".preg_replace('/\\.?0+$/','',number_format((double)$val, 128, '.', ''))."</${typ}>";
							break;
						case $GLOBALS['xmlrpcNull']:
							$rs.="<nil/>";
							break;
						default:
							// no standard type value should arrive here, but provide a possibility
							// for xmlrpcvals of unknown type...
							$rs.="<${typ}>${val}</${typ}>";
					}
					break;
				case 3:
					// struct
					if ($this->_php_class)
					{
						$rs.='<struct php_class="' . $this->_php_class . "\">\n";
					}
					else
					{
						$rs.="<struct>\n";
					}
					foreach($val as $key2 => $val2)
					{
						$rs.='<member><name>'.xmlrpc_encode_entitites($key2, $GLOBALS['xmlrpc_internalencoding'], $charset_encoding)."</name>\n";
						//$rs.=$this->serializeval($val2);
						$rs.=$val2->serialize($charset_encoding);
						$rs.="</member>\n";
					}
					$rs.='</struct>';
					break;
				case 2:
					// array
					$rs.="<array>\n<data>\n";
					for($i=0; $i<count($val); $i++)
					{
						//$rs.=$this->serializeval($val[$i]);
						$rs.=$val[$i]->serialize($charset_encoding);
					}
					$rs.="</data>\n</array>";
					break;
				default:
					break;
			}
			return $rs;
		}

		/**
		* Returns xml representation of the value. XML prologue not included
		* @param string $charset_encoding the charset to be used for serialization. if null, US-ASCII is assumed
		* @return string
		* @access public
		*/
		function serialize($charset_encoding='')
		{
			// add check? slower, but helps to avoid recursion in serializing broken xmlrpcvals...
			//if (is_object($o) && (get_class($o) == 'xmlrpcval' || is_subclass_of($o, 'xmlrpcval')))
			//{
				reset($this->me);
				list($typ, $val) = each($this->me);
				return '<value>' . $this->serializedata($typ, $val, $charset_encoding) . "</value>\n";
			//}
		}

		// DEPRECATED
		function serializeval($o)
		{
			// add check? slower, but helps to avoid recursion in serializing broken xmlrpcvals...
			//if (is_object($o) && (get_class($o) == 'xmlrpcval' || is_subclass_of($o, 'xmlrpcval')))
			//{
				$ar=$o->me;
				reset($ar);
				list($typ, $val) = each($ar);
				return '<value>' . $this->serializedata($typ, $val) . "</value>\n";
			//}
		}

		/**
		* Checks wheter a struct member with a given name is present.
		* Works only on xmlrpcvals of type struct.
		* @param string $m the name of the struct member to be looked up
		* @return boolean
		* @access public
		*/
		function structmemexists($m)
		{
			return array_key_exists($m, $this->me['struct']);
		}

		/**
		* Returns the value of a given struct member (an xmlrpcval object in itself).
		* Will raise a php warning if struct member of given name does not exist
		* @param string $m the name of the struct member to be looked up
		* @return xmlrpcval
		* @access public
		*/
		function structmem($m)
		{
			return $this->me['struct'][$m];
		}

		/**
		* Reset internal pointer for xmlrpcvals of type struct.
		* @access public
		*/
		function structreset()
		{
			reset($this->me['struct']);
		}

		/**
		* Return next member element for xmlrpcvals of type struct.
		* @return xmlrpcval
		* @access public
		*/
		function structeach()
		{
			return each($this->me['struct']);
		}

		// DEPRECATED! this code looks like it is very fragile and has not been fixed
		// for a long long time. Shall we remove it for 2.0?
		function getval()
		{
			// UNSTABLE
			reset($this->me);
			list($a,$b)=each($this->me);
			// contributed by I Sofer, 2001-03-24
			// add support for nested arrays to scalarval
			// i've created a new method here, so as to
			// preserve back compatibility

			if(is_array($b))
			{
				@reset($b);
				while(list($id,$cont) = @each($b))
				{
					$b[$id] = $cont->scalarval();
				}
			}

			// add support for structures directly encoding php objects
			if(is_object($b))
			{
				$t = get_object_vars($b);
				@reset($t);
				while(list($id,$cont) = @each($t))
				{
					$t[$id] = $cont->scalarval();
				}
				@reset($t);
				while(list($id,$cont) = @each($t))
				{
					@$b->$id = $cont;
				}
			}
			// end contrib
			return $b;
		}

		/**
		* Returns the value of a scalar xmlrpcval
		* @return mixed
		* @access public
		*/
		function scalarval()
		{
			reset($this->me);
			list(,$b)=each($this->me);
			return $b;
		}

		/**
		* Returns the type of the xmlrpcval.
		* For integers, 'int' is always returned in place of 'i4'
		* @return string
		* @access public
		*/
		function scalartyp()
		{
			reset($this->me);
			list($a,)=each($this->me);
			if($a==$GLOBALS['xmlrpcI4'])
			{
				$a=$GLOBALS['xmlrpcInt'];
			}
			return $a;
		}

		/**
		* Returns the m-th member of an xmlrpcval of struct type
		* @param integer $m the index of the value to be retrieved (zero based)
		* @return xmlrpcval
		* @access public
		*/
		function arraymem($m)
		{
			return $this->me['array'][$m];
		}

		/**
		* Returns the number of members in an xmlrpcval of array type
		* @return integer
		* @access public
		*/
		function arraysize()
		{
			return count($this->me['array']);
		}

		/**
		* Returns the number of members in an xmlrpcval of struct type
		* @return integer
		* @access public
		*/
		function structsize()
		{
			return count($this->me['struct']);
		}
	}


	// date helpers

	/**
	* Given a timestamp, return the corresponding ISO8601 encoded string.
	*
	* Really, timezones ought to be supported
	* but the XML-RPC spec says:
	*
	* "Don't assume a timezone. It should be specified by the server in its
	* documentation what assumptions it makes about timezones."
	*
	* These routines always assume localtime unless
	* $utc is set to 1, in which case UTC is assumed
	* and an adjustment for locale is made when encoding
	*
	* @param int $timet (timestamp)
	* @param int $utc (0 or 1)
	* @return string
	*/
	function iso8601_encode($timet, $utc=0)
	{
		if(!$utc)
		{
			$t=strftime("%Y%m%dT%H:%M:%S", $timet);
		}
		else
		{
			if(function_exists('gmstrftime'))
			{
				// gmstrftime doesn't exist in some versions
				// of PHP
				$t=gmstrftime("%Y%m%dT%H:%M:%S", $timet);
			}
			else
			{
				$t=strftime("%Y%m%dT%H:%M:%S", $timet-date('Z'));
			}
		}
		return $t;
	}

	/**
	* Given an ISO8601 date string, return a timet in the localtime, or UTC
	* @param string $idate
	* @param int $utc either 0 or 1
	* @return int (datetime)
	*/
	function iso8601_decode($idate, $utc=0)
	{
		$t=0;
		if(preg_match('/([0-9]{4})([0-9]{2})([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})/', $idate, $regs))
		{
			if($utc)
			{
				$t=gmmktime($regs[4], $regs[5], $regs[6], $regs[2], $regs[3], $regs[1]);
			}
			else
			{
				$t=mktime($regs[4], $regs[5], $regs[6], $regs[2], $regs[3], $regs[1]);
			}
		}
		return $t;
	}

	/**
	* Takes an xmlrpc value in PHP xmlrpcval object format and translates it into native PHP types.
	*
	* Works with xmlrpc message objects as input, too.
	*
	* Given proper options parameter, can rebuild generic php object instances
	* (provided those have been encoded to xmlrpc format using a corresponding
	* option in php_xmlrpc_encode())
	* PLEASE NOTE that rebuilding php objects involves calling their constructor function.
	* This means that the remote communication end can decide which php code will
	* get executed on your server, leaving the door possibly open to 'php-injection'
	* style of attacks (provided you have some classes defined on your server that
	* might wreak havoc if instances are built outside an appropriate context).
	* Make sure you trust the remote server/client before eanbling this!
	*
	* @author Dan Libby (dan@libby.com)
	*
	* @param xmlrpcval $xmlrpc_val
	* @param array $options if 'decode_php_objs' is set in the options array, xmlrpc structs can be decoded into php objects
	* @return mixed
	*/
	function php_xmlrpc_decode($xmlrpc_val, $options=array())
	{
		switch($xmlrpc_val->kindOf())
		{
			case 'scalar':
				if (in_array('extension_api', $options))
				{
					reset($xmlrpc_val->me);
					list($typ,$val) = each($xmlrpc_val->me);
					switch ($typ)
					{
						case 'dateTime.iso8601':
							$xmlrpc_val->scalar = $val;
							$xmlrpc_val->xmlrpc_type = 'datetime';
							$xmlrpc_val->timestamp = iso8601_decode($val);
							return $xmlrpc_val;
						case 'base64':
							$xmlrpc_val->scalar = $val;
							$xmlrpc_val->type = $typ;
							return $xmlrpc_val;
						default:
							return $xmlrpc_val->scalarval();
					}
				}
				return $xmlrpc_val->scalarval();
			case 'array':
				$size = $xmlrpc_val->arraysize();
				$arr = array();
				for($i = 0; $i < $size; $i++)
				{
					$arr[] = php_xmlrpc_decode($xmlrpc_val->arraymem($i), $options);
				}
				return $arr;
			case 'struct':
				$xmlrpc_val->structreset();
				// If user said so, try to rebuild php objects for specific struct vals.
				/// @todo should we raise a warning for class not found?
				// shall we check for proper subclass of xmlrpcval instead of
				// presence of _php_class to detect what we can do?
				if (in_array('decode_php_objs', $options) && $xmlrpc_val->_php_class != ''
					&& class_exists($xmlrpc_val->_php_class))
				{
					$obj = @new $xmlrpc_val->_php_class;
					while(list($key,$value)=$xmlrpc_val->structeach())
					{
						$obj->$key = php_xmlrpc_decode($value, $options);
					}
					return $obj;
				}
				else
				{
					$arr = array();
					while(list($key,$value)=$xmlrpc_val->structeach())
					{
						$arr[$key] = php_xmlrpc_decode($value, $options);
					}
					return $arr;
				}
			case 'msg':
				$paramcount = $xmlrpc_val->getNumParams();
				$arr = array();
				for($i = 0; $i < $paramcount; $i++)
				{
					$arr[] = php_xmlrpc_decode($xmlrpc_val->getParam($i));
				}
				return $arr;
			}
	}

	// This constant left here only for historical reasons...
	// it was used to decide if we have to define xmlrpc_encode on our own, but
	// we do not do it anymore
	if(function_exists('xmlrpc_decode'))
	{
		define('XMLRPC_EPI_ENABLED','1');
	}
	else
	{
		define('XMLRPC_EPI_ENABLED','0');
	}

	/**
	* Takes native php types and encodes them into xmlrpc PHP object format.
	* It will not re-encode xmlrpcval objects.
	*
	* Feature creep -- could support more types via optional type argument
	* (string => datetime support has been added, ??? => base64 not yet)
	*
	* If given a proper options parameter, php object instances will be encoded
	* into 'special' xmlrpc values, that can later be decoded into php objects
	* by calling php_xmlrpc_decode() with a corresponding option
	*
	* @author Dan Libby (dan@libby.com)
	*
	* @param mixed $php_val the value to be converted into an xmlrpcval object
	* @param array $options	can include 'encode_php_objs', 'auto_dates', 'null_extension' or 'extension_api'
	* @return xmlrpcval
	*/
	function &php_xmlrpc_encode($php_val, $options=array())
	{
		$type = gettype($php_val);
		switch($type)
		{
			case 'string':
				if (in_array('auto_dates', $options) && preg_match('/^[0-9]{8}T[0-9]{2}:[0-9]{2}:[0-9]{2}$/', $php_val))
					$xmlrpc_val =& new xmlrpcval($php_val, $GLOBALS['xmlrpcDateTime']);
				else
					$xmlrpc_val =& new xmlrpcval($php_val, $GLOBALS['xmlrpcString']);
				break;
			case 'integer':
				$xmlrpc_val =& new xmlrpcval($php_val, $GLOBALS['xmlrpcInt']);
				break;
			case 'double':
				$xmlrpc_val =& new xmlrpcval($php_val, $GLOBALS['xmlrpcDouble']);
				break;
				// <G_Giunta_2001-02-29>
				// Add support for encoding/decoding of booleans, since they are supported in PHP
			case 'boolean':
				$xmlrpc_val =& new xmlrpcval($php_val, $GLOBALS['xmlrpcBoolean']);
				break;
				// </G_Giunta_2001-02-29>
			case 'array':
				// PHP arrays can be encoded to either xmlrpc structs or arrays,
				// depending on wheter they are hashes or plain 0..n integer indexed
				// A shorter one-liner would be
				// $tmp = array_diff(array_keys($php_val), range(0, count($php_val)-1));
				// but execution time skyrockets!
				$j = 0;
				$arr = array();
				$ko = false;
				foreach($php_val as $key => $val)
				{
					$arr[$key] =& php_xmlrpc_encode($val, $options);
					if(!$ko && $key !== $j)
					{
						$ko = true;
					}
					$j++;
				}
				if($ko)
				{
					$xmlrpc_val =& new xmlrpcval($arr, $GLOBALS['xmlrpcStruct']);
				}
				else
				{
					$xmlrpc_val =& new xmlrpcval($arr, $GLOBALS['xmlrpcArray']);
				}
				break;
			case 'object':
				if(is_a($php_val, 'xmlrpcval'))
				{
					$xmlrpc_val = $php_val;
				}
				else
				{
					$arr = array();
					while(list($k,$v) = each($php_val))
					{
						$arr[$k] = php_xmlrpc_encode($v, $options);
					}
					$xmlrpc_val =& new xmlrpcval($arr, $GLOBALS['xmlrpcStruct']);
					if (in_array('encode_php_objs', $options))
					{
						// let's save original class name into xmlrpcval:
						// might be useful later on...
						$xmlrpc_val->_php_class = get_class($php_val);
					}
				}
				break;
			case 'NULL':
				if (in_array('extension_api', $options))
				{
					$xmlrpc_val =& new xmlrpcval('', $GLOBALS['xmlrpcString']);
				}
				if (in_array('null_extension', $options))
				{
					$xmlrpc_val =& new xmlrpcval('', $GLOBALS['xmlrpcNull']);
				}
				else
				{
					$xmlrpc_val =& new xmlrpcval();
				}
				break;
			case 'resource':
				if (in_array('extension_api', $options))
				{
					$xmlrpc_val =& new xmlrpcval((int)$php_val, $GLOBALS['xmlrpcInt']);
				}
				else
				{
					$xmlrpc_val =& new xmlrpcval();
				}
			// catch "user function", "unknown type"
			default:
				// giancarlo pinerolo <ping@alt.it>
				// it has to return
				// an empty object in case, not a boolean.
				$xmlrpc_val =& new xmlrpcval();
				break;
			}
			return $xmlrpc_val;
	}

	/**
	* Convert the xml representation of a method response, method request or single
	* xmlrpc value into the appropriate object (a.k.a. deserialize)
	* @param string $xml_val
	* @param array $options
	* @return mixed false on error, or an instance of either xmlrpcval, xmlrpcmsg or xmlrpcresp
	*/
	function php_xmlrpc_decode_xml($xml_val, $options=array())
	{
		$GLOBALS['_xh'] = array();
		$GLOBALS['_xh']['ac'] = '';
		$GLOBALS['_xh']['stack'] = array();
		$GLOBALS['_xh']['valuestack'] = array();
		$GLOBALS['_xh']['params'] = array();
		$GLOBALS['_xh']['pt'] = array();
		$GLOBALS['_xh']['isf'] = 0;
		$GLOBALS['_xh']['isf_reason'] = '';
		$GLOBALS['_xh']['method'] = false;
		$GLOBALS['_xh']['rt'] = '';
		/// @todo 'guestimate' encoding
		$parser = xml_parser_create();
		xml_parser_set_option($parser, XML_OPTION_CASE_FOLDING, true);
		// What if internal encoding is not in one of the 3 allowed?
		// we use the broadest one, ie. utf8!
		if (!in_array($GLOBALS['xmlrpc_internalencoding'], array('UTF-8', 'ISO-8859-1', 'US-ASCII')))
		{
			xml_parser_set_option($parser, XML_OPTION_TARGET_ENCODING, 'UTF-8');
		}
		else
		{
			xml_parser_set_option($parser, XML_OPTION_TARGET_ENCODING, $GLOBALS['xmlrpc_internalencoding']);
		}
		xml_set_element_handler($parser, 'xmlrpc_se_any', 'xmlrpc_ee');
		xml_set_character_data_handler($parser, 'xmlrpc_cd');
		xml_set_default_handler($parser, 'xmlrpc_dh');
		if(!xml_parse($parser, $xml_val, 1))
		{
			$errstr = sprintf('XML error: %s at line %d, column %d',
						xml_error_string(xml_get_error_code($parser)),
						xml_get_current_line_number($parser), xml_get_current_column_number($parser));
			error_log($errstr);
			xml_parser_free($parser);
			return false;
		}
		xml_parser_free($parser);
		if ($GLOBALS['_xh']['isf'] > 1) // test that $GLOBALS['_xh']['value'] is an obj, too???
		{
			error_log($GLOBALS['_xh']['isf_reason']);
			return false;
		}
		switch ($GLOBALS['_xh']['rt'])
		{
			case 'methodresponse':
				$v =& $GLOBALS['_xh']['value'];
				if ($GLOBALS['_xh']['isf'] == 1)
				{
					$vc = $v->structmem('faultCode');
					$vs = $v->structmem('faultString');
					$r =& new xmlrpcresp(0, $vc->scalarval(), $vs->scalarval());
				}
				else
				{
					$r =& new xmlrpcresp($v);
				}
				return $r;
			case 'methodcall':
				$m =& new xmlrpcmsg($GLOBALS['_xh']['method']);
				for($i=0; $i < count($GLOBALS['_xh']['params']); $i++)
				{
					$m->addParam($GLOBALS['_xh']['params'][$i]);
				}
				return $m;
			case 'value':
				return $GLOBALS['_xh']['value'];
			default:
				return false;
		}
	}

	/**
	* decode a string that is encoded w/ "chunked" transfer encoding
	* as defined in rfc2068 par. 19.4.6
	* code shamelessly stolen from nusoap library by Dietrich Ayala
	*
	* @param string $buffer the string to be decoded
	* @return string
	*/
	function decode_chunked($buffer)
	{
		// length := 0
		$length = 0;
		$new = '';

		// read chunk-size, chunk-extension (if any) and crlf
		// get the position of the linebreak
		$chunkend = strpos($buffer,"\r\n") + 2;
		$temp = substr($buffer,0,$chunkend);
		$chunk_size = hexdec( trim($temp) );
		$chunkstart = $chunkend;
		while($chunk_size > 0)
		{
			$chunkend = strpos($buffer, "\r\n", $chunkstart + $chunk_size);

			// just in case we got a broken connection
			if($chunkend == false)
			{
				$chunk = substr($buffer,$chunkstart);
				// append chunk-data to entity-body
				$new .= $chunk;
				$length += strlen($chunk);
				break;
			}

			// read chunk-data and crlf
			$chunk = substr($buffer,$chunkstart,$chunkend-$chunkstart);
			// append chunk-data to entity-body
			$new .= $chunk;
			// length := length + chunk-size
			$length += strlen($chunk);
			// read chunk-size and crlf
			$chunkstart = $chunkend + 2;

			$chunkend = strpos($buffer,"\r\n",$chunkstart)+2;
			if($chunkend == false)
			{
				break; //just in case we got a broken connection
			}
			$temp = substr($buffer,$chunkstart,$chunkend-$chunkstart);
			$chunk_size = hexdec( trim($temp) );
			$chunkstart = $chunkend;
		}
		return $new;
	}

	/**
	* xml charset encoding guessing helper function.
	* Tries to determine the charset encoding of an XML chunk received over HTTP.
	* NB: according to the spec (RFC 3023), if text/xml content-type is received over HTTP without a content-type,
	* we SHOULD assume it is strictly US-ASCII. But we try to be more tolerant of unconforming (legacy?) clients/servers,
	* which will be most probably using UTF-8 anyway...
	*
	* @param string $httpheaders the http Content-type header
	* @param string $xmlchunk xml content buffer
	* @param string $encoding_prefs comma separated list of character encodings to be used as default (when mb extension is enabled)
	*
	* @todo explore usage of mb_http_input(): does it detect http headers + post data? if so, use it instead of hand-detection!!!
	*/
	function guess_encoding($httpheader='', $xmlchunk='', $encoding_prefs=null)
	{
		// discussion: see http://www.yale.edu/pclt/encoding/
		// 1 - test if encoding is specified in HTTP HEADERS

		//Details:
		// LWS:           (\13\10)?( |\t)+
		// token:         (any char but excluded stuff)+
		// quoted string: " (any char but double quotes and cointrol chars)* "
		// header:        Content-type = ...; charset=value(; ...)*
		//   where value is of type token, no LWS allowed between 'charset' and value
		// Note: we do not check for invalid chars in VALUE:
		//   this had better be done using pure ereg as below
		// Note 2: we might be removing whitespace/tabs that ought to be left in if
        //   the received charset is a quoted string. But nobody uses such charset names...

		/// @todo this test will pass if ANY header has charset specification, not only Content-Type. Fix it?
		$matches = array();
		if(preg_match('/;\s*charset\s*=([^;]+)/i', $httpheader, $matches))
		{
			return strtoupper(trim($matches[1], " \t\""));
		}

		// 2 - scan the first bytes of the data for a UTF-16 (or other) BOM pattern
		//     (source: http://www.w3.org/TR/2000/REC-xml-20001006)
		//     NOTE: actually, according to the spec, even if we find the BOM and determine
		//     an encoding, we should check if there is an encoding specified
		//     in the xml declaration, and verify if they match.
		/// @todo implement check as described above?
		/// @todo implement check for first bytes of string even without a BOM? (It sure looks harder than for cases WITH a BOM)
		if(preg_match('/^(\x00\x00\xFE\xFF|\xFF\xFE\x00\x00|\x00\x00\xFF\xFE|\xFE\xFF\x00\x00)/', $xmlchunk))
		{
			return 'UCS-4';
		}
		elseif(preg_match('/^(\xFE\xFF|\xFF\xFE)/', $xmlchunk))
		{
			return 'UTF-16';
		}
		elseif(preg_match('/^(\xEF\xBB\xBF)/', $xmlchunk))
		{
			return 'UTF-8';
		}

		// 3 - test if encoding is specified in the xml declaration
		// Details:
		// SPACE:         (#x20 | #x9 | #xD | #xA)+ === [ \x9\xD\xA]+
		// EQ:            SPACE?=SPACE? === [ \x9\xD\xA]*=[ \x9\xD\xA]*
		if (preg_match('/^<\?xml\s+version\s*=\s*'. "((?:\"[a-zA-Z0-9_.:-]+\")|(?:'[a-zA-Z0-9_.:-]+'))".
			'\s+encoding\s*=\s*' . "((?:\"[A-Za-z][A-Za-z0-9._-]*\")|(?:'[A-Za-z][A-Za-z0-9._-]*'))/",
			$xmlchunk, $matches))
		{
			return strtoupper(substr($matches[2], 1, -1));
		}

		// 4 - if mbstring is available, let it do the guesswork
		// NB: we favour finding an encoding that is compatible with what we can process
		if(extension_loaded('mbstring'))
		{
			if($encoding_prefs)
			{
				$enc = mb_detect_encoding($xmlchunk, $encoding_prefs);
			}
			else
			{
				$enc = mb_detect_encoding($xmlchunk);
			}
			// NB: mb_detect likes to call it ascii, xml parser likes to call it US_ASCII...
			// IANA also likes better US-ASCII, so go with it
			if($enc == 'ASCII')
			{
				$enc = 'US-'.$enc;
			}
			return $enc;
		}
		else
		{
			// no encoding specified: as per HTTP1.1 assume it is iso-8859-1?
			// Both RFC 2616 (HTTP 1.1) and 1945 (HTTP 1.0) clearly state that for text/xxx content types
			// this should be the standard. And we should be getting text/xml as request and response.
			// BUT we have to be backward compatible with the lib, which always used UTF-8 as default...
			return $GLOBALS['xmlrpc_defencoding'];
		}
	}

	/**
	* Checks if a given charset encoding is present in a list of encodings or
	* if it is a valid subset of any encoding in the list
	* @param string $encoding charset to be tested
	* @param mixed $validlist comma separated list of valid charsets (or array of charsets)
	*/
	function is_valid_charset($encoding, $validlist)
	{
		$charset_supersets = array(
			'US-ASCII' => array ('ISO-8859-1', 'ISO-8859-2', 'ISO-8859-3', 'ISO-8859-4',
				'ISO-8859-5', 'ISO-8859-6', 'ISO-8859-7', 'ISO-8859-8',
				'ISO-8859-9', 'ISO-8859-10', 'ISO-8859-11', 'ISO-8859-12',
				'ISO-8859-13', 'ISO-8859-14', 'ISO-8859-15', 'UTF-8',
				'EUC-JP', 'EUC-', 'EUC-KR', 'EUC-CN')
		);
		if (is_string($validlist))
			$validlist = explode(',', $validlist);
		if (@in_array(strtoupper($encoding), $validlist))
			return true;
		else
		{
			if (array_key_exists($encoding, $charset_supersets))
				foreach ($validlist as $allowed)
					if (in_array($allowed, $charset_supersets[$encoding]))
						return true;
				return false;
		}
	}

?>