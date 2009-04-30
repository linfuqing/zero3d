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

package zerO.materials.viewport
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import zerO.materials.IRenderMaterial;
	import zerO.materials.ITriangleMaterial;
	import zerO.materials.MovieMaterial;
	import zerO.veiw.IViewport;
	
	/**
	 * 视口材质,可以把视口上的东西影射到几何体材质上.
	 */
	public class ViewportMaterial extends MovieMaterial implements ITriangleMaterial, IRenderMaterial
	{
		/**
		 * 视口材质,可以把视口上的东西影射到几何体材质上,就像一个大电影.
		 * 很神奇的材质.
		 * @param viewport  视口
		 * @param fillColor 填充颜色
		 * @param smooth    是否平滑处理
		 */
		public function ViewportMaterial(
		viewport:IViewport, 
		fillColor:uint=0, 
		smooth:Boolean=false )
		{
			super(viewport as DisplayObject, fillColor, viewport.bounds, smooth);
		}

	}
}