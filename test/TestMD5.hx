
import jabber.util.MD5;

class TestMD5 extends TestCase {

	public function test() {
		
		var t = "";
	//	eq( "d41d8cd98f00b204e9800998ecf8427e", MD5.encode(t) );
		t = "The quick brown fox jumps over the lazy dog";
		eq( "9e107d9d372bb6826bd81d3542a419d6", MD5.encode(t) );
		t = "The quick brown fox jumps over the lazy cog";
		eq( "1055d3e698d289f2af8663725127bd4b", MD5.encode(t) );
		t = "disktree";
		eq( "514d26cfd4c8b8105a6e7cf64d5cce10", MD5.encode(t) );
		t = "514d26cfd4c8b8105a6e7cf64d5cce10";
		eq( "a5a67ee535bcf341f5600d82bf09dcb6", MD5.encode(t) );
		
		
		//TODO
		//two step..
		//manystep..
		
		//trace(  haxe.Timer.stamp()-ts );
		
	}
	
}
