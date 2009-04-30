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

package zerO.materials.viewport
{
	import zerO.materials.BitmapMaterial;
	import zerO.materials.ITriangleMaterial;
	import zerO.veiw.BitmapViewport;
	
	/**
	 * 位图视口专用材质.
	 * 如果你使用位图视口.
	 * 那么使用此材质比使用比视口材质快.
	 */
	public class BitmapViewportMaterial extends BitmapMaterial implements ITriangleMaterial
	{
		/**
		 * 构建位图视口专用材质.
		 * @param bitmapViewport 位图视口.
		 * @param smooth         是否平滑处理.
		 */
		public function BitmapViewportMaterial(bitmapViewport:BitmapViewport, smooth:Boolean=false)
		{
			super(bitmapViewport.bitmapData, smooth);
		}

	}
}