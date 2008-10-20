package xmpp.disco;


/**
	Disco info packet.
*/
class Info {
	
	public static var XMLNS = 'http://jabber.org/protocol/disco#info';
	
//	public var from : String;
	public var identities : Array<xmpp.disco.Identity>; 
	public var features : Array<String>;
	
	
	public function new( ?identities : Array<xmpp.disco.Identity>, ?features : Array<String> ) {
		this.identities = ( identities == null ) ? new Array() : identities;
		this.features = ( features == null ) ? new Array() : features;
	}
	

	public function toXml() : Xml {
		var x = xmpp.IQ.createQuery( XMLNS );
		if( identities.length > 0 ) {
			for( i in identities ) {
				var identity = Xml.createElement( 'identity' );
				if( i.category != null ) identity.set( "category", i.category );
				if( i.name != null ) identity.set( "name", i.name );
				if( i.type != null ) identity.set( "type", i.type );
				x.addChild( identity );
			}
		}
		if( features.length > 0 ) {
			for( f in features ) {
				var feature = Xml.createElement( 'feature' );
				feature.set( "var", f );
				x.addChild( feature );
			}
		}
		return x;
	}
	
	public inline function toString() {
		return toXml().toString();
	}
	
	
	public static function parse( x : Xml ) : xmpp.disco.Info {
		var i = new xmpp.disco.Info();
		for( f in x.elements() ) {
			switch( f.nodeName ) {
				case "feature"  : i.features.push( f.get( "var" ) );
				case "identity" : i.identities.push( { category : f.get( "category" ), name : f.get( "name" ), type : f.get( "type" ) } );
			}
		}
		return i;
	}
	
}
