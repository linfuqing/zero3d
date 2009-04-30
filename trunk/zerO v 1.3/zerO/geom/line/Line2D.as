/**
 * Copyright 2009 (c) Lin Fuqing,zerO3D
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
**/

package zerO.geom.line
{
	import zerO.geom.points.Point2D;
	
	/**
	 * 2D线,也称线投影.
	 * 核心类,如果只使用zerO3d而不打算去开发可以不用管.
	 * 在渲染时候,它将作为3D线在视口上的投影.
	 */
	public class Line2D
	{
		public var pointA:Point2D;
		
		public var pointB:Point2D;
		
		public var curveTo:Point2D;
		
		/**
		 * 获取父级线.
		 */		
		public function get parent():Line
		{
			return _parent;
		}

		/**
		 * 获取z值，也称深度，排序时调用.
		 */
		public function get z():Number
		{
			return ( pointA.parent.z + pointB.parent.z ) / 2;
		}
		
		/**
		 * 获取深度，剔除时调用.
		 */
		public function get depth():Number
		{
			return Math.min( pointA.parent.z,pointB.parent.z );
		}
		
		public function get maxX():Number
		{
			return Math.max( pointA.parent.x,pointB.parent.x );
		}
		
		public function get minX():Number
		{
			return Math.min( pointA.parent.x,pointB.parent.x );
		}
		
		public function get maxY():Number
		{
			return Math.max( pointA.parent.y,pointB.parent.y );
		}
		
		public function get minY():Number
		{
			return Math.min( pointA.parent.y,pointB.parent.y );
		}
		
		/**
		 * 构建新的2D线.
		 * @param points 2D点集.
		 * @param parent 父级线.
		 */
		public function Line2D( pointA:Point2D,pointB:Point2D,parent:Line,curveTo:Point2D = null )
		{
			this.pointA = pointA;
			this.pointB = pointB;
			this.curveTo = curveTo;
			
			_parent = parent;
		}

		/**
		 * 父级线.
		 */
		private var _parent:Line;

	}
}