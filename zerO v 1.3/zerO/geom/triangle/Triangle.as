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

package zerO.geom.triangle
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import zerO.geom.points.Vertex;
	import zerO.materials.IMaterial;
	import zerO.materials.ITriangleMaterial;
	import zerO.materials.TriangleMaterial;
	import zerO.particles.Particles;
	import zerO.render.IRender;
	import zerO.utils.NameSetter;
	
	/**
	 * 三维三角形,也称面.
	 * 在大多数3D引擎里,三角形通常还使用Polygon(多边形),Face(面)等表示.
	 * 三角形由三个3D点组成,使用时,三维三角形只作为容器.
	 * 原理上,三维三角形投影到视口上形成2维三角形影射出来,我们才能看到它.
	 * 几何体大多是由三角形构成的.
	 * 在zerO3d里,任何复杂的几何体最终都会转换成三角形进行运算.
	 */
	public class Triangle extends NameSetter implements IRender
	{
		/**
		 * 是否进行背面剔出.
		 * 背面剔除既是指当三角形的正面与屏幕相反的时候不可见.
		 * 背面剔除可使几何体立体化.使场景高效化.
		 */
		public var backFaceCulling:Boolean;
		
		/**
		 * 点A.
		 */
		public var vertexA:Vertex;
		
		/**
		 * 点B.
		 */
		public var vertexB:Vertex;
		
		/**
		 * 点C.
		 */
		public var vertexC:Vertex;
		
		public function set interactive( volue:Boolean ):void
		{
			_interactive = volue;
		}
		
		public function get interactive():Boolean
		{
			return _interactive;
		}
		
		/**
		 * 父级几何体.
		 */
		public function set parent( particles:Particles ):void
		{
			_parent = particles;
		}
		
		/**
		 * 父级几何体.
		 */
		public function get parent():Particles
		{
			return _parent;
		}
		
		/**
		 * 设置三角形材质.
		 */
		public function set material( m:IMaterial ):void
		{
			_material = ( m is ITriangleMaterial ? m : TriangleMaterial.DEFAULT_MATERIAL ) as ITriangleMaterial;
		}
		
		/**
		 * 设置三角形材质.
		 */
		public function get material():IMaterial
		{
			return _material;
		}

		/**
		 * 设置UV坐标.
		 */
		public function set uvs( _uvs:Array ):void
		{
			this._uvs = _uvs;
			if( _uvs )
			{
				uvt_data = new Vector.<Number>();
				for each( var uv:Point in _uvs )
				{
					uvt_data.push( uv.x );
					uvt_data.push( uv.y );
				}
			}
			else
			{
				uvt_data = null;
			}
		}
		
		/**
		 * 设置UV坐标.
		 */
		public function get uvs():Array
		{
			return _uvs;
		}
		
		/**
		 * 获取UV向量集,这个主要由渲染时使用.
		 */
		public function get uvtData():Vector.<Number>
		{
			return uvt_data;
		}

		/**
		 * 构建新的三角形.
		 * @param a               点A.
		 * @param b               点B.
		 * @param c               点C.
		 * @param material        三角形材质
		 * @param uvs             UV坐标集.
		 * @param backFaceCulling 是否背面剔除.
		 */
		public function Triangle( 
		vertexA:Vertex,
		vertexB:Vertex,
		vertexC:Vertex,
		material:IMaterial,
		uvs:Array = null,
		backFaceCulling:Boolean = true,
		interactive:Boolean = false )
		{
			this.vertexA = vertexA;
			this.vertexB = vertexB;
			this.vertexC = vertexC;
			this.material = material;
			this.uvs = uvs;
			this.backFaceCulling = backFaceCulling;
			this.interactive = interactive;
			
			init();
		}
		
		/**
		 * 初始化.
		 */
		private function init():void
		{
			_parent = null;
		}
		
		/**
		 * 三角形的材质.
		 */
		private var _material:ITriangleMaterial;
		
		/**
		 * UV坐标集.
		 */
		private var _uvs:Array;
		
		/**
		 * UV坐标向量组，不用管.
		 */
		private var uvt_data:Vector.<Number>;
		
		/**
		 * 父级几何体.
		 */
		private var _parent:Particles;
		
		/**
		 * 是否交互.
		 */
		private var _interactive:Boolean;
		
	}
}