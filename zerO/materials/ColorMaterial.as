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
	
	import zerO.geom.triangle.Triangle2D;
	import zerO.lights.Light;
	import zerO.veiw.IViewport;
	
	/**
	 * 颜色材质,也叫单彩材质,支持灯光,使用后以纯色渲染.
	 */
	public class ColorMaterial extends TriangleMaterial implements ITriangleMaterial
	{
				
		/**
		 * 获取颜色.
		 */
		public function get color():uint
		{
			return _color;
		}
		
		/**
		 * 获取位图数据.
		 * 返回null
		 */
		public function get bitmapData():BitmapData
		{
			return null;
		}
		
		/**
		 * 构建新的颜色材质.
		 * @param color 颜色
		 * @param alpha 透明度
		 */
		public function ColorMaterial( color:uint = 0xffffff,alpha:Number = 1 )
		{
			_color = color;
			this.alpha = alpha;
		}

		/**
		 * 画三角形.渲染时调用.
		 * @param triangle 要绘制的三角形.
		 * @param viewpor  视口.
		 */
		override public function drawTriangle( triangle:Triangle2D,graphics:Graphics,light:Light ):void
		{
			var adjustColor:uint = light ? color : light.getAdjustColor( triangle,color );
			
			graphics.beginFill( adjustColor,alpha );
			//graphics.drawTriangles( triangle.vertices,null,null,culling );
			graphics.drawPath( triangleCommands,triangle.vertices );
			graphics.endFill();
		}

		/**
		 * 颜色.
		 */
		private var _color:uint;
		
		/**
		 * 透明度.
		 */
		private var alpha:Number;

	}
}