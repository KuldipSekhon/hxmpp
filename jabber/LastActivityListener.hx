/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package jabber;

/**
	<a href="http://xmpp.org/extensions/xep-0012.html">XEP-0012: Last Activity</a>
*/
class LastActivityListener {
	
	/** Seconds passed after last user activity */
	public var time : Int;
	public var stream(default,null) : Stream;
	
	var c : jabber.stream.PacketCollector;
	
	public function new( stream : Stream, time : Int = 0 ) {
		if( !stream.features.add( xmpp.LastActivity.XMLNS ) )
			throw "last activity listener already added" ;
		this.stream = stream;
		this.time = time;
		c = stream.collect( [ cast new xmpp.filter.IQFilter( xmpp.LastActivity.XMLNS, xmpp.IQType.get, "query" ) ], handleRequest, true );
	}
	
	public function dispose() {
		if( c == null )
			return;
		stream.features.remove( xmpp.LastActivity.XMLNS );
		stream.removeCollector(c);
		c = null;
	}
	
	function handleRequest( iq : xmpp.IQ ) {
		var r = new xmpp.IQ( xmpp.IQType.result, iq.id, iq.from );
		r.x = new xmpp.LastActivity( time );
		stream.sendPacket( r );	
	}
	
}
