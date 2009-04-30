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
	 * 笔触接口.
	 * <p>
	 * 笔触由线框材质和线条材质调用.
	 * 它可生成各种各样的3D线条样式.
	 */
	public class LineBrushwork implements IBrushwork
	{
		/**
		 * 一个整数，以磅为单位表示线条的粗细；有效值为 0 到 255。如果未指定数字，或者未定义该参数，则不绘制线条。
		 *  如果传递的值小于 0，则默认值为 0。 
		 * 值 0 表示极细的粗细；最大粗细为 255。 
		 * 如果传递的值大于 255，则默认值为 255。
		 */
		public var thickness:Number;
		
		/**
		 * 线条的十六进制颜色值（例如，红色为 0xFF0000，蓝色为 0x0000FF 等）。 如果未指明值，则默认值为 0x000000（黑色）。 可选。
		 */
		public var color:uint;
		
		/**
		 * 表示线条颜色的 Alpha 值的数字；有效值为 0 到 1。 
		 * 如果未指明值，则默认值为 1（纯色）。 
		 * 如果值小于 0，则默认值为 0。 
		 * 如果值大于 1，则默认值为 1。
		 */
		public var alpha:Number;
		
		/**
		 * 用于指定是否提示笔触采用完整像素的布尔值。 
		 * 它同时影响曲线锚点的位置以及线条笔触大小本身。 
		 * 在 pixelHinting 设置为 true 的情况下，线条宽度会调整到完整像素宽度。
		 * 在 pixelHinting 设置为 false 的情况下，对于曲线和直线可能会出现脱节。
		 */
		public var pixelHinting:Boolean;
		
		/**
		 * 用于指定要使用哪种缩放模式的 LineScaleMode 类的值。
		 */
		public var scaleMode:String;
		
		/**
		 * 用于指定线条末端处端点类型的 CapsStyle 类的值。 
		 * 有效值为：CapsStyle.NONE、CapsStyle.ROUND 和 CapsStyle.SQUARE。 
		 * 如果未指示值，则 Flash 使用圆头端点。 
		 */
		public var caps:String;
		
		/**
		 * JointStyle 类的值，指定用于拐角的连接外观的类型。 
		 * 有效值为：JointStyle.BEVEL、JointStyle.MITER 和 JointStyle.ROUND。 
		 * 如果未指示值，则 Flash 使用圆角连接。
		 */
		public var joints:String;
		
		/**
		 * 一个表示将在哪个限制位置切断尖角的数字。 
		 * 有效值的范围是 1 到 255（超出该范围的值将舍入为 1 或 255）。
		 * 此值只可用于 jointStyle 设置为 "miter" 的情况下。 
		 * miterLimit 值表示向外延伸的尖角可以超出角边相交所形成的结合点的长度。 
		 * 此值表示为线条 thickness 的因子。 
		 * 例如，miterLimit 因子为 2.5 且 thickness 为 10 像素时，尖角将在 25 像素处切断。 
		 */
		public var miterLimit:Number;
		
		/**
		 * 构建新的基础线条笔触。
		 * 
		 * @param thickness    一个整数，以磅为单位表示线条的粗细；有效值为 0 到 255。如果未指定数字，或者未定义该参数，则不绘制线条。
		 *                     如果传递的值小于 0，则默认值为 0。 
		 *                     值 0 表示极细的粗细；最大粗细为 255。 
		 *                     如果传递的值大于 255，则默认值为 255。
		 * @param color        线条的十六进制颜色值（例如，红色为 0xFF0000，蓝色为 0x0000FF 等）。 
		 *                     如果未指明值，则默认值为 0x000000（黑色）。 可选。
		 * @param alpha        表示线条颜色的 Alpha 值的数字；有效值为 0 到 1。 
		 *                     如果未指明值，则默认值为 1（纯色）。 
		 *                     如果值小于 0，则默认值为 0。 
		 *                     如果值大于 1，则默认值为 1。
		 * @param pixelHinting 用于指定是否提示笔触采用完整像素的布尔值。 
		 *                     它同时影响曲线锚点的位置以及线条笔触大小本身。 
		 *                     在 pixelHinting 设置为 true 的情况下，线条宽度会调整到完整像素宽度。
		 *                     在 pixelHinting 设置为 false 的情况下，对于曲线和直线可能会出现脱节。
		 * @param scaleMode    用于指定要使用哪种缩放模式的 LineScaleMode 类的值。
		 * @param caps         用于指定线条末端处端点类型的 CapsStyle 类的值。 
		 *                     有效值为：CapsStyle.NONE、CapsStyle.ROUND 和 CapsStyle.SQUARE。 
		 *                     如果未指示值，则 Flash 使用圆头端点。 
		 * @param joints       JointStyle 类的值，指定用于拐角的连接外观的类型。 
		 *                     有效值为：JointStyle.BEVEL、JointStyle.MITER 和 JointStyle.ROUND。 
		 *                     如果未指示值，则 Flash 使用圆角连接。
		 * @param miterLimit   一个表示将在哪个限制位置切断尖角的数字。 
		 *                     有效值的范围是 1 到 255（超出该范围的值将舍入为 1 或 255）。
		 *                     此值只可用于 jointStyle 设置为 "miter" 的情况下。 
		 *                     miterLimit 值表示向外延伸的尖角可以超出角边相交所形成的结合点的长度。 
		 *                     此值表示为线条 thickness 的因子。 
		 *                     例如，miterLimit 因子为 2.5 且 thickness 为 10 像素时，尖角将在 25 像素处切断。 
		 */
		public function LineBrushwork(
		thickness:Number = NaN,
		color:uint = 0, 
		alpha:Number = 1.0, 
		pixelHinting:Boolean = false, 
		scaleMode:String = "normal", 
		caps:String = null, 
		joints:String = null, 
		miterLimit:Number = 3 )
		{
			this.thickness = thickness;
			this.color = color;
			this.alpha = alpha;
			this.pixelHinting = pixelHinting;
			this.scaleMode = scaleMode;
			this.caps = caps;
			this.joints = joints;
			this.miterLimit = miterLimit;
		}
		
		/**
		 * 设置线条样式。
		 */
		public function setLineStyle(graphics:Graphics):void
		{
			graphics.lineStyle( 
			thickness,
			color,
			alpha,
			pixelHinting,
			scaleMode,
			caps,
			joints,
			miterLimit );
		}
		
	}
}