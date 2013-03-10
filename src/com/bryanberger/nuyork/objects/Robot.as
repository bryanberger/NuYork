package com.bryanberger.nuyork.objects
{
	import flash.utils.setTimeout;
	
	import Box2D.Common.Math.b2Vec2;
	
	import citrus.objects.platformer.box2d.Hero;
	
	import org.osflash.signals.Signal;
	
	public class Robot extends Hero
	{
		
		public var hp:int;
		public var shooting:Boolean;
		public var shootDelayDuration:uint = 300;
		public var onShoot:Signal;
		public var onMove:Signal;
		
		protected var _shootTimeoutID:Number;
		protected var _canShoot:Boolean;
		protected var _dead:Boolean;
		protected var _spaceBarDown:Boolean;

		
		public function Robot(name:String, params:Object=null)
		{
			super(name, params);
			
			onMove = new Signal();
			_playerMovingHero = false;
		}
		
		public function forceMoveRight():void
		{
			var velocity:b2Vec2 = _body.GetLinearVelocity();
			velocity.Add(getSlopeBasedMoveAngle());
			// moveKeyPressed = true;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			var velocity:b2Vec2 = _body.GetLinearVelocity();
//			if (_bodyDef.type == b2Body.b2_dynamicBody)
//			{
//				velocity.y += gravity;
//				_body.SetLinearVelocity(velocity);
//			}
			
			// DEAD
//			if(hp <= 0 && !_dead)
//			{
//				death();
//			}
//			
//			if(_dead && (velocity.y >= 0 && velocity.y <= 1 && !_onGround) )
//			{
//				_deathDown = true;
//			}
//			
//			if(_dead && _onGround)
//			{
//				_deathDown = false;
//			}
//			
//			if(_dead)
//				hp = 0;
			// END DEAD
			
			if (controlsEnabled)
			{
				var moveKeyPressed:Boolean = false;
				shooting = false;
							
				// JUMP
				if (_onGround && (_ce.input.justDid('jump', inputChannel)) )
				{
					velocity.y = -jumpHeight;
					onJump.dispatch();
				}
				
				// MOVE RIGHT
				if ( (_ce.input.isDoing('right', inputChannel)) )
				{
					velocity.Add(getSlopeBasedMoveAngle());
					moveKeyPressed = true;
					//_inverted = false;
				}
				
				// MOVE LEFT
				if ( (_ce.input.isDoing('left', inputChannel)) )
				{
					velocity.Subtract(getSlopeBasedMoveAngle());
					moveKeyPressed = true;
					//_inverted = true;
				}
				
				//If player just started moving the hero this tick.
				if (moveKeyPressed && !_playerMovingHero)
				{
//					trace('move key pressed');
//					
//					onMove.dispatch();
					_playerMovingHero = true;
					_fixture.SetFriction(0); //Take away friction so he can accelerate.
				}
					//Player just stopped moving the hero this tick.
				else if (!moveKeyPressed && _playerMovingHero)
				{
					_playerMovingHero = false;
					_fixture.SetFriction(_friction); //Add friction so that he stops running
				}
				
				//SHOOT
				if ( (_ce.input.isDoing('fire', inputChannel)) )
				{
					if(_onGround)
						velocity.x = 0;
					
					_spaceBarDown = true;
					
					shoot();
					// onShoot.dispatch();
				}
				else
				{
					_spaceBarDown = false;
					shooting = false;
				}
				
				if (_springOffEnemy != -1)
				{
					if ( (_ce.input.isDoing('jump', inputChannel)) )
						velocity.y = -enemySpringJumpHeight;
					else
						velocity.y = -enemySpringHeight;
					_springOffEnemy = -1;
				}
				
				//Cap velocities
				if (velocity.x > (maxVelocity))
					velocity.x = maxVelocity;
				else if (velocity.x < (-maxVelocity))
					velocity.x = -maxVelocity;
				
				//update physics with new velocity
				//_body.SetLinearVelocity(velocity);
			}
			
			//if(!_stopAnimations)
				updateAnimation();
		}
		
		override protected function updateAnimation():void
		{
			var prevAnimation:String = _animation;			
			//var velocity:V2 = _body.GetLinearVelocity();
			var walkingSpeed:Number = getWalkingSpeed();
			
			if (_hurt)
			{
				_animation = "impact";
				//_ce.sound.playSound("impact", 1, 0);
			}
//			else if(_dead && !_deathDown && !_onGround)
//			{
//				_animation = "death_up";
//			}
//			else if(_dead && _deathDown)
//			{
//				_animation = "death_down";
//			}
//			else if(_dead && _onGround && !_deathDown)
//			{
//				_animation = "death";
//			}
			else if (!_onGround && !shooting)
			{
				_animation = "jump";
				
				if(walkingSpeed < -acceleration)
					_inverted = true;
				else if(walkingSpeed > acceleration)
					_inverted = false;
			}
			else if( (!_onGround && shooting) || (!_onGround && _spaceBarDown ) )
			{
				trace('jumpfire');
				_animation = "zjump_fire";
			}
			else if( (_onGround && shooting) || (_onGround && _spaceBarDown ) )
			{
				_animation = "fire";
			}
//			else if( _onGround && !_dead && _blastOff && !controlsEnabled )
//			{
//				_blastOff = false;
//				
//				_stopAnimations = true;
//				_animation = "blast_off";
//				_ce.sound.playSound("blast_off", 1, 0);
//				
//				
//				trace('blasting off');
//			}
			else
			{
				if(walkingSpeed < -acceleration)
				{
					_inverted = true;	
					_animation = "walk";
					
					//onMove.dispatch();
				}
				else if(walkingSpeed > acceleration)
				{
					_inverted = false;
					_animation = "walk";
					
					//onMove.dispatch();
				}
				else
				{
					_animation = "idle";
				}
			}
			
			if (prevAnimation != _animation)
			{
				onAnimationChange.dispatch();
			}			
		}
		
		public function shoot():void
		{
			if(_canShoot)
			{
				shooting = true;
				_canShoot = false;
				_shootTimeoutID = setTimeout(endShootDelay, shootDelayDuration);
				
				onShoot.dispatch();
			}
		}
		
		protected function endShootDelay():void
		{
			shooting = false;
			_canShoot = true;
		}
		
	}
}