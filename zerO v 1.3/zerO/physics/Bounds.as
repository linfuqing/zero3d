package zerO.physics
{
	import __AS3__.vec.Vector;
	
	/**
	 * 边界,主要用于一个场景的边界限制.
	 */
	public class Bounds
	{
		/**
		 * 左.
		 */		
		public function set left(volue:Number):void
		{
			border[0] = volue;
		}
		
		/**
		 * 左.
		 */		
		public function get left():Number
		{
			return border[0];
		}
		
		/**
		 * 右.
		 */		
		public function set right(volue:Number):void
		{
			border[1] = volue;
		}
		
		/**
		 * 右.
		 */	
		public function get right():Number
		{
			return border[1];
		}
		
		/**
		 * 上.
		 */	
		public function set up(volue:Number):void
		{
			border[2] = volue;
		}
		
		/**
		 * 上.
		 */	
		public function get up():Number
		{
			return border[2];
		}
		
		/**
		 * 下.
		 */	
		public function set down(volue:Number):void
		{
			border[3] = volue;
		}
		
		/**
		 * 下.
		 */	
		public function get down():Number
		{
			return border[3];
		}
		
		/**
		 * 前.
		 */	
		public function set front(volue:Number):void
		{
			border[4] = volue;
		}
		
		/**
		 * 前.
		 */	
		public function get front():Number
		{
			return border[4];
		}
		
		/**
		 * 后.
		 */	
		public function set back(volue:Number):void
		{
			border[5] = volue;
		}
		
		/**
		 * 后.
		 */	
		public function get back():Number
		{
			return border[5];
		}
		
		/**
		 * 构建新的边界.
		 */
		public function Bounds( border:Vector.<Number> = null )
		{
			if(border)
			{
				this.border = new Vector.<Number>();
				for( var i:uint = 0;i < 6;i ++ )
				{
					this.border[i] = border[i] ? border[i] : 0;
				}
			}
			else
			{
				border = Vector.<Number>([0,0,0,0,0,0]);
			}
		}
		
		/**
		 * 边界.
		 */
		private var border:Vector.<Number>;
	}
}