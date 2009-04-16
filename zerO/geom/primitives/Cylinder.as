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
	import zerO.materials.ColorMaterial;
	
	public class Cylinder extends Geometry
	{
		//半径:
		private var radius:Number;
		
		//高:
		private var height:Number;
		
		//面数:
		private var numFaces:uint;
		
		//材质:
		private var material:IMaterial = new ColorMaterial( Math.random() * 0xffffff,0.5 );
		
		/**
		 * 圆柱体,具体看正方体
		 */
		public function Cylinder( radius:Number = 200,height:Number = 200,numFaces:uint = 20,material:IMaterial = null )
		{
			this.radius = radius;
			this.height = height;
			this.numFaces = numFaces;
			if( material )
			{
				this.material = material;
			}
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
			var index:uint = 0;
			for( var i:uint = 0; i < numFaces; i++ )
			{
				var angle:Number = Math.PI * 2 / numFaces * i;
				var xpos:Number = Math.cos(angle) * radius;
				var ypos:Number = Math.sin(angle) * radius;
				vertices[index] =     new Vertex( xpos, ypos, - height / 2 );
				vertices[index + 1] = new Vertex( xpos, ypos,  height / 2 );
				index += 2;
			}
		}
		
		private function addFaces():void
		{
			var index:Number = 0;
			for( var i:uint = 0; i < numFaces - 1; i++ )
			{
				triangles[index] =     new Triangle(vertices[index], vertices[index + 3], vertices[index + 1], material);
				triangles[index + 1] = new Triangle(vertices[index], vertices[index + 2], vertices[index + 3], material);
				index += 2;
			}
			
			triangles[index] =   new Triangle(vertices[index], vertices[1], vertices[index + 1], material);
			triangles[index+1] = new Triangle(vertices[index], vertices[0], vertices[1], material);
		}

	}
}