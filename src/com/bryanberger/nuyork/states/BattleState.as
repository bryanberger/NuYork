package com.bryanberger.nuyork.states
{
	import com.bryanberger.nuyork.core.Constants;
	import com.bryanberger.nuyork.network.P2PManager;
	
	import flash.events.StatusEvent;
	import flash.geom.Rectangle;
	
	import Box2D.Dynamics.Contacts.b2Contact;
	
	import citrus.core.CitrusEngine;
	import citrus.core.starling.StarlingState;
	import citrus.input.controllers.starling.VirtualJoystick;
	import citrus.math.MathVector;
	import citrus.objects.CitrusSprite;
	import citrus.objects.platformer.box2d.Hero;
	import citrus.objects.platformer.box2d.MovingPlatform;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.objects.platformer.box2d.Sensor;
	import citrus.physics.box2d.Box2D;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.view.starlingview.AnimationSequence;
	import citrus.view.starlingview.StarlingArt;
	import citrus.view.starlingview.StarlingCamera;
	
	import net.user1.reactor.Reactor;
	import net.user1.reactor.ReactorEvent;
	import net.user1.reactor.Room;
	import net.user1.reactor.RoomEvent;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.utils.AssetManager;
	
	public class BattleState extends StarlingState
	{
		
		private var _ce:CitrusEngine;
		private var _user:Hero;
		private var _anims:Array = ["walk", "idle", "jump", "jump_fire", "duck"];
		private var _assets:AssetManager;
		private var _camera:StarlingCamera;
		private var _w:int;
		private var _h:int;
		private var _deathSensor:Sensor;
		
		// multiplayer
		private var _p2p:P2PManager;
		private var _users:Vector.<Hero>;
		
		public function BattleState()
		{
			super();
		}
		
		override public function initialize():void {
			super.initialize();
			
			_ce = CitrusEngine.getInstance();
			_assets = NuYork.assets;
			
			_w = Starling.current.stage.stageWidth;
			_h = Starling.current.stage.stageHeight;
			initState();
		}
		
		
		private function initState():void
		{
			var box2D:Box2D = new Box2D("box2D");
			box2D.visible = true;
			add(box2D);
			
			//add(new Platform("bottom", {x:1748/2, y:800-100, width:1748}));
			
//			var bitmap:Bitmap = new robot();
//			var texture:Texture = Texture.fromBitmap(bitmap);
//			var xml:XML = XML(new robot_xml());
//			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
			
			/// load level here from XML
			addLevel();
			setupMultiplayer();
			
			var params:Object = { x:100, y:350, offsetY:5, hurtVelocityX:12, hurtVelocityY:18, hurtDuration:500, 
				width:67, height:83, acceleration:1.3, maxVelocity:6, friction:1, jumpHeight:16};	
			
			_user = new Hero("hero", params);
			_user.view = new AnimationSequence(_assets.getTextureAtlas('robot'), _anims, "idle", 24, true);;
			add(_user);
			
			StarlingArt.setLoopAnimations(_anims);
			
			// camera
			_camera = view.camera as StarlingCamera;
			var bounds:Rectangle = new Rectangle(0, 0, Constants.FULL_WIDTH, Constants.FULL_HEIGHT);
			_camera.setUp(_user, new MathVector(_w >> 1, 0), bounds, new MathVector(0.9, 0));
//			_camera.allowZoom = true;
//			_camera.setZoom(1.1);
			
			var joystick:VirtualJoystick = new VirtualJoystick('joystick');
			//view.camera.setUp(_user, new MathVector(480, 280), new Rectangle(0, 0, 1136, 640), new MathVector(0.5, 0));
		}
		
		private function setupMultiplayer():void
		{
			_users = new Vector.<Hero>();
			
			// we connect to Union Platform server test, 130ms latency (too bad for a physics game), but thanks Union for this cool/quick service.
			_p2p = new P2PManager();
			_p2p.addEventListener(StatusEvent.STATUS, handleP2PStatus);
			_p2p.connect();
		}
		
		private function addLevel():void
		{
			// level construct
			var bg:CitrusSprite = new CitrusSprite('background', {registration: 'topLeft', x:0, y:0, parallax:0.5, view: new Image(_assets.getTexture('background'))});
			add(bg);
			
			var liberty:CitrusSprite = new CitrusSprite('liberty', {registration: 'topLeft', x:0, y:0, parallax:0.65, view: new Image(_assets.getTexture('liberty'))});
			add(liberty);
			
			var structs:CitrusSprite =  new CitrusSprite('structures', {registration: 'topLeft', x:0, y:0, parallax:0.85, view: new Image(_assets.getTexture('structures'))});
			add(structs);
			
			var water:CitrusSprite =  new CitrusSprite('water', {registration: 'topLeft', x:0, y:0, parallax:0.75, view: new Image(_assets.getTexture('water'))});
			add(water);
			
			var fg:CitrusSprite =  new CitrusSprite('foreground', {registration: 'topLeft', x:0, y:0, parallax:1.0, view: new Image(_assets.getTexture('foreground'))});
			add(fg);
			
			var junk:CitrusSprite =  new CitrusSprite('junk', {registration: 'topLeft', x:0, y:0, parallax:1.0, view: new Image(_assets.getTexture('junk'))});
			add(junk);
			
			var fog:CitrusSprite =  new CitrusSprite('fog', {registration: 'topLeft', x:0, y:0, parallax:1.0, view: new Image(_assets.getTexture('fog'))});
			add(fog);
			
			// moving platforms
			var bridge:MovingPlatform = new MovingPlatform('bridge', {registration: 'center', speed:1.4, startX:(Constants.FULL_WIDTH >> 1)-200, endX:(Constants.FULL_WIDTH >> 1)+200, 
				x:(Constants.FULL_WIDTH >> 1)-100, endY:600, y:600, width:398, height:10, offsetY:-10, parallax:1.0, view: new Image(_assets.getTexture('bridge'))});
			add(bridge);
			
			// complex
			_deathSensor = new Sensor('deathSensor', {registration:'topLeft', x:810, y:1600, width:750});
			_deathSensor.onBeginContact.add(handleDeathSensorContact);
			add(_deathSensor);
			
			// add boundaries
			add(new Platform("left", {registration: 'topLeft', x:-10, y:Constants.FULL_HEIGHT>>1, width:20, height:Constants.FULL_HEIGHT}));
			add(new Platform("right", {registration: 'topLeft', x:Constants.FULL_WIDTH, y:Constants.FULL_HEIGHT>>1, width:20, height:Constants.FULL_HEIGHT}));
			add(new Platform("top", {registration: 'topLeft', x:Constants.FULL_HEIGHT, y:0, width:Constants.FULL_WIDTH}));
			
			add(new Platform("bottomLeft", {registration: 'topLeft', x:780/2, y:Constants.FULL_HEIGHT-40, width:800}));
			add(new Platform("bottomRight", {registration: 'topLeft', x:Constants.FULL_WIDTH-700/2, y:Constants.FULL_HEIGHT-40, width:700}));
		}
		
		private function handleDeathSensorContact(contact:b2Contact):void
		{
			trace('dead');
			
			if (Box2DUtils.CollisionGetOther(_deathSensor, contact) is Hero) {
				_ce.state = new BattleState();
			}

		}
		
		private function handleP2PStatus(e:StatusEvent):void
		{
			trace('p2p status', e);	
		}
		
		
		
	} // END CLASS
} // END PACKAGE