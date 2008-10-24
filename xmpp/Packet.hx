package xmpp;

//TODO

/**
	Abstract/Basic xmpp packet.
*/
class Packet {
	
	public var _type(default,null) : PacketType;
	public var to : String;
	public var from : String;
	public var id : String;	
	public var lang : String;
	public var properties : Array<Xml>;
	public var errors : Array<Xml>;
	
	
	function new( ?to : String, ?from : String, ?id : String, ?lang : String ) {
		this.to = to;
		this.from = from;
		this.id = id ;
		this.lang = lang;
		errors = new Array();
		properties = new Array();
	}

	
	/**
		Creates/Returns the xml representaion of this xmpp packet.
	*/
	public function toXml() : Xml {
		return throw new error.AbstractError();
	}
	
	/**
		Creates/Returns the string representaion of this xmpp packet.
	*/
	public inline function toString() : String {
		return toXml().toString();
	}
	

	/**
		Adds the basic xmpp packet attributes to the xml.
	*/
	function addAttributes( x : Xml ) : Xml {
		if( to != null ) x.set( "to", to );
		if( from != null ) x.set( "from", from );
		if( id != null ) x.set( "id", id );
		if( lang != null ) x.set( "xml:lang", lang );
		for( p in properties ) x.addChild( p );
		for( e in errors ) x.addChild( e );
        return x;
	}
	
	
	/**
		Parses xml into a xmpp.Packet object.
	*/
	public static function parse( x : Xml ) : xmpp.Packet {
		return switch( x.nodeName ) {
			case "iq" 		: cast IQ.parse( x );
			case "message"  : cast xmpp.Message.parse( x );
			case "presence" : cast Presence.parse( x );
			default : cast new PlainPacket( x );
		}
	}
	
	/*
	function parseErrors( x : Xml ) : Array<xmpp.Error> {
		for( el in x.elements() ) {
			if( el.nodeName == "error" ) {
				iq.errors.push( el );
			}
		}
	}
	*/
	
	/*
	static function parseBase( p, x : Xml ) {
		parseAttributes
		for( e in errors )
		for( p in properties ) 
	}
	*/
	
	/**
		Parses/adds basic attributes to the packet.
	*/
	public static function parseAttributes( p : xmpp.Packet, x : Xml ) : xmpp.Packet {
		p.to = x.get( "to" );
		p.from = x.get( "from" );
		p.id = x.get( "id" );
		p.lang = x.get( "xml:lang" );
		return p;
	}
	
	/**
		Reflects the elements of the xml into the packet.
		Use with care!
	*/
	public static function reflectPacketNodes<T>( x : Xml, p : T ) : T {
		for( e in x.elements() ) {
			var v : String = null;
			try { v = e.firstChild().nodeValue; } catch( e : Dynamic ) {};
			if( v != null ) Reflect.setField( p, e.nodeName, v );
		}
		return p;
	}
	
	/*
	public static function reflectPacketAttributes<T>( x : Xml, p : T ) : T {
	}
	*/
	
	/*
	public static function reflectField<T,V>( o : T, name : String, value : V ) {
		//trace( Type.typeof(o) );
		Reflect.setField( o, name, value );
		return o;
	}
	*/
	
	/*
		Determines the packettype of the given xml.
	public static function getPacketType( x : Xml ) : PacketType {
		return switch( x.nodeName ) {
			case "presence" : PacketType.presence;
			case "message" : PacketType.message;
			case "iq" : PacketType.iq;
			default : PacketType.custom;
		}
	}
	*/
	
}
