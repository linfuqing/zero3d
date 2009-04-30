package zerO.materials
{
	import zerO.geom.Triangle;
	import zerO.veiw.Viewport3D;
	
	public class Material
	{
		public function Material()
		{
		}
		
		public function drawTriangle( triangle:Triangle,viewport:Viewport3D ):void
		{
			if( triangle.backFaceCulling && triangle.isBackFace( viewport.id ) ||
			 triangle.depth < - viewport.focus ||
			 triangle.minX( viewport.id ) > viewport.viewWidth ||
			 triangle.minY( viewport.id ) > viewport.viewHeight ||
			 triangle.maxX( viewport.id ) < 0 ||
			 triangle.maxY( viewport.id ) < 0 )
			{
				return;
			}
			draw( triangle,viewport );
		}
		
		protected function draw( triangle:Triangle,viewport:Viewport3D ):void
		{
			
		}

	}
}