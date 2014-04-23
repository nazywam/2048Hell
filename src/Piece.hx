package ;

import flash.display.Shape;
import flash.display.Sprite;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import openfl.Assets;
import format.SVG;


class Piece extends Sprite {

	public var n:Int;
	public var body:Body;
	public var removed:Bool;
	public var svg : SVG;


	private function min(a,b) {
		return a < b?a:b;
	}
	
	public function new(n) 
	{
		var size = 107;
		
		super();
		this.n = n;

		svg = new SVG(openfl.Assets.getText("assets/pieces/" + Std.string(Math.pow(2, n)) + ".svg"));
		svg.render(this.graphics, -size/2+3,-size/2+3,size,size);

		body = new Body(BodyType.DYNAMIC);
		var shape = new Polygon(Polygon.box(107, 107));
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
			if(scaleX>1){
				scaleX = 1;
				scaleY = 1;
			}
		}
		x = body.position.x;
		y = body.position.y;
		rotation = 180 * body.rotation / Math.PI;
	}
	
}