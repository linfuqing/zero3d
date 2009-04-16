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
	import flash.geom.Vector3D;
	
	import zerO.objects.NameSetter;
	import zerO.objects.Object3D;
	import zerO.physics.Border;
	import zerO.physics.forces.Force;
	
	/**
	 * 力控制器.
	 * 使用它可以为3D项目及其子类添加力.及边界检测等物理特性.
	 */
	public class ForceController extends NameSetter implements IController
	{
		/**
		 * 目标.
		 */
		public var target:Object3D;
				
		/**
		 * 速度.
		 */
		public var velocity:Vector3D;

		/**
		 * 质量设置.
		 */
		public function set mass( _mass:Number ):void
		{
			this._mass = _mass;
		}
		
		/**
		 * 质量设置.
		 */
		public function get mass():Number
		{
			return _mass;
		}
		
		/**
		 * 摩擦力设置.
		 */
		public function set friction( _friction:Number ):void
		{
			var fri:Number = Math.max( 0,_friction );
			fri = Math.min( _friction,1 );
			this._friction = fri;
		}
		
		/**
		 * 摩擦力设置.
		 */
		public function get friction():Number
		{
			return _friction;
		}
		
		public function ForceController( 
		target:Object3D,
		velocity:Vector3D = null,
		friction:Number = 0,
		mass:Number = 1 )
		{
			this.target = target;
			this.velocity = velocity ? velocity : new Vector3D()
			this.friction = friction;
			this.mass = mass;
			
			super();
			
			init();
		}
		
						
		/**
		 * 初始化.
		 */
		private function init():void
		{
			forces = new Array();
			target.addController( this );
		}

		/**
		 * 加入力.
		 */
		public function addForce( force:Force ):void
		{
			forces.push( force );
		}
		
		/**
		 * 删除力.
		 */
		public function removeForce( force:* ):void
		{
			if( force is Force )
			{
				for( var i:String in force )
				{
					if( forces[i] === force )
					{
						delete forces[i];
					}
				}
			}
			else if( force is String )
			{		
				for( i in force )
				{
					if( forces[i].name == force )
					{
						delete forces[i];
					}
				}
			}
		}
		
		
		/**
		 * 力反弹,离界越远力越大.
		 */
		public function boundaryDetection( border:Border ):void
		{
			if( target.x > border[0] )
			{
				addForce( new Force( new Vector3D( border.left - target.x,0,0 ) ) );
			}
			
			else if( target.x < border[1] )
			{
				addForce( new Force( new Vector3D( border.right - target.x,0,0 ) ) );
			}
			
			if( target.y > border[2] )
			{
				addForce( new Force( new Vector3D( 0,border.up - target.y,0 ) ) );
			}
			
			else if( target.y < border[3] )
			{
				addForce( new Force( new Vector3D( 0,border.down - target.y,0 ) ) );
			}
			
			if( target.z > border[4] )
			{
				addForce( new Force( new Vector3D( 0,0,border.front - target.z ) ) );
			}
			
			else if( target.z < border[5] )
			{
				addForce( new Force( new Vector3D( 0,0,border.back - target.z ) ) );
			}
		}
		
		/**
		 * 界限反弹,粒子不会不超过界.
		 */
		public function boundaryBounce( border:Border,bounce:Number ):void
		{
			if( target.x > border.left )
			{
				target.x = border.left;
				velocity.x *= - bounce;
			}
			
			else if( target.x < border.right )
			{
				target.x = border.right;
				velocity.x *= - bounce;
			}
			
			if( target.y > border.up )
			{
				target.y = border.up;
				velocity.y *= - bounce;
			}
			
			else if( target.y < border.down )
			{
				target.y = border.down;
				velocity.y *= - bounce;
			}
			
			if( target.z > border.front )
			{
				target.z = border.front;
				velocity.z *= - bounce;
			}
			
			else if( target.z < border.back )
			{
				target.z = border.back;
				velocity.z *= - bounce;
			}
		}
				
		/**
		 * 移动，需要显示物理时将移动方法加到Event.ENTER_FRAME上即可.
		 */
		public function update():void
		{
			acceleration = new Vector3D();
			for( var i:String in forces )
			{
				var force:Force = forces[i];
				if( !force.live() )
				{
					delete forces[i];
				}
				else
				{
					force.w = mass;
					force.project();
					force.w = 1;
					acceleration = acceleration.add( force.volue );
				}
			}
			
			velocity = velocity.add( acceleration );
			
			var rate:Number = 1 - friction;
			velocity.w = 1 / rate;
			velocity.project();
			velocity.w = 1;
			
			target.worldPosition = target.worldPosition.add( velocity );
		}
		
						
		/**
		 * 加速度.
		 */
		private var acceleration:Vector3D;
		
		/**
		 * 质量.
		 */
		private var _mass:Number;
		
		/**
		 * 摩擦 .
		 */
		private var _friction:Number;
		
		/**
		 * 所受的力.
		 */
		private var forces:Array;
		
	}
}