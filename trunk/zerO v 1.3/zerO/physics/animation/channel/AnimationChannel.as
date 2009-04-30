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
	import zerO.physics.animation.KeyFrame;
	import zerO.utils.NameSetter;
	
	/**
	 * 动画控制器,这是一个基类,可以执行加入关键帧,帧跳转等操作.
	 */
	public class AnimationChannel extends NameSetter
	{
		/**
		 * 开始时间,这个时间的单位是秒.
		 */
		public var startTime:Number;
		
		/**
		 * 结束时间.同开始时间.
		 */
		public var endTime:Number;
		
		/**
		 * 关键帧集合,存储所有关键帧(KeyFrame)的数组.
		 */
		public function get keyFrames():Array
		{
			return key_frames;
		}
		
		/**
		 * 构建新的动画控制器.
		 * @param target 控制器所控制的目标3D显示对象.
		 * @param name 动画控制器的名字.
		 * @param return
		 */
		public function AnimationChannel( target:DisplayObject3D,name:String = null )
		{
			this.target = target;
			this.name = name;
			startTime = endTime = 0;
			key_frames = new Array();
			currentKeyFrame = nextKeyFrame = null;
			currentIndex = nextIndex = - 1;
			frameAlpha = 0;
		}
		
		/**
		 * 增加关键帧,可以将关键帧加到关键帧控制器集合里.
		 * @param keyFrame 关键帧.
		 */
		public function addKeyFrame( keyFrame:KeyFrame ):void
		{
			if( key_frames.length )
			{
				startTime = Math.min(startTime, keyFrame.time);
				endTime = Math.max(endTime, keyFrame.time);
			}
			else
			{
				startTime = endTime = keyFrame.time;
			}
			
			duration = endTime - startTime;
			
			keyFrames.push( keyFrame );
			
			keyFrames.sortOn( "time",Array.NUMERIC );
		}
		
		/**
		 * 跳到帧，相当于MovieClip的goto方法.
		 * @param numFrame 帧的索引值/下标.
		 */
		public function goToFrame( numFrame:uint ):void
		{
			if( !keyFrames.length )
			{
				return;
			}
						
			currentIndex = numFrame;
			currentIndex = currentIndex < keyFrames.length - 1 ? currentIndex : 0;

			nextIndex = currentIndex + 1;
			
			currentKeyFrame = keyFrames[currentIndex];
			nextKeyFrame = keyFrames[nextIndex];
			
			frameDuration = nextKeyFrame.time - currentKeyFrame.time;
			frameAlpha = 0;
			currentTime = currentKeyFrame.time;
		}
		
		/**
		 * 跳到时间上播放,与上面相似.
		 * @param time 要跳到的时间(秒).
		 */
		public function goToTime( time:Number ):void
		{	
			currentIndex = Math.floor( ( keyFrames.length - 1 ) * time );
			currentIndex = currentIndex < keyFrames.length - 1 ? currentIndex : 0;
			nextIndex = currentIndex + 1;
			
			currentKeyFrame = keyFrames[currentIndex];
			nextKeyFrame = keyFrames[nextIndex];
			
			frameDuration = nextKeyFrame ? nextKeyFrame.time - currentKeyFrame.time : currentKeyFrame.time;
			
			currentTime = time * duration;
			
			frameAlpha = ( currentTime - currentKeyFrame.time ) / frameDuration;
			
			frameAlpha = frameAlpha < 0 ? 0 : frameAlpha;
			frameAlpha = frameAlpha > 1 ? 1 : frameAlpha;
		}
		
		/**
		 * 关键帧集合,存储所有关键帧(KeyFrame)的数组.
		 */
		private var key_frames:Array;
			
		/**
		 * 目标3D显示对象
		 */
		protected var target:DisplayObject3D;
		
		/**
		 * 帧长度,代表当前帧与下一帧之间相差的秒数.
		 */
		protected var frameDuration:uint;
		
		/**
		 * 总长度,总秒数.
		 */
		protected var duration:Number;
		
		/**
		 * 当前时间.
		 */
		protected var currentTime:Number;
		
		/**
		 * 当前关键帧.
		 */
		protected var currentKeyFrame:KeyFrame;
		
		/**
		 * 下个关键帧.
		 */
		protected var nextKeyFrame:KeyFrame;
		
		/**
		 * 当前索引,它作为一个关键帧的索引值使用
		 */
		protected var currentIndex:int;
		
		/**
		 * 下个索引.
		 */
		protected var nextIndex:int;
		
		/**
		 * 帧缓冲值,通常用来存储帧与帧之间时间的百分值.
		 */
		protected var frameAlpha:Number;
		

	}
}