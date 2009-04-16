package zerO.materials.particle
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	
	import zerO.materials.IRenderMaterial;
	import zerO.veiw.IViewport;

	public class ParticleMovieMaterial extends ParticleBitmapMaterial implements IParticleMaterial, IRenderMaterial
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
		 
		public function ParticleMovieMaterial(
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