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

package zerO.scenes
{
	import zerO.geom.points.Point3D;
	import zerO.lights.Light;
	import zerO.materials.IRenderMaterial;
	import zerO.objects.DisplayObject3D;
	import zerO.particles.Particles;
	import zerO.render.IRender;
	import zerO.utils.ArrayUtil;
	import zerO.utils.NameSetter;
	import zerO.veiw.Viewport3D;
	
	/**
	 * 场景,将世界进行整合.做渲染的容器.
	 */
	public class Scene3D extends NameSetter
	{		
		/**
		 * 获取点
		 */
		public function get points():Array
		{
			return _points;
		}
		
		/**
		 * 获取面
		 */
		public function get renderList():Array
		{
			return render_list;
		}
		
		/**
		 * 灯.
		 */
		public function get light():Light
		{
			return _light;
		}
		
		/**
		 * 灯.
		 */
		public function set light( l:Light ):void
		{
			if( l )
			{
				add( l );
			}
			else
			{
				remove( _light );
			}
		}

		/**
		 * 开始渲染.
		 */
		public function get startRender():Boolean
		{
			return start_render;
		}
		
		/**
		 * 构建一个新的场景.
		 */
		public function Scene3D()
		{
			init();
		}
		
		/**
		 * 初始化.
		 */
		private function init():void
		{
			_light = null;
			_points = new Array();
			render_list = new Array();
			renderMaterials = new Array();
			viewports = new Array();
			start_render = false;
		}
		
		/**
		 * 如果想对物体进行渲染.必须将你的几何体等加进来.
		 * @param object 你的项目.
		 */
		public function add( object:* ):void
		{
			if( object is Viewport3D )
			{
				viewports.push( object );
			}
			
			if( object is Point3D )
			{
				points.push( object );
				
				for each( var viewport:Viewport3D in viewports )
				{
					viewport.initProjectPoint( object );
				}
			}
						
			if( object is IRender )
			{
				var render:IRender = object;
				if( render.material is IRenderMaterial )
				{
					ArrayUtil.singlePush( render.material,renderMaterials );
				}
				
				for each( viewport in viewports )
				{
					viewport.initProjectRender( object );
				}
				
				renderList.push( object );
				
			}
			
			if( object is Particles )
			{
				add( object.points );
				add( object.render );

				object.build();
			}
			
			if( object is Array )
			{
				for each( var i:* in object )
				{
					add( i );
				}
			}

			if( object is Light )
			{
				remove( object );
				_light = object;
			}
			
			if( object is DisplayObject3D )
			{
				var displayObject:DisplayObject3D = object;
				add( displayObject.children );
			}
		}
		
		/**
		 * 移出加入场景的物质.
		 */
		public function remove( object:* ):void
		{
			if( object is Viewport3D )
			{
				ArrayUtil.removeIn( object,viewports );
			}
			
			if( object is Point3D )
			{
				ArrayUtil.removeIn( object,points );
				
				for each( var viewport:Viewport3D in viewports )
				{
					viewport.removePoint( object );
				}
			}
						
			if( object is IRender )
			{
				var render:IRender = object;
				if( render.material is IRenderMaterial )
				{
					ArrayUtil.removeIn( render.material,renderMaterials );
				}
				
				for each( viewport in viewports )
				{
					viewport.removeRender( object );
				}
				
				ArrayUtil.removeIn( object,renderList );
				
			}
			
			if( object is Particles )
			{
				remove( object.points );
				remove( object.render );
			}
			
			if( object is Array )
			{
				for each( var i:* in object )
				{
					remove( i );
				}
			}

			if( object is Light )
			{
				_light = null;
			}
			
			if( object is DisplayObject3D )
			{
				var displayObject:DisplayObject3D = object;
				remove( displayObject.children );
			}
		}

		/**
		 * 场景表换，由视口做自动处理，不用管.
		 */
		public function transform():void
		{
			for each( var point:Point3D in points )
			{
				point.transform();
			}

			for each( var material:IRenderMaterial in renderMaterials )
			{
				material.doBeforeRender();
			}
			
			start_render = false;
		}
		
		/**
		 * 场景总渲染.
		 * 你可以很方便地使用它渲染场景的所有视口.
		 */
		public function render():void
		{
			transform();
			
			for each( var viewport:Viewport3D in viewports )
			{
				if( viewport.renderEngine )
				{
					viewport.renderEngine.render();
				}
			}
			
			start_render = true;
		}
		
		/**
		 * 灯列表.
		 */
		private var _light:Light;

		/**
		 * 点列表.
		 */
		private var _points:Array;
		
		/**
		 * 渲染列表.
		 */
		private var render_list:Array;
		
		/**
		 * 渲染材质.
		 */
		private var renderMaterials:Array;
		
		/**
		 * 视口.
		 */
		private var viewports:Array;
		
		/**
		 * 开始渲染.
		 */
		private var start_render:Boolean;
		
	}
}