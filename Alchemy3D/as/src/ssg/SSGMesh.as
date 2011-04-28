package ssg
{
	import __AS3__.vec.Vector;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DVertexBufferFormat;

	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;	
	import flash.geom.Matrix3D;
	import flash.geom.Matrix;
	
	public class SSGMesh extends SSGNode
	{
		public function SSGMesh()
		{
			super();
			needupload = true;
			indices_mem = null;
			vertices_mem = null;
			indices_card = null;
			vertices_card = null;	
			
			material = new SSGMaterial();		
						
			boundingsphereradius = 0;		
			boundingbox = null;						
		}
				
		// assumes vertex format: x,y,z, nx,ny,nz, u,v
		protected var indices_card : IndexBuffer3D;
		protected var vertices_card : VertexBuffer3D;
		protected var indices_mem : Vector.<uint>;
		protected var vertices_mem : Vector.<Number>;			
		protected var needupload : Boolean;		
		private var indices_card_count : int;
		private var vertices_card_count : int;
		
		protected var boundingbox : Vector.<Number>; // object space axis aligned, min(x,y,z) - max(x,y,z) 
		protected var boundingsphereradius : Number; // object space, centered around origin				
		
		protected function ComputeBoundingBoxAndSphere ( ) : void {
			if ( vertices_mem == null || vertices_mem.length < 8 ) {
				boundingbox = null;
				return;
			} 
			boundingbox = new Vector.<Number>(6,true);
			boundingbox[0] = vertices_mem[0]; boundingbox[1] = vertices_mem[1]; boundingbox[2] = vertices_mem[2];
			boundingbox[3] = vertices_mem[0]; boundingbox[4] = vertices_mem[1]; boundingbox[5] = vertices_mem[2];
			for ( var o : uint = 8; o < vertices_mem.length; o+=8 ) {
				if ( vertices_mem[o+0] < boundingbox[0] ) boundingbox[0] = vertices_mem[o+0];
				if ( vertices_mem[o+1] < boundingbox[1] ) boundingbox[1] = vertices_mem[o+1];
				if ( vertices_mem[o+2] < boundingbox[2] ) boundingbox[2] = vertices_mem[o+2];
				if ( vertices_mem[o+0] > boundingbox[3] ) boundingbox[3] = vertices_mem[o+0];
				if ( vertices_mem[o+1] > boundingbox[4] ) boundingbox[4] = vertices_mem[o+1];
				if ( vertices_mem[o+2] > boundingbox[5] ) boundingbox[5] = vertices_mem[o+2];				
			}
			boundingsphereradius = 0;
			for ( var i : uint; i<8; i++ ) {
				var x : Number = boundingbox[(i&1)==0?0:3];
				var y : Number = boundingbox[(i&2)==0?1:4];
				var z : Number = boundingbox[(i&4)==0?2:5];				
				var d : Number = x*x + y*y + z*z;
				if ( d > boundingsphereradius ) boundingsphereradius = d;  
			}			
			boundingsphereradius = Math.sqrt(boundingsphereradius);
		}
		
		protected function NormalizeAllVertexNormals ( ) : void {
			// normalize all vertex normals
			for ( var i:int=0; i<vertices_mem.length; i+=8 ) { // zero normals
				var len : Number = vertices_mem[i+3]*vertices_mem[i+3] + vertices_mem[i+4]*vertices_mem[i+4] + vertices_mem[i+5]*vertices_mem[i+5];
				if ( len==0 ) {
					vertices_mem[i+3] = 0;
					vertices_mem[i+4] = 0;
					vertices_mem[i+5] = 1;					
				} else {
					len = 1.0 / Math.sqrt(len);
					vertices_mem[i+3] *= len;
					vertices_mem[i+4] *= len;
					vertices_mem[i+5] *= len;					
				}
			}			
		}
		
		private function ComputeNormalAndAdd ( mem : Vector.<Number>, o1 : uint,o2 : uint,o3 : uint, normalize : Boolean ) : void {
			var dx1 : Number = mem[o2+0] - mem[o1+0];
			var dy1 : Number = mem[o2+1] - mem[o1+1];
			var dz1 : Number = mem[o2+2] - mem[o1+2];
 			var dx2 : Number = mem[o3+0] - mem[o1+0];
			var dy2 : Number = mem[o3+1] - mem[o1+1];
			var dz2 : Number = mem[o3+2] - mem[o1+2];
			// cross
			var nx : Number = dy1*dz2 - dz1*dy2;
			var ny : Number = dz1*dx2 - dx1*dz2;
			var nz : Number = dx1*dy2 - dy1*dx2;
			// normalize
			if ( normalize ) {
				var len : Number = nx*nx + ny*ny + nz*nz; 
				if ( len==0 ) return;
				len = 1.0 / Math.sqrt(len);
				nx *=len; ny *=len; nz *=len;
			}
			// add in
			mem[o1+3] += nx; mem[o1+4] += ny; mem[o1+5] += nz; 
			mem[o2+3] += nx; mem[o2+4] += ny; mem[o2+5] += nz;
			mem[o3+3] += nx; mem[o3+4] += ny; mem[o3+5] += nz;
		}
		
		protected function CreateVertexNormals ( normalize : Boolean = false ) : void {
			// assumes everything is set in _mem, except undefined values as normals
			var i : int;
			for ( i = 0; i<vertices_mem.length; i+=8 ) { // zero normals
				vertices_mem[i+3] = 0; vertices_mem[i+4] = 0; vertices_mem[i+5] = 0;
			}
			// compute face normals and add to vertices							
			for ( i=0; i<indices_mem.length; i+=3 ) {
				ComputeNormalAndAdd ( vertices_mem, indices_mem[i]<<3,indices_mem[i+1]<<3,indices_mem[i+2]<<3, false );				 								
			}
			NormalizeAllVertexNormals();	
			needupload = true;				
		}
		
		public function SetupAllVertexStreamsAndDraw ( dest : SSG ) : Boolean {			
			if ( indices_mem == null || vertices_mem == null ) return false;  
			if ( needupload ) {				
				if ( indices_card==null || indices_card_count!=indices_mem.length ) {
					indices_card = dest.context3D.createIndexBuffer ( indices_mem.length );
					indices_card_count = indices_mem.length;					
				}
				if ( vertices_card==null || vertices_card_count!=vertices_mem.length/8 ) {
					vertices_card = dest.context3D.createVertexBuffer ( vertices_mem.length/8, 8 );
					vertices_card_count = vertices_mem.length/8;
				}
				indices_card.uploadFromVector( indices_mem, 0, indices_mem.length );
				vertices_card.uploadFromVector( vertices_mem, 0, vertices_mem.length/8 );
				needupload = false;				
			}
			
			dest.context3D.setVertexBufferAt ( 0, vertices_card, 0, Context3DVertexBufferFormat.FLOAT_3);
			dest.context3D.setVertexBufferAt ( 1, vertices_card, 3, Context3DVertexBufferFormat.FLOAT_3);						
			dest.context3D.setVertexBufferAt ( 2, vertices_card, 6, Context3DVertexBufferFormat.FLOAT_2);						
			 
			dest.context3D.drawTriangles ( indices_card, 0, indices_mem.length/3 );
			
			dest.tricount += indices_mem.length/3;				
			return false;
		}
		
		public function GeneratePickTree ( ) : void {
			picktree = new SSGPickTree ( );
			picktree.CreateInTimer ( vertices_mem, 8, indices_mem, 10, 8 );
		}
				
		override protected function Pick ( dest : SSG, ray : SSGPickRay ) : void {
			if ( indices_mem == null || vertices_mem == null ) return;
			if ( hidden ) return;			
			ray.UpdateRayFromObject(this);
			
			if ( boundingbox!=null && !ray.IntersectBoundingBoxCheckOnly ( boundingbox ) ) return;
			
			if ( picktree==null ) {
				for ( var o : uint = 0; o<indices_mem.length; o+=3 ) {
					ray.IntersectTriangle_HM(vertices_mem, indices_mem[o]<<3, indices_mem[o+1]<<3, indices_mem[o+2]<<3, this );
					//ray.IntersectTriangle_W(vertices_mem, indices_mem[o]<<3, indices_mem[o+1]<<3, indices_mem[o+2]<<3, this );
				} 			
			} else {				
				picktree.Intersect ( ray, vertices_mem, this ); 
			}
		}						
		
		public function IsBoundingBoxVisibleInClipspace ( mvp : Matrix3D, bounds : Vector.<Number> ) : Boolean {
			// just transform 8 vertices to clipspace, then check if they are completly clipped
			// we really should add a native function to matrix3D for this ...
			// Matrix3D.CheckBoundingBoxClipspaceBits ( Vector.<Number>(6) bounds ) : uint
			
			var rawm : Vector.<Number> = mvp.rawData;
			
			var outsidebits : uint = (1<<6)-1; 
			 
			for ( var i : uint = 0; i<8; i++ ) {				
				var x : Number = boundingbox[(i&1)==0?0:3];
				var y : Number = boundingbox[(i&2)==0?1:4];
				var z : Number = boundingbox[(i&4)==0?2:5];
				// transform
				var xcs : Number = x * rawm[0] + y * rawm[4] + z * rawm[8] + rawm[12];				
				var ycs : Number = x * rawm[1] + y * rawm[5] + z * rawm[9] + rawm[13];
				var zcs : Number = x * rawm[2] + y * rawm[6] + z * rawm[10] + rawm[14];
				var wcs : Number = x * rawm[3] + y * rawm[7] + z * rawm[11] + rawm[15];
				// check clipping				
				if ( xcs >= -wcs ) outsidebits &= ~(1<<0); // no longer all are outside -x ... clear -x bit.. etc
				if ( xcs <= wcs ) outsidebits &= ~(1<<1); 
				if ( ycs >= -wcs ) outsidebits &= ~(1<<2);
				if ( ycs <= wcs ) outsidebits &= ~(1<<3);	
				if ( zcs >= 0/*-wcs*/ ) outsidebits &= ~(1<<4); // gl style...
				if ( zcs <= wcs ) outsidebits &= ~(1<<5);				
			} 			
			if ( outsidebits!=0 ) return false;  			
			return true;
		}
				
		override protected function Render ( dest : SSG ) : void {		
			if ( hidden ) return;
			
			// setup matrices
			var model : Matrix3D = GetWorldMatrix().clone();
			SetDefaultVertexMatrices ( dest, model );
			
			// check bb 
			if ( boundingbox && !IsBoundingBoxVisibleInClipspace ( model, boundingbox ) ) return; 
						
			var modeli : Matrix3D = GetWorldMatrix().clone();					
			modeli.invert();								
			
			// progs
			material.SetupForRender ( dest ); 
			
			// collect lights
			dest.PrepareAllLightsForRendering();
			
			// setup lights for pixel shader
			//dest.setProgramConstants ( Context3DProgramType.FRAGMENT, 0, 1, zerovec );
			
			//if ( dest.selectednode == this ) dest.setProgramConstants ( Context3DProgramType.FRAGMENT, 3, 1, selvec );
			//else dest.setProgramConstants ( Context3DProgramType.FRAGMENT, 3, 1, notselvec );
				
			//dest.setProgramConstants ( Context3DProgramType.FRAGMENT, 4, 1, material.preview_diffuse );
			//dest.setProgramConstants ( Context3DProgramType.FRAGMENT, 5, 1, material.preview_specular );																			
																
			//var evec:Vector.<Number> = new Vector.<Number>(4);		
			//modeli.transformVectors ( dest.activecamera.worldpos, evec );				
			//evec[3] = 1;
			//dest.setProgramConstants ( Context3DProgramType.VERTEX, 20, 1, evec ); // object space eye position
			//dest.setProgramConstants ( Context3DProgramType.VERTEX, 21, 1, zerovec ); // zero
			//dest.setProgramConstants ( Context3DProgramType.VERTEX, 22, 1, material.preview_diffuse );
			//dest.setProgramConstants ( Context3DProgramType.VERTEX, 23, 1, material.preview_specular );  											
			/*
			var nlights:int = dest.lightlist.length;
			if ( nlights > 4 ) nlights = 4;
			var i : int; 			
			for ( i = 0; i<nlights; i++ ) {
				var l : SSGLight = dest.lightlist[i];
				var lvec:Vector.<Number> = new Vector.<Number>(4);
				modeli.transformVectors ( l.worldpos, lvec );				
				lvec[3] = 1;
				dest.setProgramConstants ( Context3DProgramType.VERTEX, 24+i*4, 1, lvec ); // object space lighti position
				dest.setProgramConstants ( Context3DProgramType.VERTEX, 24+i*4+1, 1, l.color ); // light color	
				//dest.setProgramConstants ( Context3DProgramType.VERTEX, 24+i*4+2, 1, zerovec );
				//dest.setProgramConstants ( Context3DProgramType.VERTEX, 24+i*4+3, 1, zerovec );			
			} 
			*/
			//for ( i = nlights*4; i<4*4; i++ ) { // zero unused lights
			//	dest.setProgramConstants ( Context3DProgramType.VERTEX, 24+i, 1, zerovec ); // object space lighti position
			//}			
			
			dest.context3D.setBlendFactors ( Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO );
			dest.context3D.setDepthTest ( true, Context3DCompareMode.LESS_EQUAL );							 
			
			SetupAllVertexStreamsAndDraw ( dest );					
		}
		
		public function IsHiddenToActiveCamera ( dest : SSG ) : Boolean {
			return false;
		}		
		 
		public var material : SSGMaterial;		
		protected var picktree : SSGPickTree;
		
	}
}