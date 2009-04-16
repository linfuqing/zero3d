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

package zerO.geom.points
{
	import flash.geom.Vector3D;
	
	/**
	 * 向量点，说白了就是带方向的虚拟点.所谓虚拟点就是没有世界坐标的点.
	 */
	public class VectorPoint
	{
				
		/**
		 * 设置位置.
		 */
		public function set position( _position:Vector3D ):void
		{
			this._position = _position;
		}
		
		/**
		 * 设置位置.
		 */
		public function get position():Vector3D
		{
			return _position;
		}
		
		/**
		 * 设置X值.
		 */		
		public function set x( _x:Number ):void
		{
			position.x = _x;
		}
		
		/**
		 * 设置X值.
		 */
		public function get x():Number
		{
			return position.x;
		}
		
		/**
		 * 设置Y值.
		 */
		public function set y( _y:Number ):void
		{
			position.y = _y;
		}
		
		/**
		 * 设置Y值.
		 */
		public function get y():Number
		{
			return position.y;
		}
		
		/**
		 * 设置Z值.
		 */
		public function set z( _z:Number ):void
		{
			position.z = _z;
		}
		
		/**
		 * 设置Z值.
		 */
		public function get z():Number
		{
			return position.z;
		}
		
		/**
		 * 设置方向
		 */
		public function set direction( _direction:Vector3D ):void
		{
			this._direction = _direction;
		}
		
		/**
		 * 设置方向
		 */
		public function get direction():Vector3D
		{
			return _direction;
		}
		
		/**
		 * X轴旋转角度.
		 */
		public function set rotationX( angle:Number ):void
		{
			if( max_dir.x != 0 )
			{
				if( angle < 0 )
				{
					direction.x = Math.max( angle,- max_dir.x / 2 );
				}
				else
				{
					direction.x = Math.min( angle,max_dir.x / 2 );
				}
				return;
			}
			direction.x = angle;
		}
		
		/**
		 * X轴旋转角度.
		 */
		public function get rotationX():Number
		{
			return direction.x;
		}
		
		/**
		 * Y轴旋转角度.
		 */
		public function set rotationY( angle:Number ):void
		{
			if( max_dir.y != 0 )
			{
				if( angle < 0 )
				{
					direction.y = Math.max( angle,- max_dir.y / 2 );
				}
				else
				{
					direction.y = Math.min( angle,max_dir.y / 2 );
				}
				return;
			}
			direction.y = angle;
		}
		
		/**
		 * Y轴旋转角度.
		 */
		public function get rotationY():Number
		{
			return direction.y;
		}
		
		/**
		 * Z轴旋转角度.
		 */
		public function set rotationZ( angle:Number ):void
		{
			if( max_dir.z != 0 )
			{
				if( angle < 0 )
				{
					direction.z = Math.max( angle,- max_dir.z / 2 );
				}
				else
				{
					direction.z = Math.min( angle,max_dir.z / 2 );
				}
				return;
			}
			direction.z = angle;
		}
		
		/**
		 * Z轴旋转角度.
		 */
		public function get rotationZ():Number
		{
			return direction.z;
		}
		
				
		/**
		 * 将方向的度数换成角度.
		 */
		public function get angle():Vector3D
		{
			var direction:Vector3D = this.direction.clone();
			direction.w = 180 / Math.PI;
			direction.project();
			return direction;
		}
		
		/**
		 * 构建向量点.
		 * @param x x
		 * @param y y
		 * @param z z
		 */
		public function VectorPoint( x:Number = 0,y:Number = 0,z:Number = 0 )
		{
			init();
			_position = new Vector3D(x,y,z);
		}
		
		/**
		 * 初始化.
		 */
		private function init():void
		{
			_direction = new Vector3D();
			max_dir = new Vector3D();
		}

		/**
		 * 设置最大方向,设置最点方向后,方向不能超过最大方向.
		 * @param max_dir 最大方向.
		 */
		public function defineMaximunDirection( max_dir:Vector3D ):void
		{
			var vector:Vector3D = new Vector3D();
			vector.x = Math.max( 0,max_dir.x );
			vector.y = Math.max( 0,max_dir.y );
			vector.z = Math.max( 0,max_dir.z );
			
			this.max_dir = vector;
		}
		
		/**
		 * 关闭最大方向限制
		 */
		public function closeLimitDirection():void
		{
			this.max_dir = new Vector3D();
		}

		/**
		 * 获取方向上距离length的3D点.
		 * @param length 要返回的点距离本身的长度.
		 * @return 方向上距离length的3D点.
		 */
		protected function getPointAway( length:Number ):Vector3D
		{
			var point:Vector3D = position.clone();
			var angle:Vector3D = this.angle;
			point.x += length * Math.cos( angle.x ) * Math.sin( angle.y );
			point.y += - length * Math.sin( angle.x );
			point.z += length * Math.cos( angle.x ) * Math.cos( angle.y );
			return point;
		}
		
		/**
		 * 位置.
		 */
		private var _position:Vector3D;
		
		/**
		 * 方向.
		 */
		private var _direction:Vector3D;
		
		/**
		 * 最大方向,设置最点方向后,方向不能超过最大方向.
		 */
		private var max_dir:Vector3D;
		
	}
}