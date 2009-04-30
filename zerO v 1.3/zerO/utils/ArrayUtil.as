package zerO.utils
{
	public class ArrayUtil
	{
		public function ArrayUtil()
		{
		}
		
		//array part:
				
		static public function removeIn( object:*,array:* ):void
		{
			var numObjects:uint = array.length;
			for( var i:uint = 0;i < numObjects;i++ )
			{
				if( array[i] === object )
				{
					delete array[i];
					break;
				}
			}
		}
		
		static public function singlePush( object:*,array:* ):Boolean
		{
			var hadIn:Boolean = false;
			
			for each( var node:* in array )
			{
				if( object === node )
				{
					hadIn = true;
					break;
				}
			}
			
			if( !hadIn )
			{
				array.push( object );
				return true;
			}
			
			return false;
		}

	}
}