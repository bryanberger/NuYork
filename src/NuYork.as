package
{
	import com.bryanberger.nuyork.core.EmbededAssets;
	import com.bryanberger.nuyork.states.BattleState;
	
	import flash.display.Bitmap;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import citrus.core.starling.StarlingCitrusEngine;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.utils.AssetManager;
	
	[SWF(width="1136", height="640", frameRate="60", backgroundColor="0xFFFFFF")]
	public class NuYork extends StarlingCitrusEngine
	{
		[Embed(source="/textures/loading.png")]
		public static const loadingScreen:Class;
		
		public static var assets:AssetManager;
		public static var w:int;
		public static var h:int;
		
		private var _loadingScreen:Bitmap;
		
		public function NuYork()
		{		
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.LEFT;
			
			this.addEventListener(flash.events.Event.ADDED_TO_STAGE, init);	
			Starling.multitouchEnabled = true;
		}
		
		private function init(e:flash.events.Event):void
		{
			this.removeEventListener(flash.events.Event.ADDED_TO_STAGE, init);
			
			setUpStarling(true);
			
			Starling.current.addEventListener(starling.events.Event.ROOT_CREATED, handleStarlingRootCreated);
			
			_loadingScreen = new loadingScreen()
			addChild(_loadingScreen);
			
			trace('hi', stage.stageWidth, stage.stageHeight);
		}
		
		private function handleStarlingRootCreated(e:starling.events.Event):void
		{
			assets = new AssetManager(1, false);
			assets.enqueue(EmbededAssets);
			assets.loadQueue(handleLoadProgress);
			
//			state = new BattleState();
			
		}
		
		private function handleLoadProgress(ratio:Number):void
		{
			trace("Loading assets, progress:", ratio);
			
			// load comp
			if (ratio == 1.0) {
				//start	
				state = new BattleState();
				removeChild(_loadingScreen);
			}
		}
		
	}
}