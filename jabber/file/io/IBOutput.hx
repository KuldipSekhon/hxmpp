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
package jabber.file.io;

import haxe.io.Bytes;
import jabber.util.Base64;
import xmpp.IQ;

/**
	<a href="http://xmpp.org/extensions/xep-0047.html">XEP-0047: In-Band Bytestreams</a><br/>
	Outgoing inband data transfer.
*/
class IBOutput extends IBIO {
	
	public var __onComplete : Void->Void;
	
	var reciever : String;
	var input : haxe.io.Input;
	//var output : DataOutput;
	var filesize : Int;
	var bufsize : Int;
	var iq : IQ;
	
	public function new( stream : jabber.Stream, reciever : String, sid : String ) {
		super( stream, sid );
		this.reciever = reciever;
	}
	
	public function send( input : haxe.io.Input, filesize : Int, bufsize : Int ) {
		this.input = input;
		this.filesize = filesize;
		this.bufsize = bufsize;
		stream.collect( [cast new xmpp.filter.PacketFromFilter( reciever ),
						 cast new xmpp.filter.IQFilter( xmpp.file.IB.XMLNS, "close", xmpp.IQType.set )],
						handleIBClose );
		iq = new IQ( xmpp.IQType.set, null, reciever );
		bufpos = 0;
		sendNextPacket();
	}
	
	function handleIBClose( iq : IQ ) {
		if( active && bufpos == filesize ) {
			stream.sendPacket( IQ.createResult( iq ) );
			active = false;
			__onComplete();
		} else {
			stream.sendPacket( IQ.createError( iq, [new xmpp.Error( xmpp.ErrorType.cancel,
																	xmpp.ErrorCondition.BAD_REQUEST )] ) );
			__onFail( "invalid IB transfer" );
		}
	}
	
	function sendNextPacket() {
		iq.id = stream.nextID()+"_ib_"+seq;
		var remain = filesize-bufpos;
		var len = ( remain > bufsize ) ? bufsize : remain;
		var buf = Bytes.alloc( len );
		bufpos += input.readBytes( buf, 0, len );
		iq.properties = [xmpp.file.IB.createDataElement( sid, seq, Base64.encodeBytes( buf ) )];
		stream.sendIQ( iq, handleChunkResponse );
	}
	
	function handleChunkResponse( iq : IQ ) {
		switch( iq.type ) {
		case result :
			if( bufpos < filesize ) {
				seq++;
				sendNextPacket();
			} else {
				if( active ) {
					active = false;
					var iq = new IQ( xmpp.IQType.set, null, reciever );
					iq.x = new xmpp.file.IB( xmpp.file.IBType.close, sid );
					var me = this;
					stream.sendIQ( iq, function(r:xmpp.IQ) {
						switch( r.type ) {
						case result :
							me.__onComplete();
						case error :
							//TODO
							///me.__onFail();
						default : //
						}
					} );
				}
			}
		case error :
			__onFail( iq.errors[0].condition );
		default :
		}
	}
	
}
