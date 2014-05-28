
class App extends XMPPClient {
	
	var lastActivityListener : jabber.LastActivityListener;
	
	override function onLogin() {
	
		super.onLogin();
		
		lastActivityListener = new jabber.LastActivityListener( stream );
		new jabber.PresenceListener( stream, onPresence );
		stream.sendPresence();
		
	}
	
	override function onPresence( p : xmpp.Presence ) {
		var activity = new jabber.LastActivity( stream );
		activity.onLoad = function(e,secs) {
			trace( "Last activity of: "+e+": "+secs );
		};
		activity.onError = function(e){ trace(e); };
		activity.request( p.from );
	}
	
	/*
	function onTimer() {
		lastActivityListener.time++; // update own last activity time
	}
	*/

	static function main() {
		var creds = XMPPClient.readArguments();
		new App( creds.jid, creds.password, creds.ip, creds.http ).login();
	}

	
}
