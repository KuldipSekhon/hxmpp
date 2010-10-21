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
	Used to dispatch and track XMPP protocol errors.
*/
class XMPPError extends xmpp.Error {
	
	public var dispatcher(default,null) : Dynamic;
	public var from(default,null) : String;
	
	public function new( dispatcher : Dynamic, p : xmpp.Packet ) {
		var e = p.errors[0];
		#if JABBER_DEBUG
		if( e == null ) trace( "XMPP packet has no errors" );
		#end
		super( e.type, e.condition, e.code, e.text );
		this.dispatcher = dispatcher;
		this.from = p.from;
	}
	
	public function toString() : String {
		var t = "XMPPError[ "+from+", "+condition+", "+code;
		if( text != null ) t += ", "+text;
		return t += " ]";
	}
	
}
