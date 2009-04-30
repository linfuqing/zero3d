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

package zerO.materials.line
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	
	import zerO.geom.line.Line2D;
	import zerO.materials.ILineMaterial;
	import zerO.utils.NameSetter;
	import zerO.veiw.IViewport;
	
	/**
	 * 线条材质.线条渲染时使用.
	 */
	public class LineMaterial extends NameSetter implements ILineMaterial
	{		
		/**
		 * 获取默认线材质.
		 */
		static public function get DEFALUT_MATERIAL():LineMaterial
		{
			return new LineMaterial( new LineBrushwork( 1,Math.random() * 0xffffff ) );
		}
		
		
		/**
		 * 曲线是否穿过中点.
		 */
		public var curveThroughPoint:Boolean;
		
		/**
		 * 获取颜色.当前为0.
		 */
		public function get color():uint
		{
			return 0
		}
		
		/**
		 * 获取位图.当前为null.
		 */
		public function get bitmapData():BitmapData
		{
			return null;
		}
		
		public function set brushwork(b:IBrushwork):void
		{
			_brushwork = b;
		}
		
		public function get brushwork():IBrushwork
		{
			return _brushwork;
		}
		
		/**
		 * 构建新的线条材质.
		 */
		public function LineMaterial( brushwork:IBrushwork )
		{
			this.brushwork = brushwork;
			
			super();
		}
		
		/**
		 * 是否渲染.
		 */
		public function doDraw( object:*,view:IViewport ):Boolean
		{
			var line:Line2D = object;
			
			if( line.depth < - view.focus ||
			line.maxX < view.bounds.x ||
			line.maxY < view.bounds.y ||
			line.minX > view.bounds.width ||
			line.minY > view.bounds.height )
			{
				return false;
			}
			
			return true;
		}
		
		/**
		 * 交互检测.
		 */
		public function doInteractive( object:*,view:IViewport ):void
		{
			
		}
		
		/**
		 * 渲染.
		 */
		public function draw(object:*, view:IViewport):void
		{
			var line:Line2D = object;
			
			drawLine( line,view.viewport.graphics );
			
		}
		
		/**
		 * 画线.
		 */
		public function drawLine( line:Line2D,graphics:Graphics ):void
		{
			_brushwork.setLineStyle( graphics );
			
			graphics.moveTo( line.pointA.x,line.pointA.y );
			
			if( line.curveTo )
			{
				if( line.parent.curveThroughPoint || curveThroughPoint )
				{
					var x:Number = line.pointB.x + line.pointB.x - ( line.pointA.x + line.curveTo.x ) / 2;
					var y:Number = line.pointB.y + line.pointB.y - ( line.pointA.y + line.curveTo.y ) / 2
					graphics.curveTo( x,y,line.curveTo.x,line.curveTo.y );
				}
				else
				{
					graphics.curveTo( line.pointB.x,line.pointB.y,line.curveTo.x,line.curveTo.y );
				}
				
				return;
			}
			
			graphics.lineTo( line.pointB.x,line.pointB.x );
			
			graphics.lineStyle();
		}

		/**
		 * 笔触.
		 */
		private var _brushwork:IBrushwork;
		
	}
}