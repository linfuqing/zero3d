package zerO.materials.particle
{
	import zerO.veiw.IViewport;
	import flash.display.BitmapData;

	public class ParticlesBitmapMaterial extends ParticleMaterial implements IParticleMaterial
	{
		public function ParticlesBitmapMaterial()
		{
			super();
		}
		
		public function get name():String
		{
			return null;
		}
		
		public function set name(n:String):void
		{
		}
		
		public function get color():uint
		{
			return 0;
		}
		
		public function get bitmapData():BitmapData
		{
			return null;
		}
		
		public function doDraw(object:*, view:IViewport):Boolean
		{
			return false;
		}
		
		public function doInteractive(object:*, view:IViewport):void
		{
		}
		
		public function draw(object:*, view:IViewport):void
		{
		}
		
	}
}