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
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	
	/**
	 * 3维点,几乎是zerO3d所有类的核心.它具有世界坐标,真是坐标,和中心点三个属性.
	 */
	public class Point3D extends EventDispatcher
	{
		/**
		 * 获取世界坐标.
		 */
		public function get worldPosition():Vector3D
		{
			return world_position;
		}

		//Set and get worldPosition:
		/**
		 * 设置相对位置.
		 */
		public function set position( pos:Vector3D ):void
		{
			_position.x = pos.x;
			_position.y = pos.y;
			_position.z = pos.z;
			
			doTransform = true;
		}
		
		/**
		 * 获取相对坐标,即X,Y,Z的Vector3D形式.
		 * 注意:你不能修改此向量而改变点的位置.
		 * 请使用set position方法.
		 */
		public function get position():Vector3D
		{
			return _position.clone();
		}

		/**
		 * 设置X值.
		 */
		public function set x( _x:Number ):void
		{
			_position.x = _x;
			
			doTransform = true;
		}
		
		/**
		 * 设置X值.
		 */
		public function get x():Number
		{
			return _position.x;
		}
		
		/**
		 * 设置Y值.
		 */
		public function set y( _y:Number ):void
		{
			_position.y = _y;
			
			doTransform = true;
		}
		
		/**
		 * 设置Y值.
		 */
		public function get y():Number
		{
			return _position.y;
		}
		
		/**
		 * 设置Z值.
		 */
		public function set z( _z:Number ):void
		{
			_position.z = _z;
			
			doTransform = true;
		}
		
		/**
		 * 设置Z值.
		 */
		public function get z():Number
		{
			return _position.z;
		}
		
		/**
		 * 设置世界矩阵.
		 */
		public function set world( m:Matrix3D ):void
		{
			_matrix = m;
			
			doTransform = true;
		}
		
		/**
		 * 获取世界矩阵.
		 * 注意:你修改此矩阵无法改变点的世界变换.
		 * 如果你想修改点的世界矩阵,请使用set world方法.
		 */
		public function get world():Matrix3D
		{
			return _matrix ? _matrix.clone() : new Matrix3D();
		}
		
		/**
		 * 检测点是否移动.
		 */
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
			_matrix = null;
			doTransform = false;
			_move = false;
		}
		
		/**
		 * 克隆本身,返回一个与自身一模一样的3D点.
		 * @return 克隆本身.
		 */
		public function clone():Point3D
		{
			var point:Point3D = new Point3D(x,y,z);
			
			return point;
		}
		
		/**
		 * 如果做变化,更新它.
		 */
		protected function update():void
		{
			
		}
		
		/**
		 * 执行变换.
		 * 场景整合不用管.
		 * 这是对点的一次性旋转.
		 */
		public function transform():void
		{
			if( doTransform )
			{
				update();
				
				var vector:Vector3D = _matrix ? Utils3D.projectVector( _matrix, _position ) : _position;
				
				setWorldPosition( vector );
				
				doTransform = false;
				_move = true;
			}
			else
			{
				_move = false;
			}
		}
		
		/**
		 * 设置世界坐标.
		 */
		protected function setWorldPosition( v:Vector3D ):void
		{
			world_position.x = v.x;
			world_position.y = v.y;
			world_position.z = v.z;
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
		private var _matrix:Matrix3D;

		/**
		 * 是否做旋转变换，开发者的留意.
		 */
		protected var doTransform:Boolean;
		
		/**
		 *世界位置，具体请看Blog坐标篇.
		 */
		private var world_position:Vector3D;

		/**
		 * 真实位置，相对视口的位置.
		 */
		protected var _position:Vector3D;
		
		/**
		 * 点是否移动.
		 */
		private var _move:Boolean;
		
	}
}