package ssg
{
	import flash.display.BitmapData;
	import __AS3__.vec.Vector;
	import flash.geom.Rectangle;
	import flash.events.Event;
	import flash.display.Loader;
	import flash.net.URLRequest;	
	import flash.geom.Matrix;
	
	public class SSGHeightfield extends SSGMesh
	{
		public function SSGHeightfield()
		{
			super();
		}
		
		public function LoadFromFile ( url : String, scalex : Number, scaley : Number, scaleh : Number ) : void {
			if ( loader ) return; // already loading?
			// create one that is an impostor
			var bmd : BitmapData = new BitmapData(4,4,false,0x7f7f7f7f);
			CreateFromBitmapData ( bmd, scalex,scaley,scaleh );			
			// then load and update in event			
			loadscalex = scalex;
			loadscaley = scaley;
			loadscaleh = scaleh;
			loader = new Loader();
           	loader.contentLoaderInfo.addEventListener(Event.COMPLETE, ImageLoadedHandler);     
            loader.load(new URLRequest(url));            			
		}
				
		internal function ImageLoadedHandler ( e : Event ) : void {
			var bmd : BitmapData = new BitmapData(loader.width,loader.height);
			bmd.draw(loader, new Matrix());					
			CreateFromBitmapData ( bmd, loadscalex,loadscaley,loadscaleh );
			loader = null;  
		} 		
		
		public function CreateFromBitmapData ( input : BitmapData, scalex : Number, scaley : Number, scaleh : Number ) : void {
			var reindex : Boolean = false;
			if ( w!=input.width || h!=input.height ) {
				w = input.width;
				h = input.height; 			
				vertices_mem = new Vector.<Number>(w*h*8);			
				indices_mem = new Vector.<uint>((w-1)*(h-1)*6);
				reindex = true;
			}
			var x : int;
			var y : int;			
			var o : uint = 0;
			var oi : uint = 0;
			var os : uint = 0;
		
			var scaleu : Number = 1.0 / (w-1);
			var scalev : Number = 1.0 / (h-1); 
			scalex *= scaleu;
			scaley *= scalev;
			var nz : Number = 255/scaleh;
			scaleh *= 1.0 / 255.0;
								
			for ( y=0; y<h; y++ ) {								
				for ( x=0; x<w; x++ ) {
					vertices_mem[o+0] = x*scalex;
					vertices_mem[o+1] = y*scaley;
					vertices_mem[o+2] = scaleh * (input.getPixel(x,y) & 0xff);
					// normalize
					var nx : Number = (Number)(input.getPixel(x-1,y) & 0xff) 
					nx -= (Number)(input.getPixel(x+1,y) & 0xff);
					var ny : Number = (Number)(input.getPixel(x,y-1) & 0xff);
					ny -= (Number)(input.getPixel(x,y+1) & 0xff);
					nx /= scalex;
					ny /= scaley;
					
					var len : Number = nx*nx + ny*ny + nz*nz; 
					if ( len==0 ) {
						vertices_mem[o+3] = 0;
						vertices_mem[o+4] = 0;
						vertices_mem[o+5] = 1;						
					} else {	
						len = 1.0 / Math.sqrt(len);							
						vertices_mem[o+3] = nx * len;
						vertices_mem[o+4] = ny * len;
						vertices_mem[o+5] = nz * len;
					}									
					vertices_mem[o+6] = x*scaleu;
					vertices_mem[o+7] = y*scalev;
					o+=8;					
				}
				if ( y!=h-1 && reindex ) {					
					for ( x=0; x<w-1; x++ ) {													
						indices_mem[oi+0] = os;
						indices_mem[oi+1] = os+1+w;
						indices_mem[oi+2] = os+w;
						indices_mem[oi+3] = os;
						indices_mem[oi+4] = os+1;
						indices_mem[oi+5] = os+w+1;
						oi+=6;
						os++;						
					} 					
					os++;							
				}				
			}
			ComputeBoundingBoxAndSphere();
			needupload = true;											
		} 
		
		internal var w : int;
		internal var h : int;
		internal var loader : Loader;
		internal var loadscalex : Number;
		internal var loadscaley : Number;
		internal var loadscaleh : Number;
		
		
	}
}