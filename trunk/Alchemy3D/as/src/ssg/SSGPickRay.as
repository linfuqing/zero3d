package ssg
{
	import __AS3__.vec.Vector;
	
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	public class SSGPickRay
	{
		public function SSGPickRay()
		{
			ox = 0; oy = 0; oz = 0;
			dx = 0; dy = 0; dz = 1;	
			ResetHit ( );
		}
		
		public function ResetHit ( ) : void {
			thit = 1000000; // something reasonably far
			objhit = null;
			hitcount = 0;
			uhit = 0; 
			vhit = 0;
			tests = 0;
		}
		
		// x,y are normalize -1..1 window coordinates, creates ray in world space
		public function CreateRayFromCamera ( x : Number, y : Number, cam : SSGCamera ) : void {
			// eye space position is 0/0/0
			// eye space direction follows from projection
			ResetHit ( );
			
			// just use a quick projection matrix trick (only works for centered projections)
			var myrawData : Vector.<Number> = cam.projectionMatrix.rawData;
			esdx = x / myrawData[0];
			esdy = -y / myrawData[5];
			esdz = myrawData[10];
			
			var len : Number = esdx*esdx + esdy*esdy + esdz*esdz;
			len = 1.0 / Math.sqrt(len);
			esdx *= len;
			esdy *= len;
			esdz *= len;	
			
			cam.UpdateWorldMatrix();
			var wm : Matrix3D = cam.GetWorldMatrix();
			// to world space
			var rawm : Vector.<Number> = wm.rawData;
			wsox = rawm[12]; wsoy = rawm[13]; wsoz = rawm[14];
			wsdx = esdx * rawm[0] + esdy * rawm[4] + esdz * rawm[8];
			wsdy = esdx * rawm[1] + esdy * rawm[5] + esdz * rawm[9];
			wsdz = esdx * rawm[2] + esdy * rawm[6] + esdz * rawm[10];	
			
			//trace ( "wspos: "+wsox.toString()+", "+wsoy.toString()+", "+wsoz.toString() );
			//trace ( "wsdir: "+wsdx.toString()+", "+wsdy.toString()+", "+wsdz.toString() );
			
			ox = wsox; oy = wsoy; oz = wsoz;
			dx = wsdx; dy = wsdy; dz = wsdz;								
		} 
		
		public function UpdateRayFromObject ( obj : SSGNode ) : void {
			// assumes that the ws parts of the ray are set
			obj.UpdateWorldMatrix (); 
			var imv : Matrix3D = obj.GetWorldMatrix().clone();
			imv.invert ( );
			var rawm : Vector.<Number> = imv.rawData;
			ox = wsox * rawm[0] + wsoy * rawm[4] + wsoz * rawm[8] + rawm[12];
			oy = wsox * rawm[1] + wsoy * rawm[5] + wsoz * rawm[9] + rawm[13];
			oz = wsox * rawm[2] + wsoy * rawm[6] + wsoz * rawm[10] + rawm[14];
			
			dx = wsdx * rawm[0] + wsdy * rawm[4] + wsdz * rawm[8];
			dy = wsdx * rawm[1] + wsdy * rawm[5] + wsdz * rawm[9];
			dz = wsdx * rawm[2] + wsdy * rawm[6] + wsdz * rawm[10];		
			
			//trace ( "ospos: "+ox.toString()+", "+oy.toString()+", "+oz.toString() );
			//trace ( "osdir: "+dx.toString()+", "+dy.toString()+", "+dz.toString() );
		}
		
		public function IntersectBoundingBoxCheckOnly ( extents : Vector.<Number> ) : Boolean {
			var idx : Number = 1.0/dx;
			var idy : Number = 1.0/dy;
			var idz : Number = 1.0/dz;
			
			var temp : Number;
			
			var tmin : Number = (extents[0] - ox)*idx;
			var tmax : Number = (extents[3] - ox)*idx; 
			if ( tmin > tmax ) { temp = tmin; tmin = tmax; tmax = temp; }

			var tmin2 : Number = (extents[1] - oy)*idy;
			var tmax2 : Number = (extents[4] - oy)*idy; 
			if ( tmin2 > tmax2 ) { temp = tmin2; tmin2 = tmax2; tmax2 = temp; }			

			if ( tmin2 >= tmax || tmax2 <= tmin ) return false; // intervals do not overlap
			// shrink
			if ( tmin2 > tmin ) tmin = tmin2; 
			if ( tmax2 < tmax ) tmax = tmax2;

			tmin2 = (extents[2] - oz)*idz;
			tmax2 = (extents[5] - oz)*idz; 
			if ( tmin2 > tmax2 ) { temp = tmin2; tmin2 = tmax2; tmax2 = temp; }
			
			if ( tmin2 >= tmax || tmax2 <= tmin ) return false; // intervals do not overlap
			// shrink
			if ( tmin2 > tmin ) tmin = tmin2; 
			if ( tmax2 < tmax ) tmax = tmax2;

			// check before cam
			if ( tmax < 0 || tmin > thit ) return false;
			
			return true;			
		}
		
		private static const eps : Number = .0000001;
		
		// we also probably want a triangle and box intersect function native coded somewhere		
		public function IntersectTriangle_W ( points : Vector.<Number>, o0 : uint, o1 : uint, o2 : uint, obj : SSGNode ) : Boolean {
			// ingo wald based projection method (http://www.mpi-sb.mpg.de/~wald/PhD)
			// (broken... fixme)
			// calc edges and normal
			tests++;
			var e1x : Number = points[o2+0] - points[o0+0];
			var e1y : Number = points[o2+1] - points[o0+1];
			var e1z : Number = points[o2+2] - points[o0+2];
			// e2=p2-p0		
			var e2x : Number = points[o1+0] - points[o0+0];
			var e2y : Number = points[o1+1] - points[o0+1];
			var e2z : Number = points[o1+2] - points[o0+2];
			// n=e1 x e2
			var nx : Number = e1y*e2z - e1z*e2y;
			var ny : Number = e1z*e2x - e1x*e2z;
			var nz : Number = e1x*e2y - e1y*e2x;
			// distance test
			var oan : Number = (ox-points[o0+0])*nx + (oy-points[o0+1])*ny + (oz-points[o0+2])*nz;
			var dn : Number = dx*nx + dy*ny + dz*nz;  
			var t : Number = -oan / dn;
			if ( !(t>eps) ) return false;
			if ( nx<0 ) nx=-nx;
			if ( ny<0 ) ny=-ny;
			if ( nz<0 ) nz=-nz;
			var u : Number, v : Number, beta : Number, gamma : Number, ci : Number;
			if ( nx > ny ) {
				if ( nx > nz ) {
					// k=0; u=1, v=2
					u = oy + t * dy;
					v = oz + t * dz;
					ci = 1.0/(e1y*e2z - e1z*e2y);
					beta = (e1y*v - e1z*u) * ci;
					gamma = (e2z*u - e2y*v) *ci;					
				} else {
					// k=2; u=0, v=1
					u = ox + t * dx;
					v = oy + t * dy;				
					ci = 1.0/(e1x*e2y - e1y*e2x);
					beta = (e1x*v - e1y*u) * ci;
					gamma = (e2y*u - e2x*v) *ci;	
				}
			}  else {
				if ( ny > nz ) {
					// k=1, u=2, v=0
					u = oz + t * dz;
					v = ox + t * dx;
					ci = 1.0/(e1z*e2x - e1x*e2z);
					beta = (e1z*v - e1x*u) * ci;
					gamma = (e2x*u - e2z*v) *ci;											
				} else {
					// k=2, u=0, v=1
					u = ox + t * dx;
					v = oy + t * dy;
					ci = 1.0/(e1x*e2y - e1y*e2x);
					beta = (e1x*v - e1y*u) * ci;
					gamma = (e2y*u - e2x*v) *ci;										
				}
			}		
			
			if ( !(beta >= 0) ) return false;
			if ( !(gamma >= 0 && beta+gamma < 1) ) return false;
								
			hitcount ++;			
			if ( t<thit ) {
				thit = t;
				objhit = obj;
				uhit = beta;
				vhit = gamma;
			}				
			return true;							
		}		
		
		public function IntersectTriangle_HM ( points : Vector.<Number>, o0 : uint, o1 : uint, o2 : uint, obj : SSGNode ) : Boolean {
			// barycentric haines/moller test (http://www.ddj.com/184404201?pgno=1)
			// e1=p1-p0
			tests++;
			var e1x : Number = points[o1+0] - points[o0+0];
			var e1y : Number = points[o1+1] - points[o0+1];
			var e1z : Number = points[o1+2] - points[o0+2];
			// e2=p2-p0		
			var e2x : Number = points[o2+0] - points[o0+0];
			var e2y : Number = points[o2+1] - points[o0+1];
			var e2z : Number = points[o2+2] - points[o0+2];	
			// r=d x e2
			var rx : Number = dy*e2z - dz*e2y;
			var ry : Number = dz*e2x - dx*e2z;
			var rz : Number = dx*e2y - dy*e2x;
			// a=e1 . r
			var a : Number = e1x*rx + e1y*ry + e1z*rz;
						
			if ( a < eps ) return false; // too parallel or backface 				
			
			// s=o-p0
			var sx : Number = ox - points[o0+0];
			var sy : Number = oy - points[o0+1];
			var sz : Number = oz - points[o0+2]; 

			// q = s x e1
			var qx : Number = sy*e1z - sz*e1y;
			var qy : Number = sz*e1x - sx*e1z;
			var qz : Number = sx*e1y - sy*e1x;		
									
			//  f=1/a 	
			var f : Number = 1.0/a;
			
			// u=s . r			
			var u : Number = (sx*rx + sy*ry + sz*rz)*f;
			// v=d . q			
			var v : Number = (dx*qx + dy*qy + dz*qz)*f;
									
			if (u<0.0 || u>1.0) return false;
			if (v<0.0 || u+v>1.0) return false;
			  	
			// t=f * (e2 . q)
			var t : Number = (e2x*qx + e2y*qy + e2z*qz)*f;
									
			if ( t>0 ) {
				hitcount ++;			
				if ( t<thit ) {
					thit = t;
					objhit = obj;
					uhit = u;
					vhit = v;
				}				
			}
			
			return true; 			
		}
		
		public function GetWorldSpaceX ( ) : Number { return wsox+wsdx*thit; }
		public function GetWorldSpaceY ( ) : Number { return wsoy+wsdy*thit; }
		public function GetWorldSpaceZ ( ) : Number { return wsoz+wsdz*thit; }
		
		public function GetWorldSpace ( ) : Vector3D { 
			return new Vector3D ( wsox+wsdx*thit, wsoy+wsdy*thit, wsoz+wsdz*thit ); 
		}
			
		public function GetObjectSpace ( ) : Vector3D { 
			var ws : Vector3D = GetWorldSpace ( );
			var wsmatrix : Matrix3D = objhit.GetWorldMatrix().clone();
			wsmatrix.invert();
			return wsmatrix.transformVector(ws); 
		}
		
		public function GetEyeSpace ( cam : SSGCamera ) : Vector3D { 
			var ws : Vector3D = GetWorldSpace ( );			
			var wm : Matrix3D = cam.GetWorldMatrix().clone();
			wm.invert();
			return wm.transformVector(ws); 
		}
		
		
		// input (es origin is 000)
		public var esdx : Number, esdy : Number, esdz : Number;
		public var wsdx : Number, wsdy : Number, wsdz : Number;
		public var wsox : Number, wsoy : Number, wsoz : Number;
		
		// object space coords, used in functions to check 
		public var ox : Number, oy : Number, oz : Number;
		public var dx : Number, dy : Number, dz : Number;
		
		// output
		public var thit : Number; 
		public var objhit : SSGNode; 
		public var uhit : Number, vhit : Number;
		public var hitcount : int;
		public var tests : uint;
	}
}