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
	import zerO.particles.Particle;
	import zerO.particles.Particle2D;
	import zerO.veiw.BitmapViewport;
	import zerO.veiw.IViewport;
	
	/**
	 * 火花材质.与模糊滤镜结合效果很好.只能在位图视口下使用.
	 */
	public class Spark extends ParticleMaterial implements IParticleMaterial, IBitmapViewportMaterial
	{
		/**
		 * 亮度.
		 */
		public var lightness:Number;
		
		/**
		 * 颜色.
		 */		
		public function set color( volue:uint ):void
		{
			_color = volue;
		}
		
		/**
		 * 颜色.
		 */
		public function get color():uint
		{
			return _color;
		}
		
		/**
		 * 获取位图.这里返回null.
		 */
		public function get bitmapData():BitmapData
		{
			return null;
		}
		
		/**
		 * 构建新的火花.
		 */
		public function Spark( color:uint = 0xff000000,lightness:Number = 5 )
		{
			super();
			this.color = color;
			this.lightness = lightness;
		}
		
		override protected function drawParticle(particle2D:Particle2D, view:IViewport):void
		{
			if( particle2D.parent.type == Particle.CIRCLE )
			{
				drawCircle( particle2D,view );
			}
			else if( particle2D.parent.type == Particle.RECTANGLE )
			{
				drawRectangle( particle2D,view );
			}
		}
		
		/**
		 * 画圆.
		 */
		private function drawCircle(particle2D:Particle2D, view:IViewport):void
		{
			var viewport:BitmapViewport = view as BitmapViewport;
			var particle:Particle = particle2D.parent;
			
			var maxRadius:Number = particle.radius * particle2D.point.scale;
			var numPixels:Number = lightness * particle2D.point.scale;
				
			for( var i:uint = 0;i < numPixels;i++ )
			{
				var angle:Number = Math.random() * 2 * Math.PI;
				var screenRadius:Number = maxRadius * Math.random();
				viewport.bitmapData.setPixel32( 
				particle2D.point.x + screenRadius * Math.cos( angle ),
				particle2D.point.y + screenRadius * Math.sin( angle ),
				color );
			}
		}
		
		/**
		 * 画矩形.
		 */
		private function drawRectangle(particle2D:Particle2D, view:IViewport):void
		{
			var viewport:BitmapViewport = view as BitmapViewport;
			var particle:Particle = particle2D.parent;
			
			var maxWidth:Number = particle.width * particle2D.point.scale;
			var maxHeight:Number = particle.height * particle2D.point.scale;
			var numPixels:Number = lightness * particle2D.point.scale;
				
			for( var i:uint = 0;i < numPixels;i++ )
			{
				viewport.bitmapData.setPixel( 
				particle2D.point.x + Math.random() * maxWidth - maxWidth / 2,
				particle2D.point.y + Math.random() * maxHeight - maxHeight / 2,
				color );
			}			
		}
		
		/**
		 * 颜色.
		 */
		private var _color:uint;
	}
}