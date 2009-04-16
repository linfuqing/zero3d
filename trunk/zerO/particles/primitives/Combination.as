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


package zerO.particles.primitives
{
	import flash.display.BitmapData;
	import flash.geom.Vector3D;
	
	import zerO.geom.points.Point3D;
	
	public class Combination
	{	
		/**
		 * 粒子组合
		 */
		public function Combination()
		{
		}
		
		/**
		 * 正方体
		 */
		static public function cube( numPoints:uint,distance:Number ):Array
		{
			var radius:uint = Math.pow( numPoints,1 / 3 );
			var points:Array = new Array();
			
			for( var i:uint = 0;i < radius;i++ )
			{
				for( var j:uint = 0;j < radius;j++ )
				{
					for( var k:uint = 0;k < radius;k++ )
					{
						var point:Vector3D = new Vector3D( 
						( k - radius / 2 ) * distance,
						( j - radius / 2 ) * distance,
						( i - radius / 2 ) * distance );
						points.push( point );
					}
				}
			}
			
			return points;
		}
		
		static public function randomCube( numPoint:uint,radius:Number ):Array
		{
			var points:Array = new Array();
			
			for( var i:uint = 0;i < numPoint;i ++ )
			{
				var point:Vector3D = new Vector3D( 
				Math.random() * radius * 2 - radius,
				Math.random() * radius * 2 - radius,
				Math.random() * radius * 2 - radius );
				
				points.push( point );
			}
			
			return points;
		}
		
		static public function rondomCylinder( numPoints:uint,radius:Number ):Array
		{
			var points:Array = new Array();
			for( var i:uint = 0;i < numPoints;i++ )
			{
				var angle:Number = Math.random() * Math.PI * 2;
				var point:Vector3D = new Vector3D( 
				Math.sin( angle ) * radius,
				i,
				Math.cos( angle ) * radius )
				points.push( point );
			}
			
			return points;
		}
		
		static public function round( numPoints:uint,radius:Number ):Array
		{
			var points:Array = new Array();
			var perAngle:Number = 360 * radius / numPoints;
			for( var i:uint = 0;i < numPoints;i++ )
			{
				var point:Vector3D = new Vector3D( 
				radius * Math.sin( i * perAngle ),0,radius * Math.cos( i * perAngle ) );
				points.push( point );
			}
			
			return points;
			
		}
		
		static public function rondomRound( numPoints:uint,radius:Number ):Array
		{
			var points:Array = new Array();
			var perAngle:Number = 360 * radius / numPoints;
			for( var i:uint = 0;i < numPoints;i++ )
			{
				var rad:Number = radius * Math.random();
				var point:Vector3D = new Vector3D(
				rad * Math.sin( i * perAngle ),rad * Math.cos( i * perAngle ),0 );
				points.push( point );
			}
			
			return points;
		}
		
		static public function spiral( numPoints:uint,radius:Number ):Array
		{
			var points:Array = new Array();
			var perAngle:Number = 360 * radius / numPoints;
			for( var i:uint = 0;i < numPoints;i++ )
			{
				var point:Vector3D = new Vector3D( 
				radius * Math.sin( i * perAngle ),i,radius * Math.cos( i * perAngle ) );
				points.push( point );
			}
			
			return points;
		}
		
		static public function cylinder( 
		numPoints:uint,
		radius:Number,
		rise:Number,
		distance:Number ):Array
		{
			var points:Array = new Array();
			var perCirNumPoints:uint = numPoints / rise;
			var perAngle:Number = 360 * radius / perCirNumPoints;
			for( var i:uint = 0;i < rise;i++ )
			{
				for( var j:uint = 0;j < perCirNumPoints;j ++ )
				{
					var point:Vector3D = new Vector3D(
					radius * Math.sin( perAngle * j ),
					i * distance,
					radius * Math.cos( perAngle * j ) );
					
					points.push( point );
				}
			}
			return points;
		}
		
		static public function bitmap3D( 
		bitmap:BitmapData,
		rate:Number,
		distance:Number,
		length:uint = 1 ):Array
		{
			if( bitmap == null )
			{
				return null;
			}
			
			var rate:Number = 1 - Math.max( 0,Math.min( 1,rate ) );
			var points:Array = new Array();
			
			for( var i:uint = 0;i < bitmap.height;i ++ )
			{
				for( var j:uint = 0;j < bitmap.width;j ++ )
				{
					var color:uint = bitmap.getPixel( j,i );
					var red:uint = color >> 16 & 0xff;
					var green:uint = color >> 8 & 0xff;
					var blue:uint = color & 0xff;
					var total:Number = ( red  + green + blue ) / 768;
					if( total < rate )
					{
						for( var k:uint = 0;k < length;k ++ )
						{
							points.push( new Vector3D(
							j * distance,i * distance,k * distance ) );
						}
					}
				}
			}
			
			return points;
		}
		
		/**
		 * 将运用组合
		 */
		static public function toCombination( 
		points:Array,
		targets:Array,
		interpolation:Number ):void
		{
			var inter:Number = Math.min( 1,Math.max( interpolation,0 ) );
			var numPoints:uint = Math.min( points.length,targets.length );
			for( var i:uint = 0;i < numPoints;i ++ )
			{
				var point:Point3D = points[i];
				var target:Vector3D = targets[i];
				Combination.toTarget( point.worldPosition,target,inter );
			}
		}
		
		/**
		 * 接近目标
		 */
		static public function toTarget( point:Vector3D,target:Vector3D,interpolation:Number ):void
		{
			var vector:Vector3D = target.subtract( point );
			point.x += vector.x * interpolation;
			point.y += vector.y * interpolation;
			point.z += vector.z * interpolation;
		}

	}
}