package zerO.materials.line
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	
	import zerO.geom.line.Line2D;
	import zerO.materials.ILineMaterial;
	import zerO.utils.NameSetter;
	import zerO.veiw.IViewport;

	public class LineMaterial extends NameSetter implements ILineMaterial
	{
		static public function get DEFALUT_MATERIAL():LineMaterial
		{
			return new LineMaterial();
		}
		
		public var curveThroughPoint:Boolean;
		
		public function LineMaterial()
		{
			super();
		}

		public function get color():uint
		{
			return _color;
		}
		
		public function get bitmapData():BitmapData
		{
			return null;
		}
		
		public function doDraw( object:*,view:IViewport ):Boolean
		{
			var line:Line2D = object;
			
			if( line.depth < - view.focus ||
			line.maxX < view.bounds.x ||
			line.maxY < view.bounds.y ||
			line.minX > view.bounds.width ||
			line.minY > view.bounds.height )
			{
				return false;
			}
			
			return true;
		}
		
		public function doInteractive( object:*,view:IViewport ):void
		{
			
		}
		
		public function draw(object:*, view:IViewport):void
		{
			var line:Line2D = object;
			
			drawLine( line,view.viewport.graphics );
			
		}
		
		public function drawLine( line:Line2D,graphics:Graphics ):void
		{
			setLineStyle( graphics );
			
			graphics.moveTo( line.pointA.x,line.pointA.y );
			
			if( line.curveTo )
			{
				if( line.parent.curveThroughPoint || curveThroughPoint )
				{
					var x:Number = line.pointB.x + line.pointB.x - ( line.pointA.x + line.curveTo.x ) / 2;
					var y:Number = line.pointB.y + line.pointB.y - ( line.pointA.y + line.curveTo.y ) / 2
					graphics.curveTo( x,y,line.curveTo.x,line.curveTo.y );
				}
				else
				{
					graphics.curveTo( line.pointB.x,line.pointB.y,line.curveTo.x,line.curveTo.y );
				}
				
				return;
			}
			
			graphics.lineTo( line.pointB.x,line.pointB.x );
			
			graphics.lineStyle();
		}
		
		protected function setLineStyle( graphics:Graphics ):void
		{
			
		}
		
		private var _color:uint;
		
	}
}