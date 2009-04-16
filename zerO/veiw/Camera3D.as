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

package zerO.veiw
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import zerO.geom.points.VectorPoint;
	
	/**
	 * 3D相机,老生常谈了,就相当于你的眼睛,可以自由移动.也称视截体.
	 * 已经智能化,用它可做成相当棒的动画.
	 */
	public class Camera3D extends VectorPoint
	{
				
		/**
		 * 位置设置.
		 */
		override public function set position(_position:Vector3D):void
		{
			super.position = _position;
			doTransform = true;
		}
		
		/**
		 * x.
		 */
		override public function set x( _x:Number ):void
		{
			super.x = _x
			doTransform = true;
		}
		
		/**
		 * y.
		 */
		override public function set y( _y:Number ):void
		{
			super.y = _y
			doTransform = true;
		}
		
		/**
		 * z.
		 */
		override public function set z( _z:Number ):void
		{
			super.z = _z
			doTransform = true;
		}
		
		/**
		 * 设置目标,设置后相机即转换为目标相机,对目标自动进行视角跟踪，这是一个很棒的效果.
		 * 如果需要转回自由相机,请设置为NULL
		 */
		public function set target( t:Vector3D ):void
		{
			_target = t;
		}
		
		/**
		 * 设置目标,设置后相机即转换为目标相机,对目标自动进行视角跟踪，这是一个很棒的效果.
		 * 如果需要转回自由相机,请设置为NULL
		 */
		public function get target():Vector3D
		{
			return _target;
		}

		/**
		 * 获取相机到目标的长度.
		 */		
		public function get distance():Number
		{
			if( target == null )
			{
				return 0;
			}
			return target.subtract( position ).length;
		}
		
		/**
		 * 设置角度缓冲,结合目标相机用.
		 */
		public function set directionBuffer( dir_buffer:Number ):void
		{
			var dir_buffer_data:Number = Math.min( dir_buffer,1 );
			dir_buffer_data = Math.max( 0,dir_buffer_data );
			this.dir_buffer = dir_buffer_data;
		}
		
		/**
		 * 设置方向.
		 */
		override public function set direction(_direction:Vector3D):void
		{
			super.direction = _direction;
			doTransform = true;
		}
		
		/**
		 * x轴上的角度.
		 */
		override public function set rotationX( angle:Number ):void
		{
			super.rotationX = angle;
			doTransform = true;
		}
		
		/**
		 * x轴上的角度.
		 */
		override public function set rotationY( angle:Number ):void
		{
			super.rotationY = angle;
			doTransform = true;
		}
		
		/**
		 * x轴上的角度.
		 */
		override public function set rotationZ( angle:Number ):void
		{
			super.rotationZ = angle;
			doTransform = true;
		}
		
		/**
		 * 获取相机矩阵(只读).PS:相机矩阵是倒的.
		 */
		public function get matrix():Matrix3D
		{
			return _matrix;
		}
		
		/**
		 * 相机是否移动.
		 */
		public function get move():Boolean
		{
			return _move;
		}
		
		/**
		 * 构建新的相机.
		 * @param target 相机目标.
		 */
		public function Camera3D( target:Vector3D = null )
		{
			super();
			this.target = target;
			init();
		}
		
		/**
		 * 初始化.
		 */
		private function init():void
		{
			_matrix = new Matrix3D();
			doTransform = true;
			dir_buffer = 0;
		}

		/**
		 * 朝相机方向前进.
		 * @param numSteps 步数.相当于移动的像素值. 
		 */
		public function thrust( numSteps:Number ):void
		{
			position = getPointAway( numSteps );
		}
		
		/**
		 * 依照插值向目标做缓动接近.
		 */
		public function closeToTarget():void
		{
			if( target )
			{
				if( dir_buffer != 0 )
				{
					var vector:Vector3D = target.subtract( position );
					x += vector.x * dir_buffer;
					y += vector.y * dir_buffer;
					z += vector.z * dir_buffer;
				}
				else
				{
					position = target.clone();
				}
			}
		}

		/**
		 * 执行相机变换.
		 */
		public function transform():void
		{
			_move = false;
			
			if( target )
			{
				var vector:Vector3D = target.subtract( position );
				var angleX:Number;
				var angleY:Number;
				var rotation:Number = 180 / Math.PI;
				if( vector.x == 0 && vector.z == 0 && vector.y == 0 )
				{
					angleY = 0;
					angleX = 0;
				}
				else if( vector.x == 0 && vector.z == 0  )
				{
					angleX = - Math.asin( vector.y / vector.length ) * rotation;
					angleY = 0;
				}
				else if( vector.z < 0 )
				{
					angleX = - Math.asin( vector.y / vector.length ) * rotation;
					angleY = 180 - Math.asin( vector.x / Math.sqrt( vector.x * vector.x + vector.z * vector.z ) ) * rotation;
				}
				else
				{
					angleX = - Math.asin( vector.y / vector.length ) * rotation;
					angleY = Math.asin( vector.x / Math.sqrt( vector.x * vector.x + vector.z * vector.z ) ) * rotation;
				}
				
				if( dir_buffer != 0 )
				{
					rotationX += ( angleX - rotationX ) * dir_buffer;
					rotationY += ( angleY - rotationY ) * dir_buffer;
				}
				else
				{
					rotationX = angleX;
					rotationY = angleY;
				}
			}
			
			if( doTransform )
			{
				doTransform = false;
				_move = true;
				
				matrix.identity();
				matrix.appendTranslation( - x,- y,- z );
				
				var rotation_matrix:Matrix3D = new Matrix3D();
				if( rotationZ != 0 )
				{
					rotation_matrix.appendRotation( - rotationZ,Vector3D.Z_AXIS );		
				}
				
				if( rotationY != 0 )
				{
					rotation_matrix.appendRotation( - rotationY,Vector3D.Y_AXIS );
				}
				
				if( rotationX != 0 )
				{
					rotation_matrix.appendRotation( - rotationX,Vector3D.X_AXIS );
				}
				
				matrix.append( rotation_matrix );
			}
		}
		
		/**
		 * 目标.
		 */
		private var _target:Vector3D = null;
		
		/**
		 * 相机焦距.
		 */
		private var _focus:Number = 250;
		
		/**
		 * 相机数组.
		 */
		private var _matrix:Matrix3D;
		
		/**
		 * 是否执行渲染.
		 */
		private var doTransform:Boolean;
		
		/**
		 * 换方向缓冲,如果设置,转移目标时候将进行动画插值.
		 */
		private var dir_buffer:Number;
		
		/**
		 * 相机是否移动.
		 */
		private var _move:Boolean;
		
	}
}