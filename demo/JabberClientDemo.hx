
import jabber.StreamSocketConnection;
import jabber.client.Stream;
import jabber.client.NonSASLAuthentication;
import jabber.client.Roster;



class JabberClientDemo {
	
	static var stream : Stream;
	static var roster : Roster;
	
	static function main() {
		
		jabber.util.XMPPDebug.redirectTraces();
		
		trace("JÄBA");
		
		#if JABBER_SOCKETBRIDGE
		trace( "Using JABBER_SOCKETBRIDGE" );
		jabber.SocketBridgeConnection.init( "f9bridge", init );
		#else
		init();
		#end
	}
	
	
	static function init() {
		//var cnx = new jabber.BOSHConnection( "127.0.0.1", 5222 );
		var cnx = new jabber.StreamSocketConnection( "127.0.0.1", 5222 );
		stream = new jabber.client.Stream( new jabber.JID( "tong@disktree" ), cnx, "1.0" );
		stream.onOpen = function(s) {
			trace("JABBER STREAM opened...");
			var auth = new NonSASLAuthentication( stream );
			
			/*
			if( stream.sasl.negotiated ) {
				loginSuccess( stream );
				return;
			}
			var auth = new jabber.client.SASLAuthentication(stream);
			//auth.handshake.registerMechanism( net.sasl.AnonymousMechanism.ID, net.sasl.AnonymousMechanism );
			auth.handshake.mechanisms.push( new net.sasl.AnonymousMechanism() );
			auth.handshake.mechanisms.push( new net.sasl.PlainMechanism() );
			auth.handshake.mechanisms.push( new net.sasl.MD5Mechanism() );
		*/
			auth.onSuccess = loginSuccess;
			auth.onFailed = function(s) { trace( "LOGIN FAILED" ); };
			auth.authenticate( "test", "norc" );
		};
		stream.onClose = function(s) { trace( "Stream to: "+s.jid.domain+" closed." ); } ;
		stream.onXMPP.addHandler( xmppTransferHandler );
		stream.open();
	}
	
	static function loginSuccess( s ) {
		//stream.sendData("<fuckyouup>23</fuckyouup>");
		
		//var ecaps = new jabber.EntityCapabilities( stream );
		
		var service = new jabber.ServiceDiscovery( stream );
		service.onInfo = function(info) {
			trace( "INFO RECIEVED");
			for( i in info.identities ) {
				trace("  IDENTITY "+i);
			}
			for( i in info.features ) {
				trace("  FEATURE "+i);
			}
		};
		service.discoverInfo("disktree");
		
		roster = new jabber.client.Roster( stream );
		roster.onAvailable = rosterAvailableHandler;
		roster.load();
		
		//var ml = new jabber.MessageListener( stream );
		/*
		var la = new jabber.LastActivityQuery( stream );
		la.onLoad = function(e) {
			if( e.error != null ) {
				trace("Last activity error "+e.error.name );
				return;
			}
			trace( "Last activity from"+e.from+" : "+e.seconds );
		}
		la.request("account@disktree/desktop");
		var lal = new jabber.LastActivityListener( stream, "norc" );
		*/
		
		/*
		var vcard = new jabber.client.VCardTemp( stream );
		vcard.onLoad = function(vc) {
			trace("VCARD LOADED");
		}
		vcard.load();
		#if neko
		var zlib = new jabber.util.ZLibCompression();
		var compression = new jabber.StreamCompression( s );
		compression.request( zlib );
		#end
		
		var service = new jabber.client.ServiceDiscovery(stream);
		service.onInfo = function( e ) {
		}
		service.discoverInfo("account@disktree");
		*/
	}
	
	static function rosterAvailableHandler( r : jabber.client.Roster ) {
		trace( "ROSTER AVAILABLE "+r.entries.length );
		for( e in r.entries ) {
			trace("#");
			trace( "ENTRY: "+ e );
			//trace( "ENTRY: "+ e.presence );
			/*
			roster.presence.show = "online";
			var chat = new jabber.Chat( stream, stream.jid.toString(), "account@disktree/desktop" );
			chat.onMessage = function(c) {
				trace("MSG: "+c.lastMessage.body );
			};
			chat.speak("rotz.i am online");
			*/
		}
		roster.presence.set();
	}
	
	static function rosterChangeHandler( e ) {
		trace(e.type);
	}
	
	static function xmppTransferHandler( e : jabber.event.XMPPEvent ) {
		trace( "\t" + ( if( e.incoming ) "<<< "+e.data else ">>> "+e.data )+"\n" );
	}
	
}
