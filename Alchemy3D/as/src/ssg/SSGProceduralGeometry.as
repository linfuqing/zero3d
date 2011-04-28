package ssg
{
	import __AS3__.vec.Vector;
	
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
		
	
	public class SSGProceduralGeometry extends SSGMesh
	{
		public function SSGProceduralGeometry() {
			super();
		}

		protected function MergeTipVertex ( uTess : int, vTess : int ) : void {
			var x : int;
			var os : uint = 0;
			var o : uint = 0;
			for ( var i : int = 0; i<2; i++ ) {
				for ( x=0; x<uTess; x++ ) {
					vertices_mem[o+0] = vertices_mem[os+0];
					vertices_mem[o+1] = vertices_mem[os+1];
					vertices_mem[o+2] = vertices_mem[os+2];
					vertices_mem[o+3] = vertices_mem[os+3];
					vertices_mem[o+4] = vertices_mem[os+4];
					vertices_mem[o+5] = vertices_mem[os+5];
					vertices_mem[o+6] = vertices_mem[os+6];
					vertices_mem[o+7] = vertices_mem[os+7];
					o += 8;
				}
				o = ((vTess-1)*uTess)*8;
				os = o;
			}
		}

		public function CreateSuperSphere ( uTess : int, vTess : int, r : Number, n1 : Number, n2 : Number ) : void {
			var myeval : Function = function( u : Number, v : Number, dest:Vector.<Number>, o : int ) : void 
				{ evalVertexSuperSphere ( r, n1, n2, u, v, vertices_mem, o ); };
			CreateUV ( uTess, vTess, true, false, myeval );
			MergeTipVertex ( uTess, vTess );
			CreateVertexNormals();
		}
		
		public function CreateDonut ( uTess : int, vTess : int, rInner : Number, rOuter : Number ) : void {
			var myeval : Function = function( u : Number, v : Number, dest:Vector.<Number>, o : int ) : void 
				{ evalVertexTorus ( rInner, rOuter, u, v, vertices_mem, o ); };
			CreateUV ( uTess, vTess, true, true, myeval );
		}
		
		public function CreatePlane ( uTess : int, vTess : int, sizeX : Number, sizeZ : Number ) : void {
			var myeval : Function = function( u : Number, v : Number, dest:Vector.<Number>, o : int ) : void 
				{ evalVertexPlane ( sizeX, sizeZ, (u-.5)*2, (v-.5)*2, vertices_mem, o ); };
			CreateUV ( uTess, vTess, false, false, myeval );
		}		
		
		public function CreateSphere ( uTess : int, vTess : int, radius : Number ) : void {
			var myeval : Function = function( u : Number, v : Number, dest:Vector.<Number>, o : int ) : void 
				{ evalVertexSphere ( radius, u, v, vertices_mem, o ); };
			MergeTipVertex ( uTess, vTess );				
			CreateUV ( uTess, vTess, false, false, myeval );			
		}
		
		public function CreateTube ( uTess : int, vTess : int, radius : Number ) : void {
			var myeval : Function = function( u : Number, v : Number, dest:Vector.<Number>, o : int ) : void 
			{ evalVertexTube ( radius, u, v, vertices_mem, o ); };
			CreateUV ( uTess, vTess, false, false, myeval );		
		}
		
		public function CreateTree ( uTess : int, vTess : int, radius : Number, controls : Vector.<Number> ) : void { 
			var myeval : Function = function( u : Number, v : Number, dest:Vector.<Number>, o : int ) : void 
			{ evalVertexExtruder ( radius, controls, u, v, vertices_mem, o ); };
			CreateUV ( uTess, vTess, false, false, myeval );
		}
		
		public function CreateUV ( uTess : int, vTess : int, closedU : Boolean, closedV : Boolean, evalme : Function ) : void {			
			vertices_mem = new Vector.<Number>(uTess*vTess*8);
			indices_mem = new Vector.<uint>((uTess-1)*(vTess-1)*6);

			// vertices
			var o:int = 0;
			var v:int;
			var u:int;
			for ( v=0; v<vTess; v++ ) {		
				for ( u=0; u<uTess; u++ ) {		
					var un : Number = u / (uTess-1);
					var vn : Number = v / (vTess-1);									
					evalme ( un, vn, vertices_mem, o );
					vertices_mem[o+6] = un; // uv
					vertices_mem[o+7] = vn;			
					o+=8;
				}
			}
			// indices
			o = 0;
			var os:int =0;
			for ( v=0; v<vTess-1; v++ ) {
				for ( u=0; u<uTess-1; u++ ) {		
					indices_mem[o+0] = os;
					indices_mem[o+1] = os+1;			
					indices_mem[o+2] = os+uTess;						
					indices_mem[o+3] = os+1;
					indices_mem[o+4] = os+uTess+1;			
					indices_mem[o+5] = os+uTess;									
					o+=6;
					os++;
				}
				if ( closedU ) {					
					indices_mem[o-5] -= uTess-1;
					indices_mem[o-3] -= uTess-1;			
					indices_mem[o-2] -= uTess-1;															
				}
				os++;
			}	
			
			if ( closedV ) {
				o -= (uTess-1)*6;
				for ( u=0; u<uTess-1; u++ ) {
					indices_mem[o+2] = u;
					indices_mem[o+4] = u+1;			
					indices_mem[o+5] = u;		
					o+=6;				
				}
			}
					
			ComputeBoundingBoxAndSphere ( );
			needupload = true;
		}		
		
		internal function evalVertexTorus ( rInner : Number, rOuter : Number, u : Number, v : Number, dest:Vector.<Number>, o : int ) : void {
			var ur : Number = u * Math.PI*2;
			var vr : Number = v * Math.PI*2;	
			dest[o+0] = ( rOuter + rInner * Math.cos(vr) ) * Math.cos(ur);
			dest[o+1] = ( rOuter + rInner * Math.cos(vr) ) * Math.sin(ur);
			dest[o+2] = rInner * Math.sin(vr);
			
			dest[o+3] = Math.cos(vr) * Math.cos(ur);
			dest[o+4] = Math.cos(vr) * Math.sin(ur);
			dest[o+5] = Math.sin(vr);	
		}		
		
		internal function evalVertexExtruder ( rBase : Number, points : Vector.<Number>, u : Number, v : Number, dest:Vector.<Number>, o : int ) : void {
			// points are in x/y plane
			var pidx : int = int(u*(points.length/2-1))*2;			
			var x : Number,y : Number,dx : Number,dy : Number; 			
			x = points[pidx+0];
			y = points[pidx+1];
			if ( pidx >= 2 ) {
				dx = x - points[pidx-2];
				dy = y - points[pidx-1];
			} else {
				dx = points[pidx+2] - x;
				dy = points[pidx+3] - y; 			
			}
			var l : Number = 1.0/Math.sqrt(dx*dx + dy*dy);
			dx *= l;
			dy *= l;
			// dz = 0, (dx,dy,0) = up vector
			//         (0,0,1) = left vector
			//         (dx,dy,0)x(0,0,1) = (dy,-dx,0) = right vector 	
			var vr : Number = v * Math.PI*2;	
			var r : Number = rBase * (1.0-u*u); 
			var dl : Number = Math.sin(vr);
			var dr : Number = Math.cos(vr);
			dest[o+3] = dy * dr; 
			dest[o+4] = -dx * dr;
			dest[o+5] = dl; 
			dest[o+0] = x+dest[o+3]*r;  
			dest[o+1] = y+dest[o+4]*r;
			dest[o+2] = 0+dest[o+5]*r;						
		}
		
		internal function evalVertexTube ( r : Number, u : Number, v : Number, dest:Vector.<Number>, o : int ) : void {			
			var vr : Number = v * Math.PI*2;	
			dest[o+0] = r * Math.sin(vr);
			dest[o+1] = -u;
			dest[o+2] = r * Math.cos(vr);
			dest[o+3] = Math.sin(vr);
			dest[o+4] = 0;
			dest[o+5] = Math.cos(vr);	
		}		

		internal function evalVertexPlane ( sizeX : Number, sizeZ : Number, u : Number, v : Number, dest:Vector.<Number>, o : int ) : void {	
			dest[o+0] = u * sizeX;
			dest[o+1] = 0;
			dest[o+2] = v * sizeZ;
			
			dest[o+3] = 0;
			dest[o+4] = -1;
			dest[o+5] = 0;	
		}
		
		internal function cospow ( x : Number, n : Number ) : Number {
			var c : Number = Math.cos(x); 			
			if ( c<0 ) return -Math.pow(-c,n);
			else return Math.pow(c,n);;
		}
		
		internal function sinpow ( x : Number, n : Number ) : Number {
			var c : Number = Math.sin(x); 
			var cp : Number = Math.pow(c,n); 
			if ( c<0 ) return -Math.pow(-c,n);
			else return Math.pow(c,n);;
		}		
		
		internal function evalVertexSuperSphere ( r : Number, n1 : Number, n2 : Number,  u : Number, v : Number, dest:Vector.<Number>, o : int ) : void {
			var beta : Number = (u-0.5) * 2.0 * Math.PI;
			var rho : Number = (v-0.5) * Math.PI;
										
			dest[o+0] = r * cospow(rho,n1) * cospow(beta,n2); 
			dest[o+1] = r * cospow(rho,n1) * sinpow(beta,n2);
			dest[o+2] = r * sinpow(rho,n1);
						
			dest[o+3] = 0; //cospow(rho,2-n1) * cospow(beta,2-n2);
			dest[o+4] = 0; //cospow(rho,2-n1) * sinpow(beta,2-n2);
			dest[o+5] = 0; //sinpow(rho,2-n1);
		}				

		
		internal function evalVertexSphere ( radius : Number, u : Number, v : Number, dest:Vector.<Number>, o : int ) : void {
			var ur : Number = u * Math.PI;
			var vr : Number = v * Math.PI*2;
			var x : Number = Math.sin(ur)*Math.cos(vr);
			var y : Number = Math.sin(ur)*Math.sin(vr);
			var z : Number = Math.cos(ur);
			dest[o+0] = x*radius;
			dest[o+1] = y*radius;
			dest[o+2] = z*radius;
			dest[o+3] = x;
			dest[o+4] = y;
			dest[o+5] = z;						 										
		}						
		
				
		
	}
}