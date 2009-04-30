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
	import __AS3__.vec.Vector;
	
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.Utils3D;
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
		 * x
		 */
		override public function set x(_x:Number):void
		{
			updateTransform();
			
			super.x = _x;
		}
		
		/**
		 * x
		 */
		override public function get x():Number
		{
			updateTransform();
			
			return super.x;
		}
		
		/**
		 * y
		 */
		override public function set y(_y:Number):void
		{
			updateTransform();
			
			super.y = _y;
		}
		
		/**
		 * y
		 */
		override public function get y():Number
		{
			updateTransform();
			
			return super.y;
		}
		
		/**
		 * z
		 */
		override public function set z(_z:Number):void
		{
			updateTransform();
			
			super.z = _z;
		}
		
		/**
		 * z
		 */
		override public function get z():Number
		{
			updateTransform();
			
			return super.z;
		}
		
		/**
		 * 设置缩放.
		 */
		public function set scale( s:Number ):void
		{
			updateTransform();
			
			scale_data.w = s;
			
			doScale     = true;
			doTransform = true;
		}
		
		/**
		 * 设置缩放.
		 */
		public function get scale():Number
		{
			updateTransform();
			
			return  scale_data.w;
		}
		
		/**
		 * 设置X缩放.
		 */
		public function set scaleX( volue:Number ):void
		{
			updateTransform();
			
			scale_data.x = volue;
			
			doScale     = true;
			doTransform = true;
		}
		
		/**
		 * 设置X缩放.
		 */
		public function get scaleX():Number
		{
			updateTransform();
			
			return scale_data.x;
		}
		
		/**
		 * 设置Y缩放.
		 */
		public function set scaleY( volue:Number ):void
		{
			updateTransform();
			
			scale_data.y = volue;
			
			doScale     = true;
			doTransform = true;
		}
		
		/**
		 * 设置Y缩放.
		 */
		public function get scaleY():Number
		{
			updateTransform();
			
			return scale_data.y;
		}
		
		/**
		 * 设置Z缩放.
		 */
		public function set scaleZ( volue:Number ):void
		{
			updateTransform();
			
			scale_data.z = volue;
			
			doScale     = true;
			doTransform = true;
		}
		
		/**
		 * 设置Z缩放.
		 */
		public function get scaleZ():Number
		{
			updateTransform();
			
			return scale_data.z;
		}
		
		/**
		 * X轴角度.
		 */
		public function set rotationX( angleX:Number ):void
		{
			updateTransform();
			
			matrix.appendRotation( angleX - direction.x,Vector3D.X_AXIS );
			
			direction.x = angleX;
			
			doTransform = true;
		}
		
		/**
		 * X轴角度.
		 */
		public function get rotationX():Number
		{
			updateTransform();
			
			return direction.x;
		}
		
		/**
		 * Y轴角度.
		 */
		public function set rotationY( angleY:Number ):void
		{
			updateTransform();
			
			matrix.appendRotation( angleY - direction.y,Vector3D.Y_AXIS );
			
			direction.y = angleY;
			
			doTransform = true;
		}
		
		/**
		 * Y轴角度.
		 */
		public function get rotationY():Number
		{
			updateTransform();
			
			return direction.y;
		}
		
		/**
		 * Z轴角度.
		 */
		public function set rotationZ( angleZ:Number ):void
		{
			updateTransform();
			
			matrix.appendRotation( angleZ - direction.z,Vector3D.Z_AXIS );
			
			direction.z = angleZ;
			
			_update     = false;
			doTransform = true;
		}
		
		/**
		 * Z轴角度.
		 */
		public function get rotationZ():Number
		{
			updateTransform();
			
			return direction.z;
		}
		
		/**
		 * 获取世界矩阵.
		 * 世界矩阵即包含粒子系统本身内整个世界的变换.
		 */
		public function get worldMatrix():Matrix3D
		{
			if( doWorldTransform )
			{
				var matrix:Matrix3D = world;
				matrix.prepend( this.matrix );
				
				world_matrix.rawData = matrix.rawData;
				
				doWorldTransform = false;
			}
			
			return world_matrix.clone();
		}
		
		/**
		 * 获取本地变换数组.变换数组包含了粒子系统所有的变换.
		 * 变换即是指位移,缩放及旋转等操作.
		 */
		public function get transformMatrix():Matrix3D
		{
			return matrix.clone();
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
			_points          = new Array();
			renderList       = new Array();
			
			direction        = new Vector3D();
			_scale           = new Vector3D(1,1,1,1);
			scale_data       = new Vector3D(1,1,1,1);
			
			world_matrix     = new Matrix3D(); 
			matrix           = new Matrix3D();

			_interactive     = false;
			_update          = false;
			doWorldTransform = false;
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
			for each( var point:Point3D in _points )
			{
				point.position = Utils3D.projectVector( matrix, point.position );
			}
		}
		
		/**
		 * 复制变换。
		 * 
		 * @param matrix 传入的矩阵将复制到本地变换。
		 */
		public function copyTransform( matrix:Matrix3D ):void
		{
			this.matrix.rawData = matrix.rawData;
			
			_update     = true;
			doTransform = true;
		}
		
		/**
		 * 升级变换。
		 */
		private function updateTransform():void
		{
			if( !_update )
			{
				return;
			}
			
			var vector:Vector.<Vector3D> = matrix.decompose(Orientation3D.EULER_ANGLES);
			
			var position:Vector3D = vector[0];
			var radian:Vector3D   = vector[1];
			var scale:Vector3D    = vector[2];
			
			_position.x = position.x;
			_position.y = position.y;
			_position.z = position.z;
			
			var toAngle:Number = 180 / Math.PI;
			direction.x = radian.x * toAngle;
			direction.y = radian.y * toAngle;
			direction.z = radian.z * toAngle;
			
			scale_data.x = _scale.x = scale.x;
			scale_data.y = _scale.y = scale.y;
			scale_data.z = _scale.z = scale.z;
			
			doScale     = false;
			_update     = false;
		}
		
		/**
		 * 合并粒子。
		 */
		public function merge( particles:Particles ):void
		{
			points = points.concat( particles.points );
			
			for( var i:String in particles.renderList )
			{
				renderList[i] = renderList[i] ? renderList[i].concat( particles.renderList[i] ) : particles.renderList[i].concat();
			}
		}
		
		/**
		 * 更新位移。
		 */
		protected function updateTranslation():void
		{
			if( _update )
			{
				return;
			}
			
			if( doScale )
			{
				var scale:Number = scale_data.w / _scale.w;
				matrix.prependScale( 
				( scale_data.x / _scale.x ) * scale,( scale_data.y / _scale.y ) * scale,( scale_data.z / _scale.z ) * scale );
				
				_scale.x = scale_data.x;
				_scale.y = scale_data.y;
				_scale.z = scale_data.z;
				_scale.w = scale_data.w;
				
				doScale = false;
			}
			
			matrix.position = position;
		}
		
		/**
		 * 更新点集。
		 */
		protected function updatePoints():void
		{
			var world:Matrix3D = worldMatrix;
			
			for each( var point:Point3D in _points )
			{
				point.world = world;
			}
		}
		
		/**
		 * 执行变换.
		 */
		override protected function update():void
		{
			doWorldTransform = true;
			
			updateTranslation();
			
			updatePoints();
		}
		
		/*override protected function setWorldPosition(v:Vector3D):void
		{
			matrix.appendTranslation( v.x,v.y,v.z );
			
			super.setWorldPosition(v);
		}*/
		
		/**
		 * 字符化.
		 */
		public override function toString():String
		{
			return "Particles" + "( points: " + points.length + ", " + super.toString() + " )";
		}
		
		/**
		 * 渲染列表.
		 */
		protected var renderList:Array;
		
		protected var matrix:Matrix3D;
		
		/**
		 * 粒子集合.
		 */
		protected var _points:Array;
		
		/**
		 * 粒子方向.
		 */
		private var direction:Vector3D;
		
		/**
		 * 缩放.
		 */
		private var _scale:Vector3D;
		
		/**
		 * 缩放备份。
		 */
		private var scale_data:Vector3D;
		
		/**
		 * 是否缩放。
		 */
		private var doScale:Boolean;
		
		/**
		 * 是否交互。
		 */
		private var _interactive:Boolean;
		
		/**
		 * 是否更新。
		 */
		private var _update:Boolean;
		
		/**
		 * 是否做世界变换。
		 */
		private var doWorldTransform:Boolean;
		
		/**
		 * 世界矩阵。此矩阵包含世界和本地的变换。 
		 */
		protected var world_matrix:Matrix3D;
		
	}
}