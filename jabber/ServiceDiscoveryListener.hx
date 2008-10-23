package jabber;

import jabber.core.StreamBase;
import jabber.core.PacketCollector;
import xmpp.filter.IQFilter;
import xmpp.IQ;
import xmpp.IQType;


/**
	Listens for incoming service discovery requests.
*/
class ServiceDiscoveryListener {
	
	public static var defaultIdentity = { category:"client", name:"hxmpp", type:"pc" };
	
	public var stream(default,null) : StreamBase;
	public var active(default,setActive) : Bool;
	public var identity : xmpp.disco.Identity;
	
	var collector_info : PacketCollector;
	var collector_item : PacketCollector;
	var info_result : IQ;
	var info_result_ext : xmpp.disco.Info;
	var item_result : IQ;
	var item_result_ext : xmpp.disco.Item;
	
	
	public function new( stream : StreamBase,  ?identity : xmpp.disco.Identity ) {
		
		this.stream = stream;
		this.identity = if( identity != null ) identity else defaultIdentity;
		
		collector_info = new PacketCollector( [ cast new IQFilter( xmpp.disco.Info.XMLNS, null, IQType.get ) ], handleInfoQuery, true );
		collector_item = new PacketCollector( [ cast new IQFilter( xmpp.disco.Items.XMLNS, null, IQType.get ) ], handleItemQuery, true );
		
		info_result = new IQ( IQType.result );
		info_result_ext = new xmpp.disco.Info();
		info_result_ext.identities = [ identity ];
		info_result.ext = info_result_ext;
		
		item_result = new IQ( IQType.result );
		item_result.ext = item_result;
		//..
		
		setActive( true );
	}
	
	
	function setActive( a : Bool ) : Bool {
		if( a == active ) return a;
		Reflect.setField( this, "active", a );
		if( a ) {
			stream.collectors.add( collector_info );
			stream.collectors.add( collector_item );
		} else {
			stream.collectors.remove( collector_info );
			stream.collectors.remove( collector_item );
		}
		return a;
	}
	
	
	function handleInfoQuery( iq : IQ ) {
		trace("HÄNDELE INFO QUERY");
		info_result.to = iq.from;
		info_result_ext.identities = [identity];
		info_result_ext.features = new Array();
		for( f in stream.features ) info_result_ext.features.push( f );
		stream.sendIQ( info_result );
	}
	
	function handleItemQuery( iq : IQ ) {
		trace("handleItemQuery");
		//TODO
		//.
		stream.sendIQ( item_result );
	}
	
}