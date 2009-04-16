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
	 * 重力,也称向心力.它始终向Y轴正方向作用.
	 */
	public class Gravity extends Force
	{
		/**
		 * 构建重力.
		 */
		public function Gravity( volue:Number,name:String = null )
		{
			super( new Vector3D( 0,volue,0 ),name );
			style = Force.STYLE_UNLIMITED;
		}

	}
}