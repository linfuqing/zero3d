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
	import flash.geom.Matrix;
	
	import zerO.particles.Particle2D;
	import zerO.veiw.IViewport;
	
	/**
	 * 粒子位图材质。
	 */
	public class ParticleBitmapMaterial extends ParticleMaterial implements IParticleMaterial
	{
		/**
		 * 获取位图数据。
		 */
		public function get bitmap():BitmapData
		{
			return bitmapData;
		}
		
		/**
		 * 获取颜色，当前为0。
		 */
		public function get color():uint
		{
			return 0;
		}
		
		/**
		 * 构建新的粒子位图材质。
		 */
		public function ParticleBitmapMaterial( bitmapData:BitmapData )
		{
			super();
			this.bitmapData = bitmapData;
		}
		
		/**
		 * 画粒子。
		 */
		override protected function drawParticle(particle2D:Particle2D, view:IViewport):void
		{
			var matrix:Matrix = new Matrix();
			matrix.scale( particle2D.point.scale,particle2D.point.scale );
			
			view.viewport.graphics.beginBitmapFill( bitmapData,matrix );
			view.viewport.graphics.drawRect( particle2D.point.x,particle2D.point.y,
			bitmapData.width * particle2D.point.scale,bitmapData.height * particle2D.point.scale );
			view.viewport.graphics.endFill();
		}
		
		/**
		 * 位图数据。
		 */
		private var bitmapData:BitmapData;
		
	}
}