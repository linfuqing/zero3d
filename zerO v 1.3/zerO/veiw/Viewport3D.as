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

package zerO.veiw
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import zerO.events.MouseEvent3D;
	import zerO.events.ViewportEvent;
	import zerO.geom.line.Line;
	import zerO.geom.line.Line2D;
	import zerO.geom.points.Point2D;
	import zerO.geom.points.Point3D;
	import zerO.geom.triangle.Triangle;
	import zerO.geom.triangle.Triangle2D;
	import zerO.materials.IMaterial;
	import zerO.particles.Particle;
	import zerO.particles.Particle2D;
	import zerO.render.IRender;
	import zerO.render.IRenderEngine;
	import zerO.scenes.Scene3D;
	import zerO.utils.ArrayUtil;
	
	/**
	 * 视口，比较好的解释是就像观看一个场景的窗口.如果加入相机,你就可以走到场景中去.
	 */
	public class Viewport3D extends Sprite implements IViewport
	{
		/**
		 * 渲染,如果设置为true,视口将进行更新.
		 * <p>
		 * 注意:视口更新是一次性的,如果需要实时渲染,请将其加在帧上,像这样:
		 * <p>
		 * onEnterFrame( event:Event ):void
		 * {
		 * <p>
		 *     viewport.doRender = true;
		 * <p>
		 *     render.render();
		 * <p>
		 * }
		 */
		public var doRender:Boolean;
		
		/**
		 * 设置交互.
		 * 如果视口交互为true,那么你可以使用zerO3d的交互功能.
		 * 具体使用请看官方Blog使用说明交互篇.
		 */
		public function get interactive():Boolean
		{
			return _interactive;
		}
		
		/**
		 * 设置交互.
		 * 如果视口交互为true,那么你可以使用zerO3d的交互功能.
		 * 具体使用请看官方Blog使用说明交互篇.
		 */
		public function set interactive( volue:Boolean ):void
		{
			
			if( _interactive != volue )
			{
				if( volue )
				{
					addMouseEventListeners();
				}
				else
				{
					removeMouseEventListeners();
				}
			}
			
			_interactive = volue;
		}
		
		/**
		 * 获取交互列表.
		 * 此列表包含了每帧所进行交互物质.
		 * <p>
		 * 其中以下下标分别代表:
		 * <p>
		 * "triangle":三角形
		 * <p>
		 * "geometry":几何体
		 * <p>
		 * "material":材质
		 */
		public function get interactiveList():Array
		{
			return _interactiveList;
		}
		
		/**
		 * 获取边界.
		 * 使用它你可以设置边界的大小.
		 */
		public function get bounds():Rectangle
		{
			return _bounds;
		}

		/**
		 * 场景.
		 */ 
		public function get scene():Scene3D
		{
			return _scene;
		}
		
				
		/**
		 * 场景.
		 */
		public function set scene( _scene:Scene3D ):void
		{
			if( this._scene )
			{
				this._scene.remove( this );
			}
			this._scene = _scene;
			_scene.add( this );
			
			pointsProject = new Array();
			renderProject = new Array();
			pointsByTarget = new Dictionary(true);

			for each( var point:Point3D in _scene.points )
			{
				initProjectPoint( point );
			}
			
			for each( var render:IRender in _scene.renderList )
			{
				initProjectRender( render );
			}
		}

		/**
		 * 设置焦距
		 */
		public function set focus( f:Number ):void
		{
			_focus = f;
		}
		
		/**
		 * 设置焦距.
		 */
		public function get focus():Number
		{
			return _focus;
		}
		
		/**
		 * 设置插值.
		 * 视口插值为平滑插值.0为无插值.
		 * 它关系到内置相机的平滑更换.
		 */
		public function set interpolation( volue:Number ):void
		{
			_interpolation = Math.max( Math.min( 1,volue ),0 );
			
			if( !_interpolation )
			{
				if( camera )
				{
					matrix = camera.matrix;
				}
				else
				{
					matrix = DEFAULT_MATRIX;
				}
				
				updateProject();
			}
		}
		
		/**
		 * 设置插值.
		 * 视口插值为平滑插值.0为无插值.
		 * 它关系到内置相机的平滑更换.
		 */
		public function get interpolation():Number
		{
			return _interpolation;
		}
		
		/**
		 * 内置相机设置.
		 */
		public function set camera( c:Camera3D ):void
		{
			_camera = c;
			
			if( c )
			{
				matrix_data = c.matrix;
				
				if( interpolation )
				{
					matrix = matrix.clone();
				}
				else
				{
					matrix = c.matrix;
				}
			}
			else
			{
				matrix_data = DEFAULT_MATRIX;
				
				if( interpolation )
				{
					matrix = matrix.clone();
				}
				else
				{
					matrix = DEFAULT_MATRIX;
				}
			}
		}
		
		/**
		 * 内置相机设置.
		 */
		public function get camera():Camera3D
		{
			return _camera;
		}
		
		/**
		 * 获取内置视口.
		 */
		public function get viewport():Viewport3D
		{
			return this;
		}
		
		/**
		 * 获取渲染列表.
		 */
		public function get renderList():Array
		{
			return renderProject;
		}
		
		/**
		 * 渲染器.
		 */
		public function set renderEngine( render_engine:IRenderEngine ):void
		{
			this.render_engine = render_engine;
		}
		
		/**
		 * 渲染器.
		 */
		public function get renderEngine():IRenderEngine
		{
			return render_engine;
		}
		
		/**
		 * 获取视口是否活动.
		 */
		public function get move():Boolean
		{
			return _move;
		}
		
		/**
		 * 构建新的视口.
		 * @param scene         场景.
		 * @param bounds        边距,即视口的位置及宽高,如果为null,将自动设置.
		 * @param focus         焦距.
		 */
		public function Viewport3D( scene:Scene3D,bounds:Rectangle = null,focus:Number = 250 )
		{
			super();
			
			init();
			
			if( bounds )
			{
				_bounds = bounds;
				
				initVanishingPoint();
			}
			else
			{
				_bounds = new Rectangle();
				addEventListener(Event.ADDED_TO_STAGE,onAddedToStage );
			}
			
			this.focus = focus;
			this.scene = scene;
		}
		
		/**
		 * 初始化.
		 */
		private function init():void
		{
			matrix = new Matrix3D();
			matrix_data = new Matrix3D();
			camera = null;
			_move = false;
			_interactive = false;
			_interactiveList = new Array();
			mouseEventList = new Array();
			render_engine = null;
		}
		
		/**
		 * 初始化灭点.
		 */		
		internal function initVanishingPoint():void
		{
			vpX = bounds.width / 2;
			vpY = bounds.height / 2;
		}
		
		/**
		 * 当视口被加入舞台时自动设置边距.
		 * @param event 当前舞台项目.
		 */
		private function onAddedToStage( event:Event ):void
		{
			bounds.width = stage.stageWidth;
			bounds.height = stage.stageHeight;
			
			initVanishingPoint();
			
			updateProject();
			
			removeEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
		}
		
		/**
		 * 正投影,将一个三维对象投影成2维的点,并显示出来.
		 * @param point2D 投影的2D点.
		 */
		private function project( point2D:Point2D ):void
		{
			var point3D:Vector3D = point2D.parent;
			point2D.scale = focus / ( focus + point3D.z );
			point2D.x = vpX + point3D.x * point2D.scale;
			point2D.y = vpY + point3D.y * point2D.scale;

		}
		
		/**
		 * 初始化投影点.
		 * @param point 初始化的3D点.
		 */
		public function initProjectPoint( point:Point3D ):void
		{
			var point2D:Point2D = new Point2D( point );
			
			pointsProject.push( point2D );
			pointsByTarget[ point ] = point2D;
			
			if( !interpolation )
			{
				updatePointProject( point2D );
			}
		}
		
		/**
		 * 移出投影点.
		 * @param point 要移出的3D点.
		 */
		public function removePoint( point:Point3D ):void
		{
			var point2D:Point2D = pointsByTarget[ point ];
			ArrayUtil.removeIn( point2D,pointsProject );
			point2D.node = null;
			delete pointsByTarget[ point ];
		}
		
		/**
		 * 初始化渲染对象.
		 * @param render 要初始化的渲染对象.
		 */
		public function initProjectRender( render:IRender ):void
		{			
			if( render is Triangle )
			{
				var triangle:Triangle = render as Triangle;
				renderProject.push( new Triangle2D(
				pointsByTarget[triangle.vertexA],
				pointsByTarget[triangle.vertexB],
				pointsByTarget[triangle.vertexC],
				triangle ) );
			}
			
			else if( render is Line )
			{
				var line:Line = render as Line;
				renderProject.push( new Line2D( pointsByTarget[line.vertexA],
				pointsByTarget[line.vertexB],line,pointsByTarget[line.curveTo] ) );
			}
			
			else if( render is Particle )
			{
				var particle:Particle = render as Particle;
				renderProject.push( new Particle2D( pointsByTarget[ particle ],particle ) );
			}
			
			doRender = true;
			
			dispatchEvent( new ViewportEvent( ViewportEvent.INIT_RENDER,render ) );
		}
		
		/**
		 * 移出渲染对象.
		 * @param render 要移出的渲染对象.
		 */
		public function removeRender( render:IRender ):void
		{
			ArrayUtil.removeIn( render,renderProject );
			
			doRender = true;
			
			dispatchEvent( new ViewportEvent( ViewportEvent.REMOVE_RENDER,render ) );
		}
		
		/**
		 * 场景变换,将整个场景变化成2维,这是对场景的整合.
		 */
		public function transformScene():void
		{
			initVanishingPoint();
			
			doInteractive();
			
			_move = false;
			
			if( camera )
			{
				camera.transform();
			}
			
			if( interpolation )
			{
				matrix.interpolateTo( matrix_data,interpolation );
			}
			
			if( ( camera && camera.move ) || interpolation )
			{
				updateProject();
				
				_move = true;
			}
			
			else
			{
				for each( var point:Point2D in pointsProject )
				{
					if( point.node.move )
					{
						updatePointProject( point );
						
						if( point.x > bounds.x && point.y > bounds.y && point.x < bounds.width && point.y < bounds.height )
						{
							_move = true;
						}
					}
				}
			}
			
			if( doRender )
			{
				_move = true;
				doRender = false;
			}
		}
		
		/**
		 * 执行交互.
		 */
		private function doInteractive():void
		{
			if( _interactive )
			{
				if( _interactiveList.length )
				{
					buttonMode = true;
					for each( var object:EventDispatcher in _interactiveList )
					{
						for each( var event:MouseEvent in mouseEventList )
						{
							//object.dispatchEvent( event );
							object.dispatchEvent( new MouseEvent3D( event.type,object ) );
						}
					}
				}
				else
				{
					buttonMode = false;
				}
				
				_interactiveList = [];
				mouseEventList = [];
			}
		}
		
		/**
		 * 增加鼠标项目集.
		 */
		private function addMouseEventListeners():void
		{
			addEventListener(MouseEvent.CLICK,onMouseEvent );
			addEventListener(MouseEvent.DOUBLE_CLICK,onMouseEvent );
			addEventListener(MouseEvent.MOUSE_DOWN,onMouseEvent );
			addEventListener(MouseEvent.MOUSE_MOVE,onMouseEvent );
			addEventListener(MouseEvent.MOUSE_OUT,onMouseEvent );
			addEventListener(MouseEvent.MOUSE_OVER,onMouseEvent );
			addEventListener(MouseEvent.MOUSE_UP,onMouseEvent );
			addEventListener(MouseEvent.MOUSE_WHEEL,onMouseEvent );
			addEventListener(MouseEvent.ROLL_OUT,onMouseEvent );
			addEventListener(MouseEvent.ROLL_OVER,onMouseEvent );
		}
		
		/**
		 * 移出鼠标项目集.
		 */
		private function removeMouseEventListeners():void
		{
			removeEventListener(MouseEvent.CLICK,onMouseEvent );
			removeEventListener(MouseEvent.DOUBLE_CLICK,onMouseEvent );
			removeEventListener(MouseEvent.MOUSE_DOWN,onMouseEvent );
			removeEventListener(MouseEvent.MOUSE_MOVE,onMouseEvent );
			removeEventListener(MouseEvent.MOUSE_OUT,onMouseEvent );
			removeEventListener(MouseEvent.MOUSE_OVER,onMouseEvent );
			removeEventListener(MouseEvent.MOUSE_UP,onMouseEvent );
			removeEventListener(MouseEvent.MOUSE_WHEEL,onMouseEvent );
			removeEventListener(MouseEvent.ROLL_OUT,onMouseEvent );
			removeEventListener(MouseEvent.ROLL_OVER,onMouseEvent );
		}
		
		/**
		 * 将鼠标项目加入鼠标项目列表.
		 */
		private function onMouseEvent( event:MouseEvent ):void
		{
			mouseEventList.push( event );
		}
		
		/**
		 * 更新所有点投影.
		 */
		internal function updateProject():void
		{
			for each( var point2D:Point2D in pointsProject )
			{
				updatePointProject( point2D );
			}
		}
		
		/**
		 * 更新点投影.
		 * @param point2D 要升级的点投影.
		 */
		private function updatePointProject( point2D:Point2D ):void
		{
			point2D.parent = Utils3D.projectVector( matrix,point2D.node.worldPosition );
			project( point2D );
		}
		
		/**
		 * 获取3D点在视口上的2D位置.
		 * @param point3D 要获取2D位置的2D点.
		 */
		public function get2DPointProjectByTarget( point:Point3D ):Point2D
		{
			return pointsByTarget[ point ];
		}
		
		/**
		 * 渲染前使用.
		 */
		public function doBeforeRender():void
		{
			graphics.clear();
		}
		
		/**
		 * 从不同材质渲染.
		 * @param material 渲染的材质.
		 */
		public function renderForMaterial( material:IMaterial ):void
		{
			
		}
		
		/**
		 * 渲染后使用
		 */
		public function doAfterRender():void
		{
			
		}

		/**
		 * 焦距.
		 */
		private var _focus:Number;

		/**
		 * 场景.
		 */
		private var _scene:Scene3D;
		
		/**
		 * 投影点列表.
		 */
		private var pointsProject:Array;
		
		/**
		 * 投影渲染列表.
		 */
		private var renderProject:Array;
		
		/**
		 * 以地址为下标的点列表.
		 */
		private var pointsByTarget:Dictionary;
		
		// Camera part:
		
		/**
		 * 视口矩阵备份，缓冲用.
		 */
		private var matrix_data:Matrix3D;
		
		/**
		 * 视口矩阵.
		 */
		private var matrix:Matrix3D;
		
		/**
		 * 空矩阵.
		 */
		private const DEFAULT_MATRIX:Matrix3D = new Matrix3D();
		
		/**
		 * 相机.
		 */
		private var _camera:Camera3D;
		
		/**
		 * 换相机插值，此功能可生成相当漂亮的动画.
		 */
		private var _interpolation:Number;
		
		/**
		 * 视口是否活动.
		 */
		private var _move:Boolean;
		
		/**
		 * 视口边界.
		 */
		private var _bounds:Rectangle;
		
		/**
		 * 视口交互.
		 */
		private var _interactive:Boolean;
		
		/**
		 * 交互列表.
		 */
		private var _interactiveList:Array;
		
		/**
		 * 鼠标项目列表.
		 */
		private var mouseEventList:Array;
		
		/**
		 * 渲染器.
		 */
		private var render_engine:IRenderEngine;
		
		/**
		 * 灭点X.
		 */
		private var vpX:Number;
		
		/**
		 * 灭点Y.
		 */
		private var vpY:Number;
	}
}