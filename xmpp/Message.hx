package xmpp;

import util.XmlUtil;


/**
	XMPP message packet.
*/
class Message extends xmpp.Packet {
	
	public var type : MessageType;
	public var subject : String;
	public var body : String;
    public var thread : String;
	

    public function new( ?type : MessageType, ?to : String, ?subject : String, ?body : String, ?thread : String, ?from : String ) {
		super( to, from );
		_type = xmpp.PacketType.message;
		this.type = if ( type != null ) type else xmpp.MessageType.normal;
		this.subject = subject;
		this.body = body;
		this.thread = thread;
	}
    
    
    public override function toXml() : Xml {
    	var xml = super.addAttributes( Xml.createElement( "message" ) );
		if( type != null ) 	  xml.set( "type", Type.enumConstructor( type ) );
		if( subject != null ) xml.addChild( XmlUtil.createElement( "subject", subject ) );
		if( body != null ) 	  xml.addChild( XmlUtil.createElement( "body", body ) );
		if( thread != null )  xml.addChild( XmlUtil.createElement( "thread", thread ) );
		return xml;
    }
    
    
    public static function parse( src : Xml ) : xmpp.Message {
    	var type : MessageType = null;
    	var _type = src.get( "type" );
    	if( _type != null ) type = Type.createEnum( xmpp.MessageType, _type );
    	var m = new Message( type );
   		xmpp.Packet.parseAttributes( m, src );
   		for( child in src.elements() ) {
			switch( child.nodeName ) {
				case "subject" : m.subject = child.firstChild().nodeValue;
				case "body"    : m.body = child.firstChild().nodeValue;
				case "thread"  : m.thread = child.firstChild().nodeValue;
				default : m.properties.push( child );
			}
		}
   		return m;
	}
    
}
