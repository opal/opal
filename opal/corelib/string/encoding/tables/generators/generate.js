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
	Unicode Mapping Table

	SJIS  <-> UNICODE
	JIS   <-> UNICODE
	EUCJP <-> UNICODE

------------------------------------------------------- */

'use strict';

var fs         = require( 'fs' ),
	async      = require( 'async' ),
	LineReader = require( __dirname + '/linereader' ).LineReader;

var files = {
	'SJIS': [
		'CP932.TXT',
	],
	'SJISInverted': [
		'CP932.TXT',
		'CP932-ADD.TXT',
		'CP932-NEC-OVERRIDE.TXT',
		'CP932-IBM-OVERRIDE.TXT',
	],
	'JIS': [
		'JIS0208-ADD.TXT',
		'JIS0208.TXT',
		'JIS0208-NEC.TXT',
	],
	'JISInverted': [
		'JIS0208.TXT',
		'JIS0208-ADD.TXT',
		'JIS0208-NEC.TXT',
		'JIS0208-IBM.TXT',
	],
	'JISEXT': [
		'JIS0212.TXT',
		'JIS0212-ADD.TXT'
	],
	'JISEXTInverted': [
		'JIS0212.TXT',
		'JIS0212-ADD.TXT'
	]
};

var outputPath = __dirname + '/../',
	sourcePath = __dirname + '/sources/';

var COMMENT = /^#/,
	FORMAT  = /^(U\+|0x|\d\-)([0-9A-Fa-f]+)/;

function generate( key ) {
	var sources       = files[ key ],
		table         = {},
		ws            = fs.createWriteStream( outputPath + key + '.js' );

	async.eachSeries( sources, function( source, next ) {
		var rs     = fs.createReadStream( sourcePath + source ),
			reader = new LineReader( rs );

		reader.on( 'line', function( line ) {
			if( ! line || COMMENT.test( line ) ) {
				return;
			}

			var data = line.split( '\t' );
			if( ! data ) {
				return;
			}

			var code;
			var nextCode;

			// JIS0208.TXT format
			if( /JIS0208\.TXT/i.test( source ) ) {
				code     = to16bitNumeric( data[ 1 ] );
				nextCode = to16bitNumeric( data[ 2 ] );
			}
			// NORMAL format
			else {
				code     = to16bitNumeric( data[ 0 ] );
				nextCode = to16bitNumeric( data[ 1 ] );
			}

			// ASCII & HALFWIDTH_KATAKANA Part
			if( code < 0x80 || 0xA0 <= code && code <= 0xDF ) {
				return;
			}

			if( /Inverted/.test( key ) ) {
				if( /OVERRIDE/.test( source ) ) {
					table[ nextCode ] = code;
				}
				else if( code !== null && table[ nextCode ] === undefined ) {
					table[ nextCode ] = code;
				}
			}
			else {
				if( /OVERRIDE/.test( source ) ) {
					table[ code ] = nextCode;
				}
				else if( nextCode !== null && table[ code ] === undefined ) {
					table[ code ] = nextCode;
				}
			}
		});

		reader.on( 'end', function() {
			next();
		});

	}, function( error ) {

		ws.write( toTableString( table ) );

		console.log( key + ' table created.' );
	});
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

function toTableString( obj ) {
	return 'module.exports=' + JSON.stringify( obj ).replace( /"/g, '' );
}

// Run
for( var key in files ) {
	generate( key );
}
