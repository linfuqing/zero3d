package zerO.materials.line
{
	import flash.display.Graphics;

	public class GradientBrushwork implements IBrushwork
	{
		public var brushwork:LineBrushwork;
		
		public var type:String;
		
		public var colors:Array;
		
		public var alphas:Array;
		
		public var ratios:Array;
		
		public var matrix:Matrix;
		
		public var spreadMethod:String;
		
		public var interpolationMethod:String;
		
		public var focalPointRatio:Number;
		
		public function GradientBrushwork(
		brushwork:LineBrushwork,
		type:String, 
		colors:Array, 
		alphas:Array, 
		ratios:Array, 
		matrix:Matrix = null, 
		spreadMethod:String = "pad", 
		interpolationMethod:String = "rgb", 
		focalPointRatio:Number = 0 )
		{
			this.brushwork = brushwork;
			this.type = type;
			this.colors = colors;
			this.alphas = alphas;
			this.ratios = ratios;
			this.matrix = matrix;
			this.spreadMethod = spreadMethod;
			this.interpolationMethod = interpolationMethod;
			this.focalPointRatio = focalPointRatio;
		}

		public function setLineStyle(graphics:Graphics):void
		{
			brushwork.setLineStyle( graphics );
			graphics.lineGradientStyle( type,colors,alphas,rotios,matrix,spreadMethod,interpolationMethod,focalPointRatio );
		}
		
	}
}