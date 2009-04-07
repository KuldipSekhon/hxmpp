package jabber.component;

import jabber.stream.Connection;
import jabber.ServiceDiscoveryListener;

/**
	Base for Component-2-Server jabber streams.<br/>
	<a href="http://www.xmpp.org/extensions/xep-0114.html">XEP-0114: Jabber Component Protocol</a>
*/
class Stream extends jabber.Stream {
	
	public static inline var STANDARD_PORT = 5275;
	public static var defaultPort = STANDARD_PORT;
	
	/** Dispatched on authentication success */
	public dynamic function onConnect() : Void;
	
	/** */
	public var host(default,null) : String;
	/** This components subdomain */
	public var subdomain(default,null) : String;
	/** Shared secret used to identify legacy components*/
	public var secret(default,null) : String;
	/**  */
	public var authenticated(default,null) : Bool;
	/** */
	public var serviceListener(default,null) : ServiceDiscoveryListener;
	
	
	/**
	*/
	public function new( host : String, subdomain : String, secret : String, cnx : Connection,
						 ?identity : xmpp.disco.Identity ) {
						 	
		if( subdomain == null || subdomain == "" ) throw "Invalid subdomain";
		if( secret == null ) throw "Invalid secret (null)";

		super( cnx, null );
		this.host = host;
		this.subdomain = subdomain;
		this.secret = secret;
		
		authenticated = false;
		serviceListener = new ServiceDiscoveryListener( this, identity );
	}
	
	
	override function connectHandler() {
		sendData( xmpp.Stream.createOpenStream( xmpp.Stream.XMLNS_COMPONENT, subdomain ) );
		status = jabber.StreamStatus.pending;
		cnx.read( true );
	}
	
	override function processStreamInit( s : String ) {
		s = util.XmlUtil.removeXmlHeader( s );
		id = Xml.parse( s+"</stream:stream>" ).firstChild().get( "id" );
		status = jabber.StreamStatus.open;
		onOpen();
		collectors.add( new  jabber.stream.PacketCollector( [ cast new xmpp.filter.PacketNameFilter( ~/handshake/ ) ], readyHandler, false ) );
		sendData( util.XmlUtil.createElement( "handshake", Xml.createPCData( crypt.SHA1.encode( id+secret ) ).toString() ).toString() );
	}
	
	function readyHandler( p : xmpp.Packet ) {
		authenticated = true;
		onConnect();
	}
	
}
