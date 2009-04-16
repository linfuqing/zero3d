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

package zerO.lights
{
	import flash.geom.Vector3D;
	
	import zerO.geom.points.Point3D;
	import zerO.geom.triangle.Triangle2D;
	
	/**
	 * 灯,初级灯.
	 */
	public class Light extends Point3D
	{
		/**
		 * 灯光颜色. 
		 */
		public function set color( volue:uint ):void
		{
			_color = volue;
		}
		
		/**
		 * 灯光颜色. 
		 */
		public function get color():uint
		{
			return _color;
		}
		
		/**
		 * 设置亮度.
		 */
		public function set brightness( b:Number ):void
		{
			_brightness = Math.max( b,0 );
			_brightness = Math.min( _brightness,1 );
		}
		
		/**
		 * 设置亮度.
		 */
		public function get brightness():Number
		{
			return _brightness;
		}

		/**
		 * 构建新的灯光.
		 */
		public function Light( 
		x:Number = 0,
		y:Number = 0,
		z:Number = -100,
		brightness:Number = 1,
		color:uint = 0xff0000 )
		{
			this.x = x;
			this.y = y;
			this.z = z;
			this.brightness = brightness;
			this.color = color;
		}
		
		/**
		 * 获取灯影响后的颜色.
		 */ 
		public function getAdjustColor( triangle:Triangle2D,color:uint ):uint
		{
			var red:Number = color >> 16;
			var green:Number = color >> 8 & 0xff;
			var blue:Number = color & 0xff;
			
			var lightFactor:Number = getLightFactor( triangle );
			red *= lightFactor;
			green *= lightFactor;
			blue *=lightFactor;
			
			return red << 16 | green << 8 | blue;
		}
		
		/**
		 * 获取灯光强度.
		 */
		private function getLightFactor( triangle:Triangle2D ):Number
		{
			var ab:Vector3D = triangle.pointA.parent.subtract( triangle.pointB.parent );
			var bc:Vector3D = triangle.pointB.parent.subtract( triangle.pointC.parent );
			var rate:Number = Vector3D.angleBetween( ab.crossProduct( bc ),position ) / Math.PI;
			return rate * brightness;
		}
		
				
		/**
		 * 灯光强度.
		 */
		private var _brightness:Number;
		
		/**
		 * 颜色.
		 */
		private var _color:uint;
		
	}
}