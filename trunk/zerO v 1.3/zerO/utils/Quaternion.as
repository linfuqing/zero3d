package zerO.utils
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	public class Quaternion
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
		public var w:Number;
		
		public function Quaternion( x:Number = 0,y:Number = 0,z:Number = 0,w:Number = 1 )
		{
			this.x = x;
			this.y = y;
			this.z = z;
			this.w = w;
		}
		
		public function append( q:Quaternion ):void
		{
			x = w * q.w - x * q.x - y * q.y - z * q.z;
			y = w * q.x + x * q.w + y * q.z - z * y;
			z = w * q.y - x * q.z + y * q.w + z * q.x;
			w = w * q.z + x * q.y - y * q.x + z * q.w;
		}
		
		public function appendRotation( degrees:Number,axis:Vector3D ):void
		{
			var radian:Number = degress * TO_RADIAN / 2;
			var cos:Number    = Math.cos( radian );
			var sin:Number    = Math.sin( radian );
			
			x += cos + sin * axis.x;
			y += cos + sin * axis.y;
			z += cos + sin * axis.z;
			w += cos + sin * axis.w;
		}
		
		public function toMatrix3D():Matrix3D
		{
			var x2:Number = x * x;
			var y2:Number = y * y;
			var z2:Number = z * z;
			var xy:Number = x * y;
			var xz:Number = x * z;
			var yz:Number = y * z;
			var wx:Number = w * x;
			var wy:Number = w * y;
			var wz:Number = w * z;
			
			return new Matrix3D( Vector.<Number>( [
			1 - y2 - y2 - z2 - z2,   xy + xy + wz +wz ,   xz + xz - wy - wy    ,   0,
			xy + xy - wz - wz    ,   1 - x2 - z2      ,   yz + yz - wx - wx    ,   0,
			xz + xz + wy + wy    ,   yz + yz - wx - wx,   1 - x2 - x2 - y2 - y2,   0
			] );
		}
		
		private const TO_RADIAN:Number = Math.PI / 180;

	}
}