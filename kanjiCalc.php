#!/usr/bin/php -q
<?php
/**
 * KanjiCalc
 * @author    Daniele <danielep@asia-gazette.com>
 *
 * This program scans all Asahi Newspaper's articles and
 * looks for the most used kanji (Chinese characters) ranking
 * them by popularity. Useful for people studying Japanese! :D
 */

passthru('clear');
//setlocale(LC_ALL, "ja_JP.utf8");

$kanji = array();
$pattern = "/\P{Han}/u";

$urls = array("http://www.asahi.com/", );
							

$encodings = array("Shift-JIS", "EUC-JP", "JIS", "SJIS", "JIS-ms", "eucJP-win", "SJIS-win", "ISO-2022-JP", "ISO-2022-JP-MS", "SJIS-mac", "SJIS-Mobile#DOCOMO", "SJIS-Mobile#KDDI", "SJIS-Mobile#SOFTBANK", "UTF-8-Mobile#DOCOMO", "UTF-8-Mobile#KDDI-A", "UTF-8-Mobile#KDDI-B", "UTF-8-Mobile#SOFTBANK", "ISO-2022-JP-MOBILE#KDDI");

foreach ( $urls as $url ){
	$string = file_get_contents( $url );

	// Get the website's encoding and convert to UTF-8
	foreach ( $encodings as $e ){
		$pos = strpos( "charset=" . $string, $e );
		if ( $pos == true ){
			echo "Encoding for $url is " . $e . ".\n";
			$encoding = $e;
		}
	}
	$string =  mb_convert_encoding( $string, "UTF-8", $encoding );
	$string = preg_replace( $pattern, " ", $string );
	$kanji[] = array_filter( explode(" ", $string) );
}

//Flatten the multidimensional $kanji array
$flat = array();
$RII = new RecursiveIteratorIterator( new RecursiveArrayIterator($kanji) );
foreach ( $RII as $val ) $flat[] = $val;

$kanji = $flat;
unset( $flat );
$countedArray = array_count_values( $kanji );
arsort( $countedArray );
foreach ( $countedArray as $k => $count ){
	echo "$count) $k\n";
}

?>
