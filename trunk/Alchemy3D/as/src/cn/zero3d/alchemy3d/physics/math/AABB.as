package cn.zero3d.alchemy3d.physics.math
{
	import flash.geom.Vector3D;

	public class AABB
	{
		public static function get aabb():AABB
		{
			return _aabb;
		}

		public function get max():Vector3D
		{
			return _max;
		}
		
		public function get min():Vector3D
		{
			return _min;
		}
		
		public function get center():Vector3D
		{
			if( isEmpty() )
				return null;
			
			_center = _center || new Vector3D();
			
			_center.x = (min.x + max.x) * 0.5;
			_center.y = (min.y + max.y) * 0.5;
			_center.z = (min.z + max.z) * 0.5;
			
			return _center;
		}
		
		public function AABB(max:Vector3D = null, min:Vector3D = null)
		{
			_max = max || new Vector3D();
			_min = min || new Vector3D();
		}
		
		public function isEmpty():Boolean
		{
			return min.x > max.x || min.y > max.y || min.z > max.z;
		}
		
		public function hit(aabb:AABB):Boolean
		{
			_aabb._max.x = Math.min(_max.x, aabb._max.x);
			_aabb._max.y = Math.min(_max.y, aabb._max.y);
			_aabb._max.z = Math.min(_max.z, aabb._max.z);
			
			_aabb._min.x = Math.max(_min.x, aabb._min.x);
			_aabb._min.y = Math.max(_min.y, aabb._min.y);
			_aabb._min.z = Math.max(_min.z, aabb._min.z);
			
			return !_aabb.isEmpty();
		}
		
		public function getDistanceTo(aabb:AABB):Number
		{
			return center.subtract(aabb.center).length;
		}
		
		public function addVector(v:Vector3D):void
		{
			_max = _max.add(v);
			_min = _min.add(v);
		}
		
		private static var _aabb:AABB = new AABB();
		
		private var _max:Vector3D;
		private var _min:Vector3D;
		
		private var _center:Vector3D;
	}
}