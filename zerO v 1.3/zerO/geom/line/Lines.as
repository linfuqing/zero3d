package zerO.geom.line
{
	import zerO.particles.Particles;
	import zerO.utils.ArrayUtil;

	public class Lines extends Particles
	{
		/**
		 * 设置顶点集.
		 */
		public function set vertices( v:Array ):void
		{
			super.points = v;
		}
		
		/**
		 * 设置顶点集.
		 */
		public function get vertices():Array
		{
			return super.points;
		}
		
		public function set lines( l:Array ):void
		{
			renderList[ "lines" ] = l;
		}
		
		public function get lines():Array
		{
			return renderList[ "lines" ]; 
		}
		
		public function Lines(x:Number=0, y:Number=0, z:Number=0)
		{
			super(x, y, z);
			init();
		}
		
		private function init():void
		{
			renderList[ "lines" ] = new Array();
		}
		
		public function addLine( line:Line ):void
		{
			ArrayUtil.singlePush( line.vertexA,points );
			ArrayUtil.singlePush( line.vertexB,points );
			
			lines.push( line );
		}
	}
}