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
	
	/**
	 * 文件读取项目，读取文件时候用，此项目可以传出错误的文件地址.
	 */
	public class FileLoadEvent extends Event
	{
		/**
		 * 获取文件的地址
		 */
		public function get file():String
		{
			return _file;
		}
		
		/**
		 * 构建新的文件项目.
		 * @param type
		 * @param file 文件的地址.
		 * @param bubbles
		 * @param cancelable
		 */
		public function FileLoadEvent(type:String,file:String,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_file = file;
			super(type, bubbles, cancelable);
		}
		
		/**
		 * 文件的地址.
		 */
		private var _file:String;
		
	}
}