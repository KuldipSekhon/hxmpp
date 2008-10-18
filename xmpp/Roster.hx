package xmpp;


/**
	IQ roster extension.
*/
class Roster extends List<xmpp.RosterItem> {
	
	public static var XMLNS = "jabber:iq:roster";
	
	
	public function new( ?items : Iterable<RosterItem> ) {
		super();
		if( items != null ) for( i in items ) add( i );
	}
	
	
	public function toXml() : Xml {
		var q = IQ.createQuery( XMLNS );
		for( item in iterator() ) q.addChild( item.toXml() );
		return q;
	}
	
	public override function toString() : String {
		return toXml().toString();
	}
	
	
	public static function parse( x : Xml ) : xmpp.Roster {
		var r = new xmpp.Roster();
		for( item in x.elements() ) {
			if( item.nodeName == "item" ) r.add( RosterItem.parse( item ) );
		}
		return r;
	}
	
}
