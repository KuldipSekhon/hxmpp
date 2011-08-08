/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009-2010 http://www.disktree.net
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
package jabber.stream;

import haxe.io.Bytes;

#if neko
import neko.net.Host;
import neko.net.Socket;
#elseif php
import php.net.Host;
import php.net.Socket;
#elseif cpp
import cpp.net.Host;
import cpp.net.Socket;
#elseif rhino
import js.net.Host;
import js.net.Socket;
#elseif nodejs
import js.Node;
typedef Socket = Stream;
#elseif flash
#if TLS
import tls.controller.SecureSocket;
#else
import flash.net.Socket;
#end
#end

#if droid

import droid.net.Socket;

class SocketConnection extends jabber.stream.Connection {
	
	public var port(default,null) : Int;
	
	var s : Socket;
	
	public function new( host : String, port : Int = 5222, secure : Bool ) {
		super( host, secure );
		this.port = port;
	}
	
	public override function connect() {
		s = new Socket( secure );
		s.onopen = onConnect;
		s.onclose = onClose;
		s.onerror = onError;
		s.onmessage = onData;
		s.connect( host, port );
	}
	
	public override function disconnect() {
		s.close();
	}
	
	public override function write( t : String ) : Bool {
		s.send( t );
		return true;
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		//s.onmessage = yes ? onData : null;
		//s.read();
		return true;
	}
	
	function onConnect() {
		//trace("onConnect!");
		connected = true;
		__onConnect();
	}
	
	function onClose() {
		//trace("onClose!");
		connected = false;
		__onDisconnect(null);
	}
	
	function onError() {
		//trace("onError!");
		connected = false;
		__onDisconnect( "socket error" ); // no error message?
	}
	
	function onData( m : String ) {
		__onString( m );
		//__onData( haxe.io.Bytes.ofString( m ), 0, m.length );
	}
}

#else

#if (neko||php||cpp)
private typedef AbstractSocket = {
	var input(default,null) : haxe.io.Input;
	var output(default,null) : haxe.io.Output;
	function connect( host : Host, port : Int ) : Void;
	function setTimeout( t : Float ) : Void;
	function write( str : String ) : Void;
	function close() : Void;
	function shutdown( read : Bool, write : Bool ) : Void;
}
#end

class SocketConnection extends Connection {
	
	public static var defaultBufSize = #if php 65536 #else 256 #end; //TODO php buf
	public static var defaultMaxBufSize = 262144; //TODO !
	
	public var port(default,null) : Int;
	public var bufSize(default,null) : Int;
	public var maxBufSize(default,null) : Int;
	public var timeout(default,null) : Int;
	//public var timeout(default,setTimeout) : Int;
	
	#if (neko||php||cpp||rhino)
	public var socket(default,null) : AbstractSocket;
	public var reading(default,null) : Bool;
	var buf : Bytes;
	var bufbytes : Int;
	
	#elseif nodejs
//	public var socket(default,null) : Socket;
	
	#elseif (air&&js)
	public var socket(default,null) : air.Socket;
	
	#elseif flash
	#if TLS
	public var socket(default,null) : SecureSocket;
	#else
	public var socket(default,null) : Socket;
	#end
	
	#elseif (js&&JABBER_SOCKETBRIDGE)
	public var socket(default,null) : Socket;
	
	#end
	
	function new( host : String, port : Int,
				  secure : Bool,
				  ?bufSize : Int, ?maxBufSize : Int,
				  ?timeout : Int ) {
		super( host, secure, false );
		this.port = port;
		this.bufSize = ( bufSize == null ) ? defaultBufSize : bufSize;
		this.maxBufSize = ( maxBufSize == null ) ? defaultMaxBufSize : maxBufSize;
		this.timeout = timeout;
		#if (neko||cpp||php||rhino)
		reading = false;
		#end
	}
	
	/*
	function setTimeout( t : Int ) : Int {
		if( socket != null )
			throw 'cannot change timeout on active connection';
		return timeout = t;
	}
	*/
	
	#if (neko||cpp||php||rhino)
	
	public override function disconnect() {
		if( !connected )
			return;
		reading = connected = false;
		try socket.close() catch( e : Dynamic ) {
			__onDisconnect( e );
			return;
		}
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			reading = true;
			while( reading  && connected ) {
				readData();
			}
		} else {
			reading = false;
		}
		return true;
	}
	
	public override function reset() {
		buf = Bytes.alloc( bufSize );
	}
	
	function readData() {
		
		//TODO still double the buffer size if packet was not handled
		// ...
		
		var len = 0;
		//try len = socket.input.readBytes( buf, bufbytes, buflen-bufbytes ) catch( e : Dynamic ) {
		try len = socket.input.readBytes( buf, 0, bufSize ) catch( e : Dynamic ) {
			reading = connected = false;
			__onDisconnect( e );
			return;
		}
		__onData( buf.sub( 0, len ) );
		buf = Bytes.alloc( bufSize );
		//trace(len);
		
		/*
		var buflen = buf.length;
		if( bufbytes == buflen ) {
			var nsize = buflen*2;
			if( nsize > maxBufSize ) {
				nsize = maxBufSize;
				trace(buflen +":"+ maxBufSize);
				if( buflen == maxBufSize  )
					throw "max buffer size reached ["+maxBufSize+"]";
			}
			var buf2 = Bytes.alloc( nsize );
			buf2.blit( 0, buf, 0, buflen );
			buflen = nsize;
			buf = buf2;
		}
		var nbytes = 0;
		try nbytes = socket.input.readBytes( buf, bufbytes, buflen-bufbytes ) catch( e : Dynamic ) {
			reading = connected = false;
			__onDisconnect( e );
			return;
		}
		bufbytes += nbytes;
		var pos = 0;
		//TODO move buffering into jabber.Stream class
		while( bufbytes > 0 ) {
			var nbytes = __onData( buf, pos, bufbytes );
			if( nbytes == 0 ) {
				return;
			}
			pos += nbytes;
			bufbytes -= nbytes;
		}
		if( reading && pos > 0 )
			buf = Bytes.alloc( bufSize );
		//buf.blit( 0, buf, pos, bufbytes );
		*/
	}
	
	#end
	
}

#end


////////////////////////////////////////////////////////


#if JABBER_SOCKETBRIDGE

class Socket {
	
	public dynamic function onConnect() {}
	public dynamic function onDisconnect() {}
	public dynamic function onData( d : String ) {}
	public dynamic function onSecured() {}
	public dynamic function onError( e : String ) {}
	
	public var id(default,null) : Int;
	
	public function new( secure : Bool ) {
		id = jabber.SocketConnection.createSocket( this, secure );
		if( id < 0 )
			throw "failed to create socket on socket bridge";
	}
	
	public inline function connect( host : String, port : Int, ?timeout : Int ) {
		jabber.SocketConnection.swf.connect( id, host, port, timeout );
	}
	
	public inline function close() {
		jabber.SocketConnection.swf.disconnect( id );
	}
	
	public inline function send( t : String ) {
		jabber.SocketConnection.swf.send( id, t );
	}
	
	public inline function setSecure() {
		jabber.SocketConnection.swf.setSecure( id );
	}
}

#end
