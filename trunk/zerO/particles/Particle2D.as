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

package zerO.particles
{
	import zerO.geom.points.Point2D;
	
	/**
	 * 粒子投影.核心类.不开发不用管.
	 */
	public class Particle2D
	{
		/**
		 * 点.
		 */
		public var point:Point2D;
		
		/**
		 * 获取父级粒子.
		 */		
		public function get parent():Particle
		{
			return _parent;
		}
		
		/**
		 * 获取深度,排序用.
		 */
		public function get z():Number
		{
			return point.depth;
		}
		
		/**
		 * 构建新的粒子投影.
		 */
		public function Particle2D( point:Point2D,parent:Particle )
		{
			this.point = point;
			_parent = parent;
		}
		
		/**
		 * 父级粒子.
		 */		
		private var _parent:Particle;
		
	}
}