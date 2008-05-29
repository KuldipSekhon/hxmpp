package jabber;

import event.Dispatcher;
import util.IDFactory;



/**
	Abstract base for ( xmpp data exchanging ) jabber streams between any entities.<br>
*/
class StreamBase {
	
	public var connection(default,setConnection) : IStreamConnection;
	public var status(default,null) : StreamStatus;
	public var id(default,setID) : String;
	public var version(default,setVersion) : String;
	public var lang(default,setLang) : String;
	
	public var collectors 	: List<IPacketCollector>;
	public var interceptors : List<IPacketInterceptor>;
	
	public var onOpen(default,null)  : Dispatcher<StreamBase>;
	public var onClose(default,null) : Dispatcher<StreamBase>;
	public var onClose(default,null) : Dispatcher<StreamBase>;
	public var onData(default,null)  : Dispatcher<StreamBase>;
	public var onError(default,null) : Dispatcher<StreamError>;
	
	public function cache(getCache,null) : String;
	
	var cache : StringBuf;
	
	
	function new( connection : IStreamConnection ) {
		
		status = StreamStatus.closed;
		this.setConnection( connection ); // add connection listeners
		
		idFactory = new IDFactory();
		cache = new StringBuf();
		
		collectors = new List();
		interceptors = new List();
		
		onOpen = new Dispatcher();
		onClose = new Dispatcher();
		onData = new Dispatcher();
		onXMPP = new Dispatcher();
	}
	
	
	
	function setConnection( c : IStreamConnection ) : IStreamConnection {
		if( status == StreamStatus.pending ) return null;
		if( connection != null ) {
			if( connection.connected ) connection.disconnect();
		}
		connection = c;
		connection.stream = this;
		return connection;
	}
	
	function setID( id : String ) : String { // override me
		this.id = id;
		return id;
	}
	
	
	/**
	*/
	public function nextID() : String {
		return idFactory.next();
	}
	
	/**
		Request to open the stream by sending an openn stream packet if the connection is up,
		tries to connect the connection first otherwise.
		Returns false for already opened or pending streams. 
	*/
	public function open() : Bool {
		if( status == StreamStatus.open || status == StreamStatus.pending ) return false;
		//status = StreamStatus.pending;
		if( !connection.connected ) connection.connect();
		else onConnected();
		return true;
	}
	
	/**
		Sends a closing stream tag. Keeps connection up.
	*/
	//TODO public function close( ?error ) : Bool {
	public function close() : Bool {
		if( status != StreamStatus.open ) return false;
		if( status == StreamStatus.open ) {
			sendData( "</stream:stream>" ); // TODO other namespaces
			status = StreamStatus.closed;
			cache = new StringBuf();
			return true;
		}
		return false;
	}
	
	/**
		Intercepts and sends a xmpp packet.
		Returns the intercepted packet.
	*/
	public function sendPacket( packet : xmpp.Packet, ?intercept : Bool ) : xmpp.Packet {
		if( !connection.connected || status != StreamStatus.open ) return null;
		if( intercept == null || intercept == true ) {
			for( interceptor in interceptors ) interceptor.intercept( packet );
		}
		sendData( packet.toString() );
		return packet;
	}
	
	/**
		Sends raw string.
	*/
	public function sendData( data : String ) : Bool {
		if( !connection.connected ) return false;
		connection.send( data );
		return true;
	}
	
	/**
		Removes a packet collector from the stream.
		This method could be used as timeout handler for packet collectors for automatic remove on timeout.
	*/
	public function removeCollector( c : IPacketCollector ) {
		if( c.timeout != null ) c.timeout.stop();
		collectors.remove( c );
	}
	
	public function processData( data : String ) {
	}
	
	
	public function collectPacket( packet : xmpp.Packet ) {
	}
	
	
	function onConnected() { throw "Abstract error"; }
	function onDisconnect() { throw "Abstract error"; }
	function onData( data : String ) { throw "Abstract error"; }
}
