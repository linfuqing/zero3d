package zerO.utils
{
	import flash.events.EventDispatcher;
	
	/**
	 * 名字基类.名字设置工具.
	 */
	public class NameSetter extends EventDispatcher
	{
		/**
		 * 设置名字.
		 */
		public function set name( n:String ):void
		{
			_name = n;
		}
		
		/**
		 * 设置名字.
		 */
		public function get name():String
		{
			return _name;
		}
		
		/**
		 * 构造一个新的名字工具.
		 */
		public function NameSetter()
		{
		}
		
		/**
		 * 名字.
		 */
		private var _name:String;
		
	}
}