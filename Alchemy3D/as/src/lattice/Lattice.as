package lattice
{
	public class Lattice
	{
		public var x:uint;
		public var y:uint;
		public var z:uint;
		public var parent:LatticeObject;
		
		public function Lattice(x:uint = 0, y:uint = 0, z:uint = 0)
		{
			this.x = x;
			this.y = y;
			this.z = z;
			
			init();
		}
		
		private function init():void
		{
			parent  = null;
		}
	}
}