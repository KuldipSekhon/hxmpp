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
package jabber.jingle;

import jabber.jingle.io.WebRTCSDPOutput;
import xmpp.IQ;

/**
	Experimental!
	WebRTC SDP jingle session initiator.
	This implementation does NOT parse the jingle packet but attaches the transmitted SDP information directly to the processSignalingMessage method of the peerconnection.
	
	http://community.igniterealtime.org/docs/DOC-2273
*/
class WebRTCSDPCall extends OutgoingSession<WebRTCSDPOutput> {
	
	/** Callback if the peerconnection of the transport is ready to use */
	public dynamic function onPeerConnection( pc : PeerConnection ) {}
	
	public function new( stream : jabber.Stream, entity : String, contentName : String = "av" ) {
		super( stream, entity, contentName, xmpp.Jingle.XMLNS_WEBRTC );
	}
	
	public override function init() {
		trace("initinitinitinitinit");
		transport = transports[0]; //TODO
		//connectTransport();
		super.init();
		/*
		//var _init = super.init;
		transport.__onConnect = function(){
			trace("TRANSOPORT CONNECTED");
			_init();
		}
		transport.connect();
		*/
	}
	
	override function handleSessionInitResult() {
		trace("handleSessionInitResult");
		/*
		transport.__onConnect = handleTransportConnect;
		transport.__onFail = handleTransportFail;
		transport.connect();
		onPeerConnection( transport.connection );
		*/
	}
	
	override function handleSessionInfo( x : Array<Xml> ) {
		//TODO check state
		var sdp = x[0].firstChild().nodeValue;
		transport.connection.processSignalingMessage( sdp );
	}
	
	override function processSessionPacket( iq : IQ, j : xmpp.Jingle ) {
		switch( j.action ) {
		case session_accept :
			stream.sendIQ( IQ.createResult(iq) );
			onInit();
		default:
			trace("TODO????????????????");
		}
	}
	
	
	override function handleTransportConnect() {
		trace('handleTransportConnect');
		var x = xmpp.XMLUtil.createElement( "webrtc", transport.sdp );
		x.set( "xmlns", xmpp.Jingle.XMLNS_WEBRTC );
		sendInfo( x );
	}
	
	
}
