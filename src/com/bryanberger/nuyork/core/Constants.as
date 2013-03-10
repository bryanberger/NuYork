package com.bryanberger.nuyork.core
{
	import flash.geom.Point;

	public class Constants
	{
		public static const FULL_WIDTH:int = 1748;
		public static const FULL_HEIGHT:int = 800;
		
		public static const IPHONE_WIDTH:int = 1136;
		public static const IPHONE_HEIGHT:int = 640;
		
		public static const LEFT_SPAWN_COORDS:Point = new Point(100, 350);
		public static const RIGHT_SPAWN_COORDS:Point = new Point(1648, 350);
		
		public static const USER_PARAMS:Object =  { offsetY:5, hurtVelocityX:12, hurtVelocityY:18, hurtDuration:500, 
			width:175, height:173, acceleration:1.3, maxVelocity:8, friction:0.95, jumpHeight:19};	
	}
}