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

package zerO.materials.particle
{
	import flash.display.BitmapData;
	
	import zerO.materials.viewport.IBitmapViewportMaterial;
	import zerO.particles.Particle2D;
	import zerO.veiw.BitmapViewport;
	import zerO.veiw.IViewport;
	
	/**
	 * 单个像素粒子材质。
	 */
	public class ParticlePiexlMaterial extends ParticleMaterial implements IBitmapViewportMaterial, IParticleMaterial
	{
		/**
		 * 颜色。
		 */		
		public function set color( c:uint ):void
		{
			_color = c;
		}
		
		/**
		 * 颜色。
		 */
		public function get color():uint
		{
			return _color;
		}
		
		/**
		 * 获取位图数据。
		 */
		public function get bitmapData():BitmapData
		{
			return null;
		}

		/**
		 * 构建新的粒子材质。
		 * 
		 * @param color 颜色。
		 */
		public function ParticlePiexlMaterial( color:uint = 0xffffffff )
		{
			super();
			this.color = color;
		}
		
		/**
		 * 画粒子。
		 */
		override protected function drawParticle(particle2D:Particle2D, view:IViewport):void
		{
			var viewport:BitmapViewport = view as BitmapViewport;
			viewport.bitmapData.setPixel32( particle2D.point.x,particle2D.point.y,color );
		}
		
		/**
		 * 颜色。
		 */
		private var _color:uint;
	}
}