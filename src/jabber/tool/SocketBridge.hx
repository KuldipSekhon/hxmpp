package jabber.tool;

import haxe.remoting.Connection;


#if neko

import neko.net.Socket;

/**
	mode_neko socket bridge.
	// hm?
*/
class SocketBridge {
	
	
	static function main() {
		var params = neko.Web.getParams();
		if( Lambda.empty( params ) ) {
			neko.Lib.println( "NOTING " );
		} else {
			neko.Lib.println( "PARAMS " + params );
		}
	}
	
	
	function new() {
	}
	
}




#elseif flash9
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;



private class Socket extends flash.net.Socket {
	public var id : Int;
	public function new( id : Int) {
		super();
		this.id = id;
	}
}


/**
	flash9.
	Socket bridge server swf.
*/
class SocketBridge {
	
	static var cnx : haxe.remoting.Connection; // TODO cnxs : Hash<haxe.remoting.Connection>;
	static var sockets = new List<Socket>();
	static var socketsTotal = 0;
	
	
	static function main() {
		
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		
		var ctx = new haxe.remoting.Context();
		ctx.addObject( "SocketBridge", SocketBridge );
		cnx = haxe.remoting.ExternalConnection.jsConnect( "default", ctx );
	}
	
	
	static function getSocket( id : Int ) : Socket {
		for( s in sockets ) if( s.id == id ) return s;
		return null;
	}
	
	/*
TODO	auth client by name, set CLIENT
	static function authenticate( secret : String, ) {
	}
	*/
	
	static function createSocket() : Int {
		var id = socketsTotal++;
		var s = new Socket( id );
		s.addEventListener( Event.CONNECT, sockConnectHandler );
		s.addEventListener( Event.CLOSE, sockDisconnectHandler );
		s.addEventListener( IOErrorEvent.IO_ERROR, sockDisconnectHandler );
		s.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockDisconnectHandler );
		s.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
		sockets.add( s );
		return id;
	}
	
	static function connect( id : Int, host : String, port : Int ) : Bool {
		var s = getSocket( id );
		//if( s == null ) return false;
		s.connect( host, port );
		return true;
	}
	
	static function close( id : Int) : Bool {
		var s = getSocket( id );
		s.close();
		return true;
	}
	
	static function send( id : Int, data : String ) : Bool {
		var s = getSocket( id );
		s.writeUTFBytes( data ); 
		s.flush();
		return true;
	}
	
	static function sockConnectHandler( e : Event ) {
		cnx.SocketBridgeConnection.onSocketConnect.call( [e.target.id] );
	}

	static function sockDisconnectHandler( e : Event ) {
		cnx.SocketBridgeConnection.onSockClose.call( [e.target.id] );
	}
	
	static function sockDataHandler( e : ProgressEvent ) {
		cnx.SocketBridgeConnection.onSocketData.call( [e.target.id, e.target.readUTFBytes( e.bytesLoaded )] );
	}
	
}

#end // flash9
