/*
 * Copyright (c) disktree.net
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

import xmpp.Message;

/**
	Listens/Reports (user) attention requests.
	
	XEP 224 - Attention: http://www.xmpp.org/extensions/xep-0224.html
*/
class AttentionListener {
	
	public dynamic function onCapture( m : Message ) {}
	
	public var stream(default,null) : Stream;
	
	var c : PacketCollector;
	
	public function new( stream : Stream, ?onCapture : Message->Void ) {
		
		if( !stream.features.add( xmpp.Attention.XMLNS ) )
			throw 'attention listener already added';

		this.stream = stream;
		this.onCapture = onCapture;
		
		c = stream.collectPacket( [new xmpp.filter.MessageFilter(chat)], handleRequest, true );
	}
	
	public function stop() {
		stream.removeCollector( c );
	}
	
	function handleRequest( m : Message ) {
		if( xmpp.Attention.isRequest(m) )
			onCapture( m );
	}

}
