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
package jabber.client;

import jabber.sasl.Mechanism;
import jabber.util.Base64;
import xmpp.IQ;
import xmpp.filter.PacketNameFilter;

/**
	SASL client authentication.

	Responsible for:
		* Authenticating a client account using SASL
		* Binding the resource to the connection
		* Establishing a session with the server

	RFC3920-SASL http://xmpp.org/rfcs/rfc3920.html#sasl
	RFC3920-BIND http://xmpp.org/rfcs/rfc3920.html#bind
*/
class Authentication extends AuthenticationBase {
	
	/** Negotiation complete callback */
	public dynamic function onNegotiated() {}
	
	/** Clients mechanisms (in prefered order) */
	public var mechanisms(default,null) : Array<Mechanism>;
	
	/** Mechanisms offered by server */
	public var serverMechanisms(default,null) : Array<String>;
	
	/** Used mechanism */
	public var mechanism(default,null) : Mechanism;
	
	var streamOpenHandler : Void->Void;
	var c_challenge : PacketCollector;
	var c_fail : PacketCollector;
	var c_success : PacketCollector;
	
	public function new( stream : Stream, mechanisms : Iterable<Mechanism> ) {
	
		var x = stream.serverFeatures.get( "mechanisms" );
		if( x == null )
			throw "server does not support sasl";
		if( mechanisms == null || Lambda.count( mechanisms ) == 0 )
			throw "no sasl mechanisms specified";

		super( stream );
		this.serverMechanisms = xmpp.SASL.parseMechanisms( x );
		this.mechanisms = new Array();
		for( m in mechanisms ) this.mechanisms.push( m );
	}
	
	/**
		Inits authentication.
		Returns false if no supported mechanism got offered by the server.
	*/
	public override function start( password : String, ?resource : String ) : Bool {
		
		this.resource = resource;
		
		// Update jid resource
		if( stream.jid != null && resource != null )
			stream.jid.resource = resource;
		
		// Locate mechanism to use
		if( mechanism == null ) {
			for( smechs in serverMechanisms ) {
				for( m in mechanisms ) {
					if( m.id != smechs )
						continue;
					mechanism = m;
					break;
				}
				if( mechanism != null )
					break;
			}
		}
		if( mechanism == null ) {
			#if jabber_debug trace( 'no supported sasl mechanism found' ); #end
			return false;
		}

		c_fail = stream.collectPacket( [new PacketNameFilter( xmpp.SASL.EREG_FAILURE )], handleSASLFailed );
		c_success = stream.collectPacket( [new PacketNameFilter( ~/success/ )], handleSASLSuccess );
		c_challenge = stream.collectPacket( [new PacketNameFilter( ~/challenge/ )], handleSASLChallenge, true );
		
		// Start authentication
		var t = mechanism.createAuthenticationText( stream.jid.node, stream.jid.domain, password, stream.jid.resource );
		if( t != null ) t = Base64.encode( t );
		//return stream.send( xmpp.SASL.createAuth( mechanism.id, t ).toString() ) != null;
		return stream.send( xmpp.SASL.createAuth( mechanism.id, t ).toString() );
	}
	
	function handleSASLFailed( p : xmpp.Packet ) {
		removeCollectors();
		var info : String = null;
		var c = p.toXml().firstChild();
		if( c != null ) info = c.nodeName;
		onFail( info );
	}
	
	function handleSASLChallenge( p : xmpp.Packet ) {
		var c = p.toXml().firstChild().nodeValue;
		var r = Base64.encode( mechanism.createChallengeResponse( c ) );
		stream.send( xmpp.SASL.createResponse( r ).toString() );
	}
	
	function handleSASLSuccess( p : xmpp.Packet ) {
//		stream.cnx.reset(); // Clear connection buffer
		removeCollectors();
		streamOpenHandler = stream.onOpen; // Relay the stream open event
		stream.onOpen = handleStreamOpen;
		onNegotiated();
		//stream.version = false;
		//stream.cnx.reset();
		stream.open( null ); // Re-open stream
	}
	
	function handleStreamOpen() {
		stream.onOpen = streamOpenHandler;
		if( stream.serverFeatures.exists( "bind" ) ) {
			var iq = new IQ( IQType.set );
			iq.x = new xmpp.Bind( (mechanism.id == "ANONYMOUS") ? null : resource );
			stream.sendIQ( iq, handleBind );
		} else
			onSuccess();
	}
	
	function handleBind( iq : IQ ) {
		switch iq.type {
		case result :
			//onBind();
			var b = xmpp.Bind.parse( iq.x.toXml() );
			var p = jabber.JIDUtil.parts( b.jid );
			stream.jid.node = p[0];
			stream.jid.domain = p[1];
			stream.jid.resource = p[2];
			if( stream.serverFeatures.exists( "session" ) ) { // Init session
				var iq = new IQ( set );
				iq.x = new xmpp.PlainPacket( Xml.parse( '<session xmlns="urn:ietf:params:xml:ns:xmpp-session"/>' ).firstElement() );
				stream.sendIQ( iq, handleSession );
			} else {
				onSuccess();
			}
		case error :
			//trace(iq.errors);
			onFail( iq.errors[0].condition ); // TODO condition ?
//			onFail( new jabber.XMPPError( iq ) );
		default:
		}
	}
	
	function handleSession( iq : IQ ) {
		switch iq.type {
		case result:
			onSuccess();
		case error:
			onFail( iq.errors[0].condition ); // TODO condition ?
//			onFail( new jabber.XMPPError( iq ) );
		default:
		}
	}
	
	function removeCollectors() {
		stream.removeCollector( c_challenge );
		c_challenge = null;
		stream.removeCollector( c_fail );
		c_fail = null;
		stream.removeCollector( c_success );
		c_success = null;
	}
	
}
