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
	import flash.display.Shader;
	import flash.geom.Matrix;
	
	/**
	 * 着色器笔触.
	 */
	public class ShaderBrushwork implements IBrushwork
	{
		/**
		 * 要用于填充的着色器。此 Shader 实例无需指定图像输入。
		 * 但是，如果在着色器中指定图像输入，则必须手动提供输入。
		 * 若要指定输入，请设置 Shader.data 属性的对应 ShaderInput 属性的 input 属性。 
		 * <p>
		 * 传递 Shader 实例作为参数时，会在内部复制着色器。绘图填充操作将使用该内部副本，而不是对原始着色器的引用。
		 * 对着色器进行的任何更改（比如更改参数值、输入或字节代码）不会应用于所复制的用于填充的着色器。
		 */
		public var shader:Shader;
		
		/**
		 * 一个 matrix 对象（属于 flash.geom.Matrix 类），可用于对着色器定义转换。例如，可以使用以下矩阵将着色器旋转 45 度（pi/4 弧度）：
		 * <p>
		 * matrix = new flash.geom.Matrix(); 
		 * <p>
		 * matrix.rotate(Math.PI / 4);
		 * <p>
		 * 着色器中收到的坐标基于为 matrix 参数指定的矩阵。对于默认 (null) 矩阵，着色器中的坐标是可用于对输入采样的局部像素坐标。 
		 */
		public var matrix:Matrix;
		
		/**
		 * 基础线条笔触。
		 */
		public var brushwork:LineBrushwork;
		
		/**
		 * 构建新的着色器笔触。
		 * 
		 * @param shader    要用于填充的着色器。此 Shader 实例无需指定图像输入。
		 *                  但是，如果在着色器中指定图像输入，则必须手动提供输入。
		 *                  若要指定输入，请设置 Shader.data 属性的对应 ShaderInput 属性的 input 属性。 
		 *                  <p>
		 *                  传递 Shader 实例作为参数时，会在内部复制着色器。绘图填充操作将使用该内部副本，而不是对原始着色器的引用。
		 *                  对着色器进行的任何更改（比如更改参数值、输入或字节代码）不会应用于所复制的用于填充的着色器。
		 * @param matrix    一个 matrix 对象（属于 flash.geom.Matrix 类），可用于对着色器定义转换。例如，可以使用以下矩阵将着色器旋转 45 度（pi/4 弧度）：
		 *                  <p>
		 *                  matrix = new flash.geom.Matrix(); 
		 *                  <p>
		 *                  matrix.rotate(Math.PI / 4);
		 *                  <p>
		 *                  着色器中收到的坐标基于为 matrix 参数指定的矩阵。对于默认 (null) 矩阵，着色器中的坐标是可用于对输入采样的局部像素坐标。 
		 * @param brushwork 基础线条笔触。
		 */
		public function ShaderBrushwork(shader:Shader, matrix:Matrix = null,brushwork:LineBrushwork = null )
		{
			this.shader = shader;
			this.matrix = matrix;
			this.brushwork = brushwork;
		}
		
		/**
		 * 设置线条样式。
		 */
		public function setLineStyle(graphics:Graphics):void
		{
			brushwork.setLineStyle( graphics );
			graphics.lineShaderStyle( shader,matrix );
		}
		
	}
}