/**
 * Copyright 2009 (c) Lin Fuqing,zerO3D
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
**/

package zerO.materials
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	
	import zerO.events.FileLoadEvent;
	import zerO.geom.triangle.Triangle2D;
	import zerO.veiw.IViewport;
	
	/**
	 * 文件位图材质,跟位图材质一样,但是可以从外部读取位图.
	 * 你可以使用它像这样:
	 * <p>
	 * //定义它.
	 * <p>
	 * var material:BitmapFileMaterial = new BitmapFileMaterial();
	 * <p>
	 * //文件读取.
	 * <p>
	 * material.load( "your picture.jpg" );
	 * <p>
	 * //监听它完成.
	 * <p>
	 * material.addEventListener( Event.COMPLETE,yourFunction );
	 * <p>
	 */
	public class BitmapFileMaterial extends BitmapMaterial implements ITriangleMaterial
	{

		/**
		 * 构建新的位图文件材质.
		 * @param name   材质名字
		 * @param smooth 是否平滑处理
		 */
		public function BitmapFileMaterial( smooth:Boolean = false )
		{
			super( null,smooth );
		}

		/**
		 * 开始读取.
		 * @param URL 你的图片地址
		 */
		public function load( URL:String ):void
		{
			this.URL = URL;
			
			var loader:Loader = new Loader();
			loader.load( new URLRequest( URL ) );
			loader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS,onProgress );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR,onIOError );
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE,onComplete );
		}
		
		/**
		 * 读取过程,抛出读取时项目.
		 */
		private function onProgress( event:ProgressEvent ):void
		{
			dispatchEvent( event );
		}
		
		/**
		 * 遇到错误时抛出.
		 */
		private function onIOError( event:IOErrorEvent ):void
		{
			trace( "Error on loading " + URL );
			dispatchEvent( event );
			removeAllEventListener( Loader( event.target.loader ) );
		}
		
		/**
		 * 读取完成后调用.
		 */
		private function onComplete( event:Event ):void
		{
			trace( URL + " had loaded complete!" );
			var loader:Loader = Loader( event.target.loader );
			var image:Bitmap = Bitmap( loader.content );
			bitmap = image.bitmapData;
			dispatchEvent( new FileLoadEvent( Event.COMPLETE,URL ) );
			removeAllEventListener( loader );
		}
		
		/**
		 * 移除所有监听.
		 */
		private function removeAllEventListener( loader:Loader ):void
		{
			loader.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS,onProgress );
			loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR,onIOError );
			loader.contentLoaderInfo.removeEventListener( Event.COMPLETE,onComplete );
		}

		/**
		 * 位图地址.
		 */
		private var URL:String;

	}
}