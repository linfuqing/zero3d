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

package zerO.geom.primitives
{
	import zerO.geom.Geometry;
	import zerO.geom.triangle.Triangle;
	import zerO.geom.points.Vertex;
	import zerO.materials.IMaterial;
	import zerO.materials.Materials;
	import zerO.materials.ColorMaterial;
	
	public class Cube extends Geometry
	{
		//半径,也可以叫边长:
		private var radius:Number;
		
		//前上后下右左面的材质
		private var front:IMaterial = new ColorMaterial(0xcc66cc);
		private var top:IMaterial = new ColorMaterial(0x66cc66);
		private var back:IMaterial = new ColorMaterial(0xcc6666);
		private var bottom:IMaterial = new ColorMaterial(0xcc66cc);
		private var right:IMaterial = new ColorMaterial(0x66cccc);
		private var left:IMaterial = new ColorMaterial(0xcccc66);
		
		/**
		 * 正方形
		 */
		public function Cube( radius:Number = 100,materials:Materials = null )
		{
			this.radius = radius;
			
			if( materials )
			{
				if( materials.getMaterialByName( "front" ) )
				{
					front = materials.getMaterialByName( "front" );
				}
				if( materials.getMaterialByName( "top" ) )
				{
					front = materials.getMaterialByName( "top" );
				}
				if( materials.getMaterialByName( "back" ) )
				{
					front = materials.getMaterialByName( "back" );
				}
				if( materials.getMaterialByName( "bottom" ) )
				{
					front = materials.getMaterialByName( "bottom" );
				}
				if( materials.getMaterialByName( "right" ) )
				{
					front = materials.getMaterialByName( "right" );
				}
				if( materials.getMaterialByName( "left" ) )
				{
					front = materials.getMaterialByName( "left" );
				}
			}
			init();
		}
		
		/**
		 * 初始化
		 */
		private function init():void
		{
			addVertex();
			addTriangles();
			build();
		}
		
		/**
		 * 增加顶点
		 */
		private function addVertex():void
		{
			// front four corners
			vertices[0] = new Vertex(-radius, -radius, -radius);
			vertices[1] = new Vertex( radius, -radius, -radius);
			vertices[2] = new Vertex( radius,  radius, -radius);
			vertices[3] = new Vertex(-radius,  radius, -radius);
			// back four corners
			vertices[4] = new Vertex(-radius, -radius,  radius);
			vertices[5] = new Vertex( radius, -radius,  radius);
			vertices[6] = new Vertex( radius,  radius,  radius);
			vertices[7] = new Vertex(-radius,  radius,  radius);
		}
		
		/**
		 * 增加面
		 */
		private function addTriangles():void
		{
			// front
			triangles[0] = new Triangle(vertices[0], vertices[1], vertices[2], front );
			triangles[1] = new Triangle(vertices[0], vertices[2], vertices[3], front );
			// top
			triangles[2] = new Triangle(vertices[0], vertices[5], vertices[1], top );
			triangles[3] = new Triangle(vertices[0], vertices[4], vertices[5], top );
			//back
			triangles[4] = new Triangle(vertices[4], vertices[6], vertices[5], back );
			triangles[5] = new Triangle(vertices[4], vertices[7], vertices[6], back );
			// bottom
			triangles[6] = new Triangle(vertices[3], vertices[2], vertices[6], bottom );
			triangles[7] = new Triangle(vertices[3], vertices[6], vertices[7], bottom );
			// right
			triangles[8] = new Triangle(vertices[1], vertices[5], vertices[6], right );
			triangles[9] = new Triangle(vertices[1], vertices[6], vertices[2], right );
			// left
			triangles[10] = new Triangle(vertices[4], vertices[0], vertices[3], left );
			triangles[11] = new Triangle(vertices[4], vertices[3], vertices[7], left );
		}

	}
}