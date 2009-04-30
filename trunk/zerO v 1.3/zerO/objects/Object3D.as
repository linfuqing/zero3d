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

package zerO.objects
{
	import zerO.geom.points.Point3D;
	import zerO.physics.controllers.IController;
	
	/**
	 * 3D项目.是所有可渲染对象的基类.
	 */
	public class Object3D extends Point3D
	{
		/**
		 * 构造一个新的3D项目.
		 */
		public function Object3D(x:Number=0, y:Number=0, z:Number=0)
		{
			super(x, y, z);
			init();
		}
		
		/**
		 * 初始化.
		 */
		private function init():void
		{
			controllers = new Array();
		}
		
		/**
		 * 增加控制器.
		 * @param controller 控制器.
		 */
		public function addController( controller:IController ):void
		{
			controllers.push( controller );
		}
		
		/**
		 * 从名字获取控制器.
		 * @param name 控制器的名字.
		 * @return 获取的控制器.若找不到,则返回null.
		 */
		public function getControllerByName( name:String ):IController
		{
			for each( var controller:IController in controllers )
			{
				if( controller.name == name )
				{
					return controller;
				}
			}
			
			return null;
		}
		
		/**
		 * 执行变换.渲染时调用.
		 */
		override public function transform():void
		{
			super.transform();
			
			for each( var controller:IController in controllers )
			{
				controller.update();
			}
		}
		
		private var controllers:Array;
		
	}
}