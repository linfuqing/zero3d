package zerO.materials.light
{
	import zerO.veiw.IViewport;
	import flash.display.BitmapData;
	import zerO.materials.TriangleMaterial;
	import zerO.geom.triangle.Triangle2D;
	import zerO.lights.Light;
	import zerO.materials.ITriangleMaterial;
	import flash.display.Graphics;

	public class FatMaterial extends TriangleMaterial implements ITriangleMaterial
	{
		public function FatMaterial()
		{
			super();
		}
		
		public function get color():uint
		{
			return 0;
		}
	
		public function get bitmapData():BitmapData
		{
			return null;
		}
		
		public function drawTriangle(triangle:Triangle2D, graphics:Graphics, light:Light):void
		{
			if( !light )
			{
				return;
			}
			
			var color:uint = light.getAdjustColor( triangle,light.color );
			
			var alpha:Number = color / 0xffffff * light.brightness;
			
			graphics.beginFill( color,alpha );
			graphics.drawPath( TriangleMaterial.triangleCommands,triangle.vertices );
			graphics.endFill();
		}
		
	}
}