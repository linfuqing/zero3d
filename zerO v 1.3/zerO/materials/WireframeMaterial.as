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
	import flash.display.BitmapData;
	import flash.display.Graphics;
	
	import zerO.geom.triangle.Triangle2D;
	import zerO.lights.Light;
	import zerO.materials.line.IBrushwork;
	import zerO.materials.line.LineBrushwork;
	
	/**
	 * 线框材质，将面以线条显示.
	 * 可以做三角形材质,也可以做线材质.
	 */
	public class WireframeMaterial extends TriangleMaterial implements ITriangleMaterial, ILineMaterial
	{
		public var brushwork:IBrushwork;
		
		/**
		 * 是否网格处理.
		 * 如果是,三角形将显示3条边.
		 * 否则三角形显示外面两条边.
		 */		
		public var slash:Boolean;

		/**
		 * 获取颜色.
		 */				
		public function get color():uint
		{
			return 0;
		}
		
		/**
		 * 获取当前位图.此时返回null.
		 */
		public function get bitmapData():BitmapData
		{
			return null;
		}
		
		/**
		 * 构造新的线框材质.
		 * 
		 * @param brushwork    笔触.使用请查看官方文档说明.
		 * @param slash        是否网格处理.如果是,三角形将显示3条边.否则三角形显示外面两条边.
		 */
		public function WireframeMaterial( 
		brushwork:IBrushwork = null,
		slash:Boolean = true )
		{
			this.brushwork = brushwork ? brushwork : new LineBrushwork();
			this.slash = slash;
		}

		/**
		 * 画三角形.渲染时调用.
		 * @param triangle 要绘制的三角形.
		 * @param viewpor  视口.
		 */
		override public function drawTriangle(triangle:Triangle2D,graphics:Graphics,light:Light ):void
		{
			brushwork.setLineStyle( graphics );
			
			if(slash)
			{
				super.drawTriangle( triangle,graphics,null );
			}
			else
			{
				graphics.moveTo( triangle.pointA.x,triangle.pointA.y );
				graphics.lineTo( triangle.pointB.x,triangle.pointB.y );
				graphics.lineTo( triangle.pointC.x,triangle.pointC.y );
			}
			
			graphics.lineStyle();
		}
	}
}