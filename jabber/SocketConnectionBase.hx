/*
 * Copyright (c) disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber;

import haxe.io.Bytes;

#if sys
import sys.net.Host;
import sys.net.Socket;
#end

#if rhino
import js.net.Host;
import js.net.Socket;
#elseif nodejs
import js.Node;
typedef Socket = Stream;
#elseif flash
import flash.net.Socket;
#end


#if sys
private typedef AbstractSocket = {
	var input(default,null) : haxe.io.Input;
	var output(default,null) : haxe.io.Output;
	function connect( host : Host, port : Int ) : Void;
	function setTimeout( t : Float ) : Void;
	function write( str : String ) : Void;
	function close() : Void;
	function shutdown( read : Bool, write : Bool ) : Void;
	//function setBlocking( b : Bool ) : Void;
}
#end


#if droid error // deprecated
#else

/**
	Abstract base class for socket connection implementations
*/
class SocketConnectionBase extends StreamConnection {
	
	public static var defaultBufSize = #if php 65536 #else 256 #end; //TODO php buf
	public static var defaultMaxBufSize = 1<<20; // 1MB
	public static var defaultTimeout = 10; // secs
	
	public var port(default,null) : Int;
	public var maxbufsize(default,null) : Int;
	public var timeout(default,null) : Int;
	//public var timeout(default,setTimeout) : Int;
	
	#if (sys||rhino)
	public var socket(default,null) : AbstractSocket;
	public var reading(default,null) : Bool;
	#elseif nodejs
//	public var socket(default,null) : Socket;
	#elseif (js&&air)
	public var socket(default,null) : air.Socket;
	#elseif (js&&jabber_flashsocketbridge)
	public var socket(default,null) : Socket;
	#elseif (flash&&air)
	//#
	#elseif flash
	public var socket(default,null) : Socket;
	#end
	
	var buf : Bytes;
	var bufpos : Int;
	var bufsize : Int;
	
	function new( host : String, port : Int, secure : Bool,
				  bufsize : Int = -1, maxbufsize : Int = -1,
				  timeout : Int = -1 ) {

		super( host, secure, false );
		this.port = port;
		this.bufsize = ( bufsize == -1 ) ? defaultBufSize : bufsize;
		this.maxbufsize = ( maxbufsize == -1 ) ? defaultMaxBufSize : maxbufsize;
		this.timeout = ( timeout == -1 ) ? defaultTimeout : timeout;
		#if (neko||cpp||php||rhino)
		this.reading = false;
		#end
	}
	
	/*
	function setTimeout( t : Int ) : Int {
		if( socket != null )
			throw 'cannot change timeout on active connection';
		return timeout = t;
	}
	*/
	
	#if (sys||rhino)
	
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
	
	/*
	public override function reset() {
		buf = Bytes.alloc( bufSize );
	}
	*/
	
	function readData() {
		
		var len : Int;
		try {
			len = try socket.input.readBytes( buf, bufpos, bufsize );
		} catch( e : Dynamic ) {
			error( "socket read failed" );
			return;
		}
		
		bufpos += len;
		if( len < bufsize ) {
			__onData( buf.sub( 0, bufpos ) );
			bufpos = 0;
			buf = Bytes.alloc( bufsize = defaultBufSize );
		} else {
			var nsize = buf.length + bufsize;
			if( nsize > maxbufsize ) {
				error( 'max buffer size site reached ($maxbufsize)' );
				return;
			}
			var nbuf = Bytes.alloc( nsize );
			nbuf.blit( 0, buf, 0, buf.length );
			buf = nbuf;
		}
		
		/*
		var len = 0;
		try len = socket.input.readBytes( buf, 0, bufsize ) catch( e : Dynamic ) {
			reading = connected = false;
			__onDisconnect( e );
			return;
		}
		__onData( buf.sub( 0, len ) );
		buf = Bytes.alloc( bufsize );
		*/
		
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
	
	function error( info : String ) {
		reading = connected = false;
		try socket.close() catch(e:Dynamic) { #if jabber_debug trace(e,"error"); #end }
		__onDisconnect( info );
	}

	#end
}

#end


#if jabber_flashsocketbridge

class Socket {
	
	public dynamic function onConnect() {}
	public dynamic function onDisconnect( ?e : String ) {}
	public dynamic function onData( d : String ) {}
	public dynamic function onSecured() {}
	//public dynamic function onError( e : String ) {} //TODO
	
	public var id(default,null) : Int;
	
	public function new( secure : Bool, timeout : Int = 10 ) {
		id = jabber.SocketConnection.createSocket( this, secure, timeout );
		if( id < 0 )
			throw "failed to create socket on flash bridge";
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

#end // jabber_flashsocketbridge
