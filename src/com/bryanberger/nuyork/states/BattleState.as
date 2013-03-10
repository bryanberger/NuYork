package com.bryanberger.nuyork.states
{
	import com.bryanberger.nuyork.core.Constants;
	import com.bryanberger.nuyork.core.MessageVO;
	import com.bryanberger.nuyork.network.P2PManager;
	import com.bryanberger.nuyork.objects.Robot;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import Box2D.Dynamics.Contacts.b2Contact;
	
	import citrus.core.CitrusEngine;
	import citrus.core.starling.StarlingState;
	import citrus.datastructures.PoolObject;
	import citrus.input.controllers.Keyboard;
	import citrus.input.controllers.starling.VirtualButton;
	import citrus.input.controllers.starling.VirtualJoystick;
	import citrus.math.MathVector;
	import citrus.objects.CitrusSprite;
	import citrus.objects.platformer.box2d.Crate;
	import citrus.objects.platformer.box2d.Hero;
	import citrus.objects.platformer.box2d.MovingPlatform;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.objects.platformer.box2d.Sensor;
	import citrus.physics.box2d.Box2D;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.view.starlingview.AnimationSequence;
	import citrus.view.starlingview.StarlingArt;
	import citrus.view.starlingview.StarlingCamera;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.filters.ColorMatrixFilter;
	import starling.utils.AssetManager;
	
	public class BattleState extends StarlingState
	{
		
		private var _ce:CitrusEngine;
		private var _user:Robot;
		private var _anims:Array = ["walk", "idle", "jump", "fire", "zjump_fire", "skid", "duck"];
		private var _assets:AssetManager;
		private var _camera:StarlingCamera;
		private var _w:int;
		private var _h:int;
		private var _deathSensor:Sensor;
		// private var _channelId:uint = int( Math.random() * (99999 - 1) + 1 );
		private var _pool:PoolObject;
		private var _prevX:Number = 0;
		private var _prevY:Number = 0;
		private var _elapsedTime:int = 0;
		private var _lastElapsedTime:int;
		private var _lastUpdateTime:int = 0;
		private var _previousPt:Point = new Point();
		private var _futurePt:Point = new Point();
		private var _interpPt:Point = new Point();
		private var _joystick:VirtualJoystick;
		private var _button:VirtualButton;
		
		// multiplayer
		private var _p2p:P2PManager;
		private var _opponent:Robot;
		
		//private var _otherUsers:Vector.<Hero>;
		public static var user:Robot;
		
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
			
			
//			var bitmap:Bitmap = new robot();
//			var texture:Texture = Texture.fromBitmap(bitmap);
//			var xml:XML = XML(new robot_xml());
//			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
			
			// listen fgor tap
			//this.addEventListener(TouchEvent.TOUCH, handleBeganTouch);

			setupLevel();
			setupMultiplayer();
			//setupUser();
			//setupUser(Constants.LEFT_SPAWN_COORDS);
			//setupInput();
		}
		
		
		
		private function setupInput():void
		{
			var keyboard:Keyboard = _ce.input.keyboard;
			keyboard.addKeyAction("left", Keyboard.LEFT, _user.inputChannel); 
			keyboard.addKeyAction("right", Keyboard.RIGHT, _user.inputChannel); 
			keyboard.addKeyAction("jump", Keyboard.UP, _user.inputChannel); 
			keyboard.addKeyAction("fire", Keyboard.SPACE, _user.inputChannel); 
			
		//	_ce.input.addAction( new InputAction('fire', new InputController('manualevents'), _user.inputChannel) );
			
			_joystick = new VirtualJoystick('joystick', {defaultChannel:_user.inputChannel});		
			
			_button = new VirtualButton('button', {defaultChannel:_user.inputChannel, x:(Constants.IPHONE_WIDTH - 100) - 8.});	
			_button.buttonAction = "fire";
			
//			joystick.addAxisAction("x", "left", -1, -0.3);
//			joystick.addAxisAction("x", "right", 0.3, 1);
//			//joystick.addAxisAction("y", "jump", -1, -0.3);
//			//joystick.addAxisAction("y", "down", 0.3, 1);
//			joystick.addAxisAction("y", "jump", -1, -0.8);
			
			
			//_ce.input.addAction(new InputAction(u
		}
		
		private function setupMultiplayer():void
		{
			//_users = new Vector.<Hero>();
			
			// we connect to Union Platform server test, 130ms latency (too bad for a physics game), but thanks Union for this cool/quick service.
			_p2p = new P2PManager();
			_p2p.connected.add( handleOnConnected );
			_p2p.newPlayerConnected.add( handleCreateNewPlayer );
			_p2p.movePlayer.add( handleMoveOpponent );
			//_p2p.message.add( handleNewMessage );
			//_p2p.addEventListener(StatusEvent.STATUS, handleP2PStatus);
			_p2p.connect();
		}
		
		private function setupLevel():void
		{
			
			// object pool
//			_pool = new PoolObject(Missile, 20, 5, true);
//			
//			for (var i:uint = 0; i < 5; ++i)
//				_pool.create({x:i * 40 + 60, view:"crate.png"});
//			
//			addPoolObject(_pool);
			
			
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
				x:(Constants.FULL_WIDTH >> 1)-100, endY:500, y:500, width:398, height:10, offsetY:-10, parallax:1.0, view: new Image(_assets.getTexture('bridge'))});
			add(bridge);
			
			// complex
			_deathSensor = new Sensor('deathSensor', {registration:'topLeft', x:810, y:1600, width:750});
			_deathSensor.onBeginContact.add(handleDeathSensorContact);
			add(_deathSensor);
			
			// boxes
			var box1:Crate = new Crate('box1', {registration: 'center', x:500, y:300, width:91, height:91, parallax:1.0, view: new Image(_assets.getTexture('box'))});
			var box2:Crate = new Crate('box2', {registration: 'center', x:500, y:400, width:91, height:91, parallax:1.0, view: new Image(_assets.getTexture('box'))});
			add(box1);
			add(box2);
			
			var cone1:Crate = new Crate('cone1', {registration: 'center', x:950, y:200, width:52, height:81, parallax:1.0, view: new Image(_assets.getTexture('cone'))});
			add(cone1);
			
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
				//_ce.state = new BattleState();
				
			}

		}

		
		private function handleOnConnected(numOfOpponents:int):void
		{
//			if(numOfOpponents == 0)
//			{
//				setupUser(Constants.LEFT_SPAWN_COORDS);
//			}
//			else
//			{
//				setupUser(Constants.RIGHT_SPAWN_COORDS);
//			}
		}
		
		private function setupUser(coords:Point):void
		{
			//			var params:Object = {x:coords.x, y:coords.y , offsetY:5, hurtVelocityX:12, hurtVelocityY:18, hurtDuration:500, 
			//				width:175, height:173, acceleration:1.3, maxVelocity:8, friction:0.95, jumpHeight:16};	
			
			var params:Object = Constants.USER_PARAMS;
			params.x = coords.x;
			params.y = coords.y;
			
			_user = new Robot("user", params);
			_user.view = new AnimationSequence(_assets.getTextureAtlas('robot'), _anims, "idle", 24, true);
			_user.inputChannel = _p2p.channelId;
			//_user.onMove.add( handleSendMove );
			add(_user);
			
			//_ce.input.keyboard.defaultChannel = _p2p.channelId;
			
			// create static user
			user = _user;
			
			StarlingArt.setLoopAnimations(_anims);
			
			_camera = view.camera as StarlingCamera;
			var bounds:Rectangle = new Rectangle(0, 0, Constants.FULL_WIDTH, Constants.FULL_HEIGHT);
			_camera.setUp(_user, new MathVector(Constants.IPHONE_WIDTH>>1, 0), bounds, new MathVector(0.9, 0));
		}
		
		private function setupOpponent(coords:Point, channelId:int):void
		{
			var params:Object = Constants.USER_PARAMS;
			params.x = coords.x;
			params.y = coords.y;
			params.inputChannel = int(channelId);
			
			// color filter
			var colorMatrixFilter:ColorMatrixFilter = new ColorMatrixFilter();
			colorMatrixFilter.invert();                // invert image
			colorMatrixFilter.adjustSaturation(-1);    // make image Grayscale
			colorMatrixFilter.adjustContrast(0.75);    // raise contrast
			colorMatrixFilter.adjustHue(1);            // change hue
			colorMatrixFilter.adjustBrightness(-0.25); // darken image
			
			_opponent = new Robot('opponent', params);
			_opponent.view = new AnimationSequence(_assets.getTextureAtlas('robot'), _anims, "idle", 24, true);
			AnimationSequence(_opponent.view).filter = colorMatrixFilter;
			
			add(_opponent);
		}
		
		private function handleCreateNewPlayer(msg:MessageVO):void
		{
			trace('new player connected');
			
			if(_user == null && _opponent == null)
			{
				// join time difference
				if(_p2p.joinTime > msg.joinTime)
				{
					setupUser(Constants.RIGHT_SPAWN_COORDS);
					setupOpponent(Constants.LEFT_SPAWN_COORDS, msg.channelId);
				}
				else
				{
					setupUser(Constants.LEFT_SPAWN_COORDS);
					setupOpponent(Constants.RIGHT_SPAWN_COORDS, msg.channelId);
				}
			}
			
			setupInput();
		}
		
		private function handleMoveOpponent(msg:MessageVO):void
		{
			if(_opponent)
			{
				_previousPt.x = _opponent.x;
				_previousPt.y = _opponent.y;
				
				_futurePt.x = msg.x;
				_futurePt.y = msg.y;
				//_opponent.y = msg.y;
				//_opponent.forceMoveRight();
//				var tween:Tween = new Tween(_opponent, 100, Transitions.EASE_IN_OUT);
//				tween.animate("x", msg.x);
//				tween.animate("y", msg.x);
//				Starling.juggler.add(tween);
				
				//Lite.to( _opponent, 60, {x: msg.x, y: msg.y} );
				//_opponent.x = msg.x;
				//_opponent.y = msg.y;
				
				
//				_previousPt = _futurePt;
//				
//				_futurePt = new Point(msg.x, msg.y);
//				
//				if(_previousPt == null)
//					_previousPt = new Point(_opponent.x, _opponent.y);
//				
//				// current point
//				//var interpPt:Point = interpolate(_previousPt, _futurePt, _lastUpdateTime);
//				
//				// interpolate between previous point and incoming pt
//				
//				// multipler of lastUpdateTime
//				_lastUpdateTime = _elapsedTime;
//				
//				//_opponent.x = interpPt.x;
//				//_opponent.y = interpPt.y;
			}
		}
		
//		private function handleSendMove():void
//		{
//			trace('signal move');
//			
//			if (_user) {
//				
//				// we prevent to send too much messages.
//				//if (_prevX != _user.x || _prevY != _user.y) {
//					
//					//trace('change coords', _elapsedTime);
//					_p2p.sendCoords(_user.x, _user.y);
//					
//					//_prevX = _user.x;
//				//	_prevY = _user.y;
//				//}
//			}
//			
//		}
		
//		private function handleBeganTouch(e:TouchEvent):void
//		{
//			var touch:Touch = e.getTouch(this, TouchPhase.BEGAN);
//			if (touch)
//			{
//				var localPos:Point = touch.getLocation(this);
//				trace("Touched object at position: " + localPos);
//				
//				//_ce.input.justDid('fire', _user.inputChannel);
//				//_user.shoot();
//			}
//		}
		
		override public function update(timeDelta:Number):void
		{
			
			super.update(timeDelta);
			
			_elapsedTime++;
			
			//if(_elapsedTime >= _lastElapsedTime+50)
			//{
				if(_elapsedTime == 2) // everyother frame update
				{
					if(_user != null)
					{
						// we prevent to send too much messages.
						if(_prevX != _user.x || _prevY != _user.y)
						{	
							_p2p.sendCoords(_user.x, _user.y);
							
							_prevX = _user.x;
							_prevY = _user.y;
						}
					}
					
					_elapsedTime = 0;
				}
				
			if(_opponent && _futurePt != null)
			{
				_interpPt = Point.interpolate(_previousPt, _futurePt, timeDelta);
				_opponent.x = _interpPt.x;
				_opponent.y = _interpPt.y;
				//TweenLite.to(_opponent, 30, {x:pt.x, y:pt.y});
			}
			
				
				
		//		_lastElapsedTime = _elapsedTime;				
		//	}
//			
//			
//			// move opp
//			if(_futurePt != null && _previousPt != null)
//			{
//				var interpPt:Point = Point.interpolate(_previousPt, _futurePt, (_elapsedTime - _lastUpdateTime) / 50);
//				trace((_elapsedTime - _lastUpdateTime) / 50);
//				_opponent.x = interpPt.x;
//				_opponent.y = interpPt.y;
//			}
			
			
			
//			if (_user && _user.velocity) {
//				
//				// we prevent to send too much messages.
//				if (_prevX != _user.x || _prevY != _user.y) {
//					
//					_p2p.sendCoords(_user.x, _user.y);
//						
//						_prevX = _user.x;
//						_prevY = _user.y;
//					}
//			}
			
			// update projectiles
//			for each (var poolObject:PoolObject in _pool)
//			poolObject.updatePhysics(timeDelta);
//			
//			if(_user && _opponent)
//			{
//				if(_user.shooting)
//				{
//					createUserProjectile();		
//				}
//				
//				if(_opponent.shooting)
//				{
//					//createOppProjectile();
//				}
//			}
		} // END UPDATE
		
//		private function createUserProjectile():void
//		{
//			_pool.create({
//				x:_user.x + _user.width * ((_user.inverted) ? -1 : 1) + 5,
//				y:_user.y
//			});
//			refreshPoolObjectArt(_pool);
//		}
//		
//		private function interpolate(pt1:Point, pt2:Point, f:Number):Point
//		{
//			if (f > 1.0) f = 1.0;
//			var x:Number = f * pt1.x + (1 - f) * pt2.x;
//			var y:Number = f * pt1.y + (1 - f) * pt2.y;
//			
//			return new Point(x, y);
//		}
		
		
		
	} // END CLASS
} // END PACKAGE