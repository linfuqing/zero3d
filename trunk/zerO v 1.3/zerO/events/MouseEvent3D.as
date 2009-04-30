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
	import flash.events.EventDispatcher;

	public class MouseEvent3D extends Event
	{
		/**
		 * 获取子项目.
		 */
		public function get child():EventDispatcher
		{
			return _child;
		}
		
		/**
		 * 3D鼠标项目.
		 */
		public function MouseEvent3D(type:String, child:EventDispatcher, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_child = child;
		}
		
		/**
		 * 子项目.
		 */
		private var _child:EventDispatcher;
		
	}
}