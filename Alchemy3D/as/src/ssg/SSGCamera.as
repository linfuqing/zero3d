package ssg
{
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	public class SSGCamera extends SSGNode
	{
		public function SSGCamera()
		{
			super();
			aspect = 1;
			fovDegrees = 70;
			zNear = 0.02;
			zFar = 40.0;		
			updateProjectionMatrix ( );	
		}
		
		public function GetProjectionMatrix() : Matrix3D {
			updateProjectionMatrix ();
			return projectionMatrix;
		}
		
		public var aspect : Number; 
		public var fovDegrees : Number;
		public var zNear : Number;
		public var zFar : Number;
		
		internal var projectionMatrix : Matrix3D;
		
		public function XScaleFromZ ( z : Number ) : Number 
		{					
			return -z*Math.tan(fovDegrees * Math.PI / 360.0) * aspect;					
		}
				
		internal function makeFrustumMatrix ( left : Number, right : Number, top : Number, bottom : Number, zNear : Number, zFar : Number  ) : Matrix3D {
			var rval : Matrix3D = new Matrix3D;
			var myrawData : Vector.<Number> = new Vector.<Number>(16);
		
			myrawData[0] = (2*zNear)/(right-left);
			myrawData[1] = 0;
			myrawData[2] = (right+left)/(right-left);
			myrawData[3] = 0;
			
			myrawData[4] = 0;	
			myrawData[5] = (2*zNear)/(top-bottom);		
			myrawData[6] = (top+bottom)/(top-bottom);		
			myrawData[7] = 0;
		
			myrawData[8] = 0;
			myrawData[9] = 0;
			myrawData[10]= zFar/(zNear-zFar);	 
			myrawData[11]= -1;		
			
			myrawData[12]=  0;
			myrawData[13]=  0;
		    myrawData[14]=  (zNear*zFar)/(zNear-zFar);	
		    myrawData[15]=	0;
				
			rval.rawData = myrawData;	
			return rval;
		}		
		
		internal function updateProjectionMatrix ( ) : void {
			var yval:Number = zNear * Math.tan(fovDegrees * Math.PI / 360.0);
			var xval:Number = yval * aspect;	
			projectionMatrix = makeFrustumMatrix(-xval,xval,-yval,yval,zNear, zFar);
		}		
		
		public function interactiveRotateFirstPerson ( dx : Number, dy : Number ) : void {
			if ( dx!=0 ) objmatrix.prependRotation(dx,new Vector3D(0,1,0));
			if ( dy!=0 ) objmatrix.prependRotation(dy,new Vector3D(1,0,0));
			matrixdirty = true;
		}
		
		public function interactiveForwardFirstPerson ( amount : Number) : void {
			objmatrix.prependTranslation(0,0,-amount);			
			matrixdirty = true;					
		} 

		public function interactiveStrafeFirstPerson ( dx : Number, dy : Number ) : void {
			objmatrix.prependTranslation(dx,dy,0);			
			matrixdirty = true;
		} 

		
	}
}