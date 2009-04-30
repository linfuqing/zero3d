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
	import flash.display.Graphics;
	
	import zerO.geom.triangle.Triangle2D;
	import zerO.lights.Light;
	
	/**
	 * 三角形材质接口
	 */
	public interface ITriangleMaterial extends IMaterial
	{
		/**
		 * 设置单双面.
		 */
		function set doubleSided( volue:Boolean ):void;
		
		/**
		 * 设置单双面.
		 */
		function get doubleSided():Boolean;

		/**
		 * 画三角形.渲染时调用.
		 * @param triangle 要绘制的三角形.
		 * @param viewpor  视口.
		 */
		function drawTriangle( triangle:Triangle2D,graphics:Graphics,light:Light ):void
	}
}