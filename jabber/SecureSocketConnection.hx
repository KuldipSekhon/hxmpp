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
package jabber;

#if (neko||php||cpp||rhino)

#if neko
import neko.net.Host;
import neko.tls.Socket;
#elseif php
import php.net.Host;
import php.net.Socket;
#elseif cpp
import cpp.net.Host;
import cpp.net.Socket;
#end

/**
	Legacy TLS socket connection (port 5223)
*/
class SecureSocketConnection extends jabber.stream.SocketConnection {
		
	public function new( host : String, port : Int = 5223, secure : Bool = true,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, secure, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		socket = #if php Socket.newSslSocket(); #else new Socket(); #end
		buf = haxe.io.Bytes.alloc( bufSize );
		bufbytes = 0;
		try socket.connect( new Host( host ), port ) catch( e : Dynamic ) {
			__onDisconnect( e );
			return;
		}
		secured = true;
		connected = true;
		__onConnect();
	}
	
	public override function write( t : String ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.write( t );
		socket.output.flush();
		return true;
	}
}

#elseif flash

#if air
import flash.net.SecureSocket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;
import flash.utils.ByteArray;

class SecureSocketConnection extends jabber.stream.SocketConnection {
	
	var buf : ByteArray;
	#if air
	//var socket : SecureSocket;
	#end
	
	public function new( host : String, port : Int = 5223,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, true, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		buf = new ByteArray();
		socket = new SecureSocket();
		socket.addEventListener( Event.CONNECT, sockConnectHandler );
		socket.addEventListener( Event.CLOSE, sockDisconnectHandler );
		socket.addEventListener( IOErrorEvent.IO_ERROR, sockErrorHandler );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockErrorHandler );
		socket.connect( host, port );
	}
	
	public override function disconnect() {
		if( !connected )
			return;
		connected = false;
		try socket.close() catch( e : Dynamic ) {
			__onDisconnect( e );
		}
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			socket.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
		} else {
			socket.removeEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
		}
		return true;
	}
	
	public override function write( t : String ) : Bool {
		socket.writeUTFBytes( t ); 
		socket.flush();
		return true;
	}
	
	function sockConnectHandler( e : Event ) {
		connected = true;
		__onConnect();
	}

	function sockDisconnectHandler( e : Event ) {
		connected = false;
		__onDisconnect(null);
	}
	
	function sockErrorHandler( e : Event ) {
		connected = false;
		__onDisconnect( e.type );
	}
	
	function sockDataHandler( e : ProgressEvent ) {
		try socket.readBytes( buf, buf.length, Std.int(e.bytesLoaded) ) catch( e : Dynamic ) {
			#if JABBER_DEBUG
		//	trace(e);
			#end
			return;
		}
		var b = haxe.io.Bytes.ofData( untyped buf );
		if( b.length > maxBufSize )
			throw new jabber.error.Error( "Max buffer size reached ["+maxBufSize+"]" );
		if( __onData(  b, 0, b.length ) > 0 )
			buf = new ByteArray();
		//socket.flush();
	}
}

#elseif TLS

import tls.event.SecureSocketEvent;
import tls.valueobject.SecurityOptionsVO;

class SecureSocketConnection extends jabber.SocketConnection {
	
	public function new( host : String, port : Int = 5223,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, true, bufSize, maxBufSize, timeout );
	}
	
	override function sockConnectHandler( e : SecureSocketEvent ) {
		socket.startSecureSupport( SecurityOptionsVO.getDefaultOptions( SecurityOptionsVO.SECURITY_TYPE_TLS ) );
	}
	
	override function secureChannelEstablished( e : SecureSocketEvent ) {
		trace(e);
		connected = true;
		__onConnect();
	}
}
#end //TLS

#elseif js

#if air
import air.ByteArray;
import air.SecureSocket;
import air.Event;
import air.IOErrorEvent;
import air.SecurityErrorEvent;
import air.ProgressEvent;

class SecureSocketConnection extends jabber.stream.SocketConnection {
	
	var buf : ByteArray;
	
	public function new( host : String, port : Int = 5223,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, true, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		buf = new ByteArray();
		socket = new SecureSocket();
		socket.addEventListener( Event.CONNECT, sockConnectHandler );
		socket.addEventListener( Event.CLOSE, sockDisconnectHandler );
		socket.addEventListener( IOErrorEvent.IO_ERROR, sockErrorHandler );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockErrorHandler );
		socket.connect( host, port );
	}
	
	public override function disconnect() {
		if( !connected )
			return;
		connected = false;
		try socket.close() catch( e : Dynamic ) {
			__onDisconnect( "Error closing socket" );
		}
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			socket.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
		} else {
			socket.removeEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
		}
		return true;
	}
	
	public override function write( t : String ) : Bool {
		socket.writeUTFBytes( t ); 
		socket.flush();
		return true;
	}
	
	function sockConnectHandler( e : Event ) {
		connected = true;
		__onConnect();
	}

	function sockDisconnectHandler( e : Event ) {
		connected = false;
		__onDisconnect(null);
	}
	
	function sockErrorHandler( e : Event ) {
		connected = false;
		__onDisconnect( e.type );
	}
	
	function sockDataHandler( e : ProgressEvent ) {
		try socket.readBytes( buf, buf.length, e.bytesLoaded ) catch( e : Dynamic ) {
			#if JABBER_DEBUG trace(e); #end
			return;
		}
		var b = haxe.io.Bytes.ofData( untyped buf );
		if( b.length > maxBufSize )
			throw new jabber.error.Error( "Max buffer size reached ["+maxBufSize+"]" );
		if( __onData(  b, 0, b.length ) > 0 )
			buf = new ByteArray();
		socket.flush();
	}
}


#elseif nodejs

import haxe.io.Bytes;
import js.Node;
/*
class SecureSocketConnection extends jabber.stream.SocketConnection {
	
	//public var socket(default,null) : CryptoStream;
	public var socket(default,null) : Stream;

	var buf : String;
	
	public function new( host : String, port : Int = 5222, secure : Bool = true,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, true, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		buf = "";
		createConnection();
		socket.on( Node.STREAM_END, sockDisconnectHandler );
		socket.on( Node.STREAM_ERROR, sockErrorHandler );
		socket.on( Node.STREAM_DATA, sockDataHandler );
	}
	
	public override function disconnect() {
		if( !connected )
			return;
		try socket.end() catch( e : Dynamic ) {
			__onDisconnect( e );
		}
	}
	
	public override function setSecure() {
		//TODO
		trace("SET SECURE_________________________________");
		// hmm? TypeError: Object #<a Stream> has no method 'setSecure' ??????????
		//socket.on( Node.STREAM_SECURE, sockSecureHandler );
		//trace( socket.getPeerCertificate() );
//		socket.setSecure(  );
		__onSecured(null);
	}
	
	public override function write( t : String ) : Bool {
		trace("write");
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.write( t );
		return true;
	}
	
	public override function writeBytes( t : Bytes ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.write( t.getData() ); 
		return true;
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		trace("read "+yes);
		if( !yes )
			socket.removeListener( Node.STREAM_DATA, sockDataHandler );
		return true;
	}
	
	function createConnection() {
		socket = Node.net.createConnection( port, host );
		//socket = Node.tls.connect( port, host, null, sockConnectHandler );
		socket.on( Node.STREAM_CONNECT, sockConnectHandler );
	}
	
	function sockConnectHandler() {
		trace("sockConnectHandler");
		connected = true;
		__onConnect();
	}
	
	function sockDisconnectHandler() {
		trace("sockDisconnectHandler");
		connected = false;
		__onDisconnect(null);
	}
	
	function sockErrorHandler( e : String ) {
		trace("sockErrorHandler");
		connected = false;
		__onDisconnect( e );
	}
	
	function sockSecureHandler() {
		secured = true;
		__onSecured( null );
	}
	
	//TODO use bytes (no compression + stuff otherwise)
	function sockDataHandler( t : String ) {
		trace("sockDataHandler");
		var s = buf+t;
		if( s.length > maxBufSize )
			throw new jabber.error.Error( "max socket buffer size reached ["+maxBufSize+"]" );
		var r = __onData( Bytes.ofString( s ), 0, s.length );
		buf = ( r == 0 ) ? s : "";
	}
	
}
*/

class SecureSocketConnection extends jabber.SocketConnection {
	
	public function new( host : String, port : Int = 5223,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, true, bufSize, maxBufSize, timeout );
	}
	
	override function createConnection() {
		socket = Node.tls.connect( port, host, null, sockConnectHandler );
	}
}

#end //js
#end //platform
