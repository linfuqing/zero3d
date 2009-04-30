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
	
	/**
	 * 组合材质,你可以将材质组合起来使用.
	 * 在使用前,你需要把材质加进去.象这样:
	 * <p>
	 * //定义材质.
	 * var material:CompositeMaterial = new CompositeMaterial();
	 * <p>
	 * //然后把你的材质像这样加进去.
	 * material.materials.addMaterial( yourMaterial );
	 * <p>
	 */
	public class CompositeMaterial extends TriangleMaterial implements ITriangleMaterial
	{
		/**
		 * 获取材质管理器.
		 */
		public function get materials():Materials
		{
			return _materials;
		}
				
		/**
		 * 获取位图数据.
		 * 返回null.
		 */
		public function get bitmapData():BitmapData
		{
			return null;
		}
		
		/**
		 * 获取颜色.
		 * 返回0.
		 */
		public function get color():uint
		{
			return 0;
		}
		
		/**
		 * 构建新的组合材质.
		 */
		public function CompositeMaterial()
		{
			super();
			init();
		}
		
		/**
		 * 初始化.
		 */
		private function init():void
		{
			_materials = new Materials();
		}
		
		/**
		 * 画三角形.渲染时调用.
		 * @param triangle 要绘制的三角形.
		 * @param viewpor  视口.
		 */
		public function drawTrianlge( triangle:Triangle2D,graphics:Graphics ):void
		{
			for each( var material:ITriangleMaterial in _materials.materials )
			{
				material.drawTriangle( triangle,graphics );
			}
		}
		
		/**
		 * 材质管理器.
		 */
		private var _materials:Materials;

	}
}