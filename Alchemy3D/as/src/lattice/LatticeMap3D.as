package lattice
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class LatticeMap3D extends LatticeMap
	{
		public function LatticeMap3D(
			latticeXShift:uint, 
			latticeYShift:uint, 
			latticeZShift:uint,
			mapWidth :Number, 
			mapHeight:Number, 
			mapLength:Number,
			x:Number = 0, 
			y:Number = 0, 
			z:Number = 0)
		{
			_latticeZShift = latticeZShift;
			_mapLength     = mapLength;
			_startZ        = z;
			
			init();
			
			super(latticeXShift, latticeYShift, mapWidth, mapHeight, x, y);
		}
		
		public function getPosition3D(output:Vector3D, x:int, y:int, z:int, center:Boolean = false):void
		{
			output.x = x * _widthPerLattice  + _startX;
			output.y = y * _heightPerLattice + _startY;
			output.z = z * _lengthPerLattice + _startZ;
			
			if(center)
			{
				output.x += _widthPerLattice  * 0.5;
				output.y += _heightPerLattice * 0.5;
				output.z += _lengthPerLattice * 0.5;
			}
		}
		
		public function getObjectPosition3D(output:Vector3D, object:LatticeObject, center:Boolean = false):void
		{
			if(!object.lattice.length)
			{
				getPosition3D(output, object.x, object.y, object.z, center);
				
				return;
			}
			
			getPosition3D(output, object.x, object.y, object.z, false);
			
			if(center)
			{
				var max:Vector3D = new Vector3D();
				var min:Vector3D = new Vector3D();
				var result:Vector3D;
				var position:LatticePosition;
				
				position = object.lattice[object.lattice.length - 1];
				getPosition3D(max, position.x + object.x + 1, position.y + object.y + 1, position.z + object.z + 1, false);
				
				position = object.lattice[0];
				getPosition3D(min, position.x + object.x, position.y + object.y, position.z + object.z, false);
				
				result = max.subtract(min);
				
				output.x -= result.x * 0.5;
				output.y -= result.y * 0.5;
				output.z -= result.z * 0.5;
			}
			
			return;
		}
		
		override public function fillObject(object:LatticeObject, minSize:Vector3D, maxSize:Vector3D):void
		{
			var fromX:int = minSize.x / _widthPerLattice;
			var fromY:int = minSize.y / _heightPerLattice;
			var fromZ:int = minSize.z / _lengthPerLattice;
			var toX  :int = maxSize.x / _widthPerLattice;
			var toY  :int = maxSize.y / _heightPerLattice;
			var toZ  :int = maxSize.z / _lengthPerLattice;
			
			if(toX * _widthPerLattice == maxSize.x)
				toX --;
			
			if(toY * _heightPerLattice == maxSize.y)
				toY --;
			
			if(toZ * _lengthPerLattice == maxSize.z)
				toZ --;
			
			for(var k:int = fromZ; k <= toZ; k ++)
				for(var j:int = fromY; j <= toY; j ++)
					for(var i:int = fromX; i <= toX; i ++)
						object.lattice.push( new LatticePosition(i, j, k) );
		}
		
		public function moveTo3D(object:LatticeObject, x:Number, y:Number, z:Number):Boolean
		{
			if( !isOnMap3D(x, y, z) )
				return false;
			
			var toX:uint = (x - _startX) / _widthPerLattice;
			var toY:uint = (y - _startY) / _heightPerLattice;
			var toZ:uint = (z - _startZ) / _lengthPerLattice;
			
			if( canStand3D(object, toX, toY, toZ) )
			{
				move(object);
				
				stand(object, toX, toY, toZ);
				
				return true;
			}
			
			return false;
		}
		
		public function rotateTo3D(object:LatticeObject, transform:Matrix3D):Boolean
		{
			var position:Vector3D = new Vector3D();
			var source:Vector3D = new Vector3D(object.x, object.y, object.z);
			var length:uint = object.lattice.length;
			var newPosition:Vector.<Vector3D> = new Vector.<Vector3D>(length, true);
			var latticePosition:LatticePosition;
			var i:uint;
			for(i = 0; i < length; i ++)
			{
				latticePosition = object.lattice[i];
				position.x = latticePosition.x;
				position.y = latticePosition.y;
				position.z = latticePosition.z;
				position = transform.deltaTransformVector(position);
				position = position.add(source);
				//position.x += 0.5;
				//position.y += 0.5;
				//position.z += 0.5;
				if( !isValuableIndex3D(position.x, position.y, position.z) || !canSetup( object, getIndex3D(position.x, position.y, position.z) ) )
					return false;
				
				newPosition[i] = position.subtract(source);
			}
			
			move(object);
			
			for(i = 0; i < length; i ++)
			{
				latticePosition   = object.lattice[i];
				position          = newPosition[i];
				latticePosition.x = position.x;
				latticePosition.y = position.y;
				latticePosition.z = position.z;
			}
			
			stand(object, object.x, object.y, object.z);
			
			return true;
		}
		
		public function isOnMap3D(x:Number, y:Number, z:Number):Boolean
		{
			if(x < _startX || y < _startY || z < _startZ || x > _endX || y > _endY || z > _endZ)
				return false;
			
			return true;
		}
		
		public function canStand3D(object:LatticeObject, x:uint, y:uint, z:uint):Boolean
		{
			var length:uint = object.lattice.length;
			var position:LatticePosition;
			var currentX:int;
			var currentY:int;
			var currentZ:int;
			
			for(var i:uint = 0; i < length; i ++)
			{
				position = object.lattice[i];
				currentX = x + position.x;
				currentY = y + position.y;
				currentZ = z + position.z;
				if( !isValuableIndex3D(currentX, currentY, currentZ) || !canSetup( object, getIndex3D(currentX, currentY, currentZ) ) )
					return false;
			}
			
			return true;
		}
		
		override protected function initLatticeMap():void
		{
			_latticeXYShift = _latticeXShift + _latticeYShift;
			//_totalLatticeCountXY = _latticeX * _latticeY;
			
			//_latticeMap = new Vector.<Lattice>(_totalLatticeCountXY * _latticeZ, true);
			_latticeMap = new Vector.<Lattice>(_latticeXMask + (_latticeYMask << _latticeXShift) + (_latticeZMask << _latticeXYShift) + 1, true);
			
			var index:uint = 0;
			
			for(var k:uint = 0; k < _latticeZ; k ++)
				for(var j:uint = 0; j < _latticeY; j ++)
					for(var i:uint = 0; i < _latticeX; i ++)
						_latticeMap[index ++] = new Lattice(i, j, k);
		}
		
		protected function isValuableIndex3D(x:int, y:int, z:int):Boolean
		{
			return x >= 0 && x < _latticeX && y >= 0 && y < _latticeY && z >= 0 && z < _latticeZ;
		}
		
//		protected function isValuableIndex3D(offset:int, position:uint):Boolean
//		{
//			//			if(offset > _totalLatticeCountXY)
//			//				offset %= _totalLatticeCountXY;
//			//			
//			//			if(position > _totalLatticeCountXY)
//			//				position %= _totalLatticeCountXY;
//			//			
//			//			return (offset + position) < _totalLatticeCountXY;
//			
//			var x:int;
//			var y:int;
//			var z:int;
//			
//			_tempPosition = _tempPosition ? _tempPosition : new Position;
//			
//			getPositionByIndex3D(_tempPosition, offset);
//			
//			x = _tempPosition.x;
//			y = _tempPosition.y;
//			z = _tempPosition.z;
//			
//			getPositionByIndex3D(_tempPosition, position);
//			
//			x += _tempPosition.x;
//			y += _tempPosition.y;
//			z += _tempPosition.z;
//			
//			return x >= 0 && x < _latticeX && y >= 0 && y < _latticeY && z >= 0 && z < _latticeZ;
//		}
		
//		protected function getPositionByIndex3D(output:Position, index:int):void
//		{
//			output.x = index                      & _latticeXMask;
//			output.y = (index >> _latticeXShift ) & _latticeYMask;
//			output.z = (index >> _latticeXYShift) & _latticeZMask;
//			
//			if(index < 0)
//				output.invert();
//		}
		
		protected function getIndex3D(x:uint, y:uint, z:uint):uint
		{
			return x + (y << _latticeXShift) + (z << _latticeXYShift);
		}
		
		private function init():void
		{
			_latticeZ = 1 << _latticeZShift;
			_latticeZMask = _latticeZ - 1;
			
			_endZ = _startZ + _mapLength;
			_lengthPerLattice = _mapLength / _latticeZ;
		}
		
		private function stand(object:LatticeObject, x:uint, y:uint, z:uint):void
		{
			var length:uint = object.lattice.length;
			var position:LatticePosition;
			
			for(var i:uint = 0; i < length; i ++)
			{
				position = object.lattice[i];
				setup( object, getIndex3D(position.x + x, position.y + y, position.z + z) );
			}
			
			object.x = x;
			object.y = y;
			object.z = z;
		}
		
		private function move(object:LatticeObject):void
		{
			var length:uint = object.lattice.length;
			var position:LatticePosition;
			var x:int;
			var y:int;
			var z:int;
			
			for(var i:uint = 0; i < length; i ++)
			{
				position = object.lattice[i];
				x = object.x + position.x;
				y = object.y + position.y;
				z = object.z + position.z;
				if( isValuableIndex3D(x, y, z) )
					uninstall( object, getIndex3D(x, y, z) );
			}
		}
		
		public function toString():String
		{
			var i:int;
			var j:int;
			var k:int;
			var info:String;
			var isEmpty:Boolean;
			
			info += "\nXY Plane: \n";
			for(j = _latticeY - 1; j >= 0; j --)
			{
				for(i = 0; i < _latticeX; i ++)
				{
					isEmpty = true;
					for(k = 0; k < _latticeZ; k ++)
					{
						if( _latticeMap[getIndex3D(i, j, k)].parent )
							isEmpty = false;
					}
					
					info += isEmpty ? "0" : "1";
				}
				
				info += '\n';
			}
			
			info += "\nXZ Plane: \n";
			for(k = _latticeZ - 1; k >= 0; k --)
			{
				for(i = 0; i < _latticeX; i ++)
				{
					isEmpty = true;
					for(j = 0; j < _latticeY; j ++)
					{
						if( _latticeMap[getIndex3D(i, j, k)].parent )
							isEmpty = false;
					}
					
					info += isEmpty ? "0" : "1";
				}
				
				info += '\n';
			}
			
			info += "\nYZ Plane: \n";
			for(j = _latticeY - 1; j >= 0; j --)
			{
				for(k = 0; k < _latticeZ; k ++)
				{
					isEmpty = true;
					for(i = 0; i < _latticeX; i ++)
					{
						if( _latticeMap[getIndex3D(i, j, k)].parent )
							isEmpty = false;
					}
					
					info += isEmpty ? "0" : "1";
				}
				
				info += '\n';
			}
			
			return info;
		}
		
		protected var _latticeZShift:uint;
		protected var _mapLength:Number;
		protected var _startZ:Number;
		protected var _endZ:Number;
		
		protected var _latticeZMask:uint;
		protected var _latticeZ:uint;
		
		protected var _lengthPerLattice:Number;
		
		protected var _latticeXYShift:uint;
		
		//protected var _totalLatticeCountXY:uint;
	}
}