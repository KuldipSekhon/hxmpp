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

import xmpp.IQ;
import xmpp.IQType;
import xmpp.disco.Info;
import xmpp.disco.Items;

/**
	<p>
	Manages discovery of services from XMPP entities.<br/>
	Two kinds of information can be discovered:<br/>
	<ul>
		<li>The identity and capabilities of an entity, including the protocols and features it supports,</li>
		<li>The items associated with an entity, such as the list of rooms hosted at a multi-user chat service.</li>
	</ul>
	</p>
	<a href="http://www.xmpp.org/extensions/xep-0030.html">XEP 30 - ServiceDiscovery</a>
*/
class ServiceDiscovery {
	
	public dynamic function onInfo( jid : String, info : Info ) {}
	public dynamic function onItems( jid : String, items : Items ) {}
	public dynamic function onError( e : XMPPError ) {}
	
	public var stream(default,null) : jabber.Stream;
	
	public function new( stream : jabber.Stream ) {
		this.stream = stream;
	}
	
	/**
		Query entity for information.
	*/
	public function info( jid : String, ?node : String ) {
		var r = new IQ( IQType.get, null, jid );
		r.x = new Info( null, null, node );
		stream.sendIQ( r, handleInfo );
	}
	
	/**
		Query entity for items.
	*/
	public function items( jid : String, ?node : String ) {
		var r = new IQ( IQType.get, null, jid );
		r.x = new Items( node );
		stream.sendIQ( r, handleItems );
	}
	
	function handleInfo( iq : IQ ) {
		switch( iq.type ) {
		case result :
			onInfo( iq.from, Info.parse( iq.x.toXml() ) );
		case error :
			//trace("TODO");
			//trace( iq.errors[0] );
			onError( new XMPPError( iq ) );
			/* 
			trace("TODO error","error");
			trace(iq,"error");
			//TODO wtf .. this error packet thing handling is such a shit !
			if( iq.errors[0] != null ) {
				onError( new XMPPError( iq ) );
			} else {
				onError( null );
			}
			trace("-------------------------------------------------");
			*/
			
		default :
		}
	}
	
	function handleItems( iq : IQ ) {
		switch( iq.type ) {
		case result :
			onItems( iq.from, Items.parse( iq.x.toXml() ) );
		case error :
			//TODO wtf .. this error packet thing handling is such a shit !
			if( iq.errors[0] != null ) {
				onError( new XMPPError( iq ) );
			}
		default:
		}
	}
	
}
