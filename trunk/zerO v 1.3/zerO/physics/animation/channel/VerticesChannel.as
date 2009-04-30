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
	import zerO.geom.points.Point3D;
	import zerO.objects.DisplayObject3D;
	
	/**
	 * 顶点动画控制器,可以读取输出是顶点列表的关键帧.这些顶点必须跟目标的顶点数量相同.
	 * 它可以控制目标3D显示对象的顶点向关键帧的顶点位置逼近.
	 * 注意:如果关键帧的输出不正确,将出错.
	 */
	public class VerticesChannel extends AnimationChannel
	{
		/**
		 * 构建新的顶点动画控制器.
		 * @param target  目标3D显示对象.
		 * @param name    控制器的名字.
		 */
		public function VerticesChannel(target:DisplayObject3D, name:String=null)
		{
			super(target, name);
		}
		
		/**
		 * 跳到帧，相当于MovieClip的goto方法.
		 * @param numFrame 帧的索引值/下标.
		 */
		override public function goToFrame(numFrame:uint):void
		{
			super.goToFrame( numFrame );
			
			if( currentKeyFrame.outPut.length != target.vertices.length)
			{
				return;
			}
			
			var numVertices:uint = target.vertices.length;
			for( var i:int = 0; i < numVertices; i++ )
			{
				var v:Point3D = target.vertices[i];
				var w:Point3D = currentKeyFrame.outPut[i];
				
				v.x = w.x;
				v.y = w.y;
				v.z = w.z;
			}
				
		}
		
		/**
		 * 跳到时间上播放,与上面相似.
		 * @param time 要跳到的时间(秒).
		 */
		override public function goToTime(time:Number):void
		{
			super.goToTime( time );
			
			if( currentKeyFrame.outPut.length != target.vertices.length)
			{
				return;
			}
			
			var numVertices:uint = target.vertices.length;
			for(var i:int = 0; i < numVertices; i++)
			{
				var u:Point3D = target.vertices[i];
				var v:Point3D = currentKeyFrame.outPut[i];
				var w:Point3D = nextKeyFrame.outPut[i];
				
				u.x = v.x + frameAlpha * (w.x - v.x);
				u.y = v.y + frameAlpha * (w.y - v.y);
				u.z = v.z + frameAlpha * (w.z - v.z);
			}
			
		}
		
	}
}