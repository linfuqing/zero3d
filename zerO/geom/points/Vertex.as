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
	import flash.geom.Point;
	
	/**
	 * 几何体顶点.通常包含几何体UV等信息.
	 */
	public class Vertex extends Point3D
	{
		/**
		 * 构建顶点.
		 * @param x x
		 * @param y y
		 * @param z z
		 */
		public function Vertex( x:Number = 0,y:Number = 0,z:Number = 0 )
		{
			super( x,y,z );
		}
		
		override public function clone():Point3D
		{
			var vertex:Vertex = new Vertex( x,y,z );
			vertex.worldCenter = worldCenter.clone();
			return vertex;
		}
	}
}