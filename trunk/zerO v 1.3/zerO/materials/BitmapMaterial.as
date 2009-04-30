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

package zerO.materials
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import zerO.geom.triangle.Triangle2D;
	import zerO.lights.Light;
	
	/**
	 * 位图材质,可以对几何体进行贴图.
	 * 暂时不支持灯光.
	 * 相信都众所周知了.
	 */
	public class BitmapMaterial extends TriangleMaterial implements ITriangleMaterial
	{
						
		/**
		 * 是否平滑处理，当位图变大时候会像素扭曲，平滑处理可以避免这种现象.
		 */
		public var smooth:Boolean = false;
		
		/**
		 * 获取颜色,当前返回0.
		 */
		public function get color():uint
		{
			return 0;
		}
		
		/**
		 * 获取位图数据.
		 */
		public function get bitmapData():BitmapData
		{
			return bitmap;
		}

		/**
		 * 构建新的位图材质.
		 * @param bitmap 位图数据.
		 * @param smooth 是否平滑处理.是否平滑处理，当位图变大时候会像素扭曲，平滑处理可以避免这种现象.但是渲染会变慢.
		 */
		public function BitmapMaterial( bitmap:BitmapData,smooth:Boolean = false )
		{
			this.bitmap = bitmap;
			this.smooth = smooth;
			init();
		}
		
		/**
		 * 初始化.
		 */
		private function init():void
		{
			UVMatrixList = new Dictionary(true);
			lineDrawer = TriangleMaterial.DEFAULT_MATERIAL;
		}
		
		/**
		 * 画三角形.渲染时调用.
		 * @param triangle 要绘制的三角形.
		 * @param viewpor  视口.
		 */
		override public function drawTriangle( triangle:Triangle2D,graphics:Graphics,light:Light ):void
		{
			/*graphics.beginBitmapFill( triangle.parent.material.bitmapData,null,true,smooth );
			graphics.drawTriangles( triangle.vertices,null,triangle.parent.uvtData,culling );
			graphics.endFill();*/
			if( bitmap )
			{
				graphics.beginBitmapFill( 
				triangle.parent.material.bitmapData,
				buildTransform( triangle ),
				true,
				smooth );
				super.drawTriangle( triangle,graphics,null );
				//graphics.drawPath( triangleCommands,triangle.vertices );
				graphics.endFill();
			}
			else
			{
				lineDrawer.drawTriangle( triangle,graphics,light );
			}
		}
		
		/**
		 * 建立UV矩阵.
		 */
		private function buildUVMatrix( triangle:Triangle2D ):Matrix
		{
			var uvA:Point = new Point();
			uvA.x = triangle.parent.uvtData[0] * bitmap.width;
			uvA.y = triangle.parent.uvtData[1] * bitmap.height;
			var uvB:Point = new Point();
			uvB.x = triangle.parent.uvtData[2] * bitmap.width;
			uvB.y = triangle.parent.uvtData[3] * bitmap.height;
			var uvC:Point = new Point();
			uvC.x = triangle.parent.uvtData[4] * bitmap.width;
			uvC.y = triangle.parent.uvtData[5] * bitmap.height;
			
			var ba:Point = uvB.subtract( uvA );
			var ca:Point = uvC.subtract( uvA );
			
			var matrix:Matrix = new Matrix( ba.x,ba.y,ca.x,ca.y,uvA.x,uvA.y );
			
			matrix.invert();
			
			UVMatrixList[triangle] = matrix.clone();
			
			return matrix;
		}
		
		/**
		 * 建立位图填充矩阵.
		 */
		private function buildTransform( triangle:Triangle2D ):Matrix
		{
			var matrix:Matrix = UVMatrixList[triangle] ? UVMatrixList[triangle].clone() : buildUVMatrix(triangle);
			
			var ba:Point = triangle.pointB.subtract( triangle.pointA );
			var ca:Point = triangle.pointC.subtract( triangle.pointA );
			
			var transform:Matrix = new Matrix( ba.x,ba.y,ca.x,ca.y,triangle.pointA.x,triangle.pointA.y );
			
			matrix.concat( transform );
			
			return matrix;
		}

		/**
		 * 位图数据.
		 */
		protected var bitmap:BitmapData;
		
		
		/**
		 * UV矩阵列表.
		 */
		private var UVMatrixList:Dictionary;
		
		private var lineDrawer:ITriangleMaterial;
	}
}