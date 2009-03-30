package xmpp.filter;


/**
*/
class PacketPropertyFilter {
	
	public var ns : String;
	public var name : String;
	
	public function new( ns : String, ?name : String ) {
		this.ns = ns;
		this.name = name;
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		
		for( p in p.properties ) {
			if( ns != null ) {
				if( p.get( "xmlns" ) != ns ) {
					continue;
				}
			}
			if( name != null ) {
				if( p.nodeName == name ) {
					return true;
				}
			} else {
				return true;
			}
		}
		return false;
	}
	
}
