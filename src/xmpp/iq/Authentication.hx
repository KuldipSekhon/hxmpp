package xmpp.iq;

import util.XmlUtil;
import xmpp.Packet;


/**
	IQ extension for client account authenticating.
*/
class Authentication {
	
	public static inline var XMLNS = "jabber:iq:auth";
	
	
	public var username : String;
	public var password : String;
	public var digest 	: String;
	public var resource : String;
	
	
	public function new( ?username:	String, ?password : String, ?digest : String, ?resource : String ) {
		this.username = username;
		this.password = password;
		this.digest = digest;
		this.resource = resource;
	}

	
	public function toXml() : Xml {
		var query = xmpp.IQ.createQuery( XMLNS );
		if( username != null ) 	query.addChild( XmlUtil.createXmlElement( "username", username ) );
		if( password != null ) 	query.addChild( XmlUtil.createXmlElement( "password", password ) );
		if( digest != null ) 	query.addChild( XmlUtil.createXmlElement( "digest", digest ) );
		if( resource != null ) 	query.addChild( XmlUtil.createXmlElement( "resource", resource ) );
		return query;
	}
	
}
