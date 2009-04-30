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
	import flash.geom.Point;
	
	import zerO.geom.points.Vertex;
	import zerO.geom.triangle.Triangle;
	import zerO.materials.IMaterial;
	import zerO.materials.TriangleMaterial;
	
	/**
	 * 平面,它是没有厚度的几何体.
	 * 平面由单个或多个四边形组成.具体多边形的数量由段数决定.
	 */
	public class Plane extends Geometry
	{	
		/**
		 * 构建新的平面.
		 * @param width          平面宽
		 * @param height         平面高
		 * @param widthSegments  宽段数
		 * @param heightSegments 高段数
		 * @param material       材质
		 * @param single         是否单面
		 */
		public function Plane( 
		width:Number = 500,
		height:Number = 500,
		widthSegments:uint = 1,
		heightSegments:uint = 1,
		material:IMaterial = null,
		single:Boolean = false )
		{
			this.width = width;
			this.height = height;
			this.widthSegments = widthSegments;
			this.heightSegments = heightSegments;
			if(material)
			{
				this.material = material;
			}
			this.single = single;
			init();
		}
		
		/**
		 * 初始化
		 */
		private function init():void
		{
			addVertices();
			addFaces();
			build();
		}
		
		/**
		 * 增加顶点
		 */
		private function addVertices():void
		{
			var widthSegment:Number = width / widthSegments;
			var heightSegment:Number = height / heightSegments;
			
			var textureX :Number = width /2;
			var textureY :Number = height /2;
			
			for( var i:uint = 0;i < widthSegments + 1;i ++ )
			{
				for( var j:uint = 0;j < heightSegments + 1;j ++ )
				{
					vertices.push( new Vertex( 
					i * widthSegment - textureX,
					j * heightSegment - textureY,
					0 ) );
				}
			}
		}
		
		/**
		 * 增加面
		 */
		private function addFaces():void
		{
			for( var i:uint = 0;i < widthSegments;i ++ )
			{
				for( var j:uint = 0;j < heightSegments;j ++ )
				{
					// Triangle A
					var a:Vertex = vertices[ i     * ( heightSegments + 1 ) + j     ];
					var c:Vertex = vertices[ i     * ( heightSegments + 1 ) + (j+1) ];
					var b:Vertex = vertices[ (i+1) * ( heightSegments + 1 ) + j     ];
	
					var uvA:Point =  new Point( i     / widthSegments, j     / heightSegments );
					var uvC:Point =  new Point( i     / widthSegments, (j+1) / heightSegments );
					var uvB:Point =  new Point( (i+1) / widthSegments, j     / heightSegments );
	
					triangles.push( new Triangle( a, b, c, material, [ uvA, uvB, uvC ],single ) );
	
					// Triangle B
					a = vertices[ (i+1) * ( heightSegments + 1 ) + (j+1) ];
					c = vertices[ (i+1) * ( heightSegments + 1 ) + j     ];
					b = vertices[ i     * ( heightSegments + 1 ) + (j+1) ];

					uvA =  new Point( (i+1) / widthSegments, (j+1) / heightSegments );
					uvC =  new Point( (i+1) / widthSegments, j      / heightSegments );
					uvB =  new Point( i     / widthSegments, (j+1) / heightSegments );
					
					triangles.push( new Triangle( a, b, c, material, [ uvA, uvB, uvC ],single ) );
				}
			}
		}
		
		/**
		 * 平面宽.
		 */
		private var width:Number;
		
		/**
		 * 平面高.
		 */
		private var height:Number;
		
		/**
		 * 材质.
		 */
		private var material:IMaterial = TriangleMaterial.DEFAULT_MATERIAL;
		
		/**
		 * 宽段数.
		 */
		private var widthSegments:uint;
		
		/**
		 * 高段数.
		 */
		private var heightSegments:uint;
		
		/**
		 * 是否单面.
		 */
		private var single:Boolean;
		
	}
}