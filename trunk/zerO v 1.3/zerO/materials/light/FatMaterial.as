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

package zerO.materials.light
{
	import zerO.veiw.IViewport;
	import flash.display.BitmapData;
	import zerO.materials.TriangleMaterial;
	import zerO.geom.triangle.Triangle2D;
	import zerO.lights.Light;
	import zerO.materials.ITriangleMaterial;
	import flash.display.Graphics;
	
	/**
	 * Fat灯光材质.
	 * 它可以使灯光对几何体面做无插值的灯光渲染.是最低级的灯光渲染.
	 */
	public class FatMaterial extends TriangleMaterial implements ITriangleMaterial
	{
		/**
		 * 构建新的Fat灯光材质.
		 */
		public function FatMaterial()
		{
			super();
		}
		
		/**
		 * 获取颜色,这里的颜色为0.
		 */
		public function get color():uint
		{
			return 0;
		}
		
		/**
		 * 获取位图数据,这里为null;
		 */
		public function get bitmapData():BitmapData
		{
			return null;
		}
		
		/**
		 * 画三角形.
		 */
		public function drawTriangle(triangle:Triangle2D, graphics:Graphics, light:Light):void
		{
			if( !light )
			{
				return;
			}
			
			var color:uint = light.getAdjustColor( triangle,light.color );
			
			var alpha:Number = color / 0xffffff * light.brightness;
			
			graphics.beginFill( color,alpha );
			super.drawTriangle( triangle,graphics,light );
			graphics.endFill();
		}
		
	}
}