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

package zerO.physics.controllers
{
	import zerO.utils.INameSetter;
	
	/**
	 * 控制器接口.
	 * 控制器是zerO3d特色的一个物理机制.它可以操作3D项目完成动画,物理等操作.
	 */
	public interface IController extends INameSetter
	{
		function update():void
	}
}