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

package zerO.geom.points
{
	import flash.geom.Point;
	import flash.geom.Vector3D;

	/**
	 * 2D点,也称点投影.如果不打算开发zerO3d,可以不用管.
	 * 它作为3D点在视口上的投影.
	 */
	public class Point2D extends Point
	{	
		/**
		 * 设置父级点,3D向量原形,2D点本身即父级点的正投影.
		 */
		public function set parent( p:Vector3D ):void
		{
			_parent = p;
		}
		
		/**
		 * 设置父级点,3D向量原形,2D点本身即父级点的正投影.
		 */
		public function get parent():Vector3D
		{
			return _parent;
		}
		
		/**
		 * 设置原点.原点即存储原3D点.
		 */
		public function set node( n:Point3D ):void
		{
			_node = n;
		}
		
		/**
		 * 设置原点.原点即存储原3D点.
		 */
		public function get node():Point3D
		{
			return _node;
		}
		
		/**
		 * 设置缩放,这个缩放是伪缩放,代表近大远小.
		 */
		public function set scale( s:Number ):void
		{
			_scale = s;
		}
		
		/**
		 * 设置缩放,这个缩放是伪缩放,代表近大远小.
		 */
		public function get scale():Number
		{
			return _scale;
		}
		
		/**
		 * 获取深度.
		 */
		public function get depth():Number
		{
			return parent.z;
		}

		/**
		 * 构建新的2D点.
		 * @param node 原点,存储原3D点,2D点本身即父级点的正投影.
		 */
		public function Point2D( node:Point3D )
		{
			this.node = node;
			
			super();
			init();
		}

		/**
		 * 初始化.
		 */
		private function init():void
		{
			scale = 1;
		}
		
		/**
		 * 如果当前 Point 对象和作为参数指定的 Point 对象均为单位顶点，此方法将返回这两个顶点之间所成角的余弦值.
		 */
		static public function dotProduct( vectorA:Point,vectorB:Point ):Number
		{
			return dotMetrix( vectorA,vectorB ) / ( vectorA.length * vectorB.length );
		}
		
		/**
		 * 返回两个矢量之间的弧度的角度.
		 */
		static public function angleBetween( vectorA:Point,vectorB:Point ):Number
		{
			return Math.acos( dotProduct( vectorA,vectorB ) );
		}
		
		/**
		 * 叉积.
		 */
		static public function crossProduct( vectorA:Point,vectorB:Point ):Number
		{
			return vectorA.x * vectorB.y - vectorA.y * vectorB.x;
		}
		
		/**
		 * 点积.
		 */
		static public function dotMetrix( vectorA:Point,vectorB:Point ):Number
		{
			return vectorA.x * vectorB.x + vectorA.y * vectorB.y;
		}
		
		/**
		 * 缩放.这个缩放是伪缩放,代表近大远小.
		 */
		private var _scale:Number;
		
		/**
		 * 父级点.3D向量原形.
		 */
		private var _parent:Vector3D = null;
		
		/**
		 * 原点,存储原3D点,2D点本身即父级点的正投影.
		 */
		private var _node:Point3D = null;
		
	}
}