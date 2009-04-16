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
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	/**
	 * 3维点,几乎是zerO3d所有类的核心.它具有世界坐标,真是坐标,和中心点三个属性.
	 */
	public class Point3D extends EventDispatcher
	{
		/**
		 * 真实位置,即相对于舞台的位置.
		 */
		public function get position():Vector3D
		{
			return _position;
		}
		
		/**
		 * 真实X.
		 */
		public function get tx():Number
		{
			return _position.x;
		}

		/**
		 * 真实Y.
		 */
		public function get ty():Number
		{
			return _position.y;
		}

		/**
		 * 真实Z.
		 */
		public function get tz():Number
		{
			return _position.z;
		}
		
		//Set and get worldPosition:
		
		/**
		 * 设置3D点在世界的位置,即相对于世界中心的位置,实际就是3D点的XYZ.
		 */
		public function set worldPosition( world_position:Vector3D ):void
		{
			x = world_position.x;
			y = world_position.y;
			z = world_position.z;
		}
		
		/**
		 * 设置3D点在世界的位置,即相对于世界中心的位置,实际就是3D点的XYZ.
		 */
		public function get worldPosition():Vector3D
		{
			return world_position;
		}
		
		/**
		 * 设置X值.
		 */
		public function set x( world_x:Number ):void
		{
			world_position.x = world_x;
			_position.x = world_x + world_center.x;
			
			_update = true;
		}
		
		/**
		 * 设置X值.
		 */
		public function get x():Number
		{
			return world_position.x;
		}
		
		/**
		 * 设置Y值.
		 */
		public function set y( world_y:Number ):void
		{
			world_position.y = world_y;
			_position.y = world_y + world_center.y;
			
			_update = true;
		}
		
		/**
		 * 设置Y值.
		 */
		public function get y():Number
		{
			return world_position.y;
		}
		
		/**
		 * 设置Z值.
		 */
		public function set z( world_z:Number ):void
		{
			world_position.z = world_z;
			_position.z = world_z + world_center.z;
			
			_update = true;
		}
		
		/**
		 * 设置Z值.
		 */
		public function get z():Number
		{
			return world_position.z;
		}
		
		/**
		 * 设置世界中心,也称为注册点.
		 */
		public function set worldCenter( world_center:Vector3D ):void
		{
			this.world_center = world_center;
			_position = world_position.add( world_center );
			
			_update = true;
		}
		
		/**
		 * 设置世界中心,也称为注册点.
		 */
		public function get worldCenter():Vector3D
		{
			return world_center;
		}
		
		public function get move():Boolean
		{
			return _move;
		}
		
		/**
		 * 构建3D点.
		 * @param x x
		 * @param y y
		 * @param z z
		 */
		public function Point3D( x:Number = 0,y:Number = 0,z:Number = 0 )
		{
			super();
			
			init();
			
			this.x = x;
			this.y = y;
			this.z = z;
		}
		
		/**
		 * 初始化.
		 */
		private function init():void
		{
			world_position = new Vector3D();
			_position = new Vector3D();
			world_center = new Vector3D();
			rotationMatrix = new Matrix3D();
			doRotation = false;
			_update = false;
			_move = false;
		}
		
		/**
		 * 克隆本身,返回一个与自身一模一样的3D点.
		 * @return 克隆本身.
		 */
		public function clone():Point3D
		{
			var point:Point3D = new Point3D(x,y,z);
			point.worldCenter = worldCenter.clone();
			return point;
		}
		
		public function update():void
		{
			_position = world_position.add( world_center );
			
			_update = true;
		}
		
		protected function doUpdate():void
		{
			
		}
		
		/**
		 * 执行变换.
		 * 场景整合不用管.
		 * 这是对点的一次性旋转.
		 */
		public function transform():void
		{
			if( doRotation )
			{
				worldPosition = rotationMatrix.deltaTransformVector( worldPosition );
				rotationMatrix.identity();
				doRotation = false;
			}
			
			if( _update )
			{
				_move = true;
				_update = false;
				doUpdate();
			}
			else
			{
				_move = false;
			}
		}

		/**
		 * 绕注册点做X轴旋转.
		 * @param angleX 旋转的角度.
		 */
		public function rotateX( angleX:Number ):void
		{
			rotationMatrix.appendRotation( angleX,Vector3D.X_AXIS );
			
			doRotation = true;
		}
		
		/**
		 * 绕注册点做Y轴旋转.
		 * @param angleY 旋转的角度.
		 */
		public function rotateY( angleY:Number ):void
		{
			rotationMatrix.appendRotation( angleY,Vector3D.Y_AXIS );
			
			doRotation = true;
		}
		
		/**
		 * 绕注册点做Z轴旋转.
		 * @param angleZ 旋转的角度.
		 */
		public function rotateZ( angleZ:Number ):void
		{
			rotationMatrix.appendRotation( angleZ,Vector3D.Z_AXIS );
			
			doRotation = true;
		}

		/**
		 * 转换成字符.
		 * @return 3D点的世界坐标.
		 */
		public override function toString():String
		{
			return "Point3D( x: " + x + ",y: " + y + ",z: " + z + " )";
		}
		
				
		/**
		 * 旋转矩阵.
		 */
		private var rotationMatrix:Matrix3D;

		/**
		 * 是否做旋转变换，开发者的留意.
		 */
		private var doRotation:Boolean;
		
		/**
		 *世界位置，具体请看Blog坐标篇.
		 */
		private var world_position:Vector3D;
		
		/**
		 * 世界中心，可以理解为注册点,点将绕这个点做旋转.
		 */
		private var world_center:Vector3D;
		
		/**
		 * 真实位置，相对视口的位置.
		 */
		private var _position:Vector3D;
		
		private var _update:Boolean;
		
		private var _move:Boolean;
		
	}
}