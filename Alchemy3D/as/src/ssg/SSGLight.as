package ssg
{
	import flash.geom.Vector3D;
	import __AS3__.vec.Vector;
	
	public class SSGLight extends SSGNode
	{
		public function SSGLight()
		{
			super();
			color = new Vector.<Number>(4);
			color[0] = 1; color[1] = 1; color[2] = 1; color[3] = 1;
			intensity = 1;
			falloffstart = 10;
			falloffrange = 1;
		}
		
		public function ComputeLightingDistanceToNode ( node : SSGNode ) : void {
			
		}
		
		public var curlightingdistance : Number;
		 
		public var color : Vector.<Number>;
		public var intensity : Number;
		public var falloffstart : Number;
		public var falloffrange : Number;
		
	}
}