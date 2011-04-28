package ssg 
{
	import flash.display3D.*;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import __AS3__.vec.Vector;
	
	public class SSGNode {
		public function SSGNode() {
			parent = null;
			objmatrix = new Matrix3D;
			objmatrix.identity();
			children = new Array();
			matrixdirty = true;
			worldpos = new Vector.<Number>(4);
		}
		
		public function AddNode( node : SSGNode ) : void {			
			children.push(node);			
			node.ssgbase = ssgbase;
			node.parent = this;
			node.DirtyMeAndAllChildren ( );
		}		
		
		public function SetPosition ( x : Number, y : Number, z : Number ) : void {
			objmatrix.position = new Vector3D(x,y,z);
			DirtyMeAndAllChildren ( );
		}
				
		public function Move ( dx : Number, dy : Number, dz : Number ) : void {
			objmatrix.appendTranslation ( dx, dy, dz );			
			DirtyMeAndAllChildren ( );
		}
		
		public function Identity ( ) : void {
			objmatrix.identity();
			DirtyMeAndAllChildren ( );
		} 
		
		public function EulerRotate ( rxDegrees : Number, ryDegrees : Number, rzDegrees : Number ) : void {			
			objmatrix.prependRotation(rxDegrees,new Vector3D(1,0,0)); 
			objmatrix.prependRotation(ryDegrees,new Vector3D(0,1,0)); 
			objmatrix.prependRotation(rzDegrees,new Vector3D(0,0,1));
			DirtyMeAndAllChildren ( );
		}		
		
		public function EulerRotatePost ( rxDegrees : Number, ryDegrees : Number, rzDegrees : Number ) : void {			
			objmatrix.appendRotation(rxDegrees,new Vector3D(1,0,0)); 
			objmatrix.appendRotation(ryDegrees,new Vector3D(0,1,0)); 
			objmatrix.appendRotation(rzDegrees,new Vector3D(0,0,1));
			DirtyMeAndAllChildren ( );
		}				
		
		public function LookAt ( target : SSGNode ) : void {	

			DirtyMeAndAllChildren ( );
		} 
				
		public function PickRec ( dest : SSG, ray : SSGPickRay ) : void {
			if ( !hidden ) Pick ( dest, ray );
			for each(var child:SSGNode in children)
				child.PickRec ( dest, ray );			
		}
				
		protected function Pick ( dest : SSG, ray : SSGPickRay ) : void {
			// implement!
		}				
						
		public function RenderRec ( dest : SSG ) : void {
			if ( !hidden ) {
				Render ( dest );
				for each(var child:SSGNode in children)
					child.RenderRec ( dest );
			}
		}
		
		protected function Render ( dest : SSG ) : void {			
			// implement!			
		}		
		
		public function GetWorldMatrix ( ) : Matrix3D {
			UpdateWorldMatrix();
			return worldmatrix;
		}
				
		internal function UpdateWorldMatrix ( ) : void {
			if ( !matrixdirty ) return;			
			if ( parent ) {
				parent.UpdateWorldMatrix();
				worldmatrix = parent.worldmatrix.clone();				
			} else {
				worldmatrix = new Matrix3D();
				worldmatrix.identity();
			}
			worldmatrix.prepend ( objmatrix );
			matrixdirty = false;
		}
		
		public function UpdateWorldSpacePosition ( ) : void {
			UpdateWorldMatrix ( );
			var temp : Vector.<Number> = new Vector.<Number>(4);
			temp[0] = 0; temp[1] = 0; temp[2] = 0; temp[3] = 1;
			worldmatrix.transformVectors ( temp, worldpos );
		}
		
		public function DirtyMeAndAllChildren ( ) : void {
			if ( matrixdirty ) return; // already done
			matrixdirty = true;
			for each(var child:SSGNode in children)
				child.DirtyMeAndAllChildren();
		}
		
		public function CollectThingsToArrayRec ( type : Class, dest : Array ) : void {
			if ( this is type ) dest.push( this );			   
			for each( var child:SSGNode in children )
				child.CollectThingsToArrayRec ( type, dest );
		} 
		
		public function SetDefaultVertexMatrices ( dest : SSG, model : Matrix3D ) : void {
			dest.context3D.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 0, model, true );
			model.append ( dest.view );
			dest.context3D.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 8, model, true ); // modelview
			model.append ( dest.projection );
			dest.context3D.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 16, model, true ); // modelviewprojection			
		}		

		public var children : Array;
		public var parent : SSGNode; 
		public var objmatrix : Matrix3D; 
		public var matrixdirty : Boolean;
		public var ssgbase : SSG;
		public var worldpos : Vector.<Number>;
		public var worldmatrix : Matrix3D;
		
		public var hidden : Boolean;
	}
}