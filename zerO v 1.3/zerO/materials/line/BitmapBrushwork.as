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
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	/**
	 * 位图笔触.
	 * <p>
	 * 指定一个位图，用于绘制线条时的线条笔触.
	 */
	public class BitmapBrushwork implements IBrushwork
	{
		/**
		 * 原始线笔触.
		 */
		public var brushwork:LineBrushwork;
		
		/**
		 * 位图.
		 */
		public var bitmap:Bitmap;
		
		/**
		 * 位图矩阵.它可以对位图产生2维形变.
		 */
		public var matrix:Matrix;
		
		/**
		 * 是否以平铺方式重复位图。
		 */
		public var repeat:Boolean;
		
		/**
		 * 是否应对位图应用平滑处理。
		 */
		public var smooth:Boolean;
		
		/**
		 * 构建新的位图笔触.
		 * @param bitmap    用于线条笔触的位图.
		 * @param matrix    一个由 flash.geom.Matrix 类定义的可选转换矩阵。该矩阵可用于在将位图应用于线条样式之前缩放位图或以其它方式处理位图.
		 * @param repeat    是否以平铺方式重复位图.
		 * @param smooth    是否应对位图应用平滑处理.
		 * @param brushwork 基础线条笔触.
		 */
		public function BitmapBrushwork(
		bitmap:BitmapData, 
		matrix:Matrix = null, 
		repeat:Boolean = true, 
		smooth:Boolean = false,
		brushwork:IBrushwork = null )
		{
			this.bitmap = bitmap;
			this.matrix = matrix;
			this.repeat = smooth;
			this.smooth = smooth;
			this.brushwork = brushwork;
		}
		
		/**
		 * 设置线条样式.
		 */
		public function setLineStyle(graphics:Graphics):void
		{
			brushwork.setLineStyle( graphics );
			graphics.lineBitmapStyle( bitmap,matrix,repeat,smooth );
		}
		
	}
}