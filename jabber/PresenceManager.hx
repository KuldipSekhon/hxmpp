/*
 * Copyright (c) 2012, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber;

//TODO remove

/**
	Presence handling wrapper.
*/
class PresenceManager {
	
	public var target : String;
	public var last(default,null) : xmpp.Presence;
	
	var stream : jabber.Stream;

	public function new( stream : jabber.Stream, ?target : String ) {
		this.stream = stream;
		this.target = target;
	}
	
	/**
	*/
	public function change( ?show : xmpp.PresenceShow, ?status : String, ?priority : Int, ?type : xmpp.PresenceType ) : xmpp.Presence {
		return set( new xmpp.Presence( show, status, priority, type ) );
	}
	
	/**
	*/
	public function set( ?p : xmpp.Presence ) : xmpp.Presence {
		this.last = if( p == null ) new xmpp.Presence() else p;
		if( target != null && last.to == null ) last.to = target;
		return stream.sendPacket( last );
	}
	
}
