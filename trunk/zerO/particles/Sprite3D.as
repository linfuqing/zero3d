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

package zerO.particles
{
	import flash.display.Sprite;
	
	import zerO.geom.points.Point3D;
	
	public class Sprite3D extends Point3D
	{
		//内置精灵
		public var sprite:Sprite = new Sprite();
		
		
		/**
		 * ___________________________________
		 *                                 New
		 *                3D精灵
		 */
		public function Sprite3D()
		{
		}

	}
}