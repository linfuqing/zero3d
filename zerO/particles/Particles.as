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
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import zerO.geom.Geometry;
	import zerO.geom.line.Lines;
	import zerO.geom.points.Point3D;
	import zerO.objects.Object3D;
	import zerO.render.IRender;
	
	/**
	 * 粒子系统,是所有多粒子物体的基类.本身渲染列表为空.要使用渲染列表.必须使用其子类.
	 * 使用它可以方便地将你的粒子集进行各种变换.
	 */
	public class Particles extends Object3D
	{
		/**
		 * 交互.
		 */
		public function set interactive( volue:Boolean ):void
		{
			_interactive = volue;
			
			if( renderList )
			{
				for each( var array:Array in renderList )
				{
					for each( var render:IRender in array )
					{
						render.interactive = volue;
					}
				}
			}
		}
		
		/**
		 * 交互.
		 */
		public function get interactive():Boolean
		{
			return _interactive;
		}
				
		/**
		 * 获取渲染列表.
		 */
		public function get render():Array
		{
			return renderList;
		}
		
		/**
		 * 内置粒子.
		 */
		public function get points():Array
		{
			return _points;
		}
		
		/**
		 * 内置粒子.
		 */
		public function set points( p:Array ):void
		{
			_points = p;
		}

		/**
		 * 设置缩放.
		 */
		public function set scale( s:Number ):void
		{
			_scale.w = 1.0 / s;
			
			var scaleProject:Vector3D = _scale.clone();
			scaleProject.project();
			matrix.appendScale( 
			scaleProject.x / _scale.x,
			scaleProject.y / _scale.y,
			scaleProject.z / _scale.z );
			
			doTransform = true;
		}
		
		/**
		 * 设置缩放.
		 */
		public function get scale():Number
		{
			return 1.0 / _scale.w;
		}
		
		/**
		 * 设置X缩放.
		 */
		public function set scaleX( volue:Number ):void
		{
			var scale:Number = volue / _scale.x;
			
			matrix.appendScale( scale,1,1 );
			
			_scale.x = volue;
			
			doTransform = true;
		}
		
		/**
		 * 设置X缩放.
		 */
		public function get scaleX():Number
		{
			return _scale.x;
		}
		
		/**
		 * 设置Y缩放.
		 */
		public function set scaleY( volue:Number ):void
		{
			var scale:Number = volue / _scale.y;
			
			matrix.appendScale( 1,scale,1 );
			
			_scale.y = volue;
			
			doTransform = true;
		}
		
		/**
		 * 设置Y缩放.
		 */
		public function get scaleY():Number
		{
			return _scale.y;
		}
		
		/**
		 * 设置Z缩放.
		 */
		public function set scaleZ( volue:Number ):void
		{
			var scale:Number = volue / _scale.z;
			
			matrix.appendScale( 1,1,scale );
			
			_scale.z = volue;
			
			doTransform = true;
		}
		
		/**
		 * 设置Z缩放.
		 */
		public function get scaleZ():Number
		{
			return _scale.z;
		}
		
		/**
		 * X轴角度.
		 */
		public function set rotationX( angleX:Number ):void
		{
			var angle:Number = angleX - direction.x;
			
			matrix.appendRotation( angle,Vector3D.X_AXIS );
			
			direction.x = angleX;
			
			doTransform = true;
		}
		
		/**
		 * X轴角度.
		 */
		public function get rotationX():Number
		{
			return direction.x;
		}
		
		/**
		 * Y轴角度.
		 */
		public function set rotationY( angleY:Number ):void
		{
			var angle:Number = angleY - direction.y;
			
			matrix.appendRotation( angle,Vector3D.Y_AXIS );
			
			direction.y = angleY;
			
			doTransform = true;
		}
		
		/**
		 * Y轴角度.
		 */
		public function get rotationY():Number
		{
			return direction.y;
		}
		
		/**
		 * Z轴角度.
		 */
		public function set rotationZ( angleZ:Number ):void
		{
			var angle:Number = angleZ - direction.z;
			
			matrix.appendRotation( angle,Vector3D.Z_AXIS );
			
			direction.z = angleZ;
			
			doTransform = true;
		}
		
		/**
		 * Z轴角度.
		 */
		public function get rotationZ():Number
		{
			return direction.z;
		}
		
		/**
		 * 获取变换数组.变换数组包含了粒子系统所有的变换.
		 * 变换即是指位移,缩放及旋转等操作.
		 */
		public function get transformMatrix():Matrix3D
		{
			var matrix:Matrix3D = new Matrix3D();
			matrix.appendTranslation( x,y,z );
			matrix.appendScale( scaleX,scaleY,scaleZ );
			matrix.appendRotation( rotationZ,Vector3D.Z_AXIS );
			matrix.appendRotation( rotationY,Vector3D.Y_AXIS );
			matrix.appendRotation( rotationX,Vector3D.X_AXIS );
			
			return matrix;
		}
		
		/**
		 * 创建一个新的粒子系统.
		 * @param x x;
		 * @param y y;
		 * @param z z;
		 */
		public function Particles( x:Number = 0,y:Number = 0,z:Number = 0 )
		{
			super();
			this.x = x;
			this.y = y;
			this.z = z;
			init();
		}
		
		/**
		 * 初始化.
		 */
		private function init():void
		{
			_points = new Array();
			direction = new Vector3D();
			_scale = new Vector3D(1,1,1);
			_scale.w = 1;
			matrix = new Matrix3D();
			doTransform = false;
			renderList = new Array();
			_interactive = false;
		}
		
						
		/**
		 * 设置几何体.
		 */		
		public function addGeometry( geom:Geometry ):void
		{
			points = points.concat( geom.vertices );
			renderList[ "triangle" ]  = renderList[ "triangle" ] ? renderList[ "triangle" ].concat( geom.triangles ) : geom.triangles.concat();
		}
		
		public function addLines( l:Lines ):void
		{
			points = points.concat( l.points );
			renderList[ "line" ] = renderList[ "line" ] ? renderList[ "line" ].concat( l.lines ) : l.lines.concat();
		}
		
		/**
		 * 建立粒子系统，场景集成了，不用管
		 */
		public function build():void
		{
			for each( var point:Point3D in points )
			{
				point.worldCenter = worldPosition;
			}
			
			for each( var array:Array in renderList )
			{
				for each( var render:IRender in array )
				{
					render.parent = this;
				}
			}
		}

		/**
		 * 依据数组对粒子系统进行各种变换.
		 * @param matrix 变换的数组.
		 */
		public function transformVertices( matrix:Matrix3D ):void
		{
			worldPosition = matrix.transformVector( worldPosition );
			this.matrix.append( matrix );
			doTransform = true;
		}
		
		/**
		 * 依据数组对粒子系统进行各种不含平移元素的转换.
		 * @param matrix 变换的数组.
		 */
		public function deltaTransformVertices( matrix:Matrix3D ):void
		{
			for each( var point:Point3D in points )
			{
				point.worldPosition = matrix.deltaTransformVector( point.worldPosition );
			}
		}
		
		public function merge( particles:Particles ):void
		{
			points = points.concat( particles.points );
			
			for( var i:String in particles.renderList )
			{
				renderList[i] = renderList[i] ? renderList[i].concat( particles.renderList[i] ) : particles.renderList[i].concat();
			}
		}
		
		/**
		 * 执行变换.
		 */
		override public function transform():void
		{
			super.transform();
			
			if( doTransform )
			{
				deltaTransformVertices( matrix );
				matrix.identity();
				doTransform = false;
			}
		}
		
		override protected function doUpdate():void
		{
			for each( var point:Point3D in points )
			{
				point.update();
			}
		}
		
		/**
		 * 字符化.
		 */
		public override function toString():String
		{
			return "Particles( points: " + points.length + ", " + super.toString() + " )";
		}
		
		/**
		 * 渲染列表.
		 */
		protected var renderList:Array;
			
		/**
		 * 是否变换. 
		 */
		private var doTransform:Boolean;
		
		/**
		 * 非位移变换矩阵.
		 */
		private var matrix:Matrix3D;
		
		/**
		 * 粒子集合.
		 */
		private var _points:Array;
		
		/**
		 * 粒子方向.
		 */
		private var direction:Vector3D;
		
		/**
		 * 缩放.
		 */
		private var _scale:Vector3D;
				
		private var _interactive:Boolean;
		
	}
}