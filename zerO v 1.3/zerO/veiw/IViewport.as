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
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	
	import zerO.materials.IMaterial;
	import zerO.scenes.Scene3D;
	
	/**
	 * 视口接口
	 */ 
	public interface IViewport extends IEventDispatcher
	{
		function get mouseX():Number;
		function get mouseY():Number;
		
		function get bounds():Rectangle;
		function get scene():Scene3D;
		function set scene( _scene:Scene3D ):void
		function get focus():Number;
		function set focus( f:Number ):void;
		function set interpolation( volue:Number ):void
		function get interpolation():Number
		function set camera( c:Camera3D ):void
		function get camera():Camera3D
		function get viewport():Viewport3D;

		function doBeforeRender():void
		function renderForMaterial( material:IMaterial ):void
		function doAfterRender():void
	}
}