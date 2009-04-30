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
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	/**
	 * 电影材质,通过它你可以播放你的DisplayObject.
	 */
	public class MovieMaterial extends BitmapMaterial implements ITriangleMaterial, IRenderMaterial
	{
		/**
		 * 填充颜色.
		 */
		public var fillColor:uint;
		
		/**
		 * 设置裁减矩形.
		 */
		 public function set userClipRect( rect:Rectangle ):void
		 {
		 	this.rect = rect;
		 	initBitmap();
		 }
		 
		/**
		 * 设置裁减矩形.
		 */
		 public function get userClipRect():Rectangle
		 {
		 	return rect;
		 }
		
		/**
		 * 设置影片.
		 */
		 public function set movie( _movie:DisplayObject ):void
		 {
		 	this._movie = movie;
		 	initBitmap();
		 }
		 
		/**
		 * 设置影片.
		 */
		 public function get movie():DisplayObject
		 {
		 	return _movie;
		 }
		 
		/**
		 * 构建新的电影材质.
		 * 
		 * @param movie        你的DisplayObject.
		 * @param fillColor    填充颜色.
		 * @param userClipRect 剪切矩形,如果为空将自动判断,不为空时将按矩形的宽高对影片进行裁减.
		 * @param smooth       是否平滑处理.
		 */
		public function MovieMaterial(
		movie:DisplayObject, 
		fillColor:uint = 0, 
		userClipRect:Rectangle = null, 
		smooth:Boolean=false )
		{
			_movie = movie;
			this.fillColor = fillColor;
			super( null, smooth );
			this.userClipRect = userClipRect;
		}
		
		/**
		 * 初始化位图.
		 */
		private function initBitmap():void
		{
			if(bitmap)
			{
				bitmap.dispose();
			}
			if(rect)
			{
				bitmap = new BitmapData( int( rect.width + 0.5 ),int( rect.height + 0.5 ),true,fillColor );
			}
			else
			{
				bitmap = new BitmapData( int( movie.width + 0.5 ),int( movie.height + 0.5 ),true,fillColor );
			}
		}
		
		/**
		 * 在渲染前做一些事.
		 */
		public function doBeforeRender():void
		{
			bitmap.fillRect( bitmap.rect,fillColor );
			bitmap.draw( movie );
		}
		
		/**
		 * 裁减矩形.
		 */
		private var rect:Rectangle = null;
		
		/**
		 * 播放对象.
		 */
		private var _movie:DisplayObject;
		
	}
}