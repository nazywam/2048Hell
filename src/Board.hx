package ;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import nape.geom.AABB;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.space.Space;
import nape.util.BitmapDebug;

class Board extends Sprite
{

	static var size = 107;
	static var pad = size + 14;
	static var offset = 15;
	
	var space:Space;
	var pieces:List<Piece>;
	
	public function new() {
		super();
		
		pieces = new List();
		space = new Space(new Vec2(0, 0));
		
		graphics.beginFill(0xbbada0);
		graphics.drawRoundRect(0, 0, 500, 500, 12, 12);
		graphics.endFill();
		
		for (x in 0...4) {
			for (y in 0...4) {
				graphics.beginFill(0xccc0b3);
				graphics.drawRoundRect(offset + pad * x, offset + pad * y, size, size, 6, 6);
				graphics.endFill();
			}
		}
		
		addRandom();

		var wall = new Body(BodyType.STATIC);
		var f = function(shape:Polygon) {
			shape.filter.collisionGroup = -1;
			shape.filter.collisionMask = -1;
			wall.shapes.add(shape);
		}	
		f(new Polygon(Polygon.rect( -500, -500+12, 1500, 500)));
		f(new Polygon(Polygon.rect( -500, 500-12, 1500, 500)));
		f(new Polygon(Polygon.rect(-500+12, -500, 500, 1500)));
		f(new Polygon(Polygon.rect(500 - 12, -500, 500, 1500)));
		wall.space = space;

	}
	
	public function init() {
		addEventListener(Event.ENTER_FRAME, tick);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	
	public function onKeyDown(e:KeyboardEvent) {
		var power = 800;
		switch(Std.int(e.keyCode)) {
			case 37:
				space.gravity.setxy(-power, 0);
			case 38:
				space.gravity.setxy(0, -power);
			case 39:
				space.gravity.setxy(power, 0);
			case 40:
				space.gravity.setxy(0, power);
			default:
				trace(e.keyCode);
		}
	}
	
	public function onKeyUp(e:KeyboardEvent) {
		space.gravity.setxy(0, 0);
		addRandom();
	}
	
	public function addRandom() {
		var freePlaces = [];
		for (x in 0...4) {
			for ( y in 0...4) {
				if (space.bodiesInAABB(new AABB(offset + pad * x, offset + pad * y, size, size)).empty()) {
					freePlaces.push(new Vec2(x, y));
				}
			}
		}
		if (freePlaces.length == 0) {
			
		} else {
			var place = freePlaces[Std.int(Math.random() * freePlaces.length)];
			var piece = addPiece(Std.int(place.x), Std.int(place.y), Math.random() > 0.9?2:1);
			piece.scaleDown();
		}
	}
	
	public function tick(?_) {
		space.step(1.0 / 60.0);
		
		for ( a in pieces ) {
			for ( b in pieces ) {
				if(!a.removed && !b.removed) {
					if ( a!= b && Vec2.distance(a.body.position, b.body.position) < 10.0) {
						combinePiece(a, b);
					}
				}
			}
		}
		for ( piece in pieces ) {
			piece.tick();
		}
	}
	
	public function removePiece(p:Piece) {
		p.removed = true;
		p.body.space = null;
		pieces.remove(p);
		removeChild(p);
	}
	
	public function combinePiece(a:Piece, b:Piece) {
		removePiece(a);
		removePiece(b);
		var piece = new Piece(a.n+1);
		piece.body.position.set(a.body.position.add(b.body.position).mul(0.5));
		piece.body.rotation = a.body.rotation;
		piece.body.space = space;
		pieces.add(piece);
		addChild(piece);
	}
	
	public function addPiece(x, y, n) {
		var piece = new Piece(n);
		piece.body.position.setxy( x * pad + offset + size/2, y * pad + offset + size/2);
		piece.body.space = space;
		pieces.add(piece);
		addChild(piece);
		return piece;
	}
}