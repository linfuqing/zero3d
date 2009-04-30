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
	import flash.display.Graphics;
	
	import zerO.particles.Particle;
	import zerO.particles.Particle2D;
	import zerO.veiw.IViewport;
	
	/**
	 * 粒子颜色材质。
	 */
	public class ParticleColorMaterial extends ParticleMaterial implements IParticleMaterial
	{
		/**
		 * 透明度。
		 */
		public var alpha:Number;
		
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
		 * 获取位图数据，当前为null.
		 */
		public function get bitmapData():BitmapData
		{
			return null;
		}
		
		/**
		 * 构建新的粒子颜色材质。
		 */
		public function ParticleColorMaterial(color:uint = 0xffffff,alpha:Number = 1 )
		{
			super();
			this.color = color;
			this.alpha = alpha;
		}
		
		/**
		 * 画粒子。
		 * @param particle2D 粒子投影。
		 * @param view       视口。
		 */
		override protected function drawParticle(particle2D:Particle2D, view:IViewport):void
		{
			view.viewport.graphics.beginFill( color,alpha );
			
			if( particle2D.parent.type == Particle.CIRCLE )
			{
				view.viewport.graphics.drawCircle( particle2D.point.x,particle2D.point.y,particle2D.parent.radius * particle2D.point.scale );
			}
			else if( particle2D.parent.type == Particle.RECTANGLE )
			{
				view.viewport.graphics.drawRect( particle2D.point.x,particle2D.point.y,particle2D.parent.width * particle2D.point.scale,particle2D.parent.height * particle2D.point.scale );
			}
			
			view.viewport.graphics.endFill();
		}
		
		/**
		 * 颜色。
		 */
		private var _color:uint;
	}
}