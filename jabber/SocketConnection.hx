package jabber;

#if flash9
import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;
#elseif neko
import neko.net.Host;
import neko.net.Socket;
#elseif php
import php.net.Host;
import net.php.Socket;
#end

/**
*/
class SocketConnection extends jabber.stream.Connection {
	
	public static var MAX_BUFSIZE = (1<<22); // 4194304
	#if (neko||php)
	public static var DEFAULT_BUFSIZE = (1<<6); // 64
	#end
	
	public var socket(default,null) : Socket;
	public var secure(default,null) : Bool;
	public var timeout(default,null) : Int;
	
	#if (neko||php)
	var reading : Bool;
	var buffer : haxe.io.Bytes;
	var bufbytes : Int;
	#elseif (flash||JABBER_SOCKETBRIDGE)
	var buffer : String;
	#end
	
	public function new( host : String, port : Int,
						 ?secure : Bool = false , ?timeout : Int = 10 ) {
		
		super( host, port );
		#if (flash10||neko||php)
		this.timeout = timeout;
		#end
		this.secure = secure;
		
		socket = new Socket();
		
		#if flash9
		buffer = "";
		socket.addEventListener( Event.CONNECT, sockConnectHandler );
		socket.addEventListener( Event.CLOSE, sockDisconnectHandler );
		socket.addEventListener( IOErrorEvent.IO_ERROR, sockErrorHandler );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockErrorHandler );
	
		#elseif (neko||php)
		buffer = haxe.io.Bytes.alloc( DEFAULT_BUFSIZE );
		bufbytes = 0;
		reading = false;
		
		#if php //TODO WTF
		buffer = haxe.io.Bytes.alloc( (1<<16) );
		#end
		
		#elseif JABBER_SOCKETBRIDGE
		buffer = "";
		socket.onConnect = sockConnectHandler;
		socket.onDisconnect = sockDisconnectHandler;
		socket.onError = sockErrorHandler;
		#end
	}
	
	/*
	function setTimeout( t : Int ) : Int {
		return timeout = ( t <= 0 ) ? 1 : t;
	}
	*/
	
	
	public override function connect() {
		
		try {
			#if neko
			socket.connect( new Host( host ), port );
			#end
			#if php
			if( secure )
				socket.connectTLS( new Host( host ), port );
			else
				socket.connect( new Host( host ), port );
			#end
		} catch( e : Dynamic ) {
			trace( "Unable to connect socket on "+host+","+port, XMPPDebug.ERROR );
			return;
			//throw e;
		}
		
		#if (neko||php)
		connected = true;
		onConnect();
		#else
		#if flash10 socket.timeout = timeout*1000; #end
		socket.connect( host, port );
		#end
	}
	
	public override function disconnect() {
		if( !connected ) return;
		#if (neko||php) reading = false; #end
		connected = #if (neko||php) reading = #end false;
		socket.close();
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			#if flash9
			socket.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
			#elseif (neko||php)
			reading = true;
			while( reading  && connected ) {
				readData();
				processData();
			}
			#elseif JABBER_SOCKETBRIDGE
			socket.onData = sockDataHandler;
			#end
		} else {
			#if flash9
			socket.removeEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
			#elseif (neko||php)
			reading = false;
			#elseif JABBER_SOCKETBRIDGE
			socket.onData = null;
			#end
		}
		return true;
	}
	
	public override function write( t : String ) : String {
		if( !connected || t == null || t.length == 0 ) return null;
		//TODO
//		for( i in interceptors )
//			t = i.interceptData( t );
		#if flash9
		socket.writeUTFBytes( t ); 
		socket.flush();
		#elseif (neko||php)
		socket.write( t );
		#elseif JABBER_SOCKETBRIDGE
		socket.send( t );
		#end
		return t;
	}
	
	/*
	public override function writeBytes( t : haxe.io.Bytes ) : haxe.io.Bytes {
		if( !connected || t == null ) return null;
		#if (neko||php)
		for( i in interceptors )
			t = i.interceptData( t );
		socket.output.write( t );
		#end
		return t;
	}
	public function clearBuffer() {
		#if (neko||php)
		buffer = haxe.io.Bytes.alloc( DEFAULT_BUFSIZE );
		bufbytes = 0;
		#end
	}
	*/


	#if (flash9)

	function sockConnectHandler( e : Event ) {
		connected = true;
		onConnect();
	}

	function sockDisconnectHandler( e : Event ) {
		connected = false;
		onDisconnect();
	}
	
	function sockErrorHandler( e ) {
		connected = false;
		onError( e );
	}
	
	function sockDataHandler( e : ProgressEvent ) {
		var i = buffer + socket.readUTFBytes( e.bytesLoaded );
		if( i.length > MAX_BUFSIZE ) {
			#if JABBER_DEBUG trace( "Max buffer size reached ("+MAX_BUFSIZE+")" ); #end
			throw "Max buffer size reached ("+MAX_BUFSIZE+")";
		}
		buffer = ( onData( haxe.io.Bytes.ofString( i ), 0, i.length ) == 0 ) ? i : "";
	}
	
	#elseif (neko||php)
	
	function readData() {
		var buflen = buffer.length;
		// eventually double the buffer size
		if( bufbytes == buflen ) {
			var nsize = buflen*2;
			if( nsize > MAX_BUFSIZE ) {
				if( buflen == MAX_BUFSIZE )
					throw "Max buffer size reached ("+MAX_BUFSIZE+")";
				//trace( "Max buffer size reached ("+MAX_BUFSIZE+")" );
				nsize = MAX_BUFSIZE;
			}
			var buf2 = haxe.io.Bytes.alloc( nsize );
			buf2.blit( 0, buffer, 0, buflen );
			buflen = nsize;
			buffer = buf2;
		}
		var nbytes = socket.input.readBytes( buffer, bufbytes, buflen-bufbytes );
		bufbytes += nbytes;
	}
	
	function processData() {
		var pos = 0;
		while( bufbytes > 0 && reading ) {
			var nbytes = onData( buffer, pos, bufbytes );
			//var nbytes = handleData( buffer, pos, bufbytes );
			if( nbytes == 0 )
				return;
			/*
			if( nbytes == -1 ) {
				reading = false;
				disconnect();
				return;
			}
			*/
			pos += nbytes;
			bufbytes -= nbytes;
		}
		if( reading && pos > 0 )
			buffer.blit( 0, buffer, pos, bufbytes );
	}

	#elseif JABBER_SOCKETBRIDGE
	
	function sockConnectHandler() {
		connected = true;
		onConnect();
	}
	
	function sockDisconnectHandler() {
		connected = false;
		onDisconnect();
	}
	
	function sockErrorHandler( m : String ) {
		connected = false;
		onError( m );
	}
	
	function sockDataHandler( t : String ) {
		var i = buffer + t;
		if( i.length > MAX_BUFSIZE ) {
			#if JABBER_DEBUG trace( "Max socket buffer size reached ("+MAX_BUFSIZE+")" ); #end
			throw "Max socket buffer size reached ("+MAX_BUFSIZE+")";
		}
		buffer = ( onData( haxe.io.Bytes.ofString( i ), 0, i.length ) == 0 ) ? i : "";
	}
	
	#end
	
}


#if JABBER_SOCKETBRIDGE

/**
	Socket for socketbridge use.
*/
class Socket {
	
	public dynamic function onConnect() : Void;
	public dynamic function onDisconnect() : Void;
	public dynamic function onData( d : String ) : Void;
	public dynamic function onError( e : String ) : Void;
	
	public var id(default,null) : Int;
	//var timeout : Int;
	
	public function new() {
		var id : Int = SocketBridgeConnection.createSocket( this );
		if( id < 0 ) throw new error.Exception( "Error creating socket" );
		this.id = id;
	}
	
	public function connect( host : String, port : Int ) {
		untyped js.Lib.document.getElementById( SocketBridgeConnection.bridgeId ).connect( id, host, port );
	}
	
	public function close() {
		untyped js.Lib.document.getElementById( SocketBridgeConnection.bridgeId ).disconnect( id );
	}
	
	/*
	public function destroy() {
		var _s = untyped js.Lib.document.getElementById( SocketBridgeConnection.bridgeId ).destroy( id );
	}
	*/
	
	public function send( d : String ) {
		untyped js.Lib.document.getElementById( SocketBridgeConnection.bridgeId ).send( id, d );
	}
	
}


class SocketBridgeConnection {
	
	//public static var defaultBridgeId = "f9bridge";
	public static var defaultDelay = 300;
	public static var bridgeId(default,null) : String;
	
	static var sockets : IntHash<Socket>;
	static var initialized = false;
	
	/*
	public static function init( id : String ) {
		_init( id );
	}
	*/
	
	public static function init( id : String ) {
		if( initialized )
			throw "Socketbridge already initialized";
		bridgeId = id;
		sockets = new IntHash();
		initialized = true;
	}
	
	public static function initDelayed( id : String, cb : Void->Void, ?delay : Int ) {
		if( delay == null || delay <= 0 ) delay = defaultDelay;
		init( id );
		haxe.Timer.delay( cb, delay );
	}
	
	
	public static function createSocket( s : Socket ) {
		var id : Int = untyped js.Lib.document.getElementById( bridgeId ).createSocket();
		sockets.set( id, s );
		return id;
	}
	
	/*
	public static function destroySocket( id : Int ) {
		var removed = untyped js.Lib.document.getElementById( bridgeId ).destroySocket( id );
		if( removed ) {
			var s =  sockets.get( id );
			sockets.remove( id );
			s = null;
		}
	}
	*/
	
	static function handleConnect( id : Int ) {
		var s = sockets.get( id );
		s.onConnect();
	}
	
	static function handleDisonnect( id : Int ) {
		var s = sockets.get( id );
		s.onDisconnect();
	}
	
	static function handleError( id : Int, e : String ) {
		var s = sockets.get( id );
		s.onError( e );
	}
	
	static function handleData( id : Int, d : String ) {
		var s = sockets.get( id );
		s.onData( d );
	}
	
}

#end // JABBER_SOCKETBRIDGE
