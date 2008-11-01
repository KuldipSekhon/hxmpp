package jabber;

import jabber.core.IPacketCollector;
import jabber.core.IPacketInterceptor;
import jabber.core.PacketTimeout;

/**
	Represents the exchange of xmpp data to and from another jabber entity.
*/
// TODOtypedef IStream = {
interface Stream {
	
	/**
	*/
	var status : StreamStatus;
	
	/**
	*/
	var connection(default,setConnection) : jabber.core.StreamConnection;
	
	/**
	*/
	var id(default,null) : String;
	
	/**
	*/
	var collectors : List<IPacketCollector>;
	
	/**
	*/
	var interceptors : List<IPacketInterceptor>;
	
	/**
	*/
	function open() : Bool;
	
	/**
	*/
	function close( ?disconnect : Bool = false ) : Bool;
	
	/**
	*/
	function sendPacket<T>( p : xmpp.Packet, ?intercept : Bool = false ) : T;
	
	/**
	*/
	function sendData( data : String ) : Bool;
	
	/**
	*/
	function sendIQ( iq : xmpp.IQ, ?handler : xmpp.IQ->Void,
				     ?permanent : Bool, ?timeout : PacketTimeout, ?block : Bool )
	: { iq : xmpp.IQ, collector : IPacketCollector };
	
}
