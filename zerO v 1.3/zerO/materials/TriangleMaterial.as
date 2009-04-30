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

package zerO.materials
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	import zerO.geom.triangle.Triangle2D;
	import zerO.lights.Light;
	import zerO.materials.line.LineBrushwork;
	import zerO.utils.NameSetter;
	import zerO.veiw.IViewport;
	
	/**
	 * 三角形材质,做抽象类,不使用.
	 */
	public class TriangleMaterial extends NameSetter
	{
				
		/**
		 * 获取默认材质.
		 */
		static public function get DEFAULT_MATERIAL():ITriangleMaterial
		{
			return new WireframeMaterial( new LineBrushwork(1,Math.random() * 0xffffff) );
		}
		
		/**
		 * 是否交互.
		 */		
		public var interactive:Boolean;
					
		/**
		 * 单双面设置.
		 */ 
		public function set doubleSided( volue:Boolean ):void
		{
			_doubleSided = volue;
		}
		
		/**
		 * 单双面设置.
		 */
		public function get doubleSided():Boolean
		{
			return _doubleSided;
		}

		/**
		 * 三角形材质,做抽象类,不使用.
		 */
		public function TriangleMaterial()
		{
			super();
			
			init();
		}
		
		/**
		 * 初始化.
		 */
		private function init():void
		{
			interactive = false;
		}
		
		public function doDraw( object:*,view:IViewport ):Boolean
		{
			var triangle:Triangle2D = object as Triangle2D;
			
			if( ( triangle.parent.backFaceCulling && 
			!doubleSided && triangle.isBackFace() ) ||
			triangle.depth < - view.focus ||
			triangle.minX > view.bounds.width ||
			triangle.minY > view.bounds.height ||
			triangle.maxX < view.bounds.x ||
			triangle.maxY < view.bounds.y )
			{
				return false;
			}
			
			return true;
		}
		
		public function doInteractive( object:*,view:IViewport ):void
		{
			var triangle:Triangle2D = object as Triangle2D;
			
			if( triangle.parent.interactive && triangle.hitTestPoint( new Point( view.mouseX,view.mouseY ) ) )
			{
				view.viewport.interactiveList["triangle"] = this;
				
				if( triangle.parent.parent && triangle.parent.parent.interactive )
				{
					view.viewport.interactiveList["geometry"] = triangle.parent.parent;
				}
				
				if( interactive )
				{
					view.viewport.interactiveList["material"] = this;
				}
				
				view.viewport.interactiveList.length += 1;
			}
		}
		
		/**
		 * 绘制材质，渲染时调用.
		 * @param object 绘制项目
		 * @param view   视口
		 */
		public function draw( object:*,view:IViewport ):void
		{
			var triangle:Triangle2D = object as Triangle2D;
			
			drawTriangle( triangle,view.viewport.graphics,view.scene.light );
		}
		
		/**
		 * 画三角形.渲染时调用.
		 * @param triangle 要绘制的三角形.
		 * @param viewpor  视口.
		 */
		public function drawTriangle( triangle:Triangle2D,graphics:Graphics,light:Light ):void
		{		
			graphics.moveTo( triangle.pointA.x,triangle.pointA.y );
			graphics.lineTo( triangle.pointB.x,triangle.pointB.y );
			graphics.lineTo( triangle.pointC.x,triangle.pointC.y );
			graphics.lineTo( triangle.pointA.x,triangle.pointA.y );
		}
		
		/**
		 * 是否双面.
		 */
		private var _doubleSided:Boolean = false;
		
	}
}