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
package xmpp;

/**
	Standardization of ISO 8601 profiles and their lexical representation.<br/>
	<a href="http://xmpp.org/extensions/xep-0082.html">XMPP Date and Time Profiles</a>
*/
class DateTime {
	
	/**
		UTC date expression.
		CCYY-MM-DDThh:mm:ss[.sss]TZD
	*/								
	public static var EREG_DATE = ~/^([0-9]{4})-([0-9]{2})-([0-9]{2})(T([0-9]{2}):([0-9]{2}):([0-9]{2})(\.[0-9]{3})?(Z|(-[0-9]{2}:[0-9]{2}))?)?$/;
	
	/**
		UTC time expression.
		hh:mm:ss[.sss][TZD]
	*/
	public static var EREG_TIME = ~/^([0-9]{2}):([0-9]{2}):([0-9]{2})(\.[0-9]{3}Z?)?$/;
	
	public static inline function isValidDate( t : String ) : Bool {
		return EREG_DATE.match( t );
	}
	
	public static inline function isValidTime( t : String ) : Bool {
		return EREG_TIME.match( t );
	}
	
	/**
		Returns the current time as UTC formatted string
	*/
	public static inline function now( ?offset : Int ) : String {
		return fromDate( Date.now(), offset );
	}
	
	/**
		Returns a the given date as UTC formatted string
	*/
	public static inline function fromDate( d : Date, ?offset : Int ) : String {
		return utc( d.toString(), offset );
	}
	
	/**
		Returns a the given date as UTC formatted string
	*/
	public static inline function fromTime( t : Float, ?offset : Int ) : String {
		return utc( Date.fromTime( t ).toString(), offset );
	}
	
	/**
		Create a Date object from a UTC time string
	*/
	public static function toDate( utc : String, offset : Int = 0 ) : Date {
		var p = getParts( utc );
		return new Date( p[0], p[1], p[2], p[3], p[4], p[5] );
		//return new Date( p[0], p[1], p[2], p[3]+offset, p[4], p[5] );
	}
	
	/**   
		Formats a (regular) date string to a XMPP compatible UTC date string (CCYY-MM-DDThh:mm:ss[.sss]TZD)<br/>
		For example: 2008-11-01 18:45:47 gets 2008-11-01T18:45:47Z<br/>
		Optionally a timezone offset could be attached.<br/>
	*/
	public static function utc( t : String, ?offset : Null<Int> ) : String {
		var k = t.split( " " );
		if( k.length == 1 )
			return t;
		#if (flash||php)
		var b = k[0]+"T"+k[1];
		if( offset == null )
			b += "Z";
		else {
			b += "-";
			if( offset > 9 )
				b += Std.string( offset );
			else {
				b += "0"+Std.string( offset );
			}
			b += ":00";
		}
		return b;
		#else
		var b = new StringBuf();
		b.add( k[0] );
		b.add( "T" );
		b.add( k[1] );
		if( offset == null )
			b.add( "Z" );
		else {
			b.add( "-" );
			if( offset > 9 )
				b.add( Std.string( offset ) );
			else {
				b.add( "0" );
				b.add( Std.string( offset ) );
			}
			b.add( ":00" );
		}
		return b.toString();
		#end
	}
	
	/**
		Return the parts of a UTC time string
		//TODO include tzo
	*/
	public static function getParts( utc : String ) : Array<Int> {
		var r = EREG_DATE;
		if( !r.match( utc ) )
			return null;
		var t = r.matched( 4 );
		t = t.substr( 1, t.length-2 );
		var time = t.split( ":" );
		return [ Std.parseInt( r.matched(1) ),
				 Std.parseInt( r.matched(2) ),
				 Std.parseInt( r.matched(3) ),
				 Std.parseInt( time[0] ),
				 Std.parseInt( time[1] ),
				 Std.parseInt( time[2] ) ];
	}
	
	/**
		Returns the given TZO as integer value
	*/
	public static function getTZOValue( tzo : String ) : Int {
		var h = Std.parseInt( tzo.substr( 1, 2 ) );
		//if( tzo.substr( 0, 1 ) == '+' ) h = -h;
		//return h;
		
		return if( tzo.substr( 0, 1 ) == '+' ) h else -h;
	}
	
}
