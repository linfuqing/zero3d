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
	
	/**
	 * 弹力.使用它你必须有一个基点.弹力是作用于一个基点的.
	 */
	public class Elasticity extends Force
	{
		/**
		 * 弹力系数设置.
		 */
		public function set tautness( t:Number ):void
		{
			_tautness = t;
		}
		
		/**
		 * 弹力系数设置.
		 */
		public function get tautness():Number
		{
			return _tautness;
		}
		
		/**
		 * 基点,设置后,弹力向机电作用.
		 */
		public function set anchor( a:Vector3D ):void
		{
			_anchor = a;
		}
		
		/**
		 * 基点,设置后,弹力向机电作用.
		 */
		public function get anchor():Vector3D
		{
			return _anchor;
		}
		
		/**
		 * 构建弹力.
		 * @param anchor   基点.
		 * @param tautness 弹力系数.
		 */
		public function Elasticity( anchor:Vector3D,tautness:Number,name:String )
		{
			super( new Vector3D(),name );
			this.anchor = anchor;
			this.tautness = tautness;
			style = Force.STYLE_UNLIMITED;
		}
		
		/**
		 * 升级力.
		 */
		override public function update():void
		{
			_volue = parent.target.worldPosition.subtract( anchor );
			volue.w = tautness;
			volue.project();
			volue.w = 1;
		}
		
		/**
		 * 弹力系数.
		 */
		private var _tautness:Number;
		
		/**
		 * 基点.
		 */
		private var _anchor:Vector3D;
	}
}