package lattice
{
	import flash.geom.Point;

	public class LatticeObject
	{
		public var x:uint;
		public var y:uint;
		public var z:uint;
		
		public var height:Number;
		
		public var parent:LatticeObject;
		
		public function get lattice():Vector.<LatticePosition>
		{
			return _lattice;
		}
		
		public function LatticeObject(x:uint = 0, y:uint = 0, z:uint = 0)
		{
			this.x = x;
			this.y = y;
			this.z = z;
			
			init();
		}
		
		private function init():void
		{
			_lattice = new Vector.<LatticePosition>();
		}
		
		private var _lattice:Vector.<LatticePosition>;
	}
}