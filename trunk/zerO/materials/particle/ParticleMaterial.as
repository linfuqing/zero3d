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
	import zerO.particles.Particle;
	import zerO.particles.Particle2D;
	import zerO.utils.NameSetter;
	import zerO.veiw.IViewport;
	
	/**
	 * 粒子材质,抽象类.供子类调用.
	 */
	public class ParticleMaterial extends NameSetter
	{
		/**
		 * 构建粒子材质.
		 */
		public function ParticleMaterial()
		{
			super();
		}
		
		public function doDraw( object:*,view:IViewport ):Boolean
		{
			var particle2D:Particle2D = object as Particle2D;
			var particle:Particle = particle2D.parent as Particle;
			var halfWidth:Number = particle.width / 2;
			var halfHeight:Number = particle.height / 2;
			
			if( particle2D.point.x < - halfWidth ||
			particle2D.point.x > view.viewport.bounds.width + halfWidth ||
			particle2D.point.y < - halfHeight ||
			particle2D.point.y > view.viewport.bounds.height + halfHeight )
			{
				return false;
			}
			
			return true;
		}
		
		public function doInteractive( object:*,view:IViewport ):void
		{
			
		}
		
		/**
		 * 画.渲染时调用.
		 */
		public function draw(object:*, view:IViewport):void
		{
			var particle2D:Particle2D = object as Particle2D;
			drawParticle( particle2D,view );
		}
		
		/**
		 * 画粒子.
		 */
		protected function drawParticle( particle2D:Particle2D,view:IViewport ):void
		{
			
		}

		
	}
}