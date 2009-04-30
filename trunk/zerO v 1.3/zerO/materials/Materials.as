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

package zerO.materials
{
	import zerO.utils.NameSetter;
	
	/**
	 * 材质管理器,一个材质的容器.使用它你可以很方便的存取材质.
	 */
	public class Materials extends NameSetter
	{
		/**
		 * 构建新的材质管理器.
		 */
		public function Materials()
		{
			materials = new Array();
		}
		
		/**
		 * 加入材质.
		 * @param material 材质.
		 * @param symbol   下标,如果不为空,按下标加入,如果为空,按名字加入.如果名字也为空,那么按顺序加入.
		 */
		public function addMaterial( material:IMaterial,symbol:String = null ):void
		{
			if( material == null )
			{
				return;
			}
			
			if( symbol == null )
			{
				if( material.name )
				{
					materials[ material.name ] = material;
				}
				else
				{
					materials.push( material );
				}
				return;
			}
			
			materials[ symbol ] = material;
		}
		
		/**
		 * 删除材质.
		 * @param object 如果为字符,那么按照下标删除,如果为材质,那么按材质删除.
		 */
		public function removeMaterial( object:* ):void
		{
			if( object is String )
			{
				delete materials[ object ];
			}
			else if( object is IMaterial )
			{
				for( var i:String in materials )
				{
					if( materials[i] === object )
					{
						delete materials[i];
					}
				}
			}
		}
		
		/**
		 * 按名字获取材质.
		 * @param name 材质的名字.
		 * @return 获取的材质.
		 */
		public function getMaterialByName( name:String ):IMaterial
		{
			for each( var material:IMaterial in materials )
			{
				if( material.name == name )
				{
					return material;
				}
			}
			return null;
		}
		
		/**
		 * 按下标获取材质.
		 * @param symbol 下标
		 * @return 获取的材质.
		 */
		public function getMaterialBySymbol( symbol:String ):IMaterial
		{
			return materials[ symbol ];
		}
		
		/**
		 * 材质数组.
		 */
		internal var materials:Array = null;
		
	}
}