package com.bryanberger.nuyork.core
{
	import citrus.view.starlingview.AnimationSequence;
	
	import starling.textures.TextureAtlas;
	
	public class LoopAnimationSequence extends AnimationSequence
	{
		public function LoopAnimationSequence(textureAtlas:TextureAtlas, animations:Array, firstAnimation:String, animFps:Number=30, firstAnimLoop:Boolean=false, smoothing:String="bilinear")
		{
			super(textureAtlas, animations, firstAnimation, animFps, firstAnimLoop, smoothing);
		}
	}
}