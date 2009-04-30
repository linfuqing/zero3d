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

package zerO.physics.controllers
{
	import flash.utils.getTimer;
	
	import zerO.physics.animation.channel.AnimationChannel;
	import zerO.utils.NameSetter;
	
	/**
	 * 动画控制器.通过它可以使用动画.
	 */
	public class AnimationController extends NameSetter implements IController
	{
		public var loop:Boolean;
		
		/**
		 * 构建新的动画.
		 */
		public function AnimationController( loop:Boolean )
		{
			this.loop = loop;
			
			super();
			init();
		}
		
		/**
		 * 初始化.
		 */
		private function init():void
		{
			channels = new Array();
			isPlaying = false;
			_currentFrame = 0;
			_totalFrames = 0;
			_startTime = 0;
			_endTime = 0;
		}
		
				
		/**
		 * 这个方法我想大家应该不陌生吧.
		 * 开始播放.
		 */
		public function play():void
		{
			_currentFrame = 0;
			_currentTime = getTimer();
			isPlaying = ( channels && channels.length );
		}
		
		/**
		 * 停止播放.
		 */
		public function stop():void
		{
			isPlaying = false;
		}
		
		/**
		 * 加入时间轴.
		 * @param channel 可以数组也可以是单个时间轴.
		 */
		public function addChannel( channel:AnimationChannel ):void
		{
			channels.push( channel );
			
			_totalFrames = Math.max(_totalFrames, channel.keyFrames.length);	
			_startTime = Math.min(_startTime, channel.startTime);
			_endTime = Math.max(_endTime, channel.endTime);
			channel.goToTime(0);
		}
		
		/**
		 * 变换,渲染时调用.
		 */
		public function update():void
		{
			if( isPlaying && channels )
			{
				var secs:Number = _currentTime / 1000;
				var duration:Number = _endTime - _startTime;
				var elapsed:Number = ( getTimer() / 1000 ) - secs;
				
				if(elapsed > duration)
				{
					_currentTime = getTimer();
					secs = _currentTime / 1000;
					elapsed = 0;
				}
				var time:Number = elapsed / duration;

				if ( time == 0 && !loop )
				{
					stop();
				}
				else
				{
					for each(var channel:AnimationChannel in channels)
					{
						channel.goToTime(time);
					}
				}
			}
		}
		
		/**
		 * 字符化.
		 */
		public override function toString():String
		{
			return "animations (#channels: " + channels.length + " #frames: " + _totalFrames + ", startTime: " + _startTime + " endTime: " + _endTime+ ")";
		}
				
		/**
		 * 控制器列表.
		 */
		private var channels:Array;
		
		/**
		 * 当前帧下标.
		 */
		private var _currentFrame:uint;
		
		/**
		 * 是否播放.
		 */
		private var isPlaying:Boolean;
		
		/**
		 * 当前时间/秒.
		 */
		private var _currentTime:Number;
		
		/**
		 * 结束时间/秒.
		 */
		private var _endTime:Number;
		
		/**
		 * 开始时间/秒.
		 */
		private var _startTime:Number;
		
		/**
		 * 总共帧数.
		 */
		private var _totalFrames:uint;
		
	}
}