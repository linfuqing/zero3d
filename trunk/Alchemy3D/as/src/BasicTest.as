// ================================================================================
//
//	ADOBE SYSTEMS INCORPORATED
//	Copyright 2010 Adobe Systems Incorporated
//	All Rights Reserved.
//
//	NOTICE: Adobe permits you to use, modify, and distribute this file
//	in accordance with the terms of the license agreement accompanying it.
//
// ================================================================================
package
{
	// ===========================================================================
	//	Imports
	// ---------------------------------------------------------------------------
	import com.adobe.utils.*;
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.TextField;
	import flash.utils.*;
	
	// ===========================================================================
	//	Class
	// ---------------------------------------------------------------------------
	/**
	 * this is the base class for Context3D minimum functionality example
	 */
	[SWF(width="800",height="535",backgroundColor="#ffffff",frameRate="60")]
	public class BasicTest extends Sprite
	{
		// ======================================================================
		//	Embedded Resources
		// ----------------------------------------------------------------------
		[Embed( source = "asset/testpat.png" )]
		protected const TestPatternBitmap:Class;
		
		[Embed( source = "asset/molepeople.jpg" )]
		protected const MolePeopleBitmap:Class;
		
		// ======================================================================
		//	Constants
		// ----------------------------------------------------------------------
		public static const DEG2RAD:Number								= Math.PI / 180.0;
		public static const DEG2RAD_2:Number							= Math.PI / 360.0;
		
		protected static const DEFAULT_MODE:String						= Context3DRenderMode.AUTO;
		protected static const DEFAULT_WIDTH:uint						= 320;
		protected static const DEFAULT_HEIGHT:uint						= 240;
		
		protected const DEFAULT_VERTEX_SHADER:String =
			"dp4 op.x, va0, vc0		\n" +	// 4x4 matrix transform from stream 0 to output clipspace
			"dp4 op.y, va0, vc1		\n" +
			"dp4 op.z, va0, vc2		\n" +
			"dp4 op.w, va0, vc3		\n" +
			"mov v0, va1.xyzw		\n";	// copy texcoord from stream 1 to fragment program
		
		// ======================================================================
		//	Properties
		// ----------------------------------------------------------------------
		// the minimum needed to draw 
		protected var _shaderProgram:Program3D; 
		protected var _indexBuffer:IndexBuffer3D; 
		protected var _vertexBuffer:VertexBuffer3D; 
		protected var _ntris:uint;
		
		protected var _width:uint;
		protected var _height:uint;
		
		protected var _sprite:Sprite;
		protected var _label:TextField;
		
		protected var _fragmentShaderAssembler:AGALMiniAssembler;
		protected var _vertexShaderAssembler:AGALMiniAssembler;
		protected var _mvpMatrix:Matrix3D;
		
		protected var _rect : Rectangle;
		protected var _slot : int;
		protected var _rendermode : String; 
		protected var _stage : Stage; 
		protected var _nstageevents : int;
		
		public var context3D:Context3D;
		
		// ======================================================================
		//	Constructor
		// ----------------------------------------------------------------------
		public function BasicTest(  )
		{			
			super();
			
			SetStage3DParams(stage, Context3DRenderMode.AUTO, 0, new Rectangle(0, 0, 640, 480) );
			
			init();
		}
		
		public function SetStage3DParams ( stage : Stage, renderMode:String, slot:int, rectangle:Rectangle ) : void
		{
			_stage = stage;
			_nstageevents = 0; 
			_rendermode = renderMode; 
			_rect = rectangle;
			_slot = slot;
			_width = rectangle.width;
			_height = rectangle.height; 			
			// make sure event will fire	
			
			_stage.stage3Ds[_slot].addEventListener ( Event.CONTEXT3D_CREATE, stageNotificationHandler );
			_stage.stage3Ds[_slot].requestContext3D ( renderMode );
			_stage.stage3Ds[_slot].viewPort = _rect;
			
			var myTimer : Timer = new Timer (1000/60);
			myTimer.addEventListener(TimerEvent.TIMER, timerEventHandler);
			myTimer.start();	
			
			stage.addEventListener ( KeyboardEvent.KEY_DOWN, keyEventHandler );   
		}
		
		// ======================================================================
		//	Methods
		// ----------------------------------------------------------------------
		protected function timerEventHandler( event:Event ):void
		{
			if ( context3D ) renderFrame( getTimer() / 1000 );		
		}
		
		protected function keyEventHandler ( event:KeyboardEvent ) : void 
		{			
			if ( event.keyCode-49 == _slot && context3D ) { // number 1..9
				if ( event.shiftKey ) 
					_stage.stage3Ds[_slot].removeEventListener( Event.CONTEXT3D_CREATE, stageNotificationHandler );
				context3D.dispose (); 
			}			
		}
		
		protected function stageNotificationHandler ( event:Event ) : void 
		{					
			if ( _label ) _label.appendText ( _nstageevents+": stage event \n" );
			_nstageevents++;
			var t : Stage3D = event.target as Stage3D; // event.target					
			context3D = t.context3D; 	
			if ( context3D == null ) {
				if ( _label ) _label.appendText ( "contex3D null. sad mole.\n" );	
			} else {
				if ( _label ) _label.appendText ( context3D.driverInfo+"\n" );
				//context3D.enableErrorChecking = true;						
				init();
				renderFrame( getTimer() / 1000 );
			}
		}
		
		protected function init():void
		{
			// backbuffer
			// context3D.dispose();
			try {
				context3D.configureBackBuffer( _width, _height, 0, true ); // fixed size
			}
			catch ( e:* ) {
				// trace( e.prototype.toString() );
				trace( e.toString() );
			}
		}
		
		public function SetDisplayListFriends ( sprite : Sprite, label : TextField ) : void{
			_label = label; 
			_sprite = sprite; 
		}		
		
		public function extrenderFrame( t:Number ):void
		{
			renderFrame ( t ); 
		}
		
		protected function renderFrame( t:Number ):void
		{
			var a:Number = Math.sin( t / 2 ) * .5 + .5; 
			//context3D.clear( 0.5 * a, 0.5 * a, 0.5 * a, a );
			
			// this is a test for perspective projection
			// all that is different is that we need to provide a perspective
			// matrix instead of a 2d rotation. 
			// build the matrix in a traditional mvp style. 
			// this could be written much more efficiently, use Matrix3D for now for clarity
			// model: local transformation
			var modelMatrix:Matrix3D = new Matrix3D(); 
			modelMatrix.appendRotation( t * 50, Vector3D.Z_AXIS );
			modelMatrix.appendRotation( t * 70, Vector3D.Y_AXIS );
			modelMatrix.appendRotation( t * 30, Vector3D.X_AXIS ); // the classic prime spin
			
			// view: the camera
			var viewMatrix:Matrix3D = new Matrix3D(); 
			viewMatrix.appendTranslation( 0, 0, -2.0 ); // move back along z axis
			
			// project: perspective
			var projectionMatrix:Matrix3D = makeProjectionMatrix(); 
			
			// mvp: model * view * projection	
			_mvpMatrix = new Matrix3D();
			_mvpMatrix.append( modelMatrix );
			_mvpMatrix.append( viewMatrix );
			_mvpMatrix.append( projectionMatrix ); 
			
			// set to shader (transpose because we use it in 4 dp4 registers)
			context3D.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 0, _mvpMatrix, true );
		}
		
		static public function makeProjectionMatrix ( zNear:Number = 0.1, 
													  zFar:Number = 1000, 
													  fovDegrees:Number = 60, 
													  aspect:Number = 4/3 ):Matrix3D
		{  
			var yval:Number = zNear * Math.tan( fovDegrees * DEG2RAD_2 );
			var xval:Number = yval * aspect;	
			return makeFrustumMatrix( -xval, xval, -yval, yval, zNear, zFar );
		}				
		
		static public function makeFrustumMatrix( left:Number, right:Number, top:Number, bottom:Number, zNear:Number, zFar:Number ):Matrix3D 
		{
			return new Matrix3D(
				Vector.<Number>(
					[
						(2*zNear)/(right-left),
						0,
						(right+left)/(right-left),
						0,
						
						0,
						(2*zNear)/(top-bottom),
						(top+bottom)/(top-bottom),
						0,
						
						0,
						0,
						zFar/(zNear-zFar),
						-1,
						
						0,
						0,
						(zNear*zFar)/(zNear-zFar),
						0
					]
				)
			);
		}		
		
		static public function uploadTextureWithMipmaps( dest:Texture, src:BitmapData ):void 
		{		
			var ws:int = src.width;
			var hs:int = src.height;
			var level:int = 0;
			var tmp:BitmapData = new BitmapData( src.width, src.height );
			var transform:Matrix = new Matrix();
			
			while ( ws > 1 && hs > 1 )
			{
				tmp.draw( src, transform, null, null, null, true );
				dest.uploadFromBitmapData( tmp, level );
				transform.scale( 0.5, 0.5 );
				level++;
				ws >>= 1;
				hs >>= 1;
			}
			tmp.dispose();
		}
	}
}
