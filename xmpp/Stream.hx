package xmpp;

import util.XmlUtil;


//TODO rename to Stream, check with php. (?)
class Stream {
	
	public static var XMLNS_STREAM 	  = "http://etherx.jabber.org/streams";
	public static var XMLNS_CLIENT 	  = "jabber:client";
	public static var XMLNS_SERVER 	  = "jabber:client";
	public static var XMLNS_COMPONENT = "jabber:component:accept";
	
	public static var CLOSE = "</stream:stream>";
	public static var ERROR = "</stream:error>";
	
	public static var eregStreamClose = new EReg( CLOSE, "" );
	public static var eregStreamError = new EReg( ERROR, "" );
	
	/**
	*/
	public static function createOpenStream( xmlns : String, to : String,
											 ?version : Bool, ?lang : String, ?xmlHeader : Bool = true ) : String {
		var b = new StringBuf();
		b.add( '<stream:stream xmlns="' );
		b.add( xmlns );
		b.add( '" xmlns:stream="http://etherx.jabber.org/streams" to="' );
		b.add( to );
		b.add( '"' );
		if( version ) b.add( ' version="1.0"' );
		if( lang != null ) {
			b.add( ' xml:lang="' );
			b.add( lang );
			b.add( '"' );
		}
		b.add( '>' );
		return if( xmlHeader ) XmlUtil.XML_HEADER+b.toString() else b.toString();
	}
	
	/*
	public static function parseStreamFeatures( x : Xml ) {
	}
	*/
	
}
