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
	
	import zerO.utils.INameSetter;
	import zerO.veiw.IViewport;
	
	/**
	 * 材质接口,是所有材质接口的基类.
	 */
	public interface IMaterial extends INameSetter
	{
		/**
		 * 获取颜色
		 */
		function get color():uint;
		
		/**
		 * 获取位图数据
		 */
		function get bitmapData():BitmapData;
		
		function doDraw( object:*,view:IViewport ):Boolean;
		
		function doInteractive( object:*,view:IViewport ):void;
		
		/**
		 * 画渲染体,就是对一个渲染体进行渲染(一般材质是具体划分到渲染体上)
		 * @param object 绘制项目
		 * @param view   视口
		 */
		function draw( object:*,view:IViewport ):void;
		
	}
}