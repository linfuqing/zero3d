package zerO.materials.line
{
	import flash.display.Graphics;
	import flash.display.Shader;
	import flash.geom.Matrix;

	public class ShaderBrushwork implements IBrushwork
	{
		public var shader:Shader;
		
		public var matrix:Matrix;
		
		public var brushwork:LineBrushwork;
		
		public function ShaderBrushwork(shader:Shader, matrix:Matrix = null,brushwork:LineBrushwork = null )
		{
			this.shader = shader;
			this.matrix = matrix;
			this.brushwork = brushwork;
		}

		public function setLineStyle(graphics:Graphics):void
		{
			brushwork.setLineStyle( graphics );
			graphics.lineShaderStyle( shader,matrix );
		}
		
	}
}