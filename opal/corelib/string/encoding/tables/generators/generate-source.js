/*! ------------------------------------------------------

	Jconv

	Copyright (c) 2013-2014 narirou
	MIT Licensed


  https://github.com/janbiedermann/jconv/blob/for_opal/generators/generate.js

  node generators/generate-source
  node generators/generate

------------------------------------------------------- */
/* -------------------------------------------------------

	Generate
	Windows Dependent Characters vs
	Unicode Mapping Table Source

------------------------------------------------------- */

'use strict';

var fs         = require( 'fs' ),
	LineReader = require( __dirname + '/linereader' ).LineReader;

var sourcePath = __dirname + '/sources/';

var nrtFile  = fs.readFileSync( sourcePath + 'NON-ROUND-TRIP.TXT' ),
	nrtLines = nrtFile.toString().split( '\n' );

var cp932File  = fs.readFileSync( sourcePath + 'CP932.TXT' ),
	cp932Lines = cp932File.toString().split( '\n' );

var COMMENT = /^#/,
	FORMAT  = /^(U\+|0x|0X|\d\-)([0-9A-Fa-f]+)/;


function JIS0208_NEC() {
	var outputString = '';

	cp932Lines.forEach( function( line ) {
		if( ! line || COMMENT.test( line ) ) {
			return;
		}

		var data = line.split( '\t' );
		if( ! data ) {
			return;
		}

		var code    = to16bitNumeric( data[0] );
		var unicode = to16bitNumeric( data[1] );
		var comment = data[2].toUpperCase() + '\n';

		if( 0x8740 <= code && code <= 0x879C ||
			0xED40 <= code && code <= 0xEEFC ) {

			code = SJIStoJIS( code );
			outputString += [ to16bitString( code ), to16bitString( unicode ), comment ].join( '\t' );
		}
	});

	fs.writeFileSync( sourcePath + 'JIS0208-NEC.TXT', outputString );

	console.log( 'JIS0208-NEC source created.' );
}

function JIS0208_IBM() {
	var outputString = '';

	nrtLines.forEach( function( line ) {
		if( ! line || COMMENT.test( line ) ) {
			return;
		}

		var data = line.split( '\t' );
		if( ! data ) {
			return;
		}

		var code    = to16bitNumeric( data[0] );
		var unicode = to16bitNumeric( data[1] );
		var comment = data[3].toUpperCase() + '\n';

		if( 0xED40 <= code && code <= 0xEEFC ) {
			code = SJIStoJIS( code );
			outputString += [ to16bitString( code ), to16bitString( unicode ), comment ].join( '\t' );
		}
	});

	fs.writeFileSync( sourcePath + 'JIS0208-IBM.TXT', outputString );

	console.log( 'JIS0208-IBM source created.' );
}

function CP932_IBM() {
	var outputString = '';

	nrtLines.forEach( function( line ) {
		if( ! line || COMMENT.test( line ) ) {
			return;
		}

		var data = line.split( '\t' );
		if( ! data ) {
			return;
		}

		var code    = to16bitNumeric( data[2] );
		var unicode = to16bitNumeric( data[1] );
		var comment = data[3].toUpperCase() + '\n';

		if( 0xFA40 <= code && code <= 0xFC4B ) {
			outputString += [ to16bitString( code ), to16bitString( unicode ), comment ].join( '\t' );
		}
	});

	fs.writeFileSync( sourcePath + 'CP932-IBM-OVERRIDE.TXT', outputString );

	console.log( 'CP932-IBM-OVERRIDE source created.' );
}

function CP932_NEC() {
	var outputString = '';

	nrtLines.forEach( function( line ) {
		if( ! line || COMMENT.test( line ) ) {
			return;
		}

		var data = line.split( '\t' );
		if( ! data ) {
			return;
		}

		var code    = to16bitNumeric( data[2] );
		var unicode = to16bitNumeric( data[1] );
		var comment = data[3].toUpperCase() + '\n';

		if( 0x8740 <= code && code <= 0x879C ) {
			outputString += [ to16bitString( code ), to16bitString( unicode ), comment ].join( '\t' );
		}
	});

	fs.writeFileSync( sourcePath + 'CP932-NEC-OVERRIDE.TXT', outputString );

	console.log( 'CP932-NEC-OVERRIDE source created.' );
}


function to16bitString( num ) {
	if( typeof num !== 'number' ) {
		return;
	}
	if( num === null ) {
		return '';
	}
	else {
		return '0x' + num.toString( 16 ).toUpperCase();
	}
}

function to16bitNumeric( str ) {
	var formated = FORMAT.exec( str );
	if( formated ) {
		return parseInt( '0x' + formated[2], 16 );
	}
	else {
		return null;
	}
}

// SJIS CharCode To JIS CharCode
function SJIStoJIS( sjis ) {
	var b1 = sjis >> 8;
	var b2 = sjis & 0xFF;

	if( 0xA1 <= b1 && b1 <= 0xDF ) {
		return b1 - 0x80;
	}
	else if( b1 >= 0x80 ) {
		b1 <<= 1;

		if( b2 < 0x9F ) {
			if( b1 < 0x13F ) {
				b1 -= 0xE1;
			}
			else {
				b1 -= 0x61;
			}
			if( b2 > 0x7E ) {
				b2 -= 0x20;
			}
			else {
				b2 -= 0x1F;
			}
		}
		else {
			if( b1 < 0x13F ) {
				b1 -= 0xE0;
			}
			else {
				b1 -= 0x60;
			}
			b2 -= 0x7E;
		}
		return ( (b1 & 0xFF) << 8 ) + b2;
	}
	else {
		return b1;
	}
}

// Run
JIS0208_NEC();
JIS0208_IBM();
CP932_NEC();
CP932_IBM();
