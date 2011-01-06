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

class Transport {
	
	public var __onFail : String->Void;
	public var __onConnect : Void->Void;
	public var __onDisconnect : Void->Void;
	
	function new() {}
	
	public function connect() {
		throw new jabber.error.AbstractError();
	}
	
	public function close() {
		throw new jabber.error.AbstractError();
	}
	
	public function init() {
		throw new jabber.error.AbstractError();
	}
	
	public function toXml() : Xml {
		return throw new jabber.error.AbstractError();
	}
	
}
