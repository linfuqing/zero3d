package zerO.geom.triangle
{
	import flash.geom.Point;
	
	import zerO.geom.points.Point2D;
	import zerO.utils.NameSetter;
	
	/**
	 * 2D三角形,也称三角形投影.
	 * 如果不打算开发zerO3d,可以不用管
	 * 即投影到视口上的三角形.
	 */
	public class Triangle2D extends NameSetter
	{
		/**
		 * 三角形2D点，点A.
		 */
		public var pointA:Point2D;
		
		/**
		 * 点B.
		 */
		public var pointB:Point2D;
		
		/**
		 * 点C.
		 */
		public var pointC:Point2D;

		/**
		 * 获取父级三角形.
		 */		
		public function get parent():Triangle
		{
			return _parent;
		}
		
		/**
		 * 获取深度.
		 * 视口贴近时做剔出判断使用.
		 */
		public function get depth():Number
		{
			return Math.min( pointA.depth,pointB.depth,pointC.depth );
		}
		
		/**
		 * 获取三角形Z坐标.
		 * 深度排序时使用.
		 */
		public function get z():Number
		{
			return ( pointA.depth + pointB.depth + pointC.depth ) / 3;
		}
		
		/**
		 * 获取最大X值,即三角形3个点的最大X值.
		 */
		public function get maxX():Number
		{
			return Math.max( pointA.x,pointB.x,pointC.x );
		}
		
		/**
		 * 获取最小X值.
		 */
		public function get minX():Number
		{
			return Math.min( pointA.x,pointB.x,pointC.x );
		}
		
		/**
		 * 获取最大Y值.
		 */
		public function get maxY():Number
		{
			return Math.max( pointA.y,pointB.y,pointC.y );
		}
		
		/**
		 * 获取最小Y值.
		 */
		public function get minY():Number
		{
			return Math.min( pointA.y,pointB.y,pointC.y );
		}
		
		/**
		 * 获取2维顶点集.
		 */
		public function get vertices():Vector.<Number>
		{
			return Vector.<Number>([pointA.x,pointA.y,pointB.x,pointB.y,pointC.x,pointC.y]);
		}
		
		/**
		 * 获取反向量,线框排线时使用.
		 */
		public function get NegateVertices():Vector.<Number>
		{
			return Vector.<Number>([pointB.x,pointB.y,pointA.x,pointA.y,pointC.x,pointC.y]);
		}
		
			
		/**
		 * 构建新的2D三角形.
		 * @param pointA 点A
		 * @param pointB 点B
		 * @param pointC 点C
		 * @param parent 父级三角形
		 */
		public function Triangle2D(
		pointA:Point2D,
		pointB:Point2D,
		pointC:Point2D,
		parent:Triangle = null )
		{
			this.pointA = pointA;
			this.pointB = pointB;
			this.pointC = pointC;
			
			_parent = parent;

		}
		
		/**
		 * 检测点是否在三角形上.
		 * @param point 检验的点.
		 * @return 是否在三角形上.
		 */
		public function hitTestPoint( point:Point ):Boolean
		{
			if( isOnSameSide( point,pointA,pointB,pointC ) ||
			isOnSameSide( point,pointB,pointC,pointA ) ||
			isOnSameSide( point,pointC,pointA,pointB ) )
			{
				return false;
			}
			
			return true;
		}
		
		/**
		 * 判断一个点是否在三角形顺时方向的的同一边.
		 * <p>
		 * 根据判断三角形逆方向同边公式( BA × PA ) * ( CA × PA）<=0.
		 * <p>
		 * 具体请参见:http://hi.baidu.com/actionscript3/blog/item/06b2e411f84230c0a6ef3f47.html
		 * 
		 * @param point  点P
		 * @param pointA 点A
		 * @param pointB 点B
		 * @param pointC 点C
		 * @return 点是否在三角形的同一边.
		 */
		static public function isOnSameSide( point:Point,pointA:Point,pointB:Point,pointC:Point ):Boolean
		{
			var ba:Point = pointA.subtract( pointB );
			var pa:Point = pointA.subtract( point );
			var ca:Point = pointA.subtract( pointC );
			
			return Point2D.crossProduct( ba,pa ) * Point2D.crossProduct( ca,pa ) > 0;
		}
		
		/**
		 * 是否背面.背面剔除时使用.
		 * @return 是否背面.
		 */
		public function isBackFace():Boolean
		{
			var ca:Point = pointC.subtract( pointA );
			
			var bc:Point = pointB.subtract( pointC );
			
			return ca.x * bc.y > ca.y * bc.x;
		}
		
		/**
		 * 父级三角形.
		 */
		private var _parent:Triangle
		
	}
}