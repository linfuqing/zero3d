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

package zerO.physics.animation.channel
{
	import zerO.objects.DisplayObject3D;
	
	/**
	 * 数组动画帧控制器,可以读取输出为矩阵的关键帧,这个数组将改变控制器目标的顶点值.
	 * 如几何体的缩放,平移,旋转.
	 * 注意:如果关键帧的输出不正确,将出错.
	 */
	public class MatrixChannel extends AnimationChannel
	{
		/**
		 * 构建新的数组动画控制器.
		 * @param target  目标3D显示对象.
		 * @param name    控制器的名字.
		 */
		public function MatrixChannel(target:DisplayObject3D, name:String=null)
		{
			super(target, name);
		}
		
		/**
		 * 增加关键帧,可以将关键帧加到关键帧控制器集合里.
		 * @param keyFrame 关键帧.
		 */
		override public function goToFrame(numFrame:uint):void
		{
			super.goToFrame( numFrame );
			target.transformVertices( currentKeyFrame.outPut );
		}
		
		/**
		 * 跳到帧，相当于MovieClip的goto方法.
		 * @param numFrame 帧的索引值/下标.
		 */
		override public function goToTime(time:Number):void
		{
			super.goToTime( time );
			target.transformVertices( currentKeyFrame.outPut );
		}
	}
}