/**
 * Copyright 2007 (c) Tim Knip, ascollada.org.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
**/

package zerO.physics.controllers
{
	import flash.geom.Matrix3D;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	
	import zerO.geom.points.Point3D;
	import zerO.objects.DisplayObject3D;
	import zerO.objects.Skin;
	import zerO.utils.NameSetter;
	
	/**
	 * 这个控制器不是我写的.
	 * 版权归TIM KNIP所有.
	 */
	public class SkinController extends NameSetter implements IController
	{
		/** */
		public var poseMatrix:Matrix3D;
		
		/** */
		public var bindShapeMatrix:Matrix3D;
		
		/** */
		public var target:Skin;
		
		/** */
		public var joints:Array;
	
		/** */
		public var invBindMatrices:Array;
		
		/** */
		public var vertexWeights:Array;

		/**
		 * Constructor.
		 * 
		 * @param	target
		 */ 
		public function SkinController(target:Skin)
		{
			this.target = target;
			this.joints = new Array();
			this.invBindMatrices = new Array();
			this.vertexWeights = new Array();
		}

		/**
		 * Update.
		 */ 
		public function update():void
		{
			if(!joints.length || !bindShapeMatrix)
				return;
			
			if(!_cached)
				cacheVertices();
				
			if(invBindMatrices.length != this.joints.length)
				return;
				
			var vertices:Array = target.points;
			var i:int;
			
			// reset mesh's vertices to 0
			for(i = 0; i < vertices.length; i++)
				vertices[i].x = vertices[i].y = vertices[i].z = 0;
								
			// skin the mesh!
			for(i = 0; i < joints.length; i++)
				skinMesh(joints[i], this.vertexWeights[i], invBindMatrices[i], _cached, vertices);
		}
		
		/**
		 * Cache original vertices.
		 */
		private function cacheVertices():void
		{
			this.target.transformVertices(this.bindShapeMatrix);
			var vertices:Array = this.target.points;

			_cached = new Array(vertices.length);
			
			for(var i:int = 0; i < vertices.length; i++)
				_cached[i] = new Vector3D(vertices[i].x, vertices[i].y, vertices[i].z);
		}
		
		/**
		 * Skins a mesh.
		 * 
		 * @param	joint
		 * @param	meshVerts
		 * @param	skinnedVerts
		 */
		private function skinMesh(joint:DisplayObject3D, weights:Array, inverseBindMatrix:Matrix3D, meshVerts:Array, skinnedVerts:Array):void
		{
			var i:int;
			var pos:Vector3D = new Vector3D();
			var original:Vector3D;
			var skinned:Point3D;

			var matrix:Matrix3D = joint.worldMatrix;
			matrix.prepend( inverseBindMatrix );
			
			for( i = 0; i < weights.length; i++ )
			{
				var weight:Number = weights[i].weight;
				var vertexIndex:int = weights[i].vertexIndex;

				if( weight <= 0.0001 || weight >= 1.0001) continue;
								
				original = meshVerts[ vertexIndex ];	
				skinned = skinnedVerts[ vertexIndex ];
				
				pos.x = original.x;
				pos.y = original.y;
				pos.z = original.z;
				
				// joint transform
				pos = Utils3D.projectVector( matrix, pos );	
				
				//update the vertex
				skinned.x += (pos.x * weight);
				skinned.y += (pos.y * weight);
				skinned.z += (pos.z * weight);
			}
		}

		private var _cached:Array;
	}
}