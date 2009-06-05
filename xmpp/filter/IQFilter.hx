package xmpp.filter;

/**
	Filters IQ packets: namespace/nodeName/iqType
*/
class IQFilter {
	
	public var xmlns : String;
	public var nodeName : String;
	public var iqType : xmpp.IQType;
	
	public function new( ?xmlns : String, ?nodeName : String, ?type : xmpp.IQType ) {
		this.xmlns = xmlns;
		this.nodeName = nodeName;
		this.iqType = type;
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		if( p._type != xmpp.PacketType.iq ) return false;
		var iq : xmpp.IQ = cast( p, xmpp.IQ );
		if( xmlns != null ) {
			if( iq.x == null ) return false;
			var _xmlns = iq.x.toXml().get( "xmlns" );
			if( xmlns != _xmlns ) return false;
		}
		if( nodeName != null ) {
			if( iq.x == null ) return false;
			var name = iq.x.toXml().nodeName;
			if( nodeName != name ) return false;
		}
		if( iqType != null ) {
			if( iqType != iq.type ) return false;
		}
		return true;
	}
	
}
