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
	import flash.geom.Rectangle;
	
	import zerO.materials.IMaterial;
	import zerO.materials.particle.IParticleMaterial;
	import zerO.objects.Object3D;
	import zerO.render.IRender;
	
	/**
	 * 粒子,可使用粒子材质.通常情况下有圆形和矩形两种.
	 */
	public class Particle extends Object3D implements IRender
	{
		/**
		 * 圆形.
		 */
		static public const CIRCLE:String = "circle";
		
		/**
		 * 矩形.
		 */
		static public const RECTANGLE:String = "rectangle";
		
				
		/**
		 * 半径.注意,如果你使用矩形,半径将不可用.
		 */
		public var radius:Number;
		
		/**
		 * 粒子风格获取.
		 */		
		public function get type():String
		{
			return _type;
		}
		
		/**
		 * 此属性无效.
		 */
		public function get parent():Particles
		{
			return null;
		}
		
		/**
		 * 此属性无效.
		 */
		public function set parent( particles:Particles ):void
		{
			
		}
		
				
		public function set interactive( volue:Boolean ):void
		{
			_interactive = volue;
		}
		
		public function get interactive():Boolean
		{
			return _interactive;
		}
		
		/**
		 * 矩形.设置之后粒子风格将变成矩形.材质按照矩形显然.传入null可还原成圆.
		 */
		public function set rectangle( r:Rectangle ):void
		{
			if( r )
			{
				_type = Particle.RECTANGLE;
			}
			else
			{
				_type = Particle.CIRCLE;
			}
			_rectangle = r;
		}
		
		/**
		 * 矩形.设置之后粒子风格将变成矩形.材质按照矩形显然.传入null可取消粒子.
		 */
		public function get rectangle():Rectangle
		{
			return _rectangle;
		}
		
		/**
		 * 设置材质.
		 */
		public function set material( m:IMaterial ):void
		{
			if( m is IParticleMaterial )
			{
				_material = m as IParticleMaterial;
			}
		}
		
		/**
		 * 设置材质.
		 */		
		public function get material():IMaterial
		{
			return _material;
		}
		
		/**
		 * 获取宽.
		 */
		public function get width():Number
		{
			if( type == Particle.RECTANGLE )
			{
				return rectangle.width;
			}
			return radius * 2;
		}
		
		/**
		 * 获取高.
		 */
		public function get height():Number
		{
			if( type == Particle.RECTANGLE )
			{
				return rectangle.height;
			}
			return radius * 2;
		}
		
		/**
		 * 构建新的粒子.
		 */
		public function Particle( material:IParticleMaterial,radius:Number,rectangle:Rectangle = null )
		{
			this.material = material;
			this.radius = radius;
			this.rectangle = rectangle;
			
			super();
		}
		
		/**
		 * 材质.
		 */		
		private var _material:IParticleMaterial;
		
		/**
		 * 风格.
		 */
		private var _type:String;

		/**
		 * 矩形.
		 */
		private var _rectangle:Rectangle;
		
				
		/**
		 * 是否交互.
		 */
		private var _interactive:Boolean;
		
	}
}