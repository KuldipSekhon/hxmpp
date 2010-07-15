/*
 *	This file is part of HXMPP.
 *	Copyright (c)2010 http://www.disktree.net
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

typedef ApplicationErrorCondition = {
	var condition : String;
	var xmlns : String;
}

/**
	Abstract base class for xmpp.Error and xmpp.StreamError
*/
class ErrorPacket {
	
	/** */
	public var condition : String;
	/** Describes the error in more detail */
	public var text : String;
	/** Language of the text content XML character data  */
	public var lang : String;
	/** Application-specific error condition */
	public var app : ApplicationErrorCondition;
	
	function new( condition : String,
				  ?text : String, ?lang : String, ?app : ApplicationErrorCondition) {
		this.condition = condition;
		this.text = text;
		this.lang = lang;
		this.app = app;
	}
	
	function _toXml( p : String, ns: String ) : Xml {
		var x = Xml.createElement( p );
		var c = Xml.createElement( condition );
		c.set( "xmlns", ns );
		x.addChild( c );
		if( text != null ) {
			var t = XMLUtil.createElement( "text", text );
			t.set( "xmlns", ns );
			if( lang != null ) t.set( "lang", lang );
			x.addChild( t );
		}
		if( app != null && app.condition != null && app.xmlns != null ) {
			var a = Xml.createElement( app.condition );
			a.set( "xmlns", app.xmlns );
			x.addChild( a );
		}
		return x;
	}
	
	static function parseInto( p : ErrorPacket, x : Xml, xmlns : String ) {
		for( e in x.elements() ) {
			var ns = e.get( "xmlns" );
			if( ns == null )
				continue;
			switch( e.nodeName ) {
			case "text" :
				if( ns == xmlns ) {
					p.text = e.firstChild().nodeValue;
					p.lang = e.get( "xml:lang" );
				}
			default :
				if( ns == xmlns )
					p.condition = e.nodeName;
				else
					p.app = { condition : e.nodeName, xmlns : ns };
			}
		}
	}
}
