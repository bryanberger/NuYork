package com.bryanberger.nuyork.core
{
	public class EmbededAssets
	{
		/** ATTENTION: Naming conventions!
		 *  
		 *  - Classes for embedded IMAGES should have the exact same name as the file,
		 *    without extension. This is required so that references from XMLs (atlas, bitmap font)
		 *    won't break.
		 *    
		 *  - Atlas and Font XML files can have an arbitrary name, since they are never
		 *    referenced by file name.
		 * 
		 */
		
		// Texture Atlas		
		[Embed(source="/textures/robot.xml", mimeType="application/octet-stream")]
		public static const robot_xml:Class;
		
		[Embed(source="/textures/robot.atf", mimeType="application/octet-stream")]
		public static const robot:Class;
//		[Embed(source="/textures/robot.png")]
//		public static const robot:Class;
				
		// level layers
		[Embed(source="/textures/background.png")]
		public static const background:Class;
		
		[Embed(source="/textures/liberty_layer.png")]
		public static const liberty:Class;
		
		[Embed(source="/textures/water.png")]
		public static const water:Class;
		
		[Embed(source="/textures/structures.png")]
		public static const structures:Class;
		
		[Embed(source="/textures/foreground.png")]
		public static const foreground:Class;
		
		[Embed(source="/textures/junk_layer.png")]
		public static const junk:Class;
		
		[Embed(source="/textures/fog.png")]
		public static const fog:Class;
		
		[Embed(source="/textures/bridge.png")]
		public static const bridge:Class;
		
		[Embed(source="/textures/box.png")]
		public static const box:Class;
		
		[Embed(source="/textures/cone.png")]
		public static const cone:Class;
		
		// straight up bitmaps

		// Compressed textures		
		//		[Embed(source = "/textures/batesia.atf", mimeType="application/octet-stream")]
		//		public static const batesia:Class;
		
		// Bitmap Fonts		
		//		[Embed(source="/fonts/1x/desyrel.fnt", mimeType="application/octet-stream")]
		//		public static const desyrel_fnt:Class;
		//		
		//		[Embed(source = "/fonts/1x/desyrel.png")]
		//		public static const desyrel:Class;
		
		// Sounds		
		//		[Embed(source="/audio/wing_flap.mp3")]
		//		public static const wing_flap:Class;
	}
}