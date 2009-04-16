package zerO.materials.line
{
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.geom.Matrix;

	public class BitmapBrushwork implements IBrushwork
	{
		public var brushwork:LineBrushwork;
		
		public var bitmap:Bitmap;
		
		public var matrix:Matrix;
		
		public var repeat:Boolean;
		
		public var smooth:Boolean;
		
		public function BitmapBrushwork(
		bitmap:BitmapData, 
		matrix:Matrix = null, 
		repeat:Boolean = true, 
		smooth:Boolean = false,
		brushwork:IBrushwork = null )
		{
			this.bitmap = bitmap;
			this.matrix = matrix;
			this.repeat = smooth;
			this.smooth = smooth;
			this.brushwork = brushwork;
		}

		public function setLineStyle(graphics:Graphics):void
		{
			brushwork.setLineStyle( graphics );
			graphics.lineBitmapStyle( bitmap,matrix,repeat,smooth );
		}
		
	}
}