package lattice
{
	public class LatticeMap3DExtension extends LatticeMap3D
	{
		public function LatticeMap3DExtension(latticeXShift:uint, latticeYShift:uint, latticeZShift:uint, mapWidth:Number, mapHeight:Number, mapLength:Number, x:Number=0, y:Number=0, z:Number=0)
		{
			super(latticeXShift, latticeYShift, latticeZShift, mapWidth, mapHeight, mapLength, x, y, z);
		}
		
		protected override function canSetup(object:LatticeObject, latticeIndex:uint):Boolean
		{
			if( !canSetup(object, latticeIndex) )
				return false;
			
			var y:uint = (latticeIndex >> _latticeXShift) & _latticeYMask;
			var lattice:Lattice;
			if(y > 0)
			{
				lattice = _latticeMap[latticeIndex - _latticeX];
				return lattice.parent && lattice.parent != object;
			}
			
			return true;
		}
	}
}