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

import xmpp.vcard.Address;
import xmpp.vcard.EMail;
import xmpp.vcard.Label;
import xmpp.vcard.Name;
import xmpp.vcard.Org;
import xmpp.vcard.Photo;
import xmpp.vcard.Tel;
import xmpp.vcard.Geo;

/**
	<a href="http://www.xmpp.org/extensions/xep-0054.html">XEP-0054: vcard-temp</a><br/>
	Partial implemented!
*/
class VCard {
	
	public static inline var NODENAME = "vCard";
	public static inline var XMLNS = "vcard-temp";
	public static inline var PRODID = "-//HandGen//NONSGML vGen v1.0//EN";
	public static inline var VERSION = "2.0";
	
	public var fn 			: String;
	public var n 			: Name;
	public var nickname 	: String;
	public var photo 		: Photo;
	public var birthday 	: String;
	public var addresses 	: Array<Address>;
	public var label 		: Label;
	public var line 		: String;
	public var tels			: Array<Tel>;
	public var email 		: EMail;
	//public var userid 		: String;
	public var jid 			: String;
	public var mailer 		: String;
	public var tz 			: String;
	public var geo 			: Geo<Float>;
	public var title 		: String;
	public var role 		: String;
	public var logo 		: Photo;
	//public var agent :
	public var org 			: Org;
	//public var categories
	public var note 		: String;
	public var prodid 		: String;
	//public var rev : String;
	//public var sortString : String;
	//public var sound : Sound;
	//public var phonetic : String;
	//public var uid : String;
	public var url 			: String;
	public var desc 		: String;
	//public var class : _Class;
	//public var key : Key;
	
	public function new() {
		addresses = new Array();
		tels = new Array();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( NODENAME );
		x.set( "xmlns", XMLNS );
		if( fn != null ) x.addChild( XMLUtil.createElement( "FN", fn ) );
		if( n != null ) {
			var _n = Xml.createElement( "N" );
			if( n.family != null ) _n.addChild( XMLUtil.createElement( "FAMILY", n.family ) );
			if( n.given != null ) _n.addChild( XMLUtil.createElement( "GIVEN", n.given ) );
			if( n.middle != null ) _n.addChild( XMLUtil.createElement( "MIDDLE", n.middle ) );
			if( n.prefix != null ) _n.addChild( XMLUtil.createElement( "PREFIX", n.prefix ) );
			if( n.suffix != null ) _n.addChild( XMLUtil.createElement( "SUFFIX", n.suffix ) );
			x.addChild( _n );
		}
		if( nickname != null ) x.addChild( XMLUtil.createElement( "NN", nickname ) );
		if( photo != null ) {
			var p = Xml.createElement( "PHOTO" );
			p.addChild( XMLUtil.createElement( "TYPE", photo.type ) );
			p.addChild( XMLUtil.createElement( "BINVAL", photo.binval ) );
			x.addChild( p );
		}
		if( birthday != null ) x.addChild( XMLUtil.createElement( "BDAY", birthday ) );
		for( address in addresses ) {
			var a = Xml.createElement( "ADR" );
			if( address.home != null )   a.addChild( XMLUtil.createElement( "HOME", address.home ) );
			if( address.work != null )   a.addChild( XMLUtil.createElement( "WORK", address.work ) );
			if( address.postal != null ) a.addChild( XMLUtil.createElement( "POSTAL", address.postal ) );
			if( address.parcel != null ) a.addChild( XMLUtil.createElement( "PARCEL", address.parcel ) );
			if( address.pref != null )   a.addChild( XMLUtil.createElement( "PREF", address.pref ) );
			if( address.pobox != null )  a.addChild( XMLUtil.createElement( "POBOX", address.pobox ) );
			if( address.extadd != null ) a.addChild( XMLUtil.createElement( "EXTADD", address.extadd ) );
			if( address.street != null ) a.addChild( XMLUtil.createElement( "STREET", address.street ) );
			if( address.locality!=null ) a.addChild( XMLUtil.createElement( "LOCALITY", address.locality ) );
			if( address.region != null ) a.addChild( XMLUtil.createElement( "REGION", address.region ) );
			if( address.pcode != null )  a.addChild( XMLUtil.createElement( "PCODE", address.pcode ) );
			if( address.ctry != null )   a.addChild( XMLUtil.createElement( "CTRY", address.ctry ) );
			x.addChild( a );
		}
		if( label != null ) {
			var l = Xml.createElement( "LABEL" );
			if( label.home != null ) l.addChild( XMLUtil.createElement( "HOME", label.home ) );
			if( label.work != null ) l.addChild( XMLUtil.createElement( "HOME", label.work ) );
			if( label.postal != null ) l.addChild( XMLUtil.createElement( "HOME", label.postal ) );
			if( label.parcel != null ) l.addChild( XMLUtil.createElement( "HOME", label.parcel ) );
			if( label.pref != null ) l.addChild( XMLUtil.createElement( "HOME", label.pref ) );
			if( label.line != null ) l.addChild( XMLUtil.createElement( "HOME", label.line ) );
			x.addChild( l );
		}
		if( line != null ) x.addChild( XMLUtil.createElement( "LINE", line ) );
		for( tel in tels ) {
			var t = Xml.createElement( "TEL" );
			if( tel.number != null ) t.addChild( XMLUtil.createElement( "NUMBER", tel.number ) );
			if( tel.home != null )   t.addChild( XMLUtil.createElement( "HOME", tel.home ) );
			if( tel.work != null )   t.addChild( XMLUtil.createElement( "WORK", tel.work ) );
			if( tel.voice != null )  t.addChild( XMLUtil.createElement( "VOICE", tel.voice ) );
			if( tel.fax != null )    t.addChild( XMLUtil.createElement( "FAX", tel.fax ) );
			if( tel.pager != null )  t.addChild( XMLUtil.createElement( "PAGER", tel.pager ) );
			if( tel.msg != null )    t.addChild( XMLUtil.createElement( "MSG", tel.msg ) );
			if( tel.cell != null )   t.addChild( XMLUtil.createElement( "CELL", tel.cell ) );
			if( tel.video != null )  t.addChild( XMLUtil.createElement( "VIDEO", tel.video ) );
			if( tel.bbs != null )    t.addChild( XMLUtil.createElement( "BBS", tel.bbs ) );
			if( tel.modem != null )  t.addChild( XMLUtil.createElement( "MODEM", tel.modem ) );
			if( tel.isdn != null )   t.addChild( XMLUtil.createElement( "ISDN", tel.isdn ) );
			if( tel.pcs != null )    t.addChild( XMLUtil.createElement( "PCS", tel.pcs ) );
			if( tel.pref != null )   t.addChild( XMLUtil.createElement( "PREF", tel.pref ) );
			x.addChild( t );
		}
		if( email != null ) {
			var e = Xml.createElement( "EMAIL" );
			if( email.home != null ) 	 e.addChild( XMLUtil.createElement( "HOME", email.home ) );
			if( email.work != null )     e.addChild( XMLUtil.createElement( "WORK", email.work ) );
			if( email.internet != null ) e.addChild( XMLUtil.createElement( "INTERNET", email.internet ) );
			if( email.pref != null )     e.addChild( XMLUtil.createElement( "PREF", email.pref ) );
			if( email.x400 != null ) 	 e.addChild( XMLUtil.createElement( "X400", email.x400 ) );
			if( email.userid != null )   e.addChild( XMLUtil.createElement( "USERID", email.userid ) );
			x.addChild( e );
		}
		if( jid != null ) x.addChild( XMLUtil.createElement( "JABBERID", jid ) );
		if( mailer != null ) x.addChild( XMLUtil.createElement( "MAILER", mailer ) );
		if( tz != null ) x.addChild( XMLUtil.createElement( "TZ", tz ) );
		if( geo != null ) {
			var g  = Xml.createElement( "GEO" );
			g.addChild( XMLUtil.createElement( "LAT", Std.string( geo.lat ) ) );
			g.addChild( XMLUtil.createElement( "LON", Std.string( geo.lon ) ) );
			x.addChild( g );
		}
		if( title != null ) x.addChild( XMLUtil.createElement( "TITLE", title ) );
		if( role != null ) x.addChild( XMLUtil.createElement( "ROLE", role ) );
		if( logo != null ) {
			var l = Xml.createElement( "LOGO" );
			l.addChild( XMLUtil.createElement( "TYPE", logo.type ) );
			l.addChild( XMLUtil.createElement( "BINVAL", logo.binval ) );
			x.addChild( l );
		}
		if( org != null ) {
			var o = Xml.createElement( "ORG" );
			if( org.orgname != null ) o.addChild( XMLUtil.createElement( "NAME", org.orgname ) );
			if( org.orgunit != null ) o.addChild( XMLUtil.createElement( "UNIT", org.orgunit ) );
			x.addChild( o );
		}
		if( note != null ) x.addChild( XMLUtil.createElement( "NOTE", note ) );
		if( prodid != null ) x.addChild( XMLUtil.createElement( "PRODID", prodid ) );
		if( url != null ) x.addChild( XMLUtil.createElement( "URL", url ) );
		if( desc != null ) x.addChild( XMLUtil.createElement( "DESC", desc ) );
		return x;
	}
	
	/*
	function addFieldXml( n : String, x : Xml ) {
		var v = Reflect.field( this, n );
		if( v != null ) x.addChild( XMLUtil.createElement( n.toUpperCase(), v ) );
	}
	*/
	
	/*
	function createTypedefXml<T>( name : String, e : T ) : Xml {
		var x = Xml.createElement( name );
		for( f in Reflect.fields( e ) ) {
			var v = Reflect.field( e, f );
			if( v != null ) {
				x.addChild( XMLUtil.createElement( f.toUpperCase(), v ) );
			}
		}
		return x;	
	}
	*/
	
	public static function parse( x : Xml ) : xmpp.VCard  {
		var vc = new xmpp.VCard();
		for( node in x.elements() ) {
			switch( node.nodeName ) {
				case "FN" : vc.fn = node.firstChild().nodeValue;
				case "N" :
					vc.n = { family:null, given:null, middle:null, prefix:null, suffix:null };
					for( n in node.elements() ) {
						var value : String = null;
						try {
							var fc = n.firstChild();
							if( vc != null ) value = n.firstChild().nodeValue; } catch( e : Dynamic ) {}
						if( value != null ) {
							switch( n.nodeName ) {
								case "FAMILY" : vc.n.family = value;
								case "GIVEN"  : vc.n.given = value;
								case "MIDDLE" : vc.n.middle = value;
								case "PREFIX" : vc.n.prefix = value;
								case "SUFFIX" : vc.n.suffix = value;
							}
						}
					}
				case "NICKNAME" : vc.nickname = node.firstChild().nodeValue;
				case "PHOTO" : vc.photo = parsePhoto( node );
				case "BDAY" : vc.birthday = node.firstChild().nodeValue;
				case "ADR" :
					var adr : Address = untyped {};
					for( n in node.elements() ) {
						var value : String = null;
						try {  value = n.firstChild().nodeValue; } catch( e : Dynamic ) {}
						if( value != null ) {
							switch( n.nodeName ) {
								case "HOME" :  adr.home = value;
								case "WORK" : adr.work = value;
								case "POSTAL" : adr.postal = value;
								case "PARCEL" : adr.parcel = value;
								//case "DOM/INTL" :
								case "PREF" : adr.pref = value;
								case "POBOX" : adr.pobox = value;
								case "EXTADD" : adr.extadd = value;
								case "STREET" : adr.street = value;
								case "LOCALITY" : adr.locality = value;
								case "REGION" : adr.region = value;
								case "PCODE" : adr.pcode = value;
								case "CTRY" : adr.ctry = value;
							}
						}
					}				
					vc.addresses.push( adr );
				case "LABEL" :
					//TODO
					
				case "LINE" : vc.line = node.firstChild().nodeValue;
				case "TEL" :
					var tel : Tel = untyped {};
					for( n in node.elements() ) {
						var value : String = null;
							try {  value = n.firstChild().nodeValue; } catch( e : Dynamic ) {}
							if( value != null ) {
								switch( n.nodeName ) {
									case "NUMBER" :  tel.number = value;
									case "HOME" :  tel.home = value;
									case "WORK" : tel.work = value;
									case "VOICE" :  tel.voice = value;
									case "FAX" : tel.fax = value;
									case "PAGER" :  tel.pager = value;
									case "MSG" : tel.msg = value;
									case "CELL" : tel.cell = value;
									case "VIDEO" : tel.video = value;
									case "BBS" : tel.bbs = value;
									case "MODEM" : tel.modem = value;
									case "ISDN" : tel.isdn = value;
									case "PCS" : tel.pcs = value;
									case "PREF" : tel.pref = value;
								}
							}
					}
					vc.tels.push( tel );
				case "EMAIL" :
					vc.email = untyped {};
					for( n in node.elements() ) {
						var value : String = null;
						try {  value = n.firstChild().nodeValue; } catch( e : Dynamic ) {}
						if( value != null ) {
							switch( n.nodeName ) {
								case "HOME" :  vc.email.home = value;
								case "WORK" : vc.email.work = value;
								case "INTERNET" : vc.email.internet = value;
								case "PREF" : vc.email.pref = value;
								case "X400" : vc.email.x400 = value;
								case "USERID" : vc.email.userid = value;
							}
						}
					}
				case "JABBERID" :  vc.jid = node.firstChild().nodeValue;
				case "MAILER" :  vc.mailer = node.firstChild().nodeValue;
				case "TZ" :  vc.tz = node.firstChild().nodeValue;
				case "GEO" :
					vc.geo = untyped {};
					for( n in node.elements() ) {
						var value : String = null;
						try { value = n.firstChild().nodeValue; } catch( e : Dynamic ) {}
						if( value == null ) throw "Invalid vcard tz";
						switch( n.nodeName ) {
							case "LAT" :  vc.geo.lat = Std.parseInt( value );
							case "LON" :  vc.geo.lon = Std.parseInt( value );
						}
					}
				case "TITLE" : vc.title = node.firstChild().nodeValue;
				case "ROLE" : vc.role = node.firstChild().nodeValue;
				case "LOGO" : vc.logo = parsePhoto( node );
				case "AGENT" :
					//TODO
					
				case "ORG" :
					vc.org = untyped {};
					for( n in node.elements() ) {
						var value : String = null;
						try {  value = n.firstChild().nodeValue; } catch( e : Dynamic ) {}
						if( value != null ) {
							switch( n.nodeName ) {
								case "ORGNAME" :  vc.org.orgname = value;
								case "ORGUNIT" :  vc.org.orgunit = value;
							}
						}
					}
				case "NOTE" : vc.note = node.firstChild().nodeValue;
				case "PRODID" : vc.prodid = node.firstChild().nodeValue;
				//.........
				case "URL" : vc.url = node.firstChild().nodeValue;
				case "DESC" : vc.desc = node.firstChild().nodeValue;
			}
		}
		return vc;
		/*
		var vc = new xmpp.VCard();
		for( node in x.elements() ) {
			switch( node.nodeName ) {
			case "FN" : vc.fn = node.firstChild().nodeValue;
			case "N" : reflectTypedef( vc.n = untyped {}, node );
			case "NICKNAME", "NN" : vc.nickname = node.firstChild().nodeValue;
			case "PHOTO" : reflectTypedef( vc.photo = untyped {}, node ); //vc.photo = parsePhoto( node );
			case "BDAY" : vc.birthday = node.firstChild().nodeValue;
			case "ADR" :
				var adr : Dynamic = {};
				reflectTypedef( adr, node );
				vc.addresses.push( adr );
			case "LABEL" :
				//TODO
			case "LINE" : vc.line = node.firstChild().nodeValue;
			//TODO
			case "TEL" :
				var tel : Dynamic = {};
				reflectTypedef( tel, node );
				vc.tels.push( tel );
			//TODO
			case "EMAIL" :
				reflectTypedef( untyped vc.email, node );
			case "JABBERID" :  vc.jid = node.firstChild().nodeValue;
			case "MAILER" :  vc.mailer = node.firstChild().nodeValue;
			case "TZ" :  vc.tz = node.firstChild().nodeValue;
			case "GEO" : reflectTypedef( vc.geo = untyped {}, node );
			case "TITLE" : vc.title = node.firstChild().nodeValue;
			case "ROLE" : vc.role = node.firstChild().nodeValue;
			case "LOGO" : //vc.logo = parsePhoto( node );
			//case "AGENT" :
			case "ORG" : reflectTypedef( vc.org = untyped {}, node );
			case "NOTE" : vc.note = node.firstChild().nodeValue;
			case "PRODID" : vc.prodid = node.firstChild().nodeValue;
			case "URL" : vc.url = node.firstChild().nodeValue;
			case "DESC" : vc.desc = node.firstChild().nodeValue;
			}
		}
		return vc;
		*/
	}
	
	/*
	static function reflectTypedef<T>( e : T, x : Xml ) : T {
		for( n in x.elements() ) {
			var v : String = null;
			try {
				var c = n.firstChild();
				if( c != null ) v = c.nodeValue;
			} catch( e : Dynamic ) {
				trace(e);
			}
			if( v != null ) {
				Reflect.setField( e, n.nodeName.toLowerCase(), v );
			}
		}
		return e;
	}
	*/
	
	static function parsePhoto( x : Xml ) : xmpp.vcard.Photo {
		var photo = untyped {};
		for( n in x.elements() ) {
			var value : String = null;
			try {  value = n.firstChild().nodeValue; } catch( e : Dynamic ) {}
			if( value != null ) {
				switch( n.nodeName ) {
					case "TYPE" : photo.type = value;
					case "BINVAL" : photo.binval = value;
				}
			}
		}
		return photo;
	}
	
}
