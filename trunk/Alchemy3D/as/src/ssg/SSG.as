
package ssg
{
	import flash.display.BitmapData;
	import flash.display3D.*;
	import flash.geom.Matrix3D;
	
	public class SSG
	{		
		public var context3D:Context3D;
		
		public function SSG( incontext3D : Context3D ) {			
			context3D = incontext3D;
			rootnode = new SSGNode;
			activecamera = null;
			lightlist = new Array();
		}
		
		public function AddNode ( node : SSGNode ) : void {
			rootnode.AddNode ( node );
			node.ssgbase = this;
		}
				 	
		public function Render ( ) : void {
			if ( activecamera == null ) {
				trace ( "no active camera set, nothing to do." );
				return;
			}
			tricount = 0;
			
			// camera update
			activecamera.UpdateWorldSpacePosition();
			// collect lights
			PrepareAllLightsForRendering ( );
										
			// setup the camera matrix parts, objects still need to set composite matrices (model and mvp)						
			view = activecamera.GetWorldMatrix().clone();
			view.invert();
			projection = activecamera.GetProjectionMatrix().clone();			
			context3D.setCulling ( Context3DTriangleFace.BACK ); 					
			
			context3D.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 4, view, true );	
			context3D.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 12, projection, true );				
			
			// issue the preview style draw calls
			rootnode.RenderRec ( this );
			// why not..
			context3D.present();
		}
		
		public function SetActiveCamera ( cam : SSGCamera ) : void {
			activecamera = cam;
		}
		
		public function PrepareAllLightsForRendering ( ) : void {			
			lightlist.length = 0;
			rootnode.CollectThingsToArrayRec ( SSGLight, lightlist );	
			// remove disabled or otherwise zero lights
			// update light's worldspace position
			for each( var light:SSGLight in lightlist )
				light.UpdateWorldSpacePosition();
		}
		
		public function SortLightsForNode ( node : SSGNode ) : void {			
			var lightsortfunction : Function = function ( a : SSGLight, b : SSGLight ) : int {
				if ( a.curlightingdistance < b.curlightingdistance ) return -1;			
				if ( a.curlightingdistance > b.curlightingdistance ) return 1;
				return 0;
			};				
			node.UpdateWorldSpacePosition();
			for each( var light:SSGLight in lightlist )
				light.ComputeLightingDistanceToNode ( node );			
			lightlist.sort ( lightsortfunction, Array.NUMERIC );
		}		
		
		public function CreatePickRayFromScreenCoords ( x : Number, y : Number ) : SSGPickRay {
			var pr : SSGPickRay = new SSGPickRay;
			pr.CreateRayFromCamera(x,y,activecamera);
			return pr; 
		}
		
		public function Pick ( ray : SSGPickRay ) : void {
			ray.ResetHit();			
			if ( rootnode!=null ) rootnode.PickRec ( this, ray );
		}
		
		internal var rootnode : SSGNode;		
		internal var activecamera : SSGCamera;
		
		public var selectednode : SSGNode;
		
		// rendering matrix track
		public var projection : Matrix3D; 
		public var view : Matrix3D;		
		
		// light tracking
		public var lightlist : Array;
		
		// stats
		public var tricount : uint;
		
	/*
		internal var source_preview_fragment : String =
		//"f1x "+ // local tag (fragment version 1, DirectX assembly)
		//"ps_2_0\n"+
		//"dcl t0\n"+ // texcoord
		//"dcl t1\n"+ // diffuse vertex color
		//"dcl t2\n"+ // specular vertex color	
		//"dcl_2d s0\n"+ // diffuse texture	
						
		"tex ft0, v0, fs0 <2d> \n"+//"texld r0, t0, s0\n" +
		"mul ft0, ft0, fc4\n" +						
		"mul ft0, ft0, v1\n"+  // mul diffuse	* diffuse color
		//"mad ft0, fc5, v2, ft0\n"+ // add specular * specular color
		"mul ft1, fc5, v2 \n"+
		"add ft0, ft1, ft0 \n"+
		
		//"mad ft0, fc3.w, ft0, fc3\n"+ // lerp to premultiplied selection color
		"mul ft2, fc3.w, ft0 \n"+
		"add ft0, ft2, fc3 \n"+
		 		
		"mov ft0.w, fc4.w\n"+ // set alpha
		"mov oc, ft0\n"; 	// and output as color				
		
		internal var source_preview_vertex : String =
		// compute vector to eye
		"sub vt0, vc20, va0\n"+ 
		//"nrm vt1, vt0\n"+
		"dp3 vt1.w, vt0, vt0 \n"+
		"rsq vt1.w, vt1.w\n"+
		"mul vt1, vt0, vt1.w \n"+	
		// simple per vertex lighting, in object space, sum 
		//"nrm r1, v1\n"+          // v1 = normal at surface (should no need the nrm for well behaved meshes)
		"sub vt2, vc24, va0\n"+     // lights are at 32 + c0 (pos) c1 (color) 
		//"nrm vt3, vt2\n"+          // r2 = incident diffuse
		"dp3 vt3.w, vt2, vt2 \n"+
		"rsq vt3.w, vt3.w\n"+
		"mul vt3, vt2, vt3.w \n"+	
		
		"dp3 vt2.x, vt3, va1\n"+
		"max vt2.x, vt2.x, vc21.x\n"+ // c21 = const 0  		
		"mul vt6, vt2.x, vc25\n"+   // write diffuse
				 
		"add vt2, vt1, vt3\n"+ // incident + view
		//"nrm vt1, vt2\n"+ // half angle
		"dp3 vt1.w, vt2, vt2 \n"+
		"rsq vt1.w, vt1.w\n"+
		"mul vt1, vt2, vt1.w \n"+	
		
		"dp3 vt2.x, vt1, va1\n"+ // spec
		"max vt2.x, vt2.x, vc21.x\n"+
		//"pow vt1.x, vt2.x, vc23.w\n"+ // exponent from c23		
		"mul vt2.x, vt2.x, vt2.x \n" +
		"mul vt2.x, vt2.x, vt2.x \n" +
		
		"mul vt7, vt1.x, vc25\n" + // write spec		
		
		// light2
		"sub vt2, vc28, va0\n"+      
		//"nrm vt3, vt2\n"+          
		"dp3 vt3.w, vt2, vt2 \n"+
		"rsq vt3.w, vt3.w\n"+
		"mul vt3, vt2, vt3.w \n"+	
		
		"dp3 vt2.x, vt3, va1\n"+
		"max vt2.x, vt2.x, vc21.x\n"+   		
		//"mad vt6, vt2.x, vc29, vt6\n"+   // add to diffuse		Multiple + add, not supported yet
		"mul vt8, vt2.x, vc29 \n"+
		"add vt6, vt6, vt8 \n"+
		
		"add vt2, vt1, vt3\n"+ // incident + view
		//"nrm vt1, vt2\n"+ // half angle
		"dp3 vt1.w, vt2, vt2 \n"+
		"rsq vt1.w, vt1.w\n"+
		"mul vt1, vt2, vt1.w \n"+	
		
		"dp3 vt2.x, vt1, va1\n"+ // spec
		"max vt2.x, vt2.x, vc21.x\n"+
		//"pow vt1.x, vt2.x, vc23.w\n"+		
		"mul vt1.x, vt2.x, vt2.x \n" +
		"mul vt1.x, vt1.x, vt1.x \n" +
		//"mad vt7, vt1.x, vc29, vt7\n" + // add to spec
		"mul vt9, vt1.x, vc29 \n"+
		"add vt7, vt9, vt7 \n"+
		// light 3 and 4 todo, also todo attenuation of light and spot opening 				
		
		// to cs
		//"dp4 oPos.x, vc16, v0\n"+ // position to clipspace (multiply by mvp matrix)
		"dp4 op.x, vc16, va0\n"+
		"dp4 op.y, vc17, va0\n"+
		"dp4 op.z, vc18, va0\n"+
		"dp4 op.w, vc19, va0\n"+		
		// output
		"mov v0, va2\n"+		// texcoord (just copy)
		"mov v1, vt6\n"+        // diffuse color
		"mov v2, vt7\n";        // specular color
		
		*/
		  
	}
}
