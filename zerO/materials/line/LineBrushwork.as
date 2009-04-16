package zerO.materials.line
{
	import flash.display.Graphics;
	
	public class LineBrushwork implements IBrushwork
	{
		/**
		 * 请参考flash.display.Graphics.lineStype方法.
		 */
		public var thickness:Number;
		
		public var color:uint;
		
		/**
		 * 请参考flash.display.Graphics.lineStype方法.
		 */
		public var alpha:Number;
		
		/**
		 * 请参考flash.display.Graphics.lineStype方法.
		 */
		public var pixelHinting:Boolean;
		
		/**
		 * 请参考flash.display.Graphics.lineStype方法.
		 */
		public var scaleMode:String;
		
		/**
		 * 请参考flash.display.Graphics.lineStype方法.
		 */
		public var caps:String;
		
		/**
		 * 请参考flash.display.Graphics.lineStype方法.
		 */
		public var joints:String;
		
		/**
		 * 请参考flash.display.Graphics.lineStype方法.
		 */
		public var miterLimit:Number;

		public function LineBrushwork(
		thickness:Number = NaN,
		color:uint = 0, 
		alpha:Number = 1.0, 
		pixelHinting:Boolean = false, 
		scaleMode:String = "normal", 
		caps:String = null, 
		joints:String = null, 
		miterLimit:Number = 3 )
		{
			this.thickness = thickness;
			this.color = color;
			this.alpha = alpha;
			this.pixelHinting = pixelHinting;
			this.scaleMode = scaleMode;
			this.caps = caps;
			this.joints = joints;
			this.miterLimit = miterLimit;
		}

		public function setLineStyle(graphics:Graphics):void
		{
			graphics.lineStyle( 
			thickness,
			color,
			alpha,
			pixelHinting,
			scaleMode,
			caps,
			joints,
			miterLimit );
		}
		
	}
}