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

package zerO.render
{
	import zerO.materials.IMaterial;
	import zerO.utils.NameSetter;
	import zerO.veiw.IViewport;
	
	/**
	 * Z轴排序,个人认为在Flash3D里是最简单实用的排序.占资源最少，虽然偶尔破面的数量也很简单实用...
	 *
	 */
	public class Zsort extends NameSetter implements IRenderEngine
	{
		/**
		 * 构建新的z排序.
		 * @param viewport 需要渲染的视口.
		 */
		public function Zsort( viewport:IViewport )
		{
			this.viewport = viewport;
			viewport.viewport.renderEngine = this;
		}
		
		/**
		 * 执行渲染
		 */
		public function render():void
		{
			if( !viewport.scene.startRender )
			{
				viewport.scene.transform();
			}
			
			viewport.viewport.transformScene();
			
			if( viewport.viewport.move )
			{
				renderList = [];
				
				for each( var render:* in viewport.viewport.renderList )
				{
					if( render.parent.material.doDraw( render,viewport ) )
					{
						renderList.push( render );
					}
				}
				
				renderList.sortOn( "z",Array.DESCENDING | Array.NUMERIC );
				
				viewport.doBeforeRender();
			
				for each( render in renderList )
				{
					var material:IMaterial = render.parent.material;
					viewport.renderForMaterial( material );
					material.draw( render,viewport );
				}
				
				viewport.doAfterRender();
				
			}
			
			if( viewport.viewport.interactive )
			{
				for each( render in renderList )
				{
					render.parent.material.doInteractive( render,viewport );
				}
			}
		}

		/**
		 * 要渲染的视口.
		 */
		private var viewport:IViewport;
		
		private var renderList:Array;

	}
}