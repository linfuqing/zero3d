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

package zerO.physics.animation
{
	import zerO.utils.NameSetter;
	
	/**
	 * 关键帧,大家对这个概念应该不陌生吧.
	 * 可以设置在动画控制器上,做渐近效果.
	 */
	public class KeyFrame extends NameSetter
	{	
		/**
		 * 时间,代表在什么时候设置的.
		 */
		public var time:Number;
		
		/**
		 * 输出值,动画控制器将获取这些输出值对目标显示对象做各种各样的变换.
		 */
		public var outPut:*;
		
		/**
		 * 构建新的关键帧.
		 * @param name   关键帧的名字
		 * @param time   时间,代表在什么时候设置的.
		 * @param outPut 输出值,动画控制器将获取这些输出值对目标显示对象做各种各样的变换.
		 */
		public function KeyFrame( name:String,time:Number,outPut:* )
		{
			this.name = name;
			this.time = time;
			this.outPut = outPut;
		}

	}
}