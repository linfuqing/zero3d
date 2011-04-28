package lattice
{
	import flash.geom.Point;
	import flash.geom.Vector3D;

	public class LatticeMap
	{
		public function LatticeMap(latticeXShift:uint, latticeYShift:uint, mapWidth:Number, mapHeight:Number, x:Number = 0, y:Number = 0)
		{
			_latticeXShift = latticeXShift;
			_latticeYShift = latticeYShift;
			
			//_latticeX    = latticeX;
			//_latticeY    = latticeY;
			
			_mapWidth    = mapWidth;
			_mapHeight   = mapHeight;
			
			_startX      = x;
			_startY      = y;
			
			init();
		}
		
		public function getPosition(output:Point, x:int, y:int, center:Boolean = false):void
		{
			output.x = x * _widthPerLattice  + _startX;
			output.y = y * _heightPerLattice + _startY;
			
			if(center)
			{
				output.x += _widthPerLattice  * 0.5;
				output.y += _heightPerLattice * 0.5;
			}
		}
		
		public function getObjectPosition(output:Point, object:LatticeObject, center:Boolean = false):void
		{
			if(!object.lattice.length)
			{
				getPosition(output, object.x, object.y, center);
				
				return;
			}

			getPosition(output, object.x, object.y, false);
			
			if(center)
			{
				var max:Point = new Point();
				var min:Point = new Point();
				var result:Point;

				var position:LatticePosition;
				
				position = object.lattice[object.lattice.length - 1];
				getPosition(max, position.x + object.x + 1, position.y + object.y + 1, false);
				
				position = object.lattice[0];
				getPosition(min, position.x + object.x, position.y + object.y, false);
				
				result = max.subtract(min);
				
				output.x += result.x * 0.5;
				output.y += result.y * 0.5;
			}
			
			return;
		}
		
		public function fillObject(object:LatticeObject, minSize:Vector3D, maxSize:Vector3D):void
		{
			var fromX:int = minSize.x / _widthPerLattice;
			var fromY:int = minSize.z / _heightPerLattice;
			var toX  :int = maxSize.x / _widthPerLattice;
			var toY  :int = maxSize.z / _widthPerLattice;
			
			for(var j:int = fromY; j <= toY; j ++)
				for(var i:int = fromX; i <= toX; i ++)
					object.lattice.push( new LatticePosition(i, j) );
		}
		
		public function moveTo(object:LatticeObject, x:Number, y:Number):Boolean
		{
			if( !isOnMap(x, y) )
				return false;
			
			var toX:uint = (x - _startX) / _widthPerLattice;
			var toY:uint = (y - _startY) / _heightPerLattice;
			
			if( canStand(object, toX, toY) )
			{
				move(object);
				
				stand(object, toX, toY);
				
				return true;
			}
			
			return false;
		}
		
		public function isOnMap(x:Number, y:Number):Boolean
		{
			if(x < _startX || y < _startY || x > _endX || y > _endY)
				return false;
			
			return true;
		}
		
		public function canStand(object:LatticeObject, x:uint, y:uint):Boolean
		{
			var length:uint = object.lattice.length;
			
			var position:LatticePosition;
			
			var currentX:int;
			var currentY:int;
			
			for(var i:uint = 0; i < length; i ++)
			{
				position = object.lattice[i];
				currentX = x + position.x;
				currentY = y + position.y;
				if( isValuableIndex(currentX, currentY) || !canSetup( object, getIndex(currentX, currentY) ) )
					return false;
			}
			
			return true;
		}
		
		protected function canSetup(object:LatticeObject, latticeIndex:uint):Boolean
		{
			return !_latticeMap[latticeIndex].parent || _latticeMap[latticeIndex].parent == object;
		}
		
		protected function setup(object:LatticeObject, latticeIndex:uint):void
		{	
			_latticeMap[latticeIndex].parent = object;
		}
		
		protected function uninstall(object:LatticeObject, latticeIndex:uint):void
		{
			_latticeMap[latticeIndex].parent = null;
		}
		
		protected function initLatticeMap():void
		{
			_latticeMap = new Vector.<Lattice>(_latticeXMask + (_latticeYMask << _latticeXShift) + 1, true);
			
			var index:uint = 0;
			
			for(var j:uint = 0; j < _latticeY; j ++)
				for(var i:uint = 0; i < _latticeX; i ++)
					_latticeMap[index ++] = new Lattice(i, j);
		}
		
//		protected function isValuableIndex(offset:int, position:uint):Boolean
//		{
//			var x:int;
//			var y:int;
//			
//			_tempPosition = _tempPosition ? _tempPosition : new Position;
//			
//			getPositionByIndex(_tempPosition, offset);
//			
//			x = _tempPosition.x;
//			y = _tempPosition.y;
//			
//			getPositionByIndex(_tempPosition, position);
//			
//			x += _tempPosition.x;
//			y += _tempPosition.y;
//			
//			return x >= 0 && x < _latticeX && y >= 0 && y < _latticeY;
//		}
		
		protected function isValuableIndex(x:int, y:int):Boolean
		{
			return x >= 0 && x < _latticeX && y >= 0 && y < _latticeY;
		}
		
//		protected function getPositionByIndex(output:Position, index:int):void
//		{
//			output.x = index                      & _latticeXMask;
//			output.y = (index >> _latticeXShift ) & _latticeYMask;
//			
//			if(index < 0)
//				output.invert();
//		}
		
		protected function getIndex(x:uint, y:uint):uint
		{
			return x + (y << _latticeXShift);
		}
		
		private function init():void
		{    
			_latticeX         = 1 << _latticeXShift;
			_latticeY         = 1 << _latticeYShift;
			
			_latticeXMask     = _latticeX - 1;
			_latticeYMask     = _latticeY - 1;
			
			_endX             = _startX + _mapWidth;
			_endY             = _startY + _mapHeight;
			
			_widthPerLattice  = _mapWidth  / _latticeX;
			_heightPerLattice = _mapHeight / _latticeY;
			
			initLatticeMap();
		}
		
		private function stand(object:LatticeObject, x:uint, y:uint):void
		{
			var length:uint = object.lattice.length;
			var position:LatticePosition;
				
			for(var i:uint = 0; i < length; i ++)
			{
				position = object.lattice[i];
				setup( object, getIndex(position.x + x, position.y + y) );
			}
			
			object.x = x;
			object.y = y;
		}
		
		private function move(object:LatticeObject):void
		{
			var length:uint = object.lattice.length;
			var source:uint = getIndex(object.x, object.y);
			
			var position:LatticePosition;
			var x:int;
			var y:int;
			
			for(var i:uint = 0; i < length; i ++)
			{
				position = object.lattice[i];
				
				x = object.x + position.x;
				y = object.y + position.y;
				if( isValuableIndex(x, y) )
					uninstall( object, getIndex(x, y) );
			}
		}
		
		protected var _latticeXShift:uint;
		protected var _latticeYShift:uint;
		
		protected var _mapWidth:Number;
		protected var _mapHeight:Number;

		protected var _startX:Number;
		protected var _startY:Number;
		
		protected var _endX:Number;
		protected var _endY:Number;
		
		protected var _latticeXMask:uint;
		protected var _latticeYMask:uint;
		
		protected var _latticeX:uint;
		protected var _latticeY:uint;
		
		protected var _widthPerLattice:Number;
		protected var _heightPerLattice:Number;
		
		protected var _latticeMap:Vector.<Lattice>;
	}
}