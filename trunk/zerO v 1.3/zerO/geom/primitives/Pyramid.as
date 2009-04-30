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
	import zerO.materials.ColorMaterial;
	
	/**
	* 菱形,它包括5个面,每个面的材质为随机的颜色材质.尚不完善.目前只是起展示作用.
	*/
	public class Pyramid extends Geometry
	{
		//半径:
		private var radius:Number;
		
		/**
		 * 菱形,它包括5个面,每个面的材质为随机的颜色材质.尚不完善.目前只是起展示作用.
		 * 参数为半径.
		 */
		public function Pyramid( radius:Number = 200 )
		{
			this.radius = radius;
			init();
		}
		
		private function init():void
		{
			addVertices();
			addFaces();
			build();
		}
		
		private function addVertices():void
		{
			vertices[0] = new Vertex(   0, -radius,    0);
			vertices[1] = new Vertex( radius,  radius, -radius);
			vertices[2] = new Vertex(-radius,  radius, -radius);
			vertices[3] = new Vertex(-radius,  radius,  radius);
			vertices[4] = new Vertex( radius,  radius,  radius);
		}
		
		private function addFaces():void
		{
			var material:ColorMaterial = new ColorMaterial(Math.random() * 0xffffff);
			
			triangles[0] = new Triangle(vertices[0], vertices[1], vertices[2], new ColorMaterial(Math.random() * 0xffffff));
			triangles[1] = new Triangle(vertices[0], vertices[2], vertices[3], new ColorMaterial(Math.random() * 0xffffff));
			triangles[2] = new Triangle(vertices[0], vertices[3], vertices[4], new ColorMaterial(Math.random() * 0xffffff));
			triangles[3] = new Triangle(vertices[0], vertices[4], vertices[1], new ColorMaterial(Math.random() * 0xffffff));
			triangles[4] = new Triangle(vertices[1], vertices[3], vertices[2], material);
			triangles[5] = new Triangle(vertices[1], vertices[4], vertices[3], material);
		}
			

	}
}