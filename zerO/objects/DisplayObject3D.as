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
	
	import zerO.geom.Geometry;
	import zerO.geom.line.Lines;
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

		override public function set interactive(volue:Boolean):void
		{
			for each( var child:DisplayObject3D in _children )
			{
				child.interactive = volue;
			}
			
			super.interactive = volue;
		}
		
		/**
		 * 缩放设置.
		 */
		override public function set scale(s:Number):void
		{
			for each( var child:DisplayObject3D in _children )
			{
				child.worldPosition.scaleBy( s / child.scale );
				child.scale = s;
			}
			
			super.scale = s;
		}
		
		/**
		 * 缩放X.
		 */
		override public function set scaleX(volue:Number):void
		{
			for each( var child:DisplayObject3D in _children )
			{
				child.x *= volue / child.scaleX;
				child.scaleX = volue;
			}
			
			super.scaleX = volue;
		}
		
		/**
		 * 缩放Y.
		 */
		override public function set scaleY(volue:Number):void
		{
			for each( var child:DisplayObject3D in _children )
			{
				child.y *= volue / child.scaleY;
				child.scaleY = volue;
			}
			
			super.scaleY = volue;
		}
		
		/**
		 * 缩放Z.
		 */
		override public function set scaleZ(volue:Number):void
		{
			for each( var child:DisplayObject3D in _children )
			{
				child.z *= volue / child.scaleZ;
				child.scaleZ = volue;
			}
			
			super.scaleZ = volue;
		}
		
		/**
		 * 旋转X.
		 */
		override public function set rotationX(angleX:Number):void
		{
			for each( var child:DisplayObject3D in _children )
			{
				child.rotateX( angleX - child.rotationX );
				child.rotationX = angleX;
			}

			super.rotationX = angleX;
		}
		
		/**
		 * 旋转Y.
		 */
		override public function set rotationY(angleY:Number):void
		{
			for each( var child:DisplayObject3D in _children )
			{
				child.rotateY( angleY - child.rotationY );
				child.rotationY = angleY;
			}
			
			super.rotationY = angleY;
		}
		
		/**
		 * 旋转Z.
		 */
		override public function set rotationZ(angleZ:Number):void
		{
			for each( var child:DisplayObject3D in _children )
			{
				child.rotateZ( angleZ - child.rotationZ );
				child.rotationZ = angleZ;
			}
			
			super.rotationZ = angleZ;
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
		
		override protected function doUpdate():void
		{
			for each( var child:DisplayObject3D in _children )
			{
				child.update();
			}
			
			super.doUpdate();
		}
		
		/**
		 * 加入孩子:可加3D显示对象.
		 * @param child 子显示对象.
		 */
		public function addChild( child:DisplayObject3D ):void
		{
			_children.push( child );
			child._parent = this;
			child.worldCenter = worldPosition;
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

		override public function dispatchEvent(event:Event):Boolean
		{
			if( _parent )
			{
				_parent.dispatchEvent( event );
			}
			
			return super.dispatchEvent( event );
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