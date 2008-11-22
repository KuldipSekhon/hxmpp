package jabber;

import jabber.core.StreamBase;
import jabber.core.PacketCollector;

// TODO

typedef CompressionMethod = {
	var name(default,null) : String;
	function compress( data : String ) : String;
	function decompress( data : String ) : String;
}


/**
	<a href="http://www.xmpp.org/extensions/xep-0138.html">XEP-0138: Stream Compression</a>
*/
class StreamCompression {
	
	public var stream(default,null) : StreamBase;
	public var method(default,null) : CompressionMethod;

	
	public function new( stream : StreamBase ) {
		if( stream.server.features.get( "compression" ) == null ) throw "Server doesnt support stream compression";
		this.stream = stream;
	}
	
	
	/**
	*/
	public function init( method : CompressionMethod ) : Bool {
		var methods = xmpp.Compression.parseMethods( stream.server.features.get( "compression" ) );
		var match = false;
		for( m in methods ) {
			if( m == method.name ) {
				match = true;
				break;
			}
		}
		if( !match ) return false;
		this.method = method;
		stream.collectors.add( new PacketCollector( [ cast new xmpp.filter.PacketNameFilter( ~/compressed/ ) ], initSuccessHandler, false ) );
		stream.collectors.add( new PacketCollector( [ cast new xmpp.filter.PacketNameFilter( ~/failure/ ) ], initFailedHandler, false ) );
		stream.sendData( xmpp.Compression.createPacket( [method.name] ).toString() );
		return true;
	}
	
	/**
	*/
	public function interceptData( d : String ) : String {
		trace("INTERCEPT");
		return method.compress( d );
	}
	
	/**
	*/
	public function filterData( d : String ) : String {
		return method.decompress( d );
	}
	
	
	function initSuccessHandler( p ) {
		stream.connection.interceptors.push( this );
		stream.connection.filters.push( this );
		stream.status = jabber.StreamStatus.closed;
		//stream.version = null;
		stream.open();
	}
	
	function initFailedHandler( p ) {
		//TODO
		trace("Stream compression failed");
	}
	
}
