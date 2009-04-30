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
	import flash.display.Graphics;
	
	/**
	 * 渐变笔触。指定一种渐变，用于绘制线条时的笔触。
	 */
	public class GradientBrushwork implements IBrushwork
	{
		/**
		 * 基础线条笔触.
		 */
		public var brushwork:LineBrushwork;
		
		/**
		 * 用于指定要使用哪种渐变类型的 GradientType 类的值：GradientType.LINEAR 或 GradientType.RADIAL。
		 */
		public var type:String;
		
		/**
		 * 要在渐变中使用的 RGB 十六进制颜色值数组（例如，红色为 0xFF0000，蓝色为 0x0000FF 等等）。
		 */
		public var colors:Array;
		
		/**
		 * colors 数组中对应颜色的 alpha 值数组；有效值为 0 到 1。 如果值小于 0，则默认值为 0。 如果值大于 1，则默认值为 1。
		 */
		public var alphas:Array;
		
		/**
		 * 颜色分布比率的数组；有效值为 0 到 255。 该值定义 100% 采样的颜色所在位置的宽度百分比。
		 *  值 0 表示渐变框中的左侧位置，255 表示渐变框中的右侧位置。
		 * 此值表示渐变框中的位置，而不是最终渐变的坐标空间，最终渐变可能会比渐变框更宽或更窄。为 colors 参数中的每个值指定一个值。 
		 */
		public var ratios:Array;
		
		/**
		 * 渐变矩阵。
		 */
		public var matrix:Matrix;
		
		/**
		 * 用于指定要使用哪种 spread 方法的 SpreadMethod 类的值。
		 */
		public var spreadMethod:String;
		
		/**
		 * 用于指定要使用哪个值的 InterpolationMethod 类的值。
		 */
		public var interpolationMethod:String;
		
		/**
		 * 一个控制渐变的焦点位置的数字。
		 * 值 0 表示焦点位于中心。
		 * 值 1 表示焦点位于渐变圆的一条边界上。
		 * 值 -1 表示焦点位于渐变圆的另一条边界上。
		 * 小于 -1 或大于 1 的值将舍入为 -1 或 1。
		 */
		public var focalPointRatio:Number;
		
		/**
		 * 构建新的渐变笔触。
		 * @param brushwork            基础线条笔触.
		 * @param type                 用于指定要使用哪种渐变类型的 GradientType 类的值：GradientType.LINEAR 或 GradientType.RADIAL。
		 * @param colors               要在渐变中使用的 RGB 十六进制颜色值数组（例如，红色为 0xFF0000，蓝色为 0x0000FF 等等）。
		 * @param alpha                colors 数组中对应颜色的 alpha 值数组；有效值为 0 到 1。 如果值小于 0，则默认值为 0。 如果值大于 1，则默认值为 1。
		 * @param ratios               颜色分布比率的数组；有效值为 0 到 255。 该值定义 100% 采样的颜色所在位置的宽度百分比。
		 *                             值 0 表示渐变框中的左侧位置，255 表示渐变框中的右侧位置。
		 *                             此值表示渐变框中的位置，而不是最终渐变的坐标空间，最终渐变可能会比渐变框更宽或更窄。为 colors 参数中的每个值指定一个值。 
		 * @param matrix               渐变矩阵。
		 * @param spreadMethod         用于指定要使用哪种 spread 方法的 SpreadMethod 类的值。
		 * @param interpolationMethod  用于指定要使用哪个值的 InterpolationMethod 类的值。
		 * @param focalPointRatio      一个控制渐变的焦点位置的数字。
		 *                             值 0 表示焦点位于中心。
		 *                             值 1 表示焦点位于渐变圆的一条边界上。
		 *                             值 -1 表示焦点位于渐变圆的另一条边界上。
		 *                             小于 -1 或大于 1 的值将舍入为 -1 或 1。
		 */
		public function GradientBrushwork(
		brushwork:LineBrushwork,
		type:String, 
		colors:Array, 
		alphas:Array, 
		ratios:Array, 
		matrix:Matrix = null, 
		spreadMethod:String = "pad", 
		interpolationMethod:String = "rgb", 
		focalPointRatio:Number = 0 )
		{
			this.brushwork = brushwork;
			this.type = type;
			this.colors = colors;
			this.alphas = alphas;
			this.ratios = ratios;
			this.matrix = matrix;
			this.spreadMethod = spreadMethod;
			this.interpolationMethod = interpolationMethod;
			this.focalPointRatio = focalPointRatio;
		}
		
		/**
		 * 设置线条样式。
		 */
		public function setLineStyle(graphics:Graphics):void
		{
			brushwork.setLineStyle( graphics );
			graphics.lineGradientStyle( type,colors,alphas,rotios,matrix,spreadMethod,interpolationMethod,focalPointRatio );
		}
		
	}
}