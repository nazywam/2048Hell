package ;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;

class Main extends Sprite {
	var inited:Bool;

	static var kongragate = new Kongregate();
	
	function resize(e) {
		if (!inited) init();
	}
	
	function init() {
		if (inited) return;
		inited = true;

		var board = new Board();
		addChild(board);
		board.init();
	}

	public function new() {
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) {
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		init();
	}
	
	public static function main() {
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}
