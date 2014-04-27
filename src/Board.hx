package ;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
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
import format.SVG;

import admob.AD;

import flash.net.SharedObject;

import flash.events.AccelerometerEvent;
import flash.sensors.Accelerometer;


class Board extends Sprite {

	static var size = 107;
	static var pad = size + 14;
	static var offset = 15;

	var highScore : SharedObject;

	var space:Space;
	var pieces:List<Piece>;
	var score = 0;
	var maxN = 0;
	var gameOver = false;

	var controlByMouse : Bool;

	var mouseStartX : Float;
	var mouseStartY : Float;
	var mouseActive : Bool;

	var prevX : Float;
	var prevY : Float;
	var prevZ : Float;
	var shakeCount : Int;


	var tiled : Bool;

	var scale : Float;

	public function new() {
		super();
		
		AD.init("ca-app-pub-6467747076945839/7051482776", AD.LEFT, AD.BOTTOM, AD.BANNER_LANDSCAPE, false);
		AD.show();

		scaleX = scaleY = Math.min(flash.Lib.current.stage.stageWidth/500, flash.Lib.current.stage.stageHeight/500);
		scale = scaleX;

		prevX = 0;
		prevY = 0;
		prevZ = 0;
		shakeCount = 0;

		highScore = SharedObject.getLocal("reloaded");
		trace(highScore.data.value);
		if (highScore.data.value == null) {

            highScore.data.value = 0;
        }

		controlByMouse = true;
		mouseActive = false;
		tiled = true;
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
		f(new Polygon(Polygon.rect(12, -500+12, 500, 500)));
		f(new Polygon(Polygon.rect(500-12, 12, 500, 500)));
		f(new Polygon(Polygon.rect(12, 500-12, 500, 500)));
		f(new Polygon(Polygon.rect(-500+12, 12, 500, 500)));
		wall.space = space;

		if(Math.abs(width-flash.Lib.current.stage.stageWidth) > Math.abs(height-flash.Lib.current.stage.stageHeight)){
			x = (flash.Lib.current.stage.stageWidth - width)/2;
		} else {
			y = (flash.Lib.current.stage.stageHeight - height)/2;
		}

		var sprite = new Sprite();
		var svg = new SVG(openfl.Assets.getText("assets/title.svg"));
		svg.render(sprite.graphics, 0,0, 88, 17);
		flash.Lib.current.addChild(sprite); 
		
		sprite.scaleX = Math.min(flash.Lib.current.stage.stageWidth/(312), y/(60));
		sprite.scaleY = sprite.scaleX;

		sprite.x = (flash.Lib.current.stage.stageWidth-sprite.width)/2-25;
		sprite.y = (y-sprite.height)/2;

		var acc = new Accelerometer();
		acc.addEventListener(AccelerometerEvent.UPDATE, onAccUpdate);

	}
	
	public function init() {
		addEventListener(Event.ENTER_FRAME, tick);

		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}
	
	public function destroy() {
		removeEventListener(Event.ENTER_FRAME, tick);

		stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}
	
	private function setGravity(x : Float,y : Float) {
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
	public function onAccUpdate(e : AccelerometerEvent){
		var xAcc = e.accelerationX;
		var yAcc = e.accelerationY;
		var zAcc = e.accelerationZ;

		if(!controlByMouse){
			if(Math.abs(xAcc)<0.15 && Math.abs(yAcc)<0.15 && !tiled){
			addRandom();
			}	
			setGravity(-xAcc*2,yAcc*2);
		}

		var bound = 0.5;
		if(Math.abs(prevX-xAcc) > bound && Math.abs(prevY-yAcc) > bound && Math.abs(prevZ-zAcc) > bound){
			shakeCount++;
			if(shakeCount>4){
				shakeCount=0;
				switchControl();
			}
		}

		prevX = xAcc;
		prevY = yAcc;
		prevZ = zAcc;

	}
	public function onMouseDown(e:MouseEvent) {
		mouseStartX = e.stageX;
		mouseStartY = e.stageY;

		mouseActive = true;
	}
	public function onMouseMove(e:MouseEvent) {
		if(controlByMouse){
			if(mouseActive){
				if(Math.abs(e.stageX-mouseStartX)>100){
					if(e.stageX > mouseStartX){
							setGravity(1,0); //right flick
						} else {
							setGravity(-1,0); //left flick
					}
				}
				else if(Math.abs(e.stageY-mouseStartY)>100){
					if(e.stageY > mouseStartY){
							setGravity(0,1); // down flick
						} else {
							setGravity(0,-1); //up flick
					}
				}
			}
		}
	}
	public function onMouseUp(e:MouseEvent) {
		if(gameOver){
			restart();
		}
		if(controlByMouse){
			turnOffGravity();
		}
		mouseActive = false;
		
	}
	function turnOffGravity() {
		if(!gameOver) {
			space.gravity.setxy(0, 0);
			addRandom();
		}
	}
	
	public function addRandom() {
		var margin = 25;
		var freePlaces = [];
		for (x in 0...4) {
			for ( y in 0...4) {
				var box = new AABB(offset + pad * x + margin, offset + pad * y + margin, size - margin * 2 , size - margin * 2);
				if (space.bodiesInAABB(box).empty()) {
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
	public function getText(string : String, fontSize : Int){
		var format = new TextFormat();
		format.font = Assets.getFont("fonts/ClearSans-Bold.ttf").fontName;
		
		format.size = fontSize;
		format.color = 0;
		


		var text = new TextField();
		text.defaultTextFormat = format;
		text.text = string;
		text.selectable = false;
		text.autoSize = TextFieldAutoSize.LEFT;
		text.embedFonts = true;
		
		return text;
	}
	private function endGame() {
		gameOver = true;
		
		highScore.data.value = Math.max(highScore.data.value, score);

		var over = new Sprite();
		over.graphics.beginFill(0xffffff, 0.5);
		over.graphics.drawRect(0, 0, width, height);
		over.graphics.endFill();
		var overText = getText("Game Over", 72);
		over.addChild(overText);
		overText.x = over.width / (2*scale) - overText.width/2;
		overText.y = ((over.height - overText.height) / (7*scale))*2;	
		addChild(over);

		var scoreText = getText("Score: " + Std.string(score), 48);
		scoreText.x = over.width / (2*scale) - scoreText.width/2;
		scoreText.y = ((over.height - scoreText.height) / (5*scale))*3;	
		addChild(scoreText);

		var highScoreText = getText("Highscore: " + Std.string(highScore.data.value), 48);
		highScoreText.x = over.width / (2*scale) - highScoreText.width/2;
		highScoreText.y = ((over.height - highScoreText.height) / (5*scale))*4;	
		addChild(highScoreText);		


	}
	private function switchControl(){

		controlByMouse = !controlByMouse;

	}
	public function tick(?_) {
		
		if (gameOver) {
			return;
		}
		
		space.step(1.0 / 30.0);
		
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
		score += Std.int(Math.pow(2,piece.n));
		if (piece.n > maxN) {
			maxN = piece.n;
		}
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
