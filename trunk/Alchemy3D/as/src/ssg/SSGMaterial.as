package ssg
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display.*;
	import flash.display3D.*;
	
	// this does some very simple fixed shading model
	// limit to 3 per vertex lights 
	//
	// vertex constants map: 
	// 0: model to world
	// 4: view
	// 8: model to view
	// 12: projection
	// 16: model to clipspace (mvp)
	// 20: channel 0 texture matrix 
	// 24: channel 1 texture matrix 
	//
	// varying mapping	
	// 0: uv 								<- channel 0 coords
	// 1: uv * texture matrix               <- channel 1 coords
	// 2: object space pos * texgen matrix  <- envmap texture coordinates
	// 3: diffuse vertex light
	// 4: specular vertex light	
	//
	// fragment constants map: 
	// 0: const diffuse_color	
	// 1: const specular_color|specular_exponent_mod
	// 2: const emit|opacity	
	// 
	// sampler map:
	// 0: diffuse map
	// 1: specular map	
	// 2: emit|opacity map
	// 3: env cube
	
	// fragment operation:
	// [ compute specular and diffuse pixel lighting ]
	// d = diffuse.rgb * sat(diffuse_pixel_lighting + diffuse_vertex_lighting)
	// s = specular.rgb * (environment + pow (specular_pixel_lighting + specular_vertex_lighting)), specular.a * specularconst.a))
	// color = (d + s) * opacity + emit
	
	public class SSGMaterial
	{
		public function SSGMaterial() {			
			diffuse.SetConstantColor(1,1,1);
			specular.SetConstantColor(0,0,0,16);
			emitopacity.SetConstantColor(0,0,0,1);
			environment.SetConstantColor(0,0,0,0);
		}
		
		// need to call when maps change
		public function BuildProgram ( dest : SSG ) : void {
			if  ( !program )
				program = dest.context3D.createProgram ( );
										
			var source_test_vertex : String = new String;
			source_test_vertex = 
				"mov vt0, va0 \n"+ // position
				"mov vt1, va1 \n"+ // normal
				"mov vt2, va2 \n"+ // uv
				"m44 op, vt0, vc16 \n"+ // model to clip				
				"m33 v0.xyz, vt1, vc0\n" + // normal to world 
				"mov v0.w, va1.w\n" +
				"m44 v1, va2, vc";
				
				
			var source_test_fragment : String = new String;
			source_test_fragment = "mov ft1, v0\n"+
								   "mov oc, ft1\n"; 					
			
			var asm_vertex : AGALMiniAssembler = new AGALMiniAssembler;
			var asm_fragment : AGALMiniAssembler = new AGALMiniAssembler;
			asm_vertex.assemble( Context3DProgramType.VERTEX, source_test_vertex );
			asm_fragment.assemble( Context3DProgramType.FRAGMENT, source_test_fragment );
			
			program.upload ( asm_vertex.agalcode, asm_fragment.agalcode ); 			
		}
		
		public function SetupForRender ( dest : SSG ) : void {
			if ( !program ) 
				BuildProgram ( dest );
							
			dest.context3D.setProgram ( program );
			
			diffuse.SetConstant ( dest, Context3DProgramType.FRAGMENT, 0 );
			if ( !diffuse.IsConstantColor() ) diffuse.Bind( dest, 0 );
			
			specular.SetConstant ( dest, Context3DProgramType.FRAGMENT, 1 );			
			if ( !specular.IsConstantColor() ) specular.Bind( dest, 1 );
			
			emitopacity.SetConstant ( dest, Context3DProgramType.FRAGMENT, 2 ); 
			if ( !emitopacity.IsConstantColor() ) emitopacity.Bind( dest, 2 );
			
			environment.SetConstant ( dest, Context3DProgramType.FRAGMENT, 3 );
			if ( !environment.IsConstantColor() ) environment.Bind( dest, 23);
			
			dest.context3D.setCulling( twosided ? Context3DTriangleFace.NONE : Context3DTriangleFace.BACK );
		}
		
		// classic, very simple material
		public var diffuse : SSGMap = new SSGMap; // alpha ignored
		public var specular : SSGMap = new SSGMap; // alpha is exponent, rgb is modulation		
		public var emitopacity : SSGMap = new SSGMap; // alpha is opacity, rgb is emit
		public var environment : SSGMap = new SSGMap; // cubemap			
				
		public var twosided : Boolean;
		
		internal var program : Program3D;
		
		internal var ctemp : Vector.<Number> = new Vector.<Number>(4); 

	}
}