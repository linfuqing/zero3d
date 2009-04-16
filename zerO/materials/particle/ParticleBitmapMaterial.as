package zerO.materials.particle
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	import zerO.particles.Particle2D;
	import zerO.veiw.IViewport;

	public class ParticleBitmapMaterial extends ParticleMaterial implements IParticleMaterial
	{
		public function get bitmap():BitmapData
		{
			return bitmapData;
		}
		
		public function get color():uint
		{
			return 0;
		}
		
		public function ParticleBitmapMaterial( bitmapData:BitmapData )
		{
			super();
			this.bitmapData = bitmapData;
		}
		
		override protected function drawParticle(particle2D:Particle2D, view:IViewport):void
		{
			var matrix:Matrix = new Matrix();
			matrix.scale( particle2D.point.scale,particle2D.point.scale );
			
			view.viewport.graphics.beginBitmapFill( bitmapData,matrix );
			view.viewport.graphics.drawRect( particle2D.point.x,particle2D.point.y,
			bitmapData.width * particle2D.point.scale,bitmapData.height * particle2D.point.scale );
			view.viewport.graphics.endFill();
		}
		
		private var bitmapData:BitmapData;
		
	}
}