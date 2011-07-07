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
package jabber.jingle.io;

#if flash

import flash.events.NetStatusEvent;
import flash.net.NetConnection;
import flash.net.NetStream;

@:require(flash10) class RTMFPTransport extends Transport {

	public static var EREG_URL = ~/(rtmfp:\/\/)([A-Z0-9.-]+?)(\/([A-Z0-9\-]+))?/i;
	
	public var url(default,null) : String;
	public var id(default,null) : String;
	public var nc : NetConnection; // set with care !
	
	function new( url : String ) {
		if( !EREG_URL.match( url ) )
			throw "invalid rtmfp url";
		super();
		this.url = url;
	}
	
	public override function connect() {
		/*
		if( nc == null ) {
			nc = new NetConnection();
			nc.addEventListener( NetStatusEvent.NET_STATUS, netConnectionHandler, false, 0, true );
			try nc.connect( url ) catch( e : Dynamic ) {
				__onFail( "failed to connect to rtmfp service ["+url+"]" );
			}
		} else {
			if( nc.connected ) {
				id = nc.nearID;
				__onConnect();
			} else {
				try nc.connect( url ) catch( e : Dynamic ) {
					__onFail( "failed to connect to rtmfp service ["+url+"]" );
				}
			}
		}
		*/
		
		if( nc == null ) nc = new NetConnection();
		nc.addEventListener( NetStatusEvent.NET_STATUS, netConnectionHandler, false, 0, true );
		if( nc.connected ) {
			id = nc.nearID;
			__onConnect();
		} else {
			try nc.connect( url ) catch( e : Dynamic ) {
				__onFail( "failed to connect to rtmfp service ["+url+"]" );
			}
		}
	}
	
	public override function close() {
		if( nc != null && nc.connected ) try nc.close() catch(e:Dynamic){
			trace(e,"warn");
		}
	}
	
	function netConnectionHandler( e : NetStatusEvent ) {
		//#if JABBER_DEBUG trace( e.info.code ); #end
		switch( e.info.code ) {
		case 'NetConnection.Connect.Failed' :
			if( __onFail != null ) __onFail( e.info.code );
		}
	}
	
}

#end // flash
