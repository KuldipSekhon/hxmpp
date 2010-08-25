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

import jabber.stream.Connection;
import jabber.stream.TPacketInterceptor;
import jabber.stream.PacketCollector;
import jabber.stream.PacketTimeout;
import jabber.stream.TDataInterceptor;
import jabber.stream.TDataFilter;
import jabber.util.Base64;
import xmpp.XMLUtil;
import xmpp.filter.PacketIDFilter;

private typedef Server = {
	var features : Hash<Xml>;
}

private class StreamFeatures {
	var l : List<String>;
	public function new() { l = new List(); }
	public inline function iterator() { return l.iterator(); }
	public function add( f : String ) : Bool {
		if( Lambda.has( l, f ) ) return false;
		l.add( f );
		return true;
	}
	public function remove( f : String ) : Bool { return l.remove( f ); }
	public function clear( f : String ) { l = new List(); }
	#if JABBER_DEBUG
	public inline function toString() : String { return l.toString(); }
	#end
}

/**
	Abstract base for XMPP streams.
*/
class Stream {
	
	public static var defaultPacketIdLength = 5;
	
	public dynamic function onOpen() : Void;
	public dynamic function onClose( ?e : Dynamic ) : Void;
	
	public var status : StreamStatus;
	public var cnx(default,setConnection) : Connection;
	public var jidstr(getJIDStr,null) : String;  // TODO replace by JID
	#if !JABBER_COMPONENT
	public var jid(default,setJID) : JID;
	#end
	public var features(default,null) : StreamFeatures;
	public var server(default,null) : Server;
	public var id(default,null) : String;
	public var lang(default,null) : String;
	public var version : Bool;
	public var dataFilters(default,null) : List<TDataFilter>;
	public var dataInterceptors(default,null) : List<TDataInterceptor>;
	
	var idCollectors : List<PacketCollector>;
	var collectors : List<PacketCollector>;
	var interceptors : List<TPacketInterceptor>;
	var numPacketsSent : Int;
	
	function new( cnx : Connection ) {
		status = StreamStatus.closed;
		server = { features : new Hash() };
		features = new StreamFeatures();
		version = true;
		idCollectors = new List();
		collectors = new List();
		interceptors = new List();
		numPacketsSent = 0;
		dataFilters = new List();
		dataInterceptors = new List();
		if( cnx != null ) setConnection( cnx );
		// TODO remove HACK
		#if (flash&&JABBER_CONSOLE)
		XMPPDebug.stream = this;
		#end
	}
	
	#if !JABBER_COMPONENT
	function setJID( j : JID ) : JID {
		if( status != StreamStatus.closed )
			throw "Cannot change JID on open stream";
		return jid = j;
	}
	#end
	
	function getJIDStr() : String {
		#if JABBER_COMPONENT
		return throw "Abstract method";
		#else
		return jid.toString();
		#end
	}
	
	function setConnection( c : Connection ) : Connection {
		switch( status ) {
		case open, pending, starttls :
			close( true );
			setConnection( c );
			 // re-open XMPP stream
			#if JABBER_COMPONENT
			trace("TODO");
			#else
			open( jid );
			#end
		case closed :
			if( cnx != null && cnx.connected )
				cnx.disconnect();
			cnx = c;
			cnx.__onConnect = handleConnect;
			cnx.__onDisconnect = handleDisconnect;
			cnx.__onData = handleData;
			cnx.__onError = handleConnectionError;
		}
		return cnx;
	}
	
	/**
		Get the next unique id for a XMPP packet.
	*/
	public function nextID() : String {
		#if JABBER_DEBUG
		return Base64.random( defaultPacketIdLength )+"_"+numPacketsSent;
		#else
		return Base64.random( defaultPacketIdLength );
		#end
	}
	
	#if JABBER_COMPONENT
	public function open( host : String, subdomain : String, secret : String, ?identities : Array<xmpp.disco.Identity> ) {
		#if JABBER_DEBUG
		throw "Abstract method";
		#end
	}
	#else
	/**
		Open the XMPP stream.
	*/
	public function open( jid : JID ) {
		if( jid != null ) this.jid = jid
		else if( this.jid == null ) this.jid = new JID( null );
		if( cnx == null )
			throw "No stream connection set";
		cnx.connected ? handleConnect() : cnx.connect();
	}
	#end
	
	/**
		Close the XMPP stream.
		Passed argument indicates if the (TCP) connection to the server should also get closed.
	*/
	public function close( ?disconnect = false ) {
		if( status == StreamStatus.closed )
			return;
		if( !cnx.http ) sendData( "</stream:stream>" );
		status = StreamStatus.closed;
		if( cnx.http ) cnx.disconnect();
		else if( disconnect ) cnx.disconnect();
		handleDisconnect();
	}
	
	/**
		Intercept/Send/Return the given XMPP packet.
	*/
	public function sendPacket<T>( p : T, intercept : Bool = true ) : T {
		if( !cnx.connected )
			return null;
		if( intercept )
			interceptPacket( untyped p );
		return ( sendData( untyped p.toString() ) != null ) ? p : null;
	}
	
	/**
		Send raw string.
	*/
	public function sendData( t : String ) : String {
		if( !cnx.connected )
			return null;
		//TODO !!
		//for( i in dataInterceptors )
			//t = i.interceptData( t );
#if flash // haXe 2.06 fukup		
		t = StringTools.replace( t, "_xmlns_=", "xmlns=" );
#end
		if( !cnx.write( t ) )
			return null;
		numPacketsSent++;
		#if XMPP_DEBUG
		XMPPDebug.out( t );
		#end
		return t;
	}
	
	/**
		Send an IQ packet and forward the collected response to the given handler function.
	*/
	public function sendIQ( iq : xmpp.IQ, ?handler : xmpp.IQ->Void,
							?permanent : Bool, ?timeout : PacketTimeout, ?block : Bool ) //TODO permanent+remove block argument
	: { iq : xmpp.IQ, collector : PacketCollector }
	{
		if( iq.id == null ) iq.id = nextID();
		//iq.from = jidstr;
		var c : PacketCollector = null;
		if( handler != null ) {
			//c = new PacketCollector( [cast new PacketIDFilter( iq.id )], handler, permanent, timeout, block );
			//addIDCollector( c );
			c = addIDCollector( iq.id, handler );
		}
		var s : xmpp.IQ = sendPacket( iq );
		if( s == null && handler != null ) {
			collectors.remove( c );
			c = null;
			return null;
		}
		return { iq : s, collector : c };
	}

	/**
		Send a message packet (default type is 'chat').
	*/
	public function sendMessage( to : String, body : String, ?subject : String, ?type : xmpp.MessageType, ?thread : String, ?from : String ) : xmpp.Message {
		return cast sendPacket( new xmpp.Message( to, body, subject, type, thread, from ) );
	}
	
	/**
		Send a presence packet.
	*/
	public function sendPresence( ?show : xmpp.PresenceShow, ?status : String, ?priority : Int, ?type : xmpp.PresenceType ) : xmpp.Presence {
		return cast sendPacket( new xmpp.Presence( show, status, priority, type ) );
		
	}
	
	public function sendPresenceTo( jid : String ) : xmpp.Presence {
		var p = new xmpp.Presence();
		p.to = jid;
		var s : xmpp.Presence = sendPacket(p);
		return s;
	}
	
	/**
		Runs the XMPP packet interceptor on the given packet.
	*/
	public function interceptPacket( p : xmpp.Packet ) : xmpp.Packet {
		for( i in interceptors ) i.interceptPacket( p );
		return p;
	}
	
	/**
		Creates, adds and returns a XMPP packet collector.
	*/
	public function collect( filters : Iterable<xmpp.PacketFilter>, handler : Dynamic->Void, permanent : Bool = false ) : PacketCollector {
		var c = new PacketCollector( filters, handler, permanent );
		return addCollector( c ) ? c : null;
	}
	
	/**
		Adds an packet collector which filters XMPP packets by ids.
		These collectors get processed before any other collectors.
	*/
	public function addIDCollector( id : String, handler : Dynamic->Void ) : PacketCollector {
		var c = new PacketCollector( [cast new PacketIDFilter(id)], handler );
		idCollectors.add( c );
		return c;
	}
	
	/**
		Adds a XMPP packet collector to this stream and starts the timeout if not null.
	*/
	public function addCollector( c : PacketCollector ) : Bool {
		if( Lambda.has( collectors, c ) ) return false;
		collectors.add( c );
		if( c.timeout != null ) c.timeout.start();
		return true;
	}
	
	/**
	*/
	public function removeCollector( c : PacketCollector ) : Bool {
		if( !collectors.remove( c ) ) {
			if( !idCollectors.remove( c ) )
				return false;
		}
		if( c.timeout != null ) c.timeout.stop();
		return true;
	}
	
	/**
	*/
	public function addInterceptor( i : TPacketInterceptor ) : Bool {
		if( Lambda.has( interceptors, i ) ) return false;
		interceptors.add( i );
		return true;
	}
	
	/**
	*/
	public function removeInterceptor( i : TPacketInterceptor ) : Bool {
		return interceptors.remove( i );
	}
	
	/**
	*/
	public function handleData( buf : haxe.io.Bytes, bufpos : Int, buflen : Int ) : Int {
		if( status == StreamStatus.closed ) return -1;
		//TODO .. data filters
		var t : String = buf.readString( bufpos, buflen );
		
#if flash // haXe 2.06 fuckup
		t = StringTools.replace( t, "xmlns=", "_xmlns_=" );
#end
		//TODO
		if( StringTools.startsWith( t, '</stream:stream' ) ) {
			#if XMPP_DEBUG
			XMPPDebug.inc( t );
			#end
			close( true );
			return 0;
		} else if( StringTools.startsWith( t, '</stream:error' ) ) {
			#if XMPP_DEBUG
			XMPPDebug.inc( t );
			#end
			close( true );
			return 0;
		}
		switch( status ) {
		case closed :
			// TODO cleanup
			return -1;//buflen?
		case pending :
			return processStreamInit( t, buflen );
		case starttls :
			var x : Xml = null;
			try x = Xml.parse( t ).firstElement() catch( e : Dynamic ) {
				#if JABBER_DEBUG
				trace( "StartTLS failed" );
				#end
				cnx.disconnect();
				return 0;
			}
			if( x.nodeName != "proceed" || x.get( "xmlns" ) != "urn:ietf:params:xml:ns:xmpp-tls" ) {
				cnx.disconnect();
				return 0;
			}
			var me = this;
			cnx.__onSecured = function() { me.open( null ); }
			cnx.setSecure();
			
		case open :
			// filter data here ?
			var x : Xml = null;
			try {
				x = Xml.parse( t );
			} catch( e : Dynamic ) {
				//#if JABBER_DEBUG
				//trace( "Packet incomplete, waiting for more data ..", "info" );
				//#end
				return 0; // wait for more data
			}
			handleXml( x );
			return buflen;
		}
		return 0;
	}
	
	/**
		Inject incoming XML data.<br/>
		Returns array of handled XMPP packets.
	*/
	public function handleXml( x : Xml ) : Array<xmpp.Packet> {
		var ps = new Array<xmpp.Packet>();
		for( e in x.elements() ) {
			//TODO
			/*
			var p = xmpp.Packet.parse( e );
			if( p != null && handlePacket( p ) ) 
				ps.push( p );
			*/
			var p = xmpp.Packet.parse( e );
			handlePacket( p );
			ps.push( p );
		}
		return ps;
	}
	
	/**
		Handles incoming XMPP packets.<br/>
		Returns true if the packet got handled.
	*/
	public function handlePacket( p : xmpp.Packet ) : Bool {
		#if XMPP_DEBUG
		XMPPDebug.inc( p.toString() );
		#end
		for( c in idCollectors ) {
			if( c.accept( p ) ) {
				c.deliver( p );
				idCollectors.remove( c );
				c = null;
				return true;
			}
		}
		var collected = false;
		for( c in collectors ) {
			if( c.accept( p ) ) {
				collected = true;
				c.deliver( p );
				if( !c.permanent ) {
					collectors.remove( c );
				}
				if( c.block ) {
					break;
				}
			}
		}
		if( !collected ) {
			#if JABBER_DEBUG
			//trace( "Incoming '"+Type.enumConstructor( p._type )+"' packet not handled ( "+p.from+" -> "+p.to+" )", "warn" );
			#end
			if( p._type == xmpp.PacketType.iq ) { // send 'feature not implemented' response
				var q : xmpp.IQ = cast p;
				if( q.type != xmpp.IQType.error ) {
					var r = new xmpp.IQ( xmpp.IQType.error, p.id, p.from, p.to );
					r.errors.push( new xmpp.Error( xmpp.ErrorType.cancel, xmpp.ErrorCondition.FEATURE_NOT_IMPLEMENTED ) );
					sendData( r.toString() );
				}
			}
		}
		return collected;
	}
	
	function processStreamInit( t : String, buflen : Int ) : Int {
		return throw "Abstract method";
	}
	
	function handleConnect() {
		trace("handleConnecthandleConnecthandleConnect");
	}

	function handleDisconnect() {
		onClose();
	}
	
	function handleConnectionError( e : String ) {
		onClose( e );
	}
	
	/*
	function cleanup() {
		id = null;
		numPacketsSent = 0;
		collectors = new List();
		interceptors = new List();
		sever = { features : new Hash() };
		features = new StreamFeatures();
		onClose();
	}
	*/
	
}
