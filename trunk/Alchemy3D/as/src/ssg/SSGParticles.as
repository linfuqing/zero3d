package ssg
{
	import __AS3__.vec.Vector;
		
	import flash.utils.ByteArray;	
	import flash.display3D.*;
	import com.adobe.utils.AGALMiniAssembler;	
	
	public class SSGParticles extends SSGNode
	{
		
		public function SSGParticles( setcount : uint )
		{
			super();
			count = setcount; 
			activecount = 0;			
			particles = new Vector.<Number> ( count * 8 ); // pos xyz, velocity xyz, lifetime, energy
			vertices_mem = new Vector.<Number> ( count * 8 * 4); // copy, expanded by 4
			
			force_x = 0.0;
			force_y = 4.0;
			force_z = 0.0; // some fake gravity!	
			
			essize = .2;	
			fallofftime = 1;		
			
			planecount = 0;
			planes = new Vector.<Number>(32);
			
			bitmap = new SSGMap;
												
		}
				
		internal function RandRange ( min : Number, max : Number ) : Number {
			return Math.random() * (max-min) + min;
		} 
		
		internal function RandDirectionVector ( dest : Vector.<Number>, offset : uint, len : Number ) : void {
			var x:Number = Math.random()-0.5;
			var y:Number = Math.random()-0.5;
			var z:Number = Math.random()-0.5;
			var veclen:Number = x*x + y*y + z*z;
			veclen = len / Math.sqrt(veclen);
			dest[offset+0] = x*veclen;
			dest[offset+1] = y*veclen;
			dest[offset+2] = z*veclen;  
		}
		
		public function AddPlane ( xpos : Number, ypos : Number, zpos : Number, xnormal : Number, ynormal : Number, znormal : Number ) : void {
			planes[planecount*4] = xnormal;
			planes[planecount*4+1] = ynormal;
			planes[planecount*4+2] = znormal;
			planes[planecount*4+3] = xnormal*xpos + ynormal*ypos + znormal*zpos;
			planecount++;			
		}
		
		public function SpawnCircular ( num : uint, startsubposrange : Number, 
									startvelocity_min : Number, startvelocity_max : Number,
									startlife_min : Number, startlife_max : Number, 
									startenergy_min : Number, startenergy_max : Number,
									x : Number, y : Number, z : Number ) : void {
			if ( num+activecount > count ) num = count - activecount;
			var o : uint = activecount * 8;
			for ( var i : uint = 0; i<num; i++ ) { 
				RandDirectionVector ( particles, o+3, RandRange (startvelocity_min,startvelocity_max) );
				var t : Number = RandRange ( 0, startsubposrange );
				particles[o+0] = x + t*particles[o+3];
				particles[o+1] = y + t*particles[o+4];
				particles[o+2] = z + t*particles[o+5];
				particles[o+6] = RandRange ( startlife_min, startlife_max );
				particles[o+7] = RandRange ( startenergy_min, startenergy_max );							
				o+=8;
			}
			activecount += num;
		}
		
		public function SpawnSparks ( num : uint, srco : uint ) : void {
			if ( num+activecount > count ) num = count - activecount;
			var o : uint = activecount * 8;			
			for ( var i : uint = 0; i<num; i++ ) {
				RandDirectionVector ( particles, o+3, RandRange (1,1) );
				
				particles[o+0] = particles[srco];
				particles[o+1] = particles[srco+1];
				particles[o+2] = particles[srco+2];
				particles[o+3] += particles[srco+3];
				particles[o+4] += particles[srco+4];
				particles[o+5] += particles[srco+5];				
				particles[o+6] = particles[srco+6]/2;  
				particles[o+7] = particles[srco+7];							
				o+=8;
			}
			activecount += num;
		}
		
		public function RunAnimation ( dt : Number ) : void {
			var o : uint = 0;
			for ( var i : uint = 0; i<activecount; i++ ) {
				var dead : Boolean = false;				
				// check for death from time or colission 
				var o2 : uint = 0;
				for ( var j : uint = 0; j<planecount; j++ ) {
					var dotpos : Number = particles[o+0]*planes[o2] + particles[o+1]*planes[o2+1] + particles[o+2]*planes[o2+2] - planes[o2+3];
					var dotdir : Number = particles[o+3]*planes[o2] + particles[o+4]*planes[o2+1] + particles[o+4]*planes[o2+2];
					var tintersect : Number = -dotpos / dotdir;   					 
					if ( tintersect>=0 && tintersect<=dt ) {
						// oh noes! it will intersect if we do not stop it!
						// do something depending on the plane, either reflect the direction
						/*
						if ( planeprops[j].doesreflect ) {
							// just reflect the velocity vector. we can adjust positon so it is timed exactly
						} 
						if ( planeprops[j].doeskill ) {
							dead = true; 
						}
						if ( planeprops[j].doesspawn ) {
							// spawn a number of new ones at the intersection point
						}
						if ( planeprops[j].reduceenergy ) {
						}
						*/
						//dead = true;
						
						// r = i - (2 * n * dot(i, n))
						// reflect velocity						
						particles[o+3] -= planes[o2] * dotdir * 2;
						particles[o+4] -= planes[o2+1] * dotdir * 2;
						particles[o+5] -= planes[o2+2] * dotdir * 2;	
						
						// spawn some clones						
						SpawnSparks ( 4, o );					
					}
					o2 +=4;
				}				
				// pos += velocity * dt
				particles[o+0] += particles[o+3] * dt;
				particles[o+1] += particles[o+4] * dt;
				particles[o+2] += particles[o+5] * dt;				
				// velocity += acceleration * dt (acceleration is only gravity here, so constant)  
				particles[o+3] += force_x * dt;
				particles[o+4] += force_y * dt;
				particles[o+5] += force_z * dt;
				// track time for individual particle (+6 can be used for rendering)
				particles[o+6] -= dt;
				particles[o+7] = particles[o+7]; // ignore / keep energy 
				
				if ( particles[o+6] <= 0 ) dead = true;
				if ( dead ) {
					// swap in the last one here, reduce count
					if ( i!=activecount-1 ) {
						var osrc : uint = (activecount-1)*8;
						particles[o+0] = particles[osrc+0];
						particles[o+1] = particles[osrc+1];
						particles[o+2] = particles[osrc+2];
						particles[o+3] = particles[osrc+3];
						particles[o+4] = particles[osrc+4];
						particles[o+5] = particles[osrc+5];
						particles[o+6] = particles[osrc+6];
						particles[o+7] = particles[osrc+7]; 						
					}
					activecount--;
				} else {												
					o+=8;  	
				}							
			}
		}
		
		internal function CreateIndices ( dest : SSG ) : void {
			var indices_mem : Vector.<uint> = new Vector.<uint>(count*6);
			indices_card = dest.context3D.createIndexBuffer ( count*6 );
			var desto : uint = 0;
			var so : uint = 0;
			for ( var i : int=0; i<count; i++ ) {
				indices_mem[desto+0] = so;
				indices_mem[desto+1] = so+1;
				indices_mem[desto+2] = so+2;
				indices_mem[desto+3] = so+2;
				indices_mem[desto+4] = so+3;
				indices_mem[desto+5] = so;
				so += 4;
				desto+=6;
			}
			indices_card.uploadFromVector ( indices_mem, 0, count*6 );					
		} 
		
		internal function CreateUVVertices ( dest : SSG ) : void {
			var mem : Vector.<Number> = new Vector.<Number>(count*4*2);
			uvvertices_card = dest.context3D.createVertexBuffer ( count*4, 2 );
			var desto : uint = 0;
			for ( var i : int=0; i<count; i++ ) {
				mem[desto++] = 0;
				mem[desto++] = 0;				
				mem[desto++] = 1;
				mem[desto++] = 0;				
				mem[desto++] = 1;
				mem[desto++] = 1;				
				mem[desto++] = 0;
				mem[desto++] = 1;				
			}
			uvvertices_card.uploadFromVector( mem, 0, count*4 );					
		} 		
		
		public function UploadVertexData ( dest : SSG ) : void {
			if ( indices_card==null ) CreateIndices ( dest );
			if ( uvvertices_card==null ) CreateUVVertices ( dest );			
			if ( vertices_card==null ) vertices_card = dest.context3D.createVertexBuffer ( count*4, 8 );
			
			var osrc : uint = 0;			
			var odst : uint = 0;
			// just copy everything, expanding by 4. pretty wasteful :/			
			for ( var i : uint = 0; i<activecount; i++ ) {
				for ( var j : uint = 0; j<4; j++ ) {
					vertices_mem[odst+0] = particles[osrc+0];
					vertices_mem[odst+1] = particles[osrc+1];
					vertices_mem[odst+2] = particles[osrc+2];
					vertices_mem[odst+3] = particles[osrc+3];
					vertices_mem[odst+4] = particles[osrc+4];
					vertices_mem[odst+5] = particles[osrc+5];
					vertices_mem[odst+6] = particles[osrc+6];
					vertices_mem[odst+7] = particles[osrc+7];
					odst+=8;
				}				
				osrc+=8;				
			}		
			// up
			vertices_card.uploadFromVector( vertices_mem, 0, activecount*4 );
							
		}
		
		override protected function Render ( dest : SSG ) : void {							
			var zerovec:Vector.<Number> = new Vector.<Number>(4);
			var tempvec:Vector.<Number> = new Vector.<Number>(4);			
			zerovec[0] = 0; zerovec[1] = 0; zerovec[2] = 0; zerovec[3] = 0;			
							
			// this needs special shaders to do the eye plane (or whatever plane we choose)
			if ( prog==null ) {
				prog = dest.context3D.createProgram();
				var asm_vertex : AGALMiniAssembler = new AGALMiniAssembler;
				var asm_fragment : AGALMiniAssembler = new AGALMiniAssembler;				
				asm_vertex.assemble(Context3DProgramType.VERTEX,source_particles_vertex);
				asm_fragment.assemble(Context3DProgramType.FRAGMENT, source_particles_fragment);
				prog.upload( asm_vertex.agalcode, asm_fragment.agalcode );				
			}
								
			dest.context3D.setProgram (prog);					
			SetDefaultVertexMatrices ( dest, GetWorldMatrix().clone() );
			
			tempvec[0] = essize; tempvec[1] = 0; tempvec[2] = 0; tempvec[3] = 0;		
			dest.context3D.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 34, tempvec );
			tempvec[0] = 0; tempvec[1] = essize; tempvec[2] = 0; tempvec[3] = 0;
			dest.context3D.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 35, tempvec );
			
			dest.context3D.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 32, zerovec );
			dest.context3D.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 33, zerovec );
			
			tempvec[0] = 1/fallofftime; tempvec[1] = 1; tempvec[2] = 0; tempvec[3] = 0;			
			dest.context3D.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, 0, tempvec );
			
			dest.context3D.setBlendFactors ( Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE );								
			dest.context3D.setDepthTest ( false, Context3DCompareMode.LESS_EQUAL );								
			//bitmap.Bind ( dest, 0, -1, -1 );
			
			SetupAllVertexStreamsAndDraw(dest);			
			
			dest.context3D.setDepthTest ( true, Context3DCompareMode.LESS );
		}
		
		public function SetupAllVertexStreamsAndDraw ( dest : SSG ) : Boolean {
			if ( activecount==0 ) return true;
			
			UploadVertexData ( dest );						
			dest.context3D.setVertexBufferAt ( 0, vertices_card, 0, Context3DVertexBufferFormat.FLOAT_3);
			dest.context3D.setVertexBufferAt ( 1, uvvertices_card, 0, Context3DVertexBufferFormat.FLOAT_2); // the texcoords
			dest.context3D.setVertexBufferAt ( 2, vertices_card, 3, Context3DVertexBufferFormat.FLOAT_3); // actually velocity, can take magnitude and map to color
			dest.context3D.setVertexBufferAt ( 3, vertices_card, 6, Context3DVertexBufferFormat.FLOAT_2); // lifetime and energy, you can lut those to color also
						
			dest.context3D.drawTriangles ( indices_card, 0, activecount*2 );			
			dest.tricount += activecount*2;
			
			dest.context3D.setVertexBufferAt ( 0, null );
			dest.context3D.setVertexBufferAt ( 1, null );
			dest.context3D.setVertexBufferAt ( 2, null );
			dest.context3D.setVertexBufferAt ( 3, null );						
			return true;
		}				
		
		public var bitmap : SSGMap; 	
		public var essize : Number;
		public var force_x : Number;
		public var force_y : Number;
		public var force_z : Number;
		public var fallofftime : Number;		
	
		internal var indices_card : IndexBuffer3D;
		internal var vertices_card : VertexBuffer3D;
		internal var uvvertices_card : VertexBuffer3D;		
		internal var vertices_mem : Vector.<Number>;
		internal var particles : Vector.<Number>;	
		
		internal var activecount : uint;
		internal var count : uint; 		
		
		internal var planecount : uint;
		internal var planes : Vector.<Number>; 	
		
		internal var prog : Program3D;
		
		
		internal var source_particles_vertex : String =
		"m44 vt0, va0, vc0\n"+   // position to worldspace
		//"mul vt2, vc32, va1.x \n" + //pos = constworldspace_extrude_1*u + pos
		//"add vt0, vt0, vt2 \n" +
		//"mul vt2, vc33, va1.y \n" + //pos = constworldspace_extrude_2*v + pos
		//"add vt0, vt0, vt2 \n" +				
		"m44 vt1, vt0, vc4\n"+ 	// position to view		
		"mul vt2, vc34, va1.x \n" +
		"add vt1, vt1, vt2 \n" +
		"mul vt2, vc35, va1.y \n" +
		"add vt1, vt1, vt2 \n" +
		"m44 op, vt1, vc12 \n"+ 	// position to clip 						
		"mov v0, va1\n"+		// uv (just copy)
		"mov vt2, va2\n"+
		"dp3 vt2, vt2, vt2\n"+		
		"mov vt2.xy, va3\n"+
		"mov v1, vt2\n";		// life/energy/velocitysquared
		
		internal var source_particles_fragment : String =					
		//"tex ft0, v0, fs0 <2d> \n"+	
		"mov ft0, fc0.y\n"+
		"mul ft0, v1.x, fc0.x\n"+		
		"mov oc, ft0\n"; 	// output as color				
	}
}