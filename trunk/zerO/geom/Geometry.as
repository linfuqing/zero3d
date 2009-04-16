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

package zerO.geom
{
	import flash.utils.Dictionary;
	
	import zerO.geom.points.Point3D;
	import zerO.geom.points.Vertex;
	import zerO.geom.triangle.Triangle;
	import zerO.materials.ITriangleMaterial;
	import zerO.particles.Particles;
	
	/**
	 * 几何体,作为顶点和面的容器.
	 * 每个几何体的基类.
	 */
	public class Geometry extends Particles
	{
				
		/**
		 * 设置顶点集.
		 */
		public function set vertices( v:Array ):void
		{
			super.points = v;
		}
		
		/**
		 * 设置顶点集.
		 */
		public function get vertices():Array
		{
			return super.points;
		}
		
		/**
		 * 设置面集.
		 */
		public function set triangles( t:Array ):void
		{
			renderList["triangles"] = t;
		}
		
		/**
		 * 设置面集.
		 */
		public function get triangles():Array
		{
			return renderList["triangles"];
		}
		
		/**
		 * 构建新的几何体.
		 * @param x x
		 * @param y y
		 * @param z z
		 */
		public function Geometry( x:Number = 0,y:Number = 0,z:Number = 0 )
		{
			super( x,y,z );
			init();
		}
		
		/**
		 * 初始化.
		 */
		private function init():void
		{
			renderList["triangles"] = new Array();
		}
		
		/**
		 * 返回一个一模一样的几何体.
		 * 注意,这个几何体为Point3D类型.你必须这样转化它:
		 * <p>
		 * var geometry:Geomtry = geom.clone as Geometry;
		 * <p>
		 * @return 克隆本身.
		 */
		override public function clone():Point3D
		{
			var geom:Geometry = new Geometry( x,y,z );
			geom.worldCenter = worldCenter.clone();
			
			var verticesDictionary:Dictionary = new Dictionary( true );

			for( var i:String in vertices )
			{
				var vertex:Vertex = vertices[i];
				verticesDictionary[ vertex ] = vertex.clone();
				geom.vertices[i] = verticesDictionary[ vertex ];
			}
			
			for( i in triangles )
			{
				var triangle:Triangle = triangles[i];
				geom.triangles[i] = new Triangle( 
				verticesDictionary[ triangle.vertexA ],
				verticesDictionary[ triangle.vertexB ],
				verticesDictionary[ triangle.vertexC ],
				triangle.material as ITriangleMaterial,
				triangle.uvs,
				triangle.backFaceCulling );
			}
			
			return geom;
		}

		/**
		 * 字符化.
		 */
		public override function toString():String
		{
			return "Geometry( vertices: " + vertices.length + ", faces: " + triangles.length + "," + super.toString() + " )";
		}
	}
}