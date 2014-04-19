class Kongregate {

    var kongregate:Dynamic;

    public function new() {
        var parameters = flash.Lib.current.loaderInfo.parameters;
        var url:String;
        
        if (parameters.api_path == null) {
            url = "http://www.kongregate.com/flash/API_AS3_Local.swf";
		} else {
			url = parameters.api_path;
		}
        
        var request = new flash.net.URLRequest(url);             
        var loader = new flash.display.Loader();
    
		loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, onLoadComplete);
        loader.load(request);

        flash.Lib.current.addChild(loader);
    }

    function onLoadComplete(e: flash.events.Event) {
        try
        {
            kongregate = e.target.content;
            kongregate.services.connect();
        } catch(msg: Dynamic) {
			trace(msg);
        }
    }

    public function submitStat(name: String, stat: Float) {
        if(kongregate != null)
        {
            kongregate.stats.submit(name, stat);
        }
    }

}