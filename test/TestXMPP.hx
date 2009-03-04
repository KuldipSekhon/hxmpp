
import TestXMPPPacket;


class TestXMPP {
	
	static function main() {

		#if flash9
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
		
		var r = new haxe.unit.TestRunner();
		
		///// core packets
		r.add( new TestMessagePacket() );
		r.add( new TestPresencePacket() );
		r.add( new TestIQPacket() );
		r.add( new TestXMPPStreamError() );
		
		///// stuff
		r.add( new TestXMPPError() );
		r.add( new TestXMPPCompression() );
		r.add( new TestXMPPDate() );
		r.add( new TestXMPPXHTML() );
	//	r.add( new TestXMPPBind() );
		/////r.add( new TestXMPPSASL() );
		
		///// iq extension
		r.add( new TestXMPPAuth() );
		r.add( new TestXMPPCaps() );
		r.add( new TestXMPPChatState() );
		r.add( new TestXMPPDataForm() );
		r.add( new TestXMPPDelayedDelivery() );
		r.add( new TestXMPPDisco() );
	//	r.add( new TestXMPPEntityTime() );
		r.add( new TestXMPPLastActivity() );
		r.add( new TestXMPPMood() );
		r.add( new TestXMPPPrivacyLists() );
		r.add( new TestXMPPRegister() );
		r.add( new TestXMPPRoster() );
	//	r.add( new TestXMPPRPC() );
		r.add( new TestXMPPSoftwareVersion() );
		r.add( new TestXMPPSoftwareVersion() );
	
	//	r.add( new TestXMPPMUC() );
	//	r.add( new TestXMPPPubSub() );
	//	r.add( new TestXMPPJingle() );
	//	r.add( new TestXMPPFileTransfer() );
		
		///// packet filters
		r.add( new TestXMPPPacketFilters() );
		
		r.run();
	}
	
}
