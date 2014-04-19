package ;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import nape.geom.AABB;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.space.Space;
import nape.util.BitmapDebug;
import openfl.Assets;

class Board extends Sprite
{

	static var size = 107;
	static var pad = size + 14;
	static var offset = 15;
	
	var space:Space;
	var pieces:List<Piece>;
	var score = 0;
	var gameOver = false;

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
	
	public function destroy() {
		removeEventListener(Event.ENTER_FRAME, tick);
		stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	
	private function setGravity(x,y) {
		var power = 800;
		space.gravity.setxy(power*x, power*y);
	}
	
	private function restart() {
		if (gameOver) {
			var p = parent;
			destroy();
			p.removeChild(this);
			var board = new Board();
			p.addChild(board);
			board.init();
		}
	}
	
	public function onKeyDown(e:KeyboardEvent) {
		switch(Std.int(e.keyCode)) {
			case 37, 65:
				setGravity(-1,0);
			case 38, 87:
				setGravity(0,-1);
			case 39, 68:
				setGravity(1,0);
			case 40, 83:
				setGravity(0, 1);
			case 32, 82:
				restart();
			default:
				trace(e.keyCode);
		}
	}
	
	public function onKeyUp(e:KeyboardEvent) {
		switch(Std.int(e.keyCode)) {
			case 37, 65, 38, 87, 39, 68, 40, 83:
				turnOffGravity();
		}
	}
	
	function turnOffGravity() {
		if(!gameOver) {
			space.gravity.setxy(0, 0);
			addRandom();
		}
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
			endGame();
		} else {
			var place = freePlaces[Std.int(Math.random() * freePlaces.length)];
			var piece = addPiece(Std.int(place.x), Std.int(place.y), Math.random() > 0.9?2:1);
			piece.scaleDown();
		}
	}
	
	private function endGame() {
		gameOver = true;
		var format = new TextFormat();
		format.font = Assets.getFont("fonts/FreeSans.ttf").fontName;
		
		format.size = 48;
		format.color = 0;
		
		var sprite = new Sprite();
		sprite.graphics.beginFill(0xffffff, 0.25);
		sprite.graphics.drawRect(0, 0, width, height);
		sprite.graphics.endFill();
		
		var text = new TextField();
		text.defaultTextFormat = format;
		text.text = "Game Over!";
		text.selectable = false;
		text.autoSize = TextFieldAutoSize.LEFT;
		text.embedFonts = true;
		sprite.addChild(text);
		text.x = (sprite.width - text.width) / 2;
		text.y = (sprite.height - text.height) / 2;
		addChild(sprite);
	}
	
	public function tick(?_) {
		
		if (gameOver) {
			return;
		}
		
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
		score += piece.n;
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