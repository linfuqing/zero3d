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

package zerO.events
{
	import flash.events.Event;
	
	import zerO.render.IRender;

	public class ViewportEvent extends Event
	{
		/**
		 * 初始化渲染常量.
		 */
		public static const INIT_RENDER:String   = "init render";
		
		/**
		 * 移出渲染常量.
		 */
		public static const REMOVE_RENDER:String = "remove render";
		
		/**
		 * 获取渲染元素.
		 */
		public function get render():IRender
		{
			return _render;
		}
		
		/**
		 * 视口项目.
		 */
		public function ViewportEvent(type:String,render:IRender, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_render = render;
		}
		
		/**
		 * 渲染元素.
		 */
		private var _render:IRender;
		
	}
}