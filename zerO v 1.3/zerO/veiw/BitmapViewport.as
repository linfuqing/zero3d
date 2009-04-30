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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import zerO.events.ViewportEvent;
	import zerO.materials.IMaterial;
	import zerO.materials.viewport.IBitmapViewportMaterial;
	import zerO.render.IRender;
	import zerO.scenes.Scene3D;
	
	/**
	 * 位图视口.一个很神奇的视口.与普通视口不同.它是把场景影射到位图上.
	 * 它可以产生很梦幻的效果,且可以平滑化呈现.也可以组合成材质来使用.
	 * 如果你需要一个绝对边界的视口.那么就是它了.它的使用方式与普通视口完全相同.
	 * 注意:此视口由于是基于Bitmap的,故不支持交互.
	 */
	public class BitmapViewport extends Bitmap implements IViewport
	{
		/**
		 * 填充颜色.可以当成背景色使用.支持透明效果. 
		 */
		public var fillColor:uint;

		/**
		 * 设置模糊滤镜.如果使用模糊滤镜,实时渲染将采用渐消模式.
		 */
		public function set blurFilter( filter:BlurFilter ):void
		{
			_blurFilter = filter;
		}
		
		/**
		 * 获取边界.
		 * 使用它你可以设置边界的大小(width|height)及灭点(x|y).
		 */		
		public function get bounds():Rectangle
		{
			return viewport.bounds;
		}
		
		/**
		 * 场景.
		 */ 
		public function get scene():Scene3D
		{
			return viewport.scene;
		}
		
		/**
		 * 场景.
		 */ 
		public function set scene(_scene:Scene3D):void
		{
			viewport.scene = _scene;
		}
		
		/**
		 * 设置焦距
		 */
		public function get focus():Number
		{
			return viewport.focus;
		}
		
		/**
		 * 设置焦距
		 */
		public function set focus(f:Number):void
		{
			viewport.focus = f;
		}
		
		/**
		 * 设置插值.
		 * 视口插值为平滑插值.0为无插值.
		 * 它关系到内置相机的平滑更换.
		 */
		public function set interpolation(volue:Number):void
		{
			viewport.interpolation = interpolation;
		}
		
		/**
		 * 设置插值.
		 * 视口插值为平滑插值.0为无插值.
		 * 它关系到内置相机的平滑更换.
		 */
		public function get interpolation():Number
		{
			return viewport.interpolation;
		}
		
		/**
		 * 内置相机设置.
		 */
		public function set camera(c:Camera3D):void
		{
			viewport.camera = c;
		}
		
		/**
		 * 内置相机设置.
		 */
		public function get camera():Camera3D
		{
			return viewport.camera;
		}
		
		/**
		 * 获取内置视口.
		 */
		public function get viewport():Viewport3D
		{
			return _viewport;
		}
	
		/**
		 * 构建新的位图视口.
		 * @param scene         场景.
		 * @param bounds        边距,即视口的位置及宽高,如果为null,将自动设置.
		 * @param focus         焦距.
		 * @param fillColor     填充颜色.
		 * @param pixelSnapping 像素化.
		 * @param smoothing     是否平滑处理.
		 */
		public function BitmapViewport(
		scene:Scene3D,
		bounds:Rectangle = null,
		focus:Number = 250,
		fillColor:uint = 0,
		pixelSnapping:String="auto",
		smoothing:Boolean=false)
		{
			var bitmapData:BitmapData = null;
			
			if( bounds )
			{
				bitmapData = new BitmapData( bounds.width,bounds.height,true,fillColor );
				_viewport = new Viewport3D( scene,bounds,focus );
			}
			else
			{
				_viewport = new Viewport3D( scene,new Rectangle(),focus );
				addEventListener(Event.ADDED_TO_STAGE,onAddedToStage );
			}
			
			_viewport.addEventListener(ViewportEvent.INIT_RENDER,onInitRender );
			_viewport.addEventListener(ViewportEvent.REMOVE_RENDER,onRemoveRender );
			
			super( bitmapData,pixelSnapping,smoothing );
			
			this.fillColor = fillColor;
			
			init();
				
		}
		
		/**
		 * 初始化.
		 */
		private function init():void
		{
			mixedMode = false;
		}
		
		/**
		 * 当视口被加入舞台时自动设置边距.
		 * @param event 当前舞台项目.
		 */
		private function onAddedToStage( event:Event ):void
		{
			viewport.bounds.width = stage.stageWidth;
			viewport.bounds.height = stage.stageHeight;
			
			viewport.initVanishingPoint();
			
			viewport.updateProject();
			
			bitmapData = new BitmapData( viewport.bounds.width,viewport.bounds.height,true,fillColor );
			
			removeEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
		}
		
		/**
		 * 当视口初始化渲染时自动检测视口模式.
		 * @param event 视口项目. 
		 */
		private function onInitRender( event:ViewportEvent ):void
		{
			if( !mixedMode && event.render.material is IBitmapViewportMaterial )
			{
				for each( var listRender:* in viewport.renderList )
				{
					if( !( listRender.parent.material is IBitmapViewportMaterial ) )
					{
						mixedMode = true;
						break;
					}
				}
			}
		}
		
		/**
		 * 当视口移出渲染时自动检测视口模式.
		 * @param event 视口项目.
		 */
		private function onRemoveRender( event:ViewportEvent ):void
		{
			if( mixedMode && event.render.material is IBitmapViewportMaterial )
			{
				var hadBitmapViewportMaterial:Boolean = false;
				
				for each( var listRender:IRender in viewport.renderList )
				{
					if( listRender.material is IBitmapViewportMaterial )
					{
						hadBitmapViewportMaterial = true;
						break;
					}
				}
				
				if( !hadBitmapViewportMaterial )
				{
					mixedMode = false;
				}
			}
			
		}
		
		/**
		 * 渲染前初始化视口.
		 */
		public function doBeforeRender():void
		{
			if( _blurFilter )
			{
				bitmapData.applyFilter( bitmapData,bitmapData.rect,DEFAULT_BLURFILTER_POINT,_blurFilter );
			}
			else
			{
				bitmapData.fillRect( bitmapData.rect,fillColor );
			}
			viewport.doBeforeRender();
		}
		
		/**
		 * 按照材质改变当前视口模式.
		 */
		public function renderForMaterial(material:IMaterial):void
		{
			if( mixedMode && material is IBitmapViewportMaterial )
			{
				bitmapData.draw( viewport );
				viewport.graphics.clear();
			}
		}
		
		/**
		 * 渲染后打印视口.
		 */
		public function doAfterRender():void
		{
			bitmapData.draw( viewport );
		}
		
		/**
		 * 内置视口.
		 */
		private var _viewport:Viewport3D;
		
		/**
		 * 是否混合模式,自动判断.
		 */
		private var mixedMode:Boolean;

		/**
		 * 内置模糊滤镜.
		 */
		private var _blurFilter:BlurFilter;
		
		/**
		 * 默认模糊初始点.
		 */
		private const DEFAULT_BLURFILTER_POINT:Point = new Point();
	}
}