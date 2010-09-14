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
package jabber.util;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;

#if (neko||cpp||php)

#if neko
import neko.net.Socket;
#elseif cpp
import cpp.net.Socket;
#elseif php
import php.net.Socket;
#end

/**
	<a href="http://www.faqs.org/rfcs/rfc1928.html">RFC 1928</a>
	SOCKS5 negotiation for incoming socket connections (outgoing datatransfers).<br/>
	This is not a complete implementation of the SOCKS5 protocol,<br/>
	just a subset fulfilling requirements in context of XMPP (datatransfers).
*/
class SOCKS5In {
	
	public function new() {}
	
	/**
		SOCKS5 negotiation for incoming socket connections (outgoing datatransfers).
	*/
	public function run( socket : Socket, digest : String ) {
		
		var i = socket.input;
		var o = socket.output;
		
		i.readByte(); // 0x05
		for( _ in 0...i.readByte() )
			i.readByte();
		
		var b = new BytesBuffer();
		b.addByte( 0x05 );
		b.addByte( 0x00 );
		o.write( b.getBytes() );
		
		i.readByte();
		i.readByte();
		i.readByte();
		i.readByte();
		if( i.readString( i.readByte() ) != digest )
			throw "SOCKS5 digest dos not match";
		i.readInt16();
		
		o.write( SOCKS5.createOutgoingMessage( 0, digest ) );
		o.flush();
	}
}


#elseif nodejs

import js.Node;

private enum State {
	WaitInit;
	WaitResponse;
}

class SOCKS5In {
	
	var socket : Stream;
	var digest : String;
	var cb : String->Void;
	var state : State;
	
	public function new() {}
	
	public function run( socket : Stream, digest : String, cb : String->Void ) {
		this.socket = socket;
		this.digest = digest;
		this.cb = cb;
		state = WaitInit;
		socket.on( Node.EVENT_STREAM_END, onError );
		socket.on( Node.EVENT_STREAM_ERROR, onError );
		socket.on( Node.EVENT_STREAM_DATA, onData );
	}
	
	function onData( buf : Buffer ) {
		switch( state ) {
		case WaitInit :
			var b = new haxe.io.BytesBuffer();
			b.addByte( 0x05 );
			b.addByte( 0x00 );
			socket.write( b.getBytes().getData() );
			state = WaitResponse;
			
		case WaitResponse :
			var i = new haxe.io.BytesInput( Bytes.ofData( buf ) );
			i.readByte();
			i.readByte();
			i.readByte();
			i.readByte();
			if( i.readString( i.readByte() ) != digest ) {
				cb( "SOCKS5 digest does not match" );
				return;
			}
			i.readInt16();
			
			socket.write( SOCKS5.createOutgoingMessage( 0, digest ).getData() );
			
			removeSocketListeners();
			cb( null );
		}
	}
	
	function onError() {
		removeSocketListeners();
		cb( "SOCKS5 negotiation socket error" );
	}
	
	function removeSocketListeners() {
		socket.removeAllListeners( Node.EVENT_STREAM_DATA );
		socket.removeAllListeners( Node.EVENT_STREAM_END );
		socket.removeAllListeners( Node.EVENT_STREAM_ERROR );
	}
}

#end
