<?php 

// Hit/Log tracker with Browser Lookup support.
// Browser Lookup by Geoffrey Sneddon, with some help from Clayton Smith.
// Rest of the script by Jordan S. C. Thompson (Hendee).
// Released under the zlib/libpng license. 

// December 15, 2005

// This file's code should either be placed in the file you want it displayed or include it.
// If you include be sure to specify where the log files are in $dir.

// EXAMPLE OUTPUT

// Browser: Internet Explorer
// Browser Version: 6.0
// Operating System: Windows 98
// Internet Service Provider: Juno

// Site Hits: 65,485,455 

$dir = "./";
$counterDB = "hits.dat";
$logDB = "log.dat";
$currentPage = "http://" . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'];

function browser($ua) 
{ 
    if (preg_match('/bot/i', $ua) || preg_match('/crawl/i', $ua) || preg_match('/yahoo\!/i', $ua)) 
    { 
        $return['name'] = 'Bot'; 
        $return['version'] = 'Unknown'; 
    } 
    elseif (preg_match('/opera/i', $ua)) 
    { 
        preg_match('/Opera(\/| )([0-9\.]+)(u)?(\d+)?/i', $ua, $b); 
        $return['name'] = 'Opera'; 
        unset($b[0], $b[1]); 
        $return['version'] = implode('', $b); 
    } 
    elseif (preg_match('/msie/i', $ua)) 
    { 
        preg_match('/MSIE ([0-9\.]+)(b)?/i', $ua, $b); 
        $return['name'] = 'Internet Explorer'; 
        unset($b[0]); 
        $return['version'] = implode('', $b); 
    } 
    elseif (preg_match('/omniweb/i', $ua)) 
    { 
        preg_match('/OmniWeb\/([0-9\.]+)/i', $ua, $b); 
        $return['name'] = 'OmniWeb'; 
        if (isset($b[1])) 
            $return['version'] = $b[1]; 
        else 
            $return['version'] = 'Unknown'; 
    } 
    elseif (preg_match('/icab/i', $ua)) 
    { 
        preg_match('/iCab\/([0-9\.]+)/i', $ua, $b); 
        $return['name'] = 'iCab'; 
        $return['version'] = $b[1]; 
    } 
    elseif (preg_match('/Chrome/i', $ua)) 
    { 
    	$return['name'] = 'Chrome'; 
    	preg_match('/Chrome\/([0-9\.]+)/i', $ua, $b); 
        $return['version'] = $b[1]; 
    } 
    elseif (preg_match('/safari/i', $ua)) 
    { 
        preg_match('/Safari\/([0-9\.]+)/i', $ua, $b); 
        $return['name'] = 'Safari'; 
        $return['version'] = $b[1]; 
        switch ($return['version']) 
        { 
            case '412': 
            case '412.2': 
            case '412.2.2': 
                $return['version'] = '2.0'; 
            break; 
            case '412.5': 
            $return['version'] = '2.0.1'; 
            break; 
            case '416.12': 
            case '416.13': 
                $return['version'] = '2.0.2'; 
            break; 
            case '100': 
                $return['version'] = '1.1'; 
            break; 
            case '100.1': 
                $return['version'] = '1.1.1'; 
            break; 
            case '125.7': 
            case '125.8': 
                $return['version'] = '1.2.2'; 
            break; 
            case '125.9': 
                $return['version'] = '1.2.3'; 
            break; 
            case '125.11': 
            case '125.12': 
                $return['version'] = '1.2.4'; 
            break; 
            case '312': 
                $return['version'] = '1.3'; 
            break; 
            case '312.3': 
            case '312.3.1': 
                $return['version'] = '1.3.1'; 
            break; 
            case '85.5': 
                $return['version'] = '1.0'; 
            break; 
            case '85.7': 
                $return['version'] = '1.0.2'; 
            break; 
            case '85.8': 
            case '85.8.1': 
                $return['version'] = '1.0.3'; 
            break; 
        } 
    } 
    elseif (preg_match('/konqueror/i', $ua)) 
    { 
        preg_match('/Konqueror\/([0-9\.]+)(\-rc)?(\d+)?/i', $ua, $b); 
        $return['name'] = 'Konqueror'; 
        unset($b[0]); 
        $return['version'] = implode('', $b); 
    } 
    elseif (preg_match('/Flock/i', $ua)) 
    { 
        preg_match('/Flock\/([0-9\.]+)(\+)?/i', $ua, $b); 
        $return['name'] = 'Flock'; 
        unset($b[0]); 
        $return['version'] = implode('', $b); 
    } 
    elseif (preg_match('/firebird/i', $ua)) 
    { 
        preg_match('/Firebird\/([0-9\.]+)(\+)?/i', $ua, $b); 
        $return['name'] = 'Firebird'; 
        unset($b[0]); 
        $return['version'] = implode('', $b); 
    } 
    elseif (preg_match('/phoenix/i', $ua)) 
    { 
        preg_match('/Phoenix\/([0-9\.]+)(\+)?/i', $ua, $b); 
        $return['name'] = 'Phoenix'; 
        unset($b[0]); 
        $return['version'] = implode('', $b); 
    } 
    elseif (preg_match('/firefox/i', $ua)) 
    { 
        preg_match('/Firefox\/([0-9\.]+)(\+)?/i', $ua, $b); 
        $return['name'] = 'Firefox'; 
        unset($b[0]); 
        $return['version'] = implode('', $b); 
    } 
    elseif (preg_match('/chimera/i', $ua)) 
    { 
        preg_match('/Chimera\/([0-9\.]+)(a|b)?(\d+)?(\+)?/i', $ua, $b); 
        $return['name'] = 'Chimera'; 
        unset($b[0]); 
        $return['version'] = implode('', $b); 
    } 
    elseif (preg_match('/camino/i', $ua)) 
    { 
        preg_match('/Camino\/([0-9\.]+)(a|b)?(\d+)?(\+)?/i', $ua, $b); 
        $return['name'] = 'Camino'; 
        unset($b[0]); 
        $return['version'] = implode('', $b); 
    } 
    elseif (preg_match('/seamonkey/i', $ua)) 
    { 
        preg_match('/SeaMonkey\/([0-9\.]+)(a|b)?/i', $ua, $b); 
        $return['name'] = 'SeaMonkey'; 
        unset($b[0]); 
        $return['version'] = implode('', $b); 
    } 
    elseif (preg_match('/galeon/i', $ua)) 
    { 
        preg_match('/Galeon\/([0-9\.]+)/i', $ua, $b); 
        $return['name'] = 'Galeon'; 
        $return['version'] = $b[1]; 
    } 
    elseif (preg_match('/epiphany/i', $ua)) 
    { 
        preg_match('/Epiphany\/([0-9\.]+)/i', $ua, $b); 
        $return['name'] = 'Epiphany'; 
        $return['version'] = $b[1]; 
    } 
    elseif (preg_match('/mozilla\/5/i', $ua) || preg_match('/gecko/i', $ua)) 
    { 
        preg_match('/rv(:| )([0-9\.]+)(a|b)?/i', $ua, $b); 
        $return['name'] = 'Mozilla'; 
        unset($b[0], $b[1]); 
        $return['version'] = implode('', $b); 
    } 
    elseif (preg_match('/mozilla\/4/i', $ua)) 
    { 
        preg_match('/Mozilla\/([0-9\.]+)/i', $ua, $b); 
        $return['name'] = 'Netscape'; 
        $return['version'] = $b[1]; 
    } 
    elseif (preg_match('/lynx/i', $ua)) 
    { 
        preg_match('/Lynx\/([0-9\.]+)/i', $ua, $b); 
        $return['name'] = 'Lynx'; 
        $return['version'] = $b[1]; 
    } 
    elseif (preg_match('/links/i', $ua)) 
    { 
        preg_match('/Links \(([0-9\.]+)(pre)?(\d+)?/i', $ua, $b); 
        $return['name'] = 'Links'; 
        unset($b[0]); 
        $return['version'] = implode('', $b); 
    } 
    elseif (preg_match('/curl/i', $ua)) 
    { 
        preg_match('/curl\/([0-9\.]+)/i', $ua, $b); 
        $return['name'] = 'cURL'; 
        $return['version'] = $b[1]; 
    } 
    elseif (preg_match('/wget/i', $ua)) 
    { 
        preg_match('/Wget\/([0-9\.]+)/i', $ua, $b); 
        $return['name'] = 'Wget'; 
        $return['version'] = $b[1]; 
    } 
    else 
    { 
        $return['name'] = 'Unknown'; 
        $return['version'] = 'Unknown'; 
    } 
    return $return; 
}
?>
