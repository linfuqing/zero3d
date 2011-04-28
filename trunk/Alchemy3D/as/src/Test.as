package
{
	import AlchemyLib.tools.Basic;
	import AlchemyLib.tools.FPS;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	[SWF(width="640",height="480",backgroundColor="#ffffff",frameRate="120")]
	public class Test extends Basic
	{
		private var bitmapData:BitmapData;
		private var loader:Loader;
		
		public function Test()
		{
			super();
			
			load("asset/01.jpg");
		}
		
		public function load(url:String):void
		{
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.load(new URLRequest(url));
		}
		
		private function onProgress(e:ProgressEvent):void
		{
			dispatchEvent(e);
		}
		
		protected function ioErrorHandler(e:IOErrorEvent):void
		{
			throw new Error(e.toString());
		}
		
		protected function onLoadComplete(e:Event):void
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
			this.bitmapData = Bitmap(loader.content).bitmapData;
			
			dispatchEvent(e);
			
			addChild( Bitmap(loader.content) );
			
			var fps:FPS = new FPS(scene);
			addChild(fps);
			
			data = bitmapData.getPixels(bitmapData.rect);
			buffer = bitmapData.getPixels(bitmapData.rect);
			data.endian = Endian.LITTLE_ENDIAN;
			data.position = 0;
			this.startRendering();
		}
		
		private var buffer:ByteArray;
		private var data:ByteArray;
		private var vector:Vector.<uint>;
		override protected function onRenderTick(e:Event=null):void
		{
			super.onRenderTick(e);
			
			for(var i:uint = 0; i < 10; i ++)
			{
				//data.position = 0;
				//bitmapData.setPixels(bitmapData.rect, data);
//				data = bitmapData.getPixels(bitmapData.rect);
//				data.position = 0;
//				data.endian = Endian.LITTLE_ENDIAN;
//				bitmapData.setPixels(bitmapData.rect, data);
//				data = bitmapData.getPixels(bitmapData.rect);
//				data.position = 0;
//				buffer.position = 0;
//				buffer.writeBytes(data);
				
				vector = bitmapData.getVector(bitmapData.rect);
//				data.position = 0;
//				vector.every(data.writeUnsignedInt);
				
				data.position = 0;
				
				for(var j:uint = 0; j < vector.length; j ++)
					data.writeUnsignedInt(vector[i]);
				
			}
		}
	}
}