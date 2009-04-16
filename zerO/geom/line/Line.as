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
	import zerO.geom.points.Vertex;
	import zerO.materials.ILineMaterial;
	import zerO.materials.IMaterial;
	import zerO.particles.Particles;
	import zerO.render.IRender;
	
	/**
	* 3D线，可以按照你的点和线集合绘制出3D线.
	*/
	public class Line implements IRender
	{
		public var vertexA:Vertex;
		
		public var vertexB:Vertex;
		
		public var curveTo:Vertex;
		
		public var curveThroughPoint:Boolean;
		
		public function set parent( particles:Particles ):void
		{
			_parent = particles as Lines;
		}
		
		public function get parent():Particles
		{
			return _parent;
		}
		
				
		public function set interactive( volue:Boolean ):void
		{
			_interactive = volue;
		}
		
		public function get interactive():Boolean
		{
			return _interactive;
		}
							
		/**
		 * 设置材质.
		 */ 
		public function set material( m:IMaterial ):void
		{
			if( m is ILineMaterial )
			{
				_material = m as ILineMaterial;
			}
		}
		
		/**
		 * 设置材质.
		 */
		public function get material():IMaterial
		{
			return _material;
		}

		/**
		 * 构建新的线.
		 * @param point    点集.
		 * @param material 线的材质.
		 * @param name     线的名字.
		 * @param commands 线方法集合,参照flash.display.GraphicsPathCommand.
		 */
		public function Line( vertexA:Vertex,vertexB:Vertex,material:ILineMaterial,curveTo:Vertex = null,curveThroughPoint:Boolean = false )
		{
			this.vertexA = vertexA;
			this.vertexB = vertexB;
			this.curveTo = curveTo;
			this.curveThroughPoint = curveThroughPoint;
			this.material = material;
		}
		
		/**
		 * 线的材质.
		 */
		private var _material:ILineMaterial;
		
		
		private var _parent:Lines;
		
		/**
		 * 是否交互.
		 */
		private var _interactive:Boolean;
		
	}
}