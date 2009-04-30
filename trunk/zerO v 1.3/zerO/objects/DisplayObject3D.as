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
	import flash.events.Event;
	import flash.geom.Matrix3D;
	
	import zerO.geom.Geometry;
	import zerO.geom.points.Vertex;
	import zerO.materials.Materials;
	import zerO.particles.Particles;
	
	/**
	 * 3D显示对象：与DisplayObject相似.作为几何体的容器.
	 */
	public class DisplayObject3D extends Particles
	{
		/**
		 * 显示对象的名字.
		 */
		public var name:String;
		
		public function get parent():DisplayObject3D
		{
			return _parent;
		}

		/**
		 * 显示对象集合.
		 * <p>
		 * 注意:这个集合只是一个复制体.
		 * <p>
		 * 如果需要加入子集.请使用addChild方法.需要删除子集,使用removeChild方法.
		 */
		public function get children():Array
		{
			return _children.concat();
		}
		
		/**
		 * 是否交互。
		 */
		override public function set interactive(volue:Boolean):void
		{
			for each( var child:DisplayObject3D in _children )
			{
				child.interactive = volue;
			}
			
			super.interactive = volue;
		}

		/**
		 * 构造一个新的3D显示对象.
		 * @param name     显示对象的名字.
		 * @param geometry 传入一个几何体,它将变成这个几何体的容器.
		 */
		public function DisplayObject3D( name:String = null,geometry:Geometry = null )
		{
			super();
			init();

			this.name = name;
			if( geometry )
			{
				addGeometry( geometry );
			}

		}
		
		/**
		 * 初始化.
		 */
		private function init():void
		{
			materials = new Materials();
			_children = new Array();
			_parent = null;
		}
		
		override protected function updatePoints():void
		{
			super.updatePoints();
			
			updateChildren();
		}
		
		/**
		 * 更新子集。
		 */
		protected function updateChildren():void
		{
			var world:Matrix3D = worldMatrix;
			
			for each( var child:DisplayObject3D in _children )
			{
				child.world = world;
			}
		}
		
		/**
		 * 加入孩子:可加3D显示对象.
		 * @param child 子显示对象.
		 */
		public function addChild( child:DisplayObject3D ):void
		{
			_children.push( child );
			child._parent = this;
		}
		
		/**
		 * 从显示对象的名字获取子对象.
		 * @param name 名字.
		 * @return     返回的子对象.
		 */
		public function getChildByName( name:String ):DisplayObject3D
		{
			return findChildByName(this, name);
		}
		
		/**
		 * 同上
		 */
		private function findChildByName(node:DisplayObject3D, name:String):DisplayObject3D
		{
			if( node.name == name )
				return node;
				
			for each(var child:DisplayObject3D in node._children ) 
			{
				var n:DisplayObject3D = findChildByName(child, name);
				if( n )
					return n;
			}
			
			return null;
		}
		
		/**
		 * 删除子对象.
		 * @param child 要删除的孩子.
		 */
		public function removeChild( child:DisplayObject3D ):DisplayObject3D
		{
			var object:DisplayObject3D = getChildByName( child.name );
			
			if(object)
			{
				var parent:DisplayObject3D = DisplayObject3D(object._parent);

				for( var i:String in parent._children )
				{
					if( _children[i] === object )
					{
						delete _children[i];
						return object;
					}
				}
			}
			return null;	
		}
		
		/**
		 * 向上级分派对象。
		 */
		override public function dispatchEvent(event:Event):Boolean
		{
			if( _parent )
			{
				_parent.dispatchEvent( event );
			}
			
			return super.dispatchEvent( event );
		}
		
		/**
		 * 变成节点。
		 */		
		public function toJoint( skin:Skin, weights:Array, inverseBindMatrix:Matrix3D ):void
		{
			renderList = [];
			_points = [];
			
			for( var i:uint = 0; i < weights.length; i++ )
			{
				var weight:Number = weights[i].weight;
				var vertexIndex:int = weights[i].vertexIndex;
				var skinned:Vertex = skin.points[ vertexIndex ];
				
				if( weight <= 0.0001 || weight >= 1.0001)
				{
					skinned.x = skinned.y = skinned.z = 0;
				}
				else
				{				
					skinned.weight = weight;
				}

				_points.push( skinned );
			}
			
			transformVertices( inverseBindMatrix );
		}
		
		/**
		 * 字符化.
		 */
		public override function toString():String
		{
			return "DisplayObject3D( name: " + name + ", " + super.toString() + " )";
		}
		
		/**
		 * 材质列表.
		 */
		protected var materials:Materials;

		/**
		 * 父级显示对象.
		 */
		private var _parent:DisplayObject3D;
		
		
		/**
		 * 显示对象集合.
		 */
		private var _children:Array;
	}
}