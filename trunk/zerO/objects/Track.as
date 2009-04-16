package zerO.objects
{
	import flash.display.DisplayObject;
	
	import zerO.geom.points.Point2D;
	import zerO.particles.Particles;
	import zerO.veiw.Camera3D;
	import zerO.veiw.IViewport;
	
	/**
	 * 自动追踪,一个专门为懒人开发的类.
	 * 它可以作为各种跟踪及检测提供方便.
	 * 随着版本的提升,它将支持相机跟踪,碰撞检测，人机交互等功能.
	 */
	public class Track
	{
		/**
		 * 构造一个新的追踪.
		 * @param viewport 请传入视口.
		 */
		public function Track( viewport:DisplayObject )
		{
			if( viewport is IViewport )
			{
				this.viewport = viewport as IViewport;
			}
			else
			{
				throw new Error( "Viewport must be IViewport!");
			}
		}
		
		/**
		 * 相机真实方向模拟,玩过CS么..
		 * 这个方法可以使你的相机通过你鼠标真是的转动方向.
		 * 你只需在帧里加入它.
		 * @param camera 你想要使用的相机
		 * @param dirX   可转动的最大X轴角度.
		 * @param dirY   可转动的最大Y轴角度.
		 */
		public function cameraMouseController( 
		camera:Camera3D,
		dirX:Number = 90,
		dirY:Number = 90 ):void
		{
			var angleX:Number = (viewport.bounds.y - viewport.mouseY) / viewport.bounds.y * dirX;
			var angleY:Number = (viewport.mouseX - viewport.bounds.x) / viewport.bounds.x * dirY;
			camera.rotationX = angleX;
			camera.rotationY = angleY;
		}
		
		public function particlesMouseController(
		particles:Particles,
		dirX:Number = 10,
		dirY:Number = 10 ):void
		{
			var point:Point2D = viewport.viewport.get2DPointProjectByTarget( particles );
			var angleX:Number = (viewport.mouseY - point.y) / point.y * dirX;
			var angleY:Number = (point.x - viewport.mouseX) / point.x * dirY;
			particles.rotationX += angleX;
			particles.rotationY += angleY;
		}
		
		/**
		 * 视口指针.
		 */
		private var viewport:IViewport;

	}
}