package ssg
{
	import __AS3__.vec.Vector;
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.net.URLRequest;
	
	public class SSGMap
	{
		public function SSGMap( loadimage : String = null ) {
			texturesrc = null;
			color = new Vector.<Number>(4);
			color[0] = 1;
			color[1] = 1;
			color[2] = 1;
			color[3] = 1;		
			if ( loadimage!=null && loadimage!= "" ) {
				LoadImage ( loadimage );
			}
		}
		
		public function LoadImage ( source : String, sourcealpha : String = null ) : Boolean {
			if ( loadingidx ) {
				// still loading? what to do?
				return false;
			}
			texturesrc = source;	
			loadingidx = 0;				
			LoadImageFromSources ( );				
			return true;
		} 
		
		private function LoadImageFromSources ( ) : void {			
			var path : String = null;
			if ( loadingidx==0 ) path = "../res/";
			if ( loadingidx==1 ) path = "http://localhost/res/";
			if ( loadingidx==2 ) return; 
			
			if ( path == null ) {
				loader = null;
				loadingidx = 0;			
				return;
			} 			  
			if ( loader==null ) {			
				loader = new Loader();			  
           		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, ImageLoadedHandler);
           		loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, ErrorHandler );
           		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ErrorHandler );
   			}     
           	loadingidx++;
            loader.load(new URLRequest( path+texturesrc ));            													
		}
		
		internal function ErrorHandler ( e : Event ) : void {	
            LoadImageFromSources (); 
		}
		
		internal function ImageLoadedHandler ( e : Event ) : void {
			trace ( "Loaded image: "+texturesrc+" w="+loader.width.toString()+" h="+loader.height.toString() );
			texture_mem = new BitmapData(loader.width,loader.height);  
            texture_mem.draw(loader, new Matrix());  
            needsupload = true;			
            loader = null;
            loadingidx = 0;
		} 
		
		public function IsConstantColor ( ) : Boolean {
			return texture_card == null;
		}
		
		public function SetConstantColor ( r : Number, g : Number, b : Number, a : Number=1 ) : void {
			color[0] = r;
			color[1] = g;
			color[2] = b;
			color[3] = a;			
		}
		
		public function Bind ( dest : SSG, sampler : int ) : Boolean {
			Upload ( dest );
			if ( texture_card==null ) return false;			
			dest.context3D.setTextureAt(sampler, texture_card);	
			return true;
		}
		
		private function Upload ( dest : SSG ) : void {
			if ( !needsupload || loadingidx!=0 ) return;			
			if ( texture_mem==null ) {
				texture_card = null;
				return;
			} 			
			texture_card = dest.context3D.createTexture ( texture_mem.width, texture_mem.height, Context3DTextureFormat.BGRA, false );
			texture_card.uploadFromBitmapData(texture_mem);
			needsupload = false;
		}
		
		public function SetConstant ( dest : SSG, target : String, regnum : uint ) : void {
			dest.context3D.setProgramConstantsFromVector( target, regnum, color, 1 ); 			
		}
		
		public function GetConstantColor ( ) : Vector.<Number> {
			return color;
		}
		
		internal var texture_card : Texture;		 
		internal var texmatrix : Matrix3D; // after channel 		 
		internal var texture_mem : BitmapData;
		internal var texture_mem_alpha : BitmapData;
		internal var texturesrc : String;
		internal var texturesrc_alpha : String;
		internal var color : Vector.<Number>; // constant color		
		//internal var texgen : String; // null = channel
		internal var needsupload : Boolean;
		     		
		// streaming
		internal var loadingidx : uint;
		internal var loader : Loader;
	}
}