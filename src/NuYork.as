package
{
	import com.bryanberger.nuyork.core.EmbededAssets;
	import com.bryanberger.nuyork.states.BattleState;
	
	import flash.display.Bitmap;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import citrus.core.starling.StarlingCitrusEngine;
	
	import starling.core.Starling;
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
			this.stage.quality = StageQuality.LOW;
			
			this.addEventListener(flash.events.Event.ADDED_TO_STAGE, init);	
			Starling.multitouchEnabled = true;
		}
		
		private function init(e:flash.events.Event):void
		{
			this.removeEventListener(flash.events.Event.ADDED_TO_STAGE, init);
			
			setUpStarling(false, 0);
			
			this.starling.addEventListener(starling.events.Event.ROOT_CREATED, handleStarlingRootCreated);
			
			_loadingScreen = new loadingScreen()
			addChild(_loadingScreen);
			
			trace('hi', stage.stageWidth, stage.stageHeight);
		}
		
		private function handleStarlingRootCreated(e:starling.events.Event):void
		{
			this.starling.removeEventListener(starling.events.Event.ROOT_CREATED, handleStarlingRootCreated);			
			this.starling.simulateMultitouch = false;
			this.starling.showStats = true;
			
			assets = new AssetManager(1, false);
			assets.enqueue(EmbededAssets);
			assets.loadQueue(handleLoadProgress);
		}
		
		private function handleLoadProgress(ratio:Number):void
		{
			trace("Loading assets, progress:", ratio);
			
			// load comp
			if (ratio == 1.0) {
				//start	
				state = new BattleState();
				removeChild(_loadingScreen);
				_loadingScreen = null;
			}
		}
		
		
		/**
		 * Override for testing purposes only 
		 * @param e
		 * 
		 */		
		override protected function handleStageDeactivated(e:flash.events.Event):void
		{
			
		
		}
		
		/**
		 * Override for testing purposes only 
		 * @param e
		 * 
		 */			
		override protected function handleStageActivated(e:flash.events.Event):void
		{
			
		
		}
		
	}
}