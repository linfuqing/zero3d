package ssg
{
	import flash.net.URLLoader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.text.TextField; 
	
	public class SSGBunny extends SSGMesh
	{
		public function SSGBunny()
		{
			super();
		}
		
		public function LoadPLY ( source : String, scalex : Number, scaley : Number, scalez : Number ) : void {
    		var request:URLRequest = new URLRequest(source);
            loader = new URLLoader();            
            loader.addEventListener(Event.COMPLETE, LoadHandler );                       
           	loader.load(request);        
           	loadscalex = scalex;
           	loadscaley = scaley;
           	loadscalez = scalez;
           	   	                				
		}
		
		private function TimerLoadHandler ( event:Event ) : void {
			var line : String;
			var match : Array;
			var linesperstep : uint = 200;
			var i : uint;
			if ( loadstage==0 ) {								
				for ( i=0; i<linesperstep; i++ ) {				
					// read verts x y z
					line = loadlines.shift();
					match = vertexregex.exec(line);		
					vertices_mem[loadoffset+0] = match[1].valueOf() * loadscalex;
					vertices_mem[loadoffset+1] = match[2].valueOf() * loadscaley;
					vertices_mem[loadoffset+2] = match[3].valueOf() * loadscalez;
					vertices_mem[loadoffset+3] = 0;
					vertices_mem[loadoffset+4] = 0;
					vertices_mem[loadoffset+5] = 0;
					vertices_mem[loadoffset+6] = 0;
					vertices_mem[loadoffset+7] = 0;
					loadoffset+=8;					
					if ( loadoffset >= vertices_mem.length ) {						
						loadstage = 1;
						loadoffset = 0;
						return;
					}							
				}		
				if ( loadnotify ) loadnotify.text = ( "background loader vertex stage: "+(loadoffset/8).toString()+" of "+(vertices_mem.length/8).toString() );				
			}	
			if ( loadstage==1 ) {
				for ( i=0; i<linesperstep; i++ ) {				
					// read faces
					line = loadlines.shift();
					match = faceregex.exec(line);				
					indices_mem[loadoffset+0] = match[1].valueOf();
					indices_mem[loadoffset+1] = match[2].valueOf();
					indices_mem[loadoffset+2] = match[3].valueOf();
					loadoffset+=3;					
					if ( loadoffset >= indices_mem.length ) {
						loadstage = 2;		
						return;			
					}							
				}				
				if ( loadnotify ) loadnotify.text = ( "background loader index stage: "+(loadoffset/3).toString()+" of "+(indices_mem.length/3).toString() );		
			}		
			if ( loadstage==2 ) {	
				if ( loadnotify ) loadnotify.text = ( "background loader finalizer." );		
				// fix it
				CreateVertexNormals(); // blocks (can split)
				ComputeBoundingBoxAndSphere();// blocks	(can split)
				// begin picking
				picktree = new SSGPickTree();
				picktree.CreateBegin(vertices_mem,8,indices_mem, 8,8 );
				loadstage = 3;
				//GeneratePickTree(); //can split or make lazy				
			}			
			if ( loadstage==3 ) {
				if ( loadnotify ) loadnotify.text = ( "background loader pick tree creator. Nodes: "+picktree.CountNodes ( false ).toString() );		
				if ( picktree.CreateContinue(5) == 0 ) {
					loadstage=4;
				}			
			}
			
			if ( loadstage==4 ) {
				// done!
				needupload = true;	
				hidden = false;
				loadtimer.stop();
				loadtimer = null;
				loadstage = 23;	
				if ( loadnotify ) {					
					loadnotify.text = ( "background loader done." );
					loadnotify.parent.removeChild(loadnotify); 
					loadnotify = null;
				}
			}
		}
		
		private function LoadHandler ( event:Event ):void {
			var s : String = loader.data;
			
			loader = null; 
			// one big string, parse it!
			
			var headerregex : RegExp = new RegExp ( /ply.*element vertex (\d+).*element face (\d+).*end_header/gsm );	
			vertexregex = new RegExp ( /^([-+]?[\d]*\.?[\d]+[eE]?[-+]?[\d]+)\s([-+]?[\d]*\.?[\d]+[eE]?[-+]?[\d]+)\s([-+]?[\d]*\.?[\d]+[eE]?[-+]?[\d]+)/ );
			faceregex = new RegExp (  /^3 (\d+) (\d+) (\d+)/ );		
			var header : Array = headerregex.exec(s);
			if ( header.length!=3 ) {
				trace ( "bad ply!" );
				return;						
			}
			var match : Array;
			var verts : int = header[1].valueOf();
			var faces : int = header[2].valueOf();
			var i : int;			
			if ( verts==0 || faces==0 ) {
				trace ( "bad ply!" );
				return;			
			}
			// alloc
			vertices_mem = new Vector.<Number>(verts*8, true);
			indices_mem = new Vector.<uint>(faces*3, true);
			
			loadlines = s.slice(headerregex.lastIndex).split('\n');
			loadlines.shift();
			loadstage = 0;
			loadoffset = 0;
			
			hidden = true;
			
			loadtimer = new Timer ( 10, verts+faces+100 );
			loadtimer.addEventListener(TimerEvent.TIMER, TimerLoadHandler );	
			loadtimer.start();																		
		}
		
		protected var loader : URLLoader;
		protected var loadscalex : Number, loadscaley : Number, loadscalez : Number;		
		protected var loadtimer : Timer;
		protected var loadstage : uint;
		protected var loadoffset : uint;
		protected var loadlines : Array;
		public var loadnotify : TextField; 
		
		protected var vertexregex : RegExp; 
		protected var faceregex : RegExp;		
		
	}
}