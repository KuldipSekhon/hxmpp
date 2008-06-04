package jabber;

// TODO TimeoutProcess

/**
	
*/
class PacketTimeout {
	
	public static var DEFAULT_TIMEOUT = 5;
	
	
	public var time(getTime,setTime) : Int;
	public var handlers : Array<IPacketCollector->Void>;
	public var collector : PacketCollector;
	
	var _time : Int;
	var active : Bool;
	//var current_time : Int;
	
	
	public function new( handlers : Array<IPacketCollector->Void>, ?time : Int ) {
		active = false;
		this.handlers = handlers;
		setTime( time ); 
	}
	
	
	function getTime() : Int { return _time; }
	function setTime( t : Null<Int> ) : Null<Int> {
		switch( t ) {
			case null	: _time = 0; 				 // no timeout	
			case 0 		: _time = DEFAULT_TIMEOUT;   // default timeout 
			default 	: _time = t; 			     // given timeout
		}
		if( _time == 0 ) {
			active = false;
		} else {
			start( _time );
		}
		return _time;	
	}
	
	
	/**
	*/
	public function start( t : Int ) {
		
	//	if( active ) stop(); // TODO TimeoutProcess
	
		active = true;
		_time = t;
		
		#if neko
		util.Delay.run( Std.int( _time ), timeoutHandler )();
			
		#else true
		haxe.Timer.delayed( timeoutHandler, _time * 1000 )();
			
		#end
	}
	
	/**
		Stops reporting timeout to handlers.
	*/
	public function stop() {
		active = false;
	}
	
	/**
		Force to report timeout and stop.
	*/
	public function forceTimeout() {
		reportTimeout();
		active = false;
	}
	
	
	function reportTimeout() {
		for( handle in handlers ) handle( collector );
	}
	
	function timeoutHandler() {
		if( active ) {
			reportTimeout();
			active = false;
		}
	}
}


/*
private class TimeoutProcess {
	
	public function new() {
	}
}
*/
