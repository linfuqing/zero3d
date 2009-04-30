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

package zerO.physics.forces
{
	import flash.geom.Vector3D;
	
	import zerO.physics.controllers.ForceController;
	
	/**
	 * 力.所有力的基类.它可以作用于物理粒子及其子类.
	 */
	public class Force extends Vector3D
	{
				
		/**
		 * 普通力风格.即有生命期的力.
		 */		
		static public const STYLE_NORMAL:uint = 1;
		
		/**
		 * 无限力风格.即无生命期的力.
		 */
		static public const STYLE_UNLIMITED:uint = 0;
		
		/**
		 * 名字.
		 */
		public var name:String;
				
		/**
		 * 设置生存期
		 */
		public function set life( _life:Number ):void
		{
			this._life = _life;
		}
		
		/**
		 * 设置生存期.
		 */
		public function get life():Number
		{
			return _life;
		}
		
				
		/**
		 * 获得力的大小(只读)
		 */
		public function get volue():Vector3D
		{
			return _volue;
		}
		
		/**
		 * 设置作用对象
		 */
		public function set parent( _parent:ForceController ):void
		{
			this._parent = _parent;
		}
		
		/**
		 * 设置作用对象.
		 */
		public function get parent():ForceController
		{
			return _parent;
		}

		/**
		 * 构建力.
		 */
		public function Force( volue:Vector3D,name:String = null )
		{
			this._volue = volue;
			this.name = name;
		}
		
		/**
		 * 力生存,如果力非无限力,不断调用生存期会减少.
		 */
		public function live():Boolean
		{
			if ( style && _life-- <= 0 )
			{
				return false;
			}
			update();
			return true;
		}
		
		/**
		 * 供子类用
		 */
		public function update():void
		{
		}

		/**
		 * 作用的对象.
		 */
		private var _parent:ForceController;
		
		/**
		 * 生存期.
		 */
		private var _life:Number = 1;
		
				
		/**
		 * 力大小.
		 */
		protected var _volue:Vector3D;
		
		/**
		 * 力的类型.
		 * 设置它可以使力有不同的生命期.
		 */
		protected var style:uint = Force.STYLE_NORMAL;

	}
}