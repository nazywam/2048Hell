package ;

import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.text.AntiAliasType;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import openfl.Assets;

class Piece extends Sprite {

	public var n:Int;
	public var body:Body;
	public var removed:Bool;
	
	private function min(a,b) {
		return a < b?a:b;
	}
	
	public function new(n) 
	{
		var colors = [0, 0xeee4da, 0xede0c8, 0xf2b179, 0xf59563, 0xf67c5f, 0xf65e3b, 0xedcf72, 0xedcc61, 0xedc850, 0xedc53f, 0xedc22e, 0x3c3a32];
		var fontColor = [0, 0x776e65, 0x776e65, 0xffffff];
		var fontSize = [0, 55, 55, 55, 55, 55, 55, 45, 45, 45, 35];
		var size = 107;
		
		super();
		this.n = n;
		graphics.beginFill(colors[min(n,colors.length-1)]);
		graphics.drawRoundRect(-size/2, -size/2, size, size, 6, 6);
		graphics.endFill();
		
		var format = new TextFormat();
		format.font = Assets.getFont("fonts/FreeSans.ttf").fontName;
		
		format.size = fontSize[min(n,fontSize.length-1)];
		format.color = fontColor[min(n,fontColor.length-1)];
		format.align = TextFormatAlign.CENTER;
		
		var text = new TextField();
		text.defaultTextFormat = format;
		text.text = Std.string(1 << n);
		text.selectable = false;
		text.autoSize = TextFieldAutoSize.LEFT;
		text.embedFonts = true;
		addChild(text);
		text.x = (width - text.width) / 2 - width/2;
		text.y = (height - text.height) / 2 - height/2;

		body = new Body(BodyType.DYNAMIC);
		var shape = new Polygon(Polygon.box(109, 109));
		shape.filter.collisionMask = (1 << n);
		shape.filter.collisionGroup = ~ (1 << n);
		body.shapes.add(shape);		
	}
	
	public function scaleDown() {
		scaleX = 0.1;
		scaleY = 0.1;
	}
	
	public function tick() {
		if (scaleX < 1) {
			scaleX += 0.1;
			scaleY = scaleX;
		}
		x = body.position.x;
		y = body.position.y;
		rotation = 180 * body.rotation / Math.PI;
	}
	
}