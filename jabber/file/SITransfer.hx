/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package jabber.file;

import haxe.io.Bytes;
import jabber.util.Base64;
import xmpp.IQ;
import xmpp.IQType;
#if neko
import neko.FileSystem;
import neko.io.File;
import neko.io.Path;
#elseif cpp
import cpp.FileSystem;
import cpp.io.File;
import cpp.io.Path;
#elseif php
import php.FileSystem;
import php.io.File;
import php.io.Path;
#elseif nodejs
import js.Node;
import js.FileSystem;
import js.io.File;
import js.io.Path;
#elseif (air&&flash)
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;
#elseif (air&&js)
import air.File;
import air.FileMode;
import air.FileStream;
import air.ByteArray;
#end

/**
	<a href="http://xmpp.org/extensions/xep-0096.html">XEP-0096: SI File Transfer</a><br/>
	Outgoing file transfer negotiator.
*/
class SITransfer {
	
	public dynamic function onProgress( bytes : Int ) : Void;
	public dynamic function onComplete() : Void;
	//public dynamic function onFail( info : String ) : Void;
	public dynamic function onFail( error : String, ?info : String ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	public var reciever(default,null) : String;
	public var methods(default,null) : Array<FileTransfer>;
	public var filepath(default,null) : String;
	public var filesize(default,null) : Int;
	
	var input : haxe.io.Input;
	var id : String;
	var methodIndex : Int;
	
	public function new( stream : jabber.Stream, reciever : String ) {
		this.stream = stream;
		this.reciever = reciever;
		methods = new Array();
	}
	
	// TODO description, hash, date, (range)
	
	public function sendData( bytes : Bytes, name : String ) {
		this.input = new haxe.io.BytesInput( bytes );
		this.filesize = bytes.length;
		sendRequest( name, bytes.length );
	}
	
	#if (neko||cpp||php||air||nodejs)
	
	public function sendFile( filepath : String ) {
		
		#if air
		var file = File.applicationDirectory.resolvePath( filepath ); //TODO 
		if( !file.exists )
			throw "File not found ["+filepath+"]";
		this.filepath = filepath;
		filesize = file.size;
		var fname = file.name;
		var fs = new FileStream();
		fs.open( file, FileMode.READ );
		var ba = new ByteArray();
		fs.readBytes( ba ); 
		this.input = new haxe.io.BytesInput( Bytes.ofData( ba ) );
		
		#else
		if( !FileSystem.exists( filepath ) )
			throw "File not found ["+filepath+"]";
		this.filepath = filepath;
		this.input = File.read( filepath, true );
		var fstat = FileSystem.stat( filepath );
		filesize = Std.int( fstat.size );
		var fname = Path.withoutDirectory( filepath );
		
		#end
		
		sendRequest( fname, filesize );
	}
	
	#end
	
	function sendRequest( name : String, size : Int ) {
		if( methods.length == 0 )
			throw "No file transfer methods registered";
		id = Base64.random( 16 );
		var iq = new IQ( IQType.set );
		iq.to = reciever;
		var si = new xmpp.file.SI( id, "text/plain", xmpp.file.SI.XMLNS_PROFILE ); //TODO mime-type
		var file = new xmpp.file.File( name, size );
		
		si.any.push( file.toXml() );
		var form = new xmpp.DataForm( xmpp.dataform.FormType.form );
		var form_f = new xmpp.dataform.Field( xmpp.dataform.FieldType.list_single );
		form_f.variable = "stream-method";
		for( m in methods )
			form_f.options.push( new xmpp.dataform.FieldOption( null, m.xmlns ) ); //TODO
		form.fields.push( form_f );
		var feature = Xml.createElement( "feature" );
		feature.set( "xmlns", xmpp.FeatureNegotiation.XMLNS );
		feature.addChild( form.toXml() );
		si.any.push( feature );
		iq.x = si;
		stream.sendIQ( iq, handleRequestResponse );
	}
	
	function handleRequestResponse( iq : IQ ) {
		switch( iq.type ) {
		case result :
			var si = xmpp.file.SI.parse( iq.x.toXml() );
			var _methods = new Array<String>();
			for( e in si.any ) {
				#if flash
				if( e.nodeName == "feature" && e.get( "_xmlns_" ) == xmpp.FeatureNegotiation.XMLNS ) {
				#else
				if( e.nodeName == "feature" && e.get( "xmlns" ) == xmpp.FeatureNegotiation.XMLNS ) {
				#end
					for( e in e.elementsNamed( "x" ) ) {
						var form = xmpp.DataForm.parse( e );
						switch( form.type ) {
						case submit :
							var field = form.fields[0];
							if( field.variable == "stream-method" ) {
								for( v in field.values ) {
									_methods.push( v );
								}
							}
						default :
						}
					}
				}
			}
			var acceptedMethods = new Array<FileTransfer>();
			for( m in methods ) {
				for( _m in _methods ) {
					if( _m == m.xmlns ) {
						acceptedMethods.push( m );
						continue;
					}
				}
			}
			if( acceptedMethods.length == 0 ) {
				onFail( "reciever accpeted none of the offered filetransfer methods" );
				return;
			}
			this.methods = acceptedMethods;
			methodIndex = 0;
			initFileTransfer();
			
		case error :
			//TODO hm?
			var e = iq.errors[0];
			onFail( e.condition, e.text );
			
		default : //
		}
	}
	
	function initFileTransfer() {
		var ft = methods[methodIndex];
		ft.onProgress = handleFileTransferProgress;
		ft.onComplete = handleFileTransferComplete;
		ft.onFail = handleFileTransferFail;
		ft.init( input, id, filesize );
	}
	
	function handleFileTransferProgress( bytes : Int ) {
		if( onProgress != null ) onProgress( bytes );
	}
	
	function handleFileTransferComplete() {
		onComplete();
	}
	
	function handleFileTransferFail( info ) {
		onFail( info );
	}
	
}
